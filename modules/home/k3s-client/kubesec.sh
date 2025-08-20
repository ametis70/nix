#!/usr/bin/env bash

set -eo pipefail

# Ensure we are running under bash (for process substitution and mapfile)
if [[ -z "${BASH_VERSION:-}" ]]; then
  exec /usr/bin/env bash "$0" "$@"
fi

show_help() {
  cat <<EOF
Usage: $0 [edit <sealed-secret-file> [--apply]]

Interactive wizard for creating or editing Kubernetes SealedSecrets using a kube wrapper.

Modes:
  - No args: create a new SealedSecret via interactive prompts
  - edit <file>: edit an existing SealedSecret by decrypting the SEALED FILE via the controller,
                 opening it in \$EDITOR, showing a diff, and resealing on confirmation.
                 Use --apply to apply the updated SealedSecret to the cluster immediately.

Environment:
  - SEALED_SECRETS_PRIVATE_KEY (or KUBESEAL_PRIVATE_KEY): path to a private key (or directory of keys)
    If provided, the script will decrypt the sealed file locally using 'kubeseal --recovery-unseal'.
    Without it, the script fetches the current live Secret from the cluster for editing.

Requirements:
  - kube wrapper that provides 'kubectl' and 'kubeseal'
  - kubeseal and kubectl installed and configured
  - Access to the cluster that has the Secret generated from the SealedSecret being edited
EOF
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  show_help
  exit 0
fi

fetch_pub_cert() {
  echo "Fetching sealed secrets public cert..." >&2
  local controller_name="${SEALED_SECRETS_CONTROLLER_NAME:-sealed-secrets-controller}"
  local controller_ns="${SEALED_SECRETS_NAMESPACE:-flux-system}"

  # First try via kubeseal service endpoint
  if kube kubeseal --fetch-cert \
    --controller-name="$controller_name" \
    --controller-namespace="$controller_ns" 2>/dev/null; then
    return 0
  fi

  # Fallback: read cert from the active key Secret directly (avoids service proxy)
  local crt_b64
  crt_b64=$(kube kubectl -n "$controller_ns" \
    get secret -l sealedsecrets.bitnami.com/sealed-secrets-key=active \
    -o jsonpath='{.items[0].data.tls\.crt}' 2>/dev/null || true)
  if [[ -n "$crt_b64" ]]; then
    # Try both BSD and GNU base64 flags
    printf '%s' "$crt_b64" | base64 -D 2>/dev/null || printf '%s' "$crt_b64" | base64 -d 2>/dev/null
    return 0
  fi

  echo "Error: unable to fetch Sealed Secrets public certificate. Tried service via kubeseal and reading tls.crt from Secret in namespace '$controller_ns'." >&2
  echo "Hints: verify the controller namespace/name, service endpoints, and that the active key Secret exists." >&2
  return 1
}

trim_quotes() {
  local s="$1"
  s="${s#\' }"
  s="${s% \'}" # remove loose quotes if any
  s="${s#\"}"
  s="${s%\"}"
  printf '%s' "$s"
}

extract_from_sealed() {
  # Args: <sealed_file> <field> where field is one of: name, namespace, type
  # Heuristics: prefer spec.template.metadata.*, fallback to top-level metadata.* for name/namespace; type from spec.template.type
  local file="$1"
  local field="$2"
  case "$field" in
  name)
    awk '
        $1=="spec:" {spec=1}
        spec && $1=="template:" {tmpl=1}
        spec && tmpl && $1=="metadata:" {meta=1}
        spec && tmpl && meta && $1=="name:" {print $2; found=1; exit}
        END { if (!found) exit 0 }
      ' "$file" || true
    ;;
  namespace)
    awk '
        $1=="spec:" {spec=1}
        spec && $1=="template:" {tmpl=1}
        spec && tmpl && $1=="metadata:" {meta=1}
        spec && tmpl && meta && $1=="namespace:" {print $2; found=1; exit}
        END { if (!found) exit 0 }
      ' "$file" || true
    ;;
  type)
    awk '
        $1=="spec:" {spec=1}
        spec && $1=="template:" {tmpl=1}
        spec && tmpl && $1=="type:" {print $2; found=1; exit}
        END { if (!found) exit 0 }
      ' "$file" || true
    ;;
  esac
}

extract_from_metadata() {
  # Fallback to top-level metadata for name/namespace
  local file="$1"
  local field="$2"
  awk -v want="$field:" '
    $1=="metadata:" {meta=1}
    meta && $1==want {print $2; exit}
  ' "$file" || true
}

write_secret_yaml() {
  # Args: outfile name namespace type (and reads decoded key=value pairs from stdin)
  local out="$1" name="$2" ns="$3" type="$4"
  {
    echo "apiVersion: v1"
    echo "kind: Secret"
    echo "type: $type"
    echo "metadata:"
    echo "  name: $name"
    echo "  namespace: $ns"
    echo "stringData:"
    while IFS='=' read -r k v; do
      # v is decoded value; choose quoting based on content
      if [[ "$v" == *$'\n'* ]]; then
        echo "  $k: |"
        # indent block content by two spaces
        while IFS= read -r line; do
          printf '    %s\n' "$line"
        done <<<"$v"
      else
        # escape double quotes and backslashes
        local esc=${v//\\/\\\\}
        esc=${esc//\"/\\\"}
        echo "  $k: \"$esc\""
      fi
    done
  } >"$out"
}

editor=${EDITOR:-vi}

if [[ "$1" == "edit" ]]; then
  # Args: edit <sealed_file> [--apply]
  SEALED_FILE="$2"
  APPLY_AFTER=0
  if [[ "$3" == "--apply" ]]; then
    APPLY_AFTER=1
  fi
  if [[ -z "$SEALED_FILE" ]]; then
    echo "Usage: $0 edit <sealed-secret-file> [--apply]" >&2
    exit 1
  fi
  if [[ ! -f "$SEALED_FILE" ]]; then
    echo "File not found: $SEALED_FILE" >&2
    exit 1
  fi

  # Try to derive name/namespace/type from the sealed file
  NAME=$(extract_from_sealed "$SEALED_FILE" name)
  NS=$(extract_from_sealed "$SEALED_FILE" namespace)
  TYPE=$(extract_from_sealed "$SEALED_FILE" type)
  # Fallbacks
  [[ -z "$NAME" ]] && NAME=$(extract_from_metadata "$SEALED_FILE" name)
  [[ -z "$NS" ]] && NS=$(extract_from_metadata "$SEALED_FILE" namespace)
  NAME=$(trim_quotes "$NAME")
  NS=$(trim_quotes "$NS")
  TYPE=$(trim_quotes "$TYPE")

  if [[ -z "$NAME" || -z "$NS" ]]; then
    echo "Could not determine name/namespace from sealed file. Please enter them:" >&2
    read -r -p "Secret name: " NAME
    read -r -p "Namespace: " NS
  fi

  echo "Editing Secret '$NAME' in namespace '$NS' based on $SEALED_FILE" >&2

  # Try to decrypt the sealed file locally (preferred), otherwise fall back to reading from the live Secret
  TMP_DIR="tmp-secrets"
  mkdir -p "$TMP_DIR"
  if ! grep -q "^tmp-secrets$" .gitignore 2>/dev/null; then
    echo "tmp-secrets" >>.gitignore
  fi

  DECRYPTED_FILE="$TMP_DIR/${NAME}.decrypted.yaml"
  USED_DECRYPTION=0

  # Attempt local decryption using provided private key(s)
  if [[ -n "${SEALED_SECRETS_PRIVATE_KEY:-}" || -n "${KUBESEAL_PRIVATE_KEY:-}" ]]; then
    keypath="${SEALED_SECRETS_PRIVATE_KEY:-$KUBESEAL_PRIVATE_KEY}"
    ks_args=(--recovery-unseal)
    if [[ -d "$keypath" ]]; then
      for f in "$keypath"/*; do
        [[ -f "$f" ]] && ks_args+=(--recovery-private-key "$f")
      done
    else
      ks_args+=(--recovery-private-key "$keypath")
    fi
    if kube kubeseal "${ks_args[@]}" <"$SEALED_FILE" >"$DECRYPTED_FILE" 2>/dev/null; then
      USED_DECRYPTION=1
    fi
  fi

  # Attempt decryption by retrieving the controller's private key from the cluster (admin only)
  if [[ $USED_DECRYPTION -eq 0 ]]; then
    controller_ns="${SEALED_SECRETS_NAMESPACE:-flux-system}"
    PEM_B64=$(kube kubectl -n "$controller_ns" get secret -l sealedsecrets.bitnami.com/sealed-secrets-key=active -o jsonpath='{.items[0].data.tls\.key}' 2>/dev/null || true)
    if [[ -n "$PEM_B64" ]]; then
      if kube kubeseal --recovery-unseal --recovery-private-key <(printf '%s' "$PEM_B64" | base64 -D 2>/dev/null || printf '%s' "$PEM_B64" | base64 -d 2>/dev/null) <"$SEALED_FILE" >"$DECRYPTED_FILE" 2>/dev/null; then
        USED_DECRYPTION=1
      fi
    fi
  fi

  if [[ $USED_DECRYPTION -eq 1 ]]; then
    # Extract key=value b64 pairs from the decrypted Secret file
    mapfile -t kv_b64 < <(kube kubectl create -f "$DECRYPTED_FILE" --dry-run=client -o go-template='{{range $k, $v := .data}}{{printf "%s=%s\n" $k $v}}{{end}}')
    # Determine type from decrypted file if not set
    if [[ -z "$TYPE" ]]; then
      TYPE=$(kube kubectl create -f "$DECRYPTED_FILE" --dry-run=client -o jsonpath='{.type}' 2>/dev/null || true)
      TYPE=${TYPE:-Opaque}
    fi
  else
    # Fallback: fetch the live Secret and decode key/value pairs
    if ! kube kubectl -n "$NS" get secret "$NAME" >/dev/null 2>&1; then
      echo "Secret '$NAME' not found in namespace '$NS'. Unable to decrypt and no live Secret to edit." >&2
      exit 1
    fi
    # Determine type if not set from file
    if [[ -z "$TYPE" ]]; then
      TYPE=$(kube kubectl -n "$NS" get secret "$NAME" -o jsonpath='{.type}' 2>/dev/null || true)
      TYPE=${TYPE:-Opaque}
    fi
    mapfile -t kv_b64 < <(kube kubectl -n "$NS" get secret "$NAME" -o go-template='{{range $k, $v := .data}}{{printf "%s=%s\n" $k $v}}{{end}}')
  fi
  if [[ ${#kv_b64[@]} -eq 0 ]]; then
    echo "Secret has no data. Nothing to edit." >&2
    exit 1
  fi

  ORIG_FILE="$TMP_DIR/${NAME}.original.yaml"
  EDIT_FILE="$TMP_DIR/${NAME}.edit.yaml"

  # Decode and write original YAML
  {
    for line in "${kv_b64[@]}"; do
      k="${line%%=*}"
      b64="${line#*=}"
      # Allow empty values
      if [[ -n "$b64" ]]; then
        v=$(printf '%s' "$b64" | base64 -D 2>/dev/null || printf '%s' "$b64" | base64 -d 2>/dev/null || true)
      else
        v=""
      fi
      printf '%s=%s\n' "$k" "$v"
    done
  } | write_secret_yaml "$ORIG_FILE" "$NAME" "$NS" "$TYPE"

  cp "$ORIG_FILE" "$EDIT_FILE"
  ${editor} "$EDIT_FILE"

  if diff -u "$ORIG_FILE" "$EDIT_FILE" >/dev/null; then
    echo "No changes made. Exiting."
    exit 0
  fi

  echo "Proposed changes:"
  diff -u "$ORIG_FILE" "$EDIT_FILE" || true

  read -r -p "Save changes and update sealed file $SEALED_FILE? (y/N): " CONFIRM
  if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Aborting."
    exit 1
  fi

  PUB_CERT=$(fetch_pub_cert)
  cp "$SEALED_FILE" "${SEALED_FILE}.bak"
  kube kubeseal --format yaml --cert <(echo "$PUB_CERT") <"$EDIT_FILE" >"$SEALED_FILE"
  echo "Updated sealed secret written to $SEALED_FILE (backup at ${SEALED_FILE}.bak)"

  if [[ $APPLY_AFTER -eq 1 ]]; then
    echo "Applying updated SealedSecret to cluster..."
    kube kubectl -n "$NS" apply -f "$SEALED_FILE"
    echo "Applied. Note: controller may take a few seconds to reconcile the Secret."
  else
    echo "Note: only the sealed file was updated. Commit/push and let Flux (or run with --apply) to update the live Secret."
  fi
  exit 0
fi

# ---------- Create mode (default) ----------

# Fetch pub-sealed-secrets.pem and store in a variable
PUB_CERT=$(fetch_pub_cert)

# Wizard: Scope selection
echo "Is this secret scoped at the app level or system level?"
select SCOPE in "app" "system"; do
  case $SCOPE in
  app)
    read -p "Enter the namespace for the secret: " NAMESPACE
    BASE_NAME="$NAMESPACE"
    ;;
  system)
    NAMESPACE="flux-system"
    read -p "Enter the base name for the secret (e.g. app name): " BASE_NAME
    ;;
  esac
  break
done

DEFAULT_SECRET_TYPE=Opaque
read -p "Enter the type of the secret [${DEFAULT_SECRET_TYPE}]: " SECRET_TYPE
SECRET_TYPE="${SECRET_TYPE:-$DEFAULT_SECRET_TYPE}"

# Generate default secret name
if [[ $SCOPE == "system" ]]; then
  DEFAULT_SECRET_NAME="${BASE_NAME}-secrets-system"
else
  DEFAULT_SECRET_NAME="${BASE_NAME}-secrets"
fi

# Prompt for secret name, allowing change
read -p "Enter the name of the secret [${DEFAULT_SECRET_NAME}]: " SECRET_NAME
SECRET_NAME="${SECRET_NAME:-$DEFAULT_SECRET_NAME}"

# Validate secret name
if [[ $SCOPE == "system" ]]; then
  if [[ $SECRET_NAME != *-secrets-system ]]; then
    echo "System scoped secrets must end with '-secrets-system'."
    exit 1
  fi
  SECRET_PATH="clusters/production/secrets"
else
  if [[ $SECRET_NAME != *-secrets ]]; then
    echo "App scoped secrets must end with '-secrets'."
    exit 1
  fi
  read -p "Enter the path to store the sealed secret file: " SECRET_PATH
fi

# Create tmp-secrets dir
TMP_DIR="tmp-secrets"
mkdir -p "$TMP_DIR"
if ! grep -q "^tmp-secrets$" .gitignore 2>/dev/null; then
  echo "tmp-secrets" >>.gitignore
fi

# Collect secrets
declare -A SECRETS
while true; do
  read -p "Enter secret key (leave empty to finish): " KEY
  if [[ -z "$KEY" ]]; then
    break
  fi
  read -p "Enter value for '$KEY': " VALUE
  SECRETS["$KEY"]="$VALUE"
done

if [[ ${#SECRETS[@]} -eq 0 ]]; then
  echo "No secrets provided. Exiting."
  exit 1
fi

# Write unencrypted secret manifest directly
SECRET_FILE="$TMP_DIR/$SECRET_NAME.yaml"
{
  echo "apiVersion: v1"
  echo "kind: Secret"
  echo "type: $SECRET_TYPE"
  echo "metadata:"
  echo "  name: $SECRET_NAME"
  echo "  namespace: $NAMESPACE"
  echo "stringData:"
  for K in "${!SECRETS[@]}"; do
    echo "  $K: \"${SECRETS[$K]}\""
  done
} >"$SECRET_FILE"

echo "Secret created at $SECRET_FILE"

# SealedSecret output path
SEALED_FILE="$SECRET_PATH/$SECRET_NAME.yaml"
mkdir -p "$SECRET_PATH"

if [[ -f "$SEALED_FILE" ]]; then
  read -p "SealedSecret file already exists at $SEALED_FILE. Overwrite? (y/N): " CONFIRM
  [[ "$CONFIRM" =~ ^[Yy]$ ]] || {
    echo "Aborting."
    exit 1
  }
fi

kube kubeseal --format yaml --cert <(echo "$PUB_CERT") <"$SECRET_FILE" >"$SEALED_FILE"

echo "SealedSecret created at $SEALED_FILE"

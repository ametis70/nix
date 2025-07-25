set -e

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  cat <<EOF
Usage: $0

Interactive wizard for creating Kubernetes SealedSecrets using kubeseal and kube wrapper.

This is meant to be used in a FluxCD repo.

Steps:
  - Choose secret scope (app or system)
  - Enter namespace (for app scope)
  - Enter base name (for system scope)
  - Enter secret name (default suggested)
  - Enter secret key/value pairs
  - SealedSecret is saved to the appropriate directory

Requirements:
  - kube wrapper script for kubectl and kubeseal
  - kubeseal and kubectl installed
EOF
  exit 0
fi

# Fetch pub-sealed-secrets.pem and store in a variable
echo "Fetching sealed secrets public cert..."
PUB_CERT=$(kube kubeseal --fetch-cert \
  --controller-name=sealed-secrets-controller \
  --controller-namespace=flux-system)

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
if ! grep -q "^tmp-secrets$" .gitignore; then
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

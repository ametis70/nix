# Script to fetch /etc/rancher/k3s/k3s.yaml from a remote host via SSH,
# store it in the GNOME keyring, and wrap kubectl, helm, or k9s to use it.

KEY_NAME="k3s_kubeconfig"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

function usage() {
  echo "Usage:"
  echo "  $0 setup fetch <[user@]host> [ssh_options]"
  echo "  $0 setup show"
  echo "  $0 kubectl [kubectl_args...]"
  echo "  $0 helm [helm_args...]"
  echo "  $0 helmfile [helm_args...]"
  echo "  $0 k9s [k9s_args...]"
  echo "  $0 [kubectl_args...]"
  exit 1
}

function fetch_kubeconfig() {
  local userhost="$1"
  shift
  local ssh_opts=("$@")
  local user=""
  local host="$userhost"
  if [[ "$userhost" == *"@"* ]]; then
    user="${userhost%@*}"
    host="${userhost#*@}"
  else
    user="root"
  fi

  local ssh_target="$host"
  [[ -n "$user" ]] && ssh_target="$user@$host"

  local remote_cmd="cat /etc/rancher/k3s/k3s.yaml"
  local kubeconfig
  if [[ "$user" != "root" ]]; then
    # Use -t for interactive terminal to allow sudo password input and show the default prompt by running in a shell
    kubeconfig=$(ssh -t "${ssh_opts[@]}" "$ssh_target" "sh -c 'sudo cat /etc/rancher/k3s/k3s.yaml'" 2>&1)
  else
    kubeconfig=$(ssh "${ssh_opts[@]}" "$ssh_target" "$remote_cmd" 2>&1)
  fi
  if [[ $? -ne 0 || -z "$kubeconfig" ]]; then
    echo "Failed to fetch kubeconfig from $ssh_target"
    echo "$kubeconfig"
    exit 2
  fi
  # Replace 127.0.0.1 with the actual host in the kubeconfig
  kubeconfig="${kubeconfig//127.0.0.1/$host}"
  secret-tool store --label="K3s kubeconfig" service "$KEY_NAME" dummy dummy <<<"$kubeconfig"
  echo "Kubeconfig stored in keyring"
}

function show_kubeconfig() {
  kubeconfig=$(secret-tool lookup service "$KEY_NAME" dummy dummy)
  if [[ -n "$kubeconfig" ]]; then
    echo "$kubeconfig"
  else
    echo "No kubeconfig found in keyring"
    exit 4
  fi
}

function run_with_kubeconfig() {
  local cmd="$1"
  shift
  local kubeconfig
  kubeconfig=$(secret-tool lookup service "$KEY_NAME" dummy dummy)
  if [[ -z "$kubeconfig" ]]; then
    echo "No kubeconfig found in keyring. Please run '$0 setup fetch <host>' first."
    exit 3
  fi
  local tmpfile
  tmpfile=$(mktemp)
  echo "$kubeconfig" >"$tmpfile"
  KUBECONFIG="$tmpfile" "$cmd" "$@"
  rm -f "$tmpfile"
}

case "$1" in
setup)
  shift
  case "$1" in
  fetch)
    shift
    [[ $# -lt 1 ]] && usage
    fetch_kubeconfig "$@"
    ;;
  show)
    show_kubeconfig
    ;;
  *)
    usage
    ;;
  esac
  ;;
helm | helmfile | k9s)
  cmd="$1"
  shift
  run_with_kubeconfig "$cmd" "$@"
  ;;
kubectl)
  shift
  run_with_kubeconfig kubectl "$@"
  ;;
*)
  run_with_kubeconfig kubectl "$@"
  ;;
esac

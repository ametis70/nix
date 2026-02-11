#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
DEFAULT_EDITOR="${EDITOR:-vi}"

function usage() {
	cat <<'EOF'
Usage:
  kubesec2 list [-n|--namespace <namespace>]
  kubesec2 get [secret-name]
  kubesec2 edit [secret-name]
  kubesec2 add [secret-name] [-n|--namespace <namespace>]
  kubesec2 browse
  kubesec2 metrics
EOF
}

function require_cmd() {
	local cmd="$1"
	if ! command -v "$cmd" >/dev/null 2>&1; then
		echo "Missing required command: $cmd" >&2
		exit 127
	fi
}

function confirm() {
	local prompt="$1"
	local response
	read -r -p "$prompt" response
	[[ "$response" == "y" || "$response" == "Y" ]]
}

function list_secrets() {
	local namespace="$1"
	local filter=()
	if [[ -n "$namespace" ]]; then
		filter=("--filter=labels.namespace=$namespace")
	fi
	gcloud secrets list --format='value(name)' "${filter[@]}"
}

function select_secret() {
	local namespace="$1"
	local selection
	require_cmd fzf
	selection=$(list_secrets "$namespace" | fzf --prompt="secret> ")
	printf "%s" "$selection"
}

function secret_exists() {
	local secret_name="$1"
	gcloud secrets describe "$secret_name" >/dev/null 2>&1
}

function access_secret() {
	local secret_name="$1"
	gcloud secrets versions access latest --secret="$secret_name" 2>/dev/null || true
}

function edit_secret() {
	local secret_name="$1"

	if ! secret_exists "$secret_name"; then
		echo "Secret not found: $secret_name" >&2
		return 1
	fi

	local original_file=""
	local edit_file=""
	original_file=$(mktemp)
	edit_file=$(mktemp)
	trap 'rm -f "${original_file:-}" "${edit_file:-}"' RETURN

	access_secret "$secret_name" >"$original_file"
	cp "$original_file" "$edit_file"

	"$DEFAULT_EDITOR" "$edit_file"

	if cmp -s "$original_file" "$edit_file"; then
		echo "No changes saved."
		return 0
	fi

	if [[ ! -s "$edit_file" ]]; then
		echo "Secret is empty. Ignoring changes."
		return 0
	fi

	if command -v delta >/dev/null 2>&1; then
		diff -u "$original_file" "$edit_file" | delta || true
	else
		diff -u "$original_file" "$edit_file" || true
	fi

	if ! confirm "Update secret '$secret_name'? [y/N] "; then
		echo "Update cancelled."
		return 0
	fi

	gcloud secrets versions add "$secret_name" --data-file="$edit_file"
	echo "Secret updated: $secret_name"
}

function list_command() {
	local namespace=""

	while [[ $# -gt 0 ]]; do
		case "$1" in
		-n | --namespace)
			namespace="${2:-}"
			shift 2
			;;
		-h | --help)
			usage
			return 0
			;;
		*)
			echo "Unknown option: $1" >&2
			usage
			return 1
			;;
		esac
	done

	list_secrets "$namespace"
}

function get_command() {
	local secret_name="${1:-}"

	if [[ -z "$secret_name" ]]; then
		secret_name=$(select_secret "")
	fi

	if [[ -z "$secret_name" ]]; then
		echo "No secret selected."
		return 1
	fi

	gcloud secrets versions access latest --secret="$secret_name"
}

function edit_command() {
	local secret_name="${1:-}"

	if [[ -z "$secret_name" ]]; then
		secret_name=$(select_secret "")
	fi

	if [[ -z "$secret_name" ]]; then
		echo "No secret selected."
		return 1
	fi

	edit_secret "$secret_name"
}

function open_url() {
	local url="$1"
	if command -v xdg-open >/dev/null 2>&1; then
		xdg-open "$url" >/dev/null 2>&1
		return 0
	fi
	if command -v open >/dev/null 2>&1; then
		open "$url" >/dev/null 2>&1
		return 0
	fi
	echo "No opener found (xdg-open or open)." >&2
	return 1
}

function browse_command() {
	open_url "https://console.cloud.google.com/security/secret-manager"
}

function metrics_command() {
	open_url "https://console.cloud.google.com/apis/api/secretmanager.googleapis.com/metrics"
}

function add_command() {
	local secret_name=""
	local namespace=""

	while [[ $# -gt 0 ]]; do
		case "$1" in
		-n | --namespace)
			namespace="${2:-}"
			shift 2
			;;
		-h | --help)
			usage
			return 0
			;;
		*)
			if [[ -z "$secret_name" ]]; then
				secret_name="$1"
				shift
			else
				echo "Unexpected argument: $1" >&2
				usage
				return 1
			fi
			;;
		esac
	done

	if [[ -z "$secret_name" ]]; then
		read -r -p "Secret name: " secret_name
	fi

	if [[ -z "$namespace" ]]; then
		read -r -p "Namespace: " namespace
	fi

	if [[ -z "$secret_name" || -z "$namespace" ]]; then
		echo "Secret name and namespace are required." >&2
		return 1
	fi

	local full_name="${namespace}_${secret_name}"

	if secret_exists "$full_name"; then
		echo "Secret already exists: $full_name"
		if confirm "Edit it instead? [y/N] "; then
			edit_secret "$full_name"
		else
			echo "Add cancelled."
		fi
		return 0
	fi

	if ! confirm "Create secret '$full_name' in namespace '$namespace'? [y/N] "; then
		echo "Add cancelled."
		return 0
	fi

	gcloud secrets create "$full_name" --replication-policy="automatic" --labels="namespace=$namespace"
	edit_secret "$full_name"
}

function main() {
	require_cmd gcloud

	local command="${1:-}"
	shift || true

	case "$command" in
	list)
		list_command "$@"
		;;
	get)
		get_command "$@"
		;;
	edit)
		edit_command "$@"
		;;
	add)
		add_command "$@"
		;;
	browse)
		browse_command
		;;
	metrics)
		metrics_command
		;;
	-h | --help | help | "")
		usage
		;;

	-h | --help | help | "")
		usage
		;;
	*)
		echo "Unknown command: $command" >&2
		usage
		exit 1
		;;
	esac
}

main "$@"

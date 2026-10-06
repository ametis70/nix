#!/bin/bash

set -eo pipefail

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  cat <<EOF
Usage: $0 <command> [arguments]

Tool for managing docker-mailserver accounts via kubectl.

Commands:
  list                    List all mail accounts
  password <email>        Set password for existing mail account (with confirmation)
  create <email>          Create new mail account with password

Requirements:
  - kube wrapper script for kubectl
  - docker-mailserver pod running in mail namespace
EOF
  exit 0
fi

# Function to check if mailserver pod exists
check_mailserver_pod() {
  echo "Checking for docker-mailserver pod in mail namespace..."
  POD_NAME=$(kube kubectl get pods -n mail -o name | grep docker-mailserver | head -1 | sed 's/pod\///' 2>/dev/null || echo "")
  
  if [[ -z "$POD_NAME" ]]; then
    echo "Error: No docker-mailserver pod found in mail namespace."
    echo "Please ensure the docker-mailserver is running."
    echo
    echo "Available pods in mail namespace:"
    kube kubectl get pods -n mail
    exit 1
  fi
  
  echo "Found mailserver pod: $POD_NAME"
}

# Function to list all mail accounts
list_accounts() {
  echo "Listing all mail accounts..."
  kube kubectl exec -n mail "$POD_NAME" -- setup email list
}

# Function to set password for existing account
set_password() {
  local email="$1"
  
  # Validate email format
  if [[ ! "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
    echo "Error: Invalid email format."
    exit 1
  fi
  
  # Check if account exists
  echo "Checking if account $email exists..."
  if ! kube kubectl exec -n mail "$POD_NAME" -- setup email list | grep -q "^\* $email "; then
    echo "Error: Account $email does not exist."
    echo "Use 'create' command to create a new account."
    exit 1
  fi
  
  read -s -p "Enter new password: " password
  echo
  read -s -p "Confirm new password: " password_confirm
  echo
  
  if [[ "$password" != "$password_confirm" ]]; then
    echo "Error: Passwords do not match."
    exit 1
  fi
  
  if [[ -z "$password" ]]; then
    echo "Error: Password cannot be empty."
    exit 1
  fi
  
  echo "Setting password for $email..."
  kube kubectl exec -n mail "$POD_NAME" -- setup email update "$email" "$password"
  echo "Password updated successfully for $email"
}

# Function to create new mail account
create_account() {
  local email="$1"
  
  # Validate email format
  if [[ ! "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
    echo "Error: Invalid email format."
    exit 1
  fi
  
  # Check if account already exists
  echo "Checking if account $email already exists..."
  if kube kubectl exec -n mail "$POD_NAME" -- setup email list | grep -q "^\* $email "; then
    echo "Error: Account $email already exists."
    echo "Use 'password' command to update the password."
    exit 1
  fi
  
  read -s -p "Enter password: " password
  echo
  read -s -p "Confirm password: " password_confirm
  echo
  
  if [[ "$password" != "$password_confirm" ]]; then
    echo "Error: Passwords do not match."
    exit 1
  fi
  
  if [[ -z "$password" ]]; then
    echo "Error: Password cannot be empty."
    exit 1
  fi
  
  echo "Creating account $email..."
  kube kubectl exec -n mail "$POD_NAME" -- setup email add "$email" "$password"
  echo "Account created successfully: $email"
}



# Check if command is provided, show help by default
if [[ $# -eq 0 ]]; then
  exec "$0" --help
fi

# Main script logic
check_mailserver_pod

case "$1" in
  "list")
    list_accounts
    ;;
  "password")
    if [[ $# -lt 2 ]]; then
      echo "Error: Email address required for password command."
      echo "Usage: $0 password <email>"
      exit 1
    fi
    set_password "$2"
    ;;
  "create")
    if [[ $# -lt 2 ]]; then
      echo "Error: Email address required for create command."
      echo "Usage: $0 create <email>"
      exit 1
    fi
    create_account "$2"
    ;;
  *)
    echo "Unknown command: $1"
    echo "Use '$0 --help' for usage information."
    exit 1
    ;;
esac
#!/usr/bin/env bash

set -o pipefail

# Define the file path
POOR_MANS_MFA_DIR="${HOME}/.poor-mans-mfa"
SECRET_FILE="${POOR_MANS_MFA_DIR}/2fa.gpg"
BASH_COMPLETION_FILE="${POOR_MANS_MFA_DIR}/bash-completion"

# Function to display help
show_help() {
  echo "Usage: $0 [OPTION]... [NAME]..."
  echo "Options:"
  echo "  [name]      Generate TOTP code for the given name"
  echo "  -h          Display this help message"
  echo "  -a          Add a new secret"
  echo "  -l          List secret names"
  echo "  -e          Edit secret file"
  echo "  -g          Generate bash completion data"
  echo "  -c [name]   Return list of names matching [name] for bash completion"
}

# Function to decrypt the secrets file and use it directly
decrypt_secrets() {
  local gpg_passphrase="${1}"
  if [ -z "${gpg_passphrase}" ]; then
    echo "The GPG passphrase is not set."
    return 1
  fi
  gpg --passphrase "${gpg_passphrase}" --batch --pinentry-mode loopback --quiet --decrypt "${SECRET_FILE}"
}

get_gpg_passphrase() {
  echo -n "Enter GPG passphrase: " >&2
  read -s -r gpg_passphrase
  echo -n "${gpg_passphrase}"
}

# Function to generate bash completion data
generate_completion_data() {
  echo "Generating bash completion data..."
  gpg_passphrase="$(get_gpg_passphrase)"
  echo
  decrypt_secrets "${gpg_passphrase}" | awk -F ':' '{print $1}' > "${HOME}/.poor-mans-mfa/bash-completion"
  echo "Done."
}

# Function to match and list names for completion
list_matching_names() {
  local name="$1"
  grep -i "$name" "${BASH_COMPLETION_FILE}"
}

list_names() {
  echo "Secret names:"
  echo
  cat "${BASH_COMPLETION_FILE}" | sort
}

edit_secret_file() {
  echo "Editing secret file ${SECRET_FILE}..."
  # Ensure EDITOR is set
  if [ -z "${EDITOR}" ]; then
    echo "The EDITOR environment variable is not set."
    exit 1
  fi

  # Create a secure temporary file
  local temp_file=$(mktemp)

  # Ensure temporary file is removed on script exit or if any signal is received
  trap 'rm -f "${temp_file}"' EXIT INT TERM

  gpg_passphrase="$(get_gpg_passphrase)"
  echo

  # Decrypt the file into the temporary file
  decrypt_secrets "${gpg_passphrase}" > "${temp_file}"

  # Check if decryption was successful
  if [ $? -ne 0 ]; then
      echo "Failed to decrypt the secrets file."
      return 1
  fi

  # Open the temporary file in the editor
  ${EDITOR} "${temp_file}"

  # Re-encrypt the file after editing
  gpg --passphrase "${gpg_passphrase}" --batch --pinentry-mode loopback --yes --quiet --symmetric --cipher-algo AES256 --output "${SECRET_FILE}" "${temp_file}"
}

# Function to add a new secret
add_secret() {
  gpg_passphrase="$(get_gpg_passphrase)"
  echo

  echo -n "Enter Name: "
  read -r name
  # Validate name format
  if ! [[ "${name}" =~ ^[a-zA-Z0-9\.@_-]+$ ]]; then
    echo "Invalid name format."
    return 1
  fi

  # Check if name already exists
  if decrypt_secrets "${gpg_passphrase}" | grep -q "^${name} *: *"; then
    echo "Name '${name}' already exists."
    return 1
  fi

  echo -n "Enter Secret: "
  read -r -s secret

  echo
  echo "Adding secret for ${name} to ${SECRET_FILE}..."

  # Decrypt, append, and re-encrypt without writing decrypted content to disk
  decrypt_secrets "${gpg_passphrase}" | { cat; echo "${name}: ${secret}"; } | gpg --passphrase "${gpg_passphrase}" --batch --pinentry-mode loopback --yes --quiet --symmetric --cipher-algo AES256 --output "${SECRET_FILE}"
}

# Function to generate TOTP code
generate_totp() {
  local name="${1}"
  local secret
  gpg_passphrase="$(get_gpg_passphrase)"
  echo
  secret=$(decrypt_secrets "${gpg_passphrase}" | grep "^${name}:" | sed 's/ *: */:/g' | cut -d ':' -f2)

  if [ -z "${secret}" ]; then
    echo "No valid secret found for ${name}."
    return 1
  fi

  echo "Generating TOTP code for ${name}..."
  oathtool --base32 --totp "${secret}"
}

generate_secret_file() {
  if [ ! -f "${SECRET_FILE}" ]; then
    echo "Secret file ${SECRET_FILE} does not exist, generating..."
    local tempfile=$(mktemp)
    gpg_passphrase="$(get_gpg_passphrase)"
    echo
    gpg --passphrase "${gpg_passphrase}" --batch --pinentry-mode loopback -c --cipher-algo AES256 -o "${SECRET_FILE}" "${tempfile}"
    rm "${tempfile}"
    echo "Secret file generated."
  fi
}

setup() {
  mkdir -p "${POOR_MANS_MFA_DIR}"
  generate_secret_file
}

setup

# Parse command-line arguments
case "$1" in
  -a)
    add_secret
    ;;
  -h)
    show_help
    ;;
  -l)
    list_names
    ;;
  -e)
    edit_secret_file
    ;;
  -g)
    generate_completion_data
    ;;
  -c)
    list_matching_names "${2}"
    ;;
  *)
    if [ $# -eq 1 ]; then
      generate_totp "${1}"
    else
      show_help
    fi
    ;;
esac

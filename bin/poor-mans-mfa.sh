#!/usr/bin/env bash

set -o pipefail

# Define file paths
POOR_MANS_MFA_DIR="${HOME}/.poor-mans-mfa"
SECRET_FILE="${POOR_MANS_MFA_DIR}/2fa.gpg"
BASH_COMPLETION_FILE="${POOR_MANS_MFA_DIR}/bash-completion"
GPG_PASSPHRASE=""

mkdir -p "${POOR_MANS_MFA_DIR}"

# Check for required commands
for cmd in gpg oathtool; do
  if ! command -v ${cmd} &> /dev/null; then
    echo "Required command ${cmd} not found. Please install it."
    exit 1
  fi
done

setup() {
  get_passphrase && \
  generate_secret_file && \
  check_passphrase_validity
}

get_passphrase() {
  echo -n "Enter GPG passphrase: " >&2
  read -s -r GPG_PASSPHRASE
  echo >&2
  if [ -z "${GPG_PASSPHRASE}" ]; then
    echo "Passphrase cannot be empty." >&2
    exit 1
  fi
}

decrypt_secrets() {
  gpg --passphrase "${GPG_PASSPHRASE}" --batch --pinentry-mode loopback --quiet --decrypt "${SECRET_FILE}"
}

generate_secret_file() {
  if [ ! -f "${SECRET_FILE}" ]; then
    echo "Secret file ${SECRET_FILE} does not exist, generating..."
    local tempfile=$(mktemp)
    gpg --passphrase "${GPG_PASSPHRASE}" --batch --pinentry-mode loopback -c --cipher-algo AES256 -o "${SECRET_FILE}" "${tempfile}" && \
      chmod 600 "${SECRET_FILE}"
    rm "${tempfile}"
    if [ ! -f "${SECRET_FILE}" ]; then
      echo "Failed to generate secret file."
    else
      echo "Secret file generated."
    fi
  fi
}

check_passphrase_validity() {
  if ! decrypt_secrets &> /dev/null; then
    echo "Failed to decrypt the secrets file with the provided passphrase."
    exit 1
  fi
  echo "Passphrase verified successfully."
}

add_secret() {
  echo -n "Enter Name: "
  read -r name
  if ! [[ "${name}" =~ ^[a-zA-Z0-9\.@_-]+$ ]]; then
    echo "Invalid name format."
    return 1
  fi
  if decrypt_secrets | grep -q "^${name} *: *"; then
    echo "Name '${name}' already exists."
    return 1
  fi
  echo -n "Enter Secret: "
  read -r -s secret
  echo
  decrypt_secrets | { cat; echo "${name}: ${secret}"; } | gpg --passphrase "${GPG_PASSPHRASE}" --batch --pinentry-mode loopback --yes --quiet --symmetric --cipher-algo AES256 --output "${SECRET_FILE}" && generate_completion_data
  echo "Secret added for ${name}"
}

edit_secret_file() {
  local temp_file=$(mktemp)
  trap 'rm -f "${temp_file}"' EXIT INT TERM
  decrypt_secrets > "${temp_file}"
  ${EDITOR:-vi} "${temp_file}"
  gpg --passphrase "${GPG_PASSPHRASE}" --batch --pinentry-mode loopback --yes --quiet --symmetric --cipher-algo AES256 --output "${SECRET_FILE}" "${temp_file}" && generate_completion_data
  if [[ $? -ne 0 ]]; then
    echo "Error editing the secrets file."
    exit 1
  fi
}

generate_totp() {
  local name="${1}"
  local secret=$(decrypt_secrets | grep "^${name}:" | sed 's/ *: */:/g' | cut -d ':' -f2)
  if [ -z "${secret}" ]; then
    echo "No valid secret found for ${name}."
    return 1
  fi
  echo "Generating TOTP code for ${name}..."
  local totp_code=$(oathtool --base32 --totp "${secret}")
  echo "TOTP code for ${name}: ${totp_code}"
  if command -v xclip &> /dev/null; then
    echo -n "${totp_code}" | xclip -selection clipboard
    echo "Code copied to clipboard."
  fi
}

interactive_mode() {
  if ! command -v rlwrap &> /dev/null; then
    echo "rlwrap is not installed. Please install it for interactive mode."
    exit 1
  fi
  echo "Interactive mode enabled"
  rlwrap -i -b ":" -f "${BASH_COMPLETION_FILE}" ${0} -o
}

loop_mode() {
  while true; do
    echo -n "Enter Name: "
    read -r name
    if [[ -n "${name}" ]]; then
      generate_totp "${name}"
    else
      echo "Done."
      break
    fi
  done
}

generate_completion_data() {
  echo "Generating bash completion data..."
  decrypt_secrets | awk -F ':' '{print $1}' > "${BASH_COMPLETION_FILE}"
}

list_names() {
  if [ -f "${BASH_COMPLETION_FILE}" ]; then
    echo "Secret names:"
    echo
    cat "${BASH_COMPLETION_FILE}" | sort
  else
    echo "No secret names found."
  fi
}

list_matching_names() {
  local name="${1}"
  if [ -z "${name}" ]; then
    return
  fi
  grep -i "${name}" "${BASH_COMPLETION_FILE}"
}

show_help() {
  echo "Usage: $0 [OPTION]... [NAME]..."
  echo "Options:"
  echo "  [name]      Generate TOTP code for the given name"
  echo "  -h          Display this help message"
  echo "  -i          Interactive mode"
  echo "  -a          Add a new secret"
  echo "  -l          List secret names"
  echo "  -e          Edit secret file"
  echo "  -g          Generate bash completion data"
  echo "  -c [name]   Return list of names matching [name] for bash completion"
}

if [ ${1} = "-h" ] || [ ${1} = "--help" ]; then
  show_help
  exit 0
fi

case "${1}" in
  -l)
    list_names
    exit 0
    ;;
  -c)
    list_matching_names "${2}"
    exit 0
    ;;
  -i)
    interactive_mode
    exit 0
    ;;
esac

setup || { echo "Setup failed. Exiting."; exit 1; }

case "${1}" in
  -a)
    add_secret
    ;;
  -e)
    edit_secret_file
    ;;
  -g)
    generate_completion_data
    ;;
  -o)
    loop_mode
    ;;
  *)
    if [ $# -eq 1 ]; then
      generate_totp "${1}"
    else
      show_help
    fi
    ;;
esac

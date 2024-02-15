#!/usr/bin/env bash

set -o pipefail

# Defaults file paths
DEFAULT_POOR_MANS_MFA_DIR="${HOME}/.poor-mans-mfa"
DEFAULT_SECRET_FILE="2fa.gpg"
DEFAULT_COMPLETION_DATA_FILE="completion-data"

# Check if environment variables are set, if so use them, otherwise use defaults
POOR_MANS_MFA_DIR="${POOR_MANS_MFA_DIR:-${DEFAULT_POOR_MANS_MFA_DIR}}"
POOR_MANS_MFA_SECRET_FILE="${POOR_MANS_MFA_SECRET_FILE:-${DEFAULT_SECRET_FILE}}"
POOR_MANS_MFA_COMPLETION_DATA_FILE="${POOR_MANS_MFA_COMPLETION_DATA_FILE:-${DEFAULT_COMPLETION_DATA_FILE}}"

# File paths.
SECRET_FILE="${POOR_MANS_MFA_DIR}/${POOR_MANS_MFA_SECRET_FILE}"
COMPLETION_DATA_FILE="${POOR_MANS_MFA_DIR}/${POOR_MANS_MFA_COMPLETION_DATA_FILE}"

# Populated with GPG passphrase, set globally so it can be used throughout the script.
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
  if [[ -z "${GPG_PASSPHRASE}" ]]; then
    echo "Passphrase cannot be empty." >&2
    exit 1
  fi
}

decrypt_secrets() {
  gpg --passphrase "${GPG_PASSPHRASE}" --batch --pinentry-mode loopback --quiet --decrypt "${SECRET_FILE}"
}

generate_secret_file() {
  if [[ ! -f "${SECRET_FILE}" ]]; then
    echo "Secret file ${SECRET_FILE} does not exist, generating..."
    local tempfile=$(mktemp)
    gpg --passphrase "${GPG_PASSPHRASE}" --batch --pinentry-mode loopback -c --cipher-algo AES256 -o "${SECRET_FILE}" "${tempfile}" && \
      chmod 600 "${SECRET_FILE}"
    rm "${tempfile}"
    if [[ ! -f "${SECRET_FILE}" ]]; then
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

validate_name() {
  local name="${1}"
  if ! [[ "${name}" =~ ^[^[:space:]:]+$ ]]; then
    return 1
  fi
}

check_unique_names() {
  local names=("$@")
  local unique_names
  mapfile -t unique_names < <(printf '%s\n' "${names[@]}" | sort | uniq -d)
  if (( ${#unique_names[@]} > 0 )); then
    echo "Error: duplicate names found:"
    printf '%s\n' "${unique_names[@]}"
    return 1
  fi
}

check_valid_names() {
  local names=("$@")
  local invalid_names=()
  for name in "${names[@]}"; do
    if ! validate_name "${name}"; then
      invalid_names+=("${name}")
    fi
  done
  if (( ${#invalid_names[@]} > 0 )); then
    echo "Error: invalid name format found for the following names:"
    printf '%s\n' "${invalid_names[@]}"
    return 1
  fi
}

add_secret() {
  echo -n "Enter Name: "
  read -r name
  if ! validate_name "${name}"; then
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
  local names
  local output
  local errors=()
  local temp_file=$(mktemp)
  echo "Editing ${SECRET_FILE} via temp file ${temp_file}"
  trap "rm -v '${temp_file}'" EXIT INT TERM
  decrypt_secrets > "${temp_file}"
  ${EDITOR:-vi} "${temp_file}"
  mapfile -t names < <(awk -F ':' '{print $1}' "${temp_file}")
  output=$(check_valid_names "${names[@]}" 2>&1)
  local status_valid_names=$?
  [[ ${status_valid_names} -ne 0 ]] && errors+=("${output}")
  output=$(check_unique_names "${names[@]}" 2>&1)
  local status_unique_names=$?
  [[ ${status_unique_names} -ne 0 ]] && errors+=("${output}")
  if (( ${status_valid_names} != 0 || ${status_unique_names} != 0 )); then
    printf '%s\n' "File not saved because of the following errors:" "${errors[@]}"
    exit 1
  fi
  gpg --passphrase "${GPG_PASSPHRASE}" --batch --pinentry-mode loopback --yes --quiet --symmetric --cipher-algo AES256 --output "${SECRET_FILE}" "${temp_file}" && generate_completion_data
  if [[ $? -ne 0 ]]; then
    echo "Error editing the secrets file."
    exit 1
  fi
}

copy_totp_to_clipboard() {
  local totp_code="${1}"
  if [[ -z "${POOR_MANS_MFA_DISABLE_CLIPBOARD_INTEGRATION}" ]]; then
    if command -v xclip &> /dev/null; then
      echo -n "${totp_code}" | xclip -selection clipboard
      echo "Code copied to clipboard."
    fi
  fi
}

generate_totp() {
  local name="${1}"
  local secret=$(decrypt_secrets | grep "^${name}:" | sed 's/ *: */:/g' | cut -d ':' -f2)
  if [[ -z "${secret}" ]]; then
    echo "No valid secret found for ${name}."
    return 1
  fi
  echo "Generating TOTP code for ${name}..."
  local totp_code=$(oathtool --base32 --totp "${secret}")
  echo "TOTP code for ${name}: ${totp_code}"
  copy_totp_to_clipboard "${totp_code}"
}

interactive_mode() {
  if ! command -v rlwrap &> /dev/null; then
    echo "rlwrap is not installed. Please install it for interactive mode."
    exit 1
  fi
  echo "Interactive mode enabled"
  rlwrap -i -b ":" -f "${COMPLETION_DATA_FILE}" ${0} -o
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
  decrypt_secrets | awk -F ':' '{print $1}' > "${COMPLETION_DATA_FILE}"
}

list_names() {
  if [[ -f "${COMPLETION_DATA_FILE}" ]]; then
    echo "Secret names:"
    echo
    cat "${COMPLETION_DATA_FILE}" | sort
  else
    echo "No secret names found."
  fi
}

list_matching_names() {
  local name="${1}"
  if [[ -z "${name}" ]]; then
    cat "${COMPLETION_DATA_FILE}"
  else
    grep -i "${name}" "${COMPLETION_DATA_FILE}"
  fi
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

if [[ $# -eq 0 ]] || [[ "${1}" = "-h" ]] || [[ "${1}" = "--help" ]]; then
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
    if [[ $# -eq 1 ]]; then
      generate_totp "${1}"
    else
      show_help
    fi
    ;;
esac

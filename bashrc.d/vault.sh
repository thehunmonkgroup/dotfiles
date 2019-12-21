# Autocomplete for Hashicorp Vault.
vault_bin=`which vault`
if [ -n "${vault_bin}" ]; then
  complete -C ${vault_bin} vault
fi

# Bash functions for poor man's Vault.
vault_funcs="${HOME}/git/stirlab/vault/vault.sh"
if [ -r "${vault_funcs}" ]; then
  . ${vault_funcs}
fi

# Apartment Lines data vault for poor man's Vault.
vault_dir="${HOME}/git/apartmentlines/vault"
if [ -r "${vault_dir}" ]; then
  export VAULT_ENV="staging"
  export VAULT_VAULT_DIR="${vault_dir}"
fi

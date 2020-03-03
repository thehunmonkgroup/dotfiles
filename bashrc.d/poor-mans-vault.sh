# Bash functions for poor man's Vault.
pmv_funcs="${HOME}/git/stirlab/poor-mans-vault/pmv.sh"
if [ -r "${pmv_funcs}" ]; then
  . ${pmv_funcs}
fi

# Apartment Lines data vault for poor man's Vault.
vault_dir="${HOME}/git/apartmentlines/vault"
if [ -r "${vault_dir}" ]; then
  export PMV_VAULT_DIR="${vault_dir}"
fi

# Autocomplete for Hashicorp Vault.
vault_bin=`which vault`
if [ -n "${vault_bin}" ]; then
  complete -C ${vault_bin} vault
fi

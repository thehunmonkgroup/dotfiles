# Autocomplete for Hashicorp Terraform.
terraform_bin=`which terraform`
if [ -n "${terraform_bin}" ]; then
  complete -C ${terraform_bin} terraform
fi

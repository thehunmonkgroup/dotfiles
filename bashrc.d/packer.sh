# Autocomplete for Hashicorp Packer.
packer_bin=`which packer`
if [ -n "${packer_bin}" ]; then
  complete -C ${packer_bin} packer
fi

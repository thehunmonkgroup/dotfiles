if [ -n "$(which brew)" ]; then
  export NVM_DIR="${HOME}/.nvm"
  NVM_BASE_DIR="$(brew --prefix nvm)"
  [ -s "${NVM_BASE_DIR}/nvm.sh" ] && \. "${NVM_BASE_DIR}/nvm.sh"  # This loads nvm
  [ -s "${NVM_BASE_DIR}/etc/bash_completion.d/nvm" ] && \. "${NVM_BASE_DIR}/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
fi

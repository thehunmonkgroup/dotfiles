export PYENV_ROOT="${HOME}/.pyenv"
export PATH="${PYENV_ROOT}/bin:${PATH}"

if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi
pyenv virtualenv-init --help > /dev/null 2>&1
if [ $? -eq 0 ]; then
  eval "$(pyenv virtualenv-init -)"
fi

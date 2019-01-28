prefix=""
brewpath=`which brew`
if [ -n "$brewpath" ]; then
  prefix="$(brew --prefix)"
fi

if [ -f ${prefix}/etc/bash_completion ]; then
  . ${prefix}/etc/bash_completion
fi

if [ -z "${BASH_COMPLETION_COMPAT_DIR}" ] && [ -d ${HOME}/.bash_completion.d ]; then
  export BASH_COMPLETION_COMPAT_DIR=${HOME}/.bash_completion.d
fi

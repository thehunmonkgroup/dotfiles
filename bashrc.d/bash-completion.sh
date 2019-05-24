USER_COMPLETION_DIR="${HOME}/.bash_completion.d"

prefix=""
brewpath=`which brew`
if [ "${OS}" = "Darwin" ] && [ -n "$brewpath" ]; then
  prefix="$(brew --prefix)"
fi

if [ -f ${prefix}/etc/bash_completion ]; then
  . ${prefix}/etc/bash_completion
fi

if [ -d ${USER_COMPLETION_DIR} ]; then
  for i in "${USER_COMPLETION_DIR}"/*; do
    . "$i"
  done
fi

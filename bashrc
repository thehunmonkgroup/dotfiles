###############################################################################
# PROMPT SETTINGS
###############################################################################

PS1="\u@\H\$\w: "
PS2=\$

###############################################################################
# OS CUSTOM VARIABLES
###############################################################################

OS=`uname -s`
case "$OS" in
    Linux)
		PATH=$HOME/bin:$PATH:/sbin:/usr/sbin
		color="--color=auto"
		SHELL=/bin/bash
		# Keep environment on sudo
		alias sudo="sudo -E"
		alias sudoroot="sudo"
        ;;
    Darwin)
    PS1="\h\$\w: "
		PATH=$HOME/bin:/usr/local/sbin:$PATH
		color="-G"
		SHELL=/usr/local/bin/bash
        ;;
    FreeBSD)
		PATH=$HOME/bin:/usr/local/bin:$PATH
		color="-G"
		SHELL=/usr/local/bin/bash
        ;;
esac

EDITOR="$(PATH="${PATH}:/opt/neovim/bin" which nvim)"
if [ -z "${EDITOR}" ]; then
  EDITOR="$(which vim)"
fi

###############################################################################
# ENVIRONMENT VARIABLES
###############################################################################
export TERM=xterm-256color
export EDITOR="${EDITOR}"
export CLICOLOR=1
export LSCOLORS=exfxcxdxbxegedabagacad;

###############################################################################
# ALIASES
###############################################################################

# List aliases.
if [ -n "$(which exa 2>&1)" ]; then
  alias ls="exa -F"
  alias a="exa -alh --icons"
  alias l="exa -alh --icons --color=always | less -R"
else
  alias ls="ls -F $color"
  alias a="ls -alh -F $color"
  alias l="ls -alh -F --color=always | less -R"
fi

# cat alias
if [ -n "$(which batcat 2>&1)" ]; then
  alias cat="batcat"
fi

#grep alias
alias cgrep="grep -n --colour=auto"

# Navigation aliases.
alias cl="clear"
alias cdl="cd; clear; title bash 2> /dev/null"
alias pd="pushd"
alias bd="popd"
alias ast="cd ${HOME}/.config/astronvim/lua/user/"

# Include custom setup if found.
if [ -d ~/.bashrc.d ]; then
  files=`echo ~/.bashrc.d/*.sh 2>/dev/null`
  for file in $files;
  do
    . $file
  done
fi

###############################################################################
# FUNCTIONS
###############################################################################

cd() {
  if [ $# -eq 0 ]; then
    pushd ~ > /dev/null
  elif [ " $1" = " -" ]; then
    pushd "$OLDPWD" > /dev/null
  else
    pushd "$@" > /dev/null
  fi
}

v() {
  ${EDITOR} "$@"
}

ppath() {
  local path=`echo $PATH | tr -s '\:' '\n'`
  local pathsorted=`echo $PATH | tr -s '\:' '\n' | sort -f`

  cat <<HEREDOC

Path (executed order):

$path

Path (sorted):

$pathsorted

HEREDOC
}

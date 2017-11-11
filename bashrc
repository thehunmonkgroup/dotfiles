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

###############################################################################
# ENVIRONMENT VARIABLES
###############################################################################
export TERM=xterm-256color
export EDITOR=vim
export CLICOLOR=1
export LSCOLORS=exfxcxdxbxegedabagacad;

###############################################################################
# ALIASES
###############################################################################

# List aliases.
alias ls="ls -F $color"
alias a="ls -alh"
alias l="ls -alh | less"

#grep alias
alias cgrep="grep -n --colour=auto"

# Navigation aliases.
alias cl="clear"
alias cdl="cd; clear; title bash 2> /dev/null"
alias pd="pushd"
alias bd="popd"

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

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

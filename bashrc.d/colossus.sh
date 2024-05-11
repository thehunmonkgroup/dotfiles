export IS_COLOSSUS="true"
NVIM_SWAP_DIR="${HOME}/.local/state/nvim/swap"

###############################################################################
# ENVIRONMENT VARIABLES
###############################################################################
export ANSIBLE_PYTHON_INTERPRETER="${HOME}/.pyenv/shims/python"

###############################################################################
# ALIASES
###############################################################################
alias sy="cat ~/sync-status.txt"
alias cdns="sudo killall -HUP mDNSResponder; echo 'DNS cache cleared'"

# lifetolive.one aliases
alias vlog="v ~/Documents/mcg/video-log.otl"
alias writ="v ~/Documents/mcg/writing-ideas.otl"
alias food="v ~/Documents/reference/health/food-journal.otl"


# Secure access.
alias sec="cd ~/Documents/reference && gocryptfs security.encrypted security && cd security"
alias fin="cd ~/Documents/reference && gocryptfs finance.encrypted security && cd security"

# LLM Workflow Engine.
alias lwe="cd ~/git/llm-workflow-engine && lwe --log ~/.local/share/llm-workflow-engine/logs/$(date +%Y-%m-%d).log"

# Shortcut to kill python-lsp-server, it goes nuts sometimnes and hogs CPU.
alias pylsp_slayer='pgrep -f python-lsp-server | sort -n | head -n 1 | xargs kill -9 && echo "Killed python-lsp-server"'

###############################################################################
# FUNCTIONS
###############################################################################

y() {
  local filename="/tmp/yt-video.mp4"
  rm -vf "${filename}" &&  yt-dlp -f mp4 -o "${filename}"  "${1}" && vivaldi "${filename}"
}

now() {
  echo "[$(date '+%a, %I:%M%p %Z')]: "
}

fswp() {
  find . ${NVIM_SWAP_DIR} -name '*.sw[klmnop]' ${1}
}

kswp() {
  swp_files="$(fswp)"
  if [ -z "${swp_files}" ]; then
    echo "No .swp files to kill"
  else
    echo "${swp_files}"
    read -r -p "Kill .swp files in $(pwd) and ${NVIM_SWAP_DIR}? [y/N] " response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
      fswp "-delete -print"
    else
      echo "Aborted"
    fi
  fi
}

vman()
{
  T=/tmp/$$.pdf
  man -t $1 | ps2pdf - >$T
  xpdf $T
  rm -f $T;
}

# function for setting terminal titles in OSX
function title {
  printf "\033]0;%s\007" "$1"
}

# Color diffs for CVS.
function cvsdiff () {
  if [ "$1" != "" ]; then
    cvs diff $@ | colordiff;
  else
    cvs diff | colordiff;
  fi
}

# Color diffs for SVN.
function svndiff () {
  if [ "$1" != "" ]; then
    svn diff $@ | colordiff
  else
    svn diff | colordiff
  fi
}

function svndiffmeld () {
  svn diff --diff-cmd="meld" $@
}

function crtview() {
    if [ -z "$1" ]; then
        echo "Usage: crtview <certificate.crt>"
        return 1
    fi
    openssl x509 -in "$1" -text -noout
}

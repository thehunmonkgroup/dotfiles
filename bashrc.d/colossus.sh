# Misc aliases.
alias sy="cat ~/sync-status.txt"
alias cdns="sudo killall -HUP mDNSResponder; echo 'DNS cache cleared'"

# lifetolive.one aliases
alias vlog="v ~/Documents/mcg/video-log.otl"
alias writ="v ~/Documents/mcg/writing-ideas.otl"

# Secure access.
alias sec="cd ~/Documents/reference && gocryptfs security.encrypted security && cd security"
alias fin="cd ~/Documents/reference && gocryptfs finance.encrypted security && cd security"

# ChatGPT wrapper.
alias chatgpt="chatgpt --log ~/.local/share/chatgpt-wrapper/logs/$(date +%Y-%m-%d).log"

###############################################################################
# FUNCTIONS
###############################################################################
now() {
  echo "[$(date '+%a, %I:%M%p %Z')]: "
}

fswp() {
  find . -name *.swp
}

kswp() {
  swp_files=`fswp`
  if [ -z "${swp_files}" ]; then
    echo "No .swp files to kill"
  else
    echo "${swp_files}"
    read -r -p "Kill .swp files in `pwd`? [y/N] " response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
      find . -name *.swp -exec rm  {} \;
    else
      echo "Aborted"
    fi
  fi
}

# Man pages in preview.
pman()
{
  man -t "${1}" | open -f -a /Applications/Preview.app/
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

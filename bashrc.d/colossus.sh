# Misc aliases.
alias e="/usr/local/bin/mate"
alias sy="cat ~/sync-status.txt"
alias cdns="sudo killall -HUP mDNSResponder; echo 'DNS cache cleared'"

###############################################################################
# FUNCTIONS
###############################################################################

# Man pages in preview.
pman()
{
  man -t "${1}" | open -f -a /Applications/Preview.app/
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
    svn diff $@ | colordiff;
  else
    svn diff | colordiff;
  fi
}

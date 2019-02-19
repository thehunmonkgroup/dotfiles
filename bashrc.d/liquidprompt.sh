# Only load liquidprompt in interactive shells, not from a script or from scp
if [ -f ${HOME}/liquidprompt/liquidprompt ]; then
  echo $- | grep -q i 2>/dev/null && . ${HOME}/liquidprompt/liquidprompt
else
  echo $- | grep -q i 2>/dev/null && . /usr/share/liquidprompt/liquidprompt
fi


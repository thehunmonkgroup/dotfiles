#!/bin/bash

_tunnel()
{
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  local tunnel_list=$( tunnel list )
  COMPREPLY=($(compgen -W "${tunnel_list}" -- ${cur}))
  return 0
}
complete -F _tunnel tunnel


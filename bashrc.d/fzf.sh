if [ -n "$(command -v brew 2>&1)" ]; then
  FZF_PATH="$(brew --prefix)/opt/fzf"
  FZF_KEYBINDINGS="${FZF_PATH}/shell/completion.bash"
  FZF_COMPLETIONS="${FZF_PATH}/shell/key-bindings.bash"
else
  USR_SHARE_DIR="/usr/share"
  FZF_KEYBINDINGS="${USR_SHARE_DIR}/doc/fzf/examples/key-bindings.bash"
  FZF_COMPLETIONS="${USR_SHARE_DIR}/bash-completion/completions/fzf"
fi

# Check if both fzf completion and key-bindings files exist before proceeding
if [ -f "${FZF_KEYBINDINGS}" ] && [ -f "${FZF_COMPLETIONS}" ]; then
    # shellcheck source=/dev/null
    source "${FZF_KEYBINDINGS}"
    # shellcheck source=/dev/null
    source "${FZF_COMPLETIONS}"

    # Use ripgrep as the default source for fzf
    export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'

    # Apply the command to CTRL-T as well
    export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"

    # Default options without preview
    export FZF_DEFAULT_OPTS="--height 50% --layout=reverse --border"

    # File-specific preview options for commands that work with files
    export FZF_CTRL_T_OPTS="--preview 'batcat --style=numbers --color=always --line-range :500 {}'"

    # Custom path completion for common commands
    _fzf_compgen_path() {
        rg --files --glob "!.git" . "${1}"
    }

    # Directory completion
    _fzf_compgen_dir() {
        fdfind --type d --hidden --follow --exclude ".git" . "${1}"
    }

    # Command-specific preview window configuration for fzf completion
    # - First argument ($1) is the command name being completed
    # - Remaining arguments ($@) must be passed to fzf
    _fzf_comprun() {
      local command="${1}"
      shift
      case "${command}" in
        cd)      fzf "$@" --preview 'tree -C {} | head -200' ;;
        *)       fzf "$@" ;;
      esac
    }

    # Useful keybinding for editor integration
    if [[ "${-}" == *i* ]] && [[ -t 1 ]]; then
        bind -x '"\C-p": ${EDITOR:-vim} $(fzf);'
    fi
fi

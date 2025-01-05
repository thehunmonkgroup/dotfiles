FZF_PATH="$(brew --prefix)/opt/fzf"

# Check if fzf completion file exists before proceeding with any fzf configuration
if [ -f "$FZF_PATH/shell/completion.bash" ]; then
    # Source fzf keybindings and completion from Homebrew installation
    source "$FZF_PATH/shell/key-bindings.bash"
    source "$FZF_PATH/shell/completion.bash"

    # Use ripgrep as the default source for fzf
    export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'

    # Apply the command to CTRL-T as well
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

    # Add preview window
    export FZF_DEFAULT_OPTS="--preview 'batcat --style=numbers --color=always --line-range :500 {}'"

    # Custom path completion for common commands
    _fzf_compgen_path() {
        rg --files --glob "!.git" . "$1"
    }

    # Directory completion
    _fzf_compgen_dir() {
        fdfind --type d --hidden --follow --exclude ".git" . "$1"
    }

    # Useful keybinding for editor integration
    bind -x '"\C-p": ${EDITOR:-vim} $(fzf);'
fi

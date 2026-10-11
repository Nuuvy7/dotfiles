if status is-interactive

    set -g fish_greeting

	fastfetch

	starship init fish | source
end

# Hermes Agent command
fish_add_path "$HOME/.local/bin"
set -gx PATH $HOME/.npm-global/bin $PATH

source /usr/share/cachyos-fish-config/cachyos-config.fish
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
#Enable transience in starship prompt
function starship_transient_promt_func
    starship module character
end

starship init fish | source
enable_transience

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

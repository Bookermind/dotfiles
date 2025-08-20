#Source from conf.d before this fish config
#TODO: Why do they do this?

#Format man pages
set -x MANROFFOPT "-c"
set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"

#Set settings for https://github.com/franciscolourenco/done
set -U __done_min_cmd_duration 10000
set -U __done_notification_urgency_level low

#Environment setup
#Apply .profile
if test -f ~/.fish_profile
    source ~/.fish_profile
end
#Add ~/.local/bin to PATH
if test -d ~/.local/bin
    if not contains -- ~/.local/bin $PATH
        set -p PATH ~/.local/bin
    end
end
#Add depot_tools to PATH
if test -d ~/Applications/depot_tools
    if not contains -- ~/Applications/depot_tools $PATH
        set -p PATH ~/Applications/depot_tools
    end
end
#Functions (not lazy loaded)
#Done
#source ~/.config/fish/conf.d/done.fish
#Plugin bang-bang functions
function __history_previous_command
    switch (commandline -t)
    case "!"
        commandline -t $history[1]; commandline -f repaint
    case "*"
        commandline -i !
    end
end

function __history_previous_command_arguments
    switch (commandline -t)
    case "!"
        commandline -t ""
        commandline -f history-token-search-backward
    case "*"
        commandline -i '$'
    end
end

function fish_greeting
    fastfetch
end

#source /usr/share/cachyos-fish-config/cachyos-config.fish
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
#Enable transience in starship prompt
function starship_transient_promt_func
    starship module character
end

starship init fish | source
enable_transience

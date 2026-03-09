# Nushell Config File
#
# version = "0.100.0"

$env.config = {

    show_banner: false

    table: {
        mode: reinforced
    }

    completions: {
        algorithm: "fuzzy"
    }

    cursor_shape: {
        vi_insert: block
        vi_normal: underscore
        emacs: line
    }

    edit_mode: vi

    keybindings: [
        {
            name: move_up
            modifier: none
            keycode: char_p
            mode: [vi_normal]
            event: {
                until: [
                    { send: menuup }
                    { send: up }
                ]
            }
        }
        {
            name: move_down
            modifier: none
            keycode: char_i
            mode: [vi_normal]
            event: {
                until: [
                    { send: menudown }
                    { send: down }
                ]
            }
        }
        {
            name: move_left
            modifier: none
            keycode: char_u
            mode: [vi_normal]
            event: {
                until: [
                    { send: menuleft }
                    { send: left }
                ]
            }
        }
        {
            name: move_right_or_take_history_hint
            modifier: none
            keycode: char_e
            mode: [vi_normal]
            event: {
                until: [
                    { send: historyhintcomplete }
                    { send: menuright }
                    { send: right }
                ]
            }
        }
        {
            name: move_to_line_start
            modifier: shift
            keycode: char_u
            mode: [vi_normal]
            event: { edit: movetolinestart }
        }
        {
            name: move_to_line_end
            modifier: shift
            keycode: char_e
            mode: [vi_normal]
            event: { edit: movetolineend }
        }
    ]

}

alias ll = eza --long --all --git --no-user --icons --group-directories-first --hyperlink --sort modified --no-permissions 
alias n = nvim
alias pacman-orphans = pacman -Qdtq
alias pacman-paru    = pacman -Qem
alias pacman-ls      = pacman -Qen
def images [] { identify * | from ssv -m 1 -n }

source ~/.config/nushell/sources/mise.nu
source ~/.config/nushell/sources/carapace.nu
source ~/.config/nushell/sources/starship.nu
source ~/.config/nushell/sources/zoxide.nu

use ~/.config/nushell/modules/ *


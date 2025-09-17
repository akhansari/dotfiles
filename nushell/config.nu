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

alias lse = eza -la --group-directories-first --time-style long-iso --git
alias bat = batcat
alias n = nvim
def images [] { identify * | from ssv -m 1 -n }

source ~/.config/carapace/init.nu
source ~/.cache/starship/init.nu
source ~/.cache/zoxide/init.nu
source ~/.cache/mise/init.nu

use ~/.config/nushell/modules/ *
use ~/git-aviv/arch/aviv_architecture/nushell/aviv/ *

# if ($env.ZELLIJ? == null) {
#     if ($env.ZELLIJ_AUTO_ATTACH? == "true") {
#         zellij attach -c
#     } else {
#         zellij
#     }
#     if ($env.ZELLIJ_AUTO_EXIT? == "true") {
#         exit
#     }
# }


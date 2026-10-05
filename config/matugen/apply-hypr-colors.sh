#!/bin/sh
# applique en direct aux bordures hyprland les couleurs que matugen vient d ecrire
# dans ~/.config/hypr/matugen-colors.lua (hyprctl eval = execute du lua dans hyprland).
# lance par le post_hook de matugen. ecrit en sh pour marcher quel que soit le shell
# de l utilisateur (matugen lance ses hooks avec $SHELL, ici nushell).
hyprctl eval 'local t = dofile(os.getenv("HOME") .. "/.config/hypr/matugen-colors.lua"); hl.config({ general = { col = { active_border = { colors = { t.active_border }, angle = 45 }, inactive_border = t.inactive_border } } })' > /dev/null 2>&1

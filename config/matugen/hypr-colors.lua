-- genere par matugen a partir du fond d ecran, ne pas editer a la main
-- modele : config/matugen/hypr-colors.lua dans le repo nixos-config
return {
    active_border = "rgb({{ colors.primary.default.hex_stripped }})",
    inactive_border = "rgb({{ colors.surface_container.default.hex_stripped }})",
}

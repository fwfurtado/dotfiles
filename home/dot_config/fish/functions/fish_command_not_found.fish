# Evita que o fish sonde pkgfile/command-not-found no startup só para decidir
# qual handler usar. Em máquina com exec lento isso custa centenas de ms.
function fish_command_not_found
    __fish_default_command_not_found_handler $argv
end

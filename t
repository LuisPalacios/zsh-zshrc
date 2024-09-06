#!/usr/bin/env zsh
# By LuisPa 2024
# Ejecuto tmux si es que debo/puedo
#
# Referencias:
# - https://www.luispa.com/administraci%C3%B3n/2024/04/25/tmux.html
# - https://www.luispa.com/administraci%C3%B3n/2024/04/23/zsh.html
#
# Ejecución de `tmux` si está disponible (usando `~/.tmux.conf`)
#
# [ -t 1 ]: Comprueba si el file descriptor 1 (stdout) está asociado a un terminal.
# (( $+commands[tmux] )): Comprueba si el ejecutable tmux está en el PATH
# [[ -f ~/.tmux.conf ]]: Compruebo si tengo el fichero  de configuración
# $PPID != 1: Me aseguro que mi proceso padre no es 1, que significaría que esta
# sesión se está ejecutando desde init/systemd.
# $$ != 1: Me aseguro que mi número de proceso no es el 1, que sería un desastre ;-)
# $TERM != dumb, linux, screen, xterm. En esos casos arranco sin tmux, por ejemplo
# me interesa que gnome-terminal y terminator ejecuten tmux, pero xterm no.
# -z $TMUX: Me aseguro de que no esté puesta la variable TMUX, es decir que no este
# ya en una sesión encadenada de tmux
# if (tmux has-session -t TMUX); Si ya hay una sesión ejecutándose me conecto con ella.
# en caso contrario arranco una sesión nueva
#
if [ -t 1 ] && (( $+commands[tmux] )) && \
      [[ -f ~/.tmux.conf && \
               $PPID != 1 && \
               $$ != 1 && \
               $TERM != dumb && \
               $TERM != xterm && \
               $TERM != linux && \
               $TERM != screen* && \
               $IS_VSCODE != true && \
               -z $TMUX ]]; then
    if (tmux has-session -t TMUX >/dev/null 2>&1); then
        exec tmux attach -t TMUX >/dev/null 2>&1
    else
        exec tmux new -s TMUX >/dev/null 2>&1
#        exec tmux new -s TMUX 
   fi
fi

# Fichero .zshrc de LuisPa 2024
# Utilizado en MacOS (con brew), Linux (Ubuntu), Windows WSL2
#
# Referencias:
# - https://www.luispa.com/administraci%C3%B3n/2024/04/25/tmux.html
#
# - https://www.luispa.com/administraci%C3%B3n/2024/04/23/zsh.html
# DEPENDIENCIAS
#   1) Script .zshrc.async
#      Lo descargo automáticamente desde https://github.com/LuisPalacios/zsh-async
#      se trata de un FORK del proyecto https://github.com/mafredri/zsh-async
#      Se trata de una librería de apoyo para ejecutar código en modo asíncrono
#
# Creditos:
#   1) Ideas y más en "My .zshrc" -> https://github.com/vincentbernat/zshrc
#
# Probado en:
#   linux, normal user and root - OK
#   MacOS normal user - OK
#   MacOS root - usa una versión especial de bash que consume /root.lprofile
#
# Activar para debug
#set -x

# In bash escape-delete deletes a single word. However in ZSH a variable defines which
# special characters are considered part of a word. By default its value is
# WORDCHARS='*?_-.[]~=/&;!#$%^(){}<>'
# In order to behave similar to bash, I'm modifying it, in example removing '/' so
# its more convenient when deleting directory componentes while in the CLI.
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

# Elimino el mensaje "Last login" en las sesiones y nuevos tabs.
[ ! -f ~/.hushlogin ] && touch ~/.hushlogin

# Si estoy en un MacOS necesito actualizar el PATH con homebrew
if [[ "$(uname)" == "Darwin" ]]; then whence -p brew &>/dev/null || eval "$(/opt/homebrew/bin/brew shellenv)"; fi

# IMPORTANTE:
# Descargo una librería de apoyo para ejecutar ciertas partes de estes cript en modo asíncrono
if [[ ! -a ~/.zshrc.async ]]; then
  curl -LJs -o ~/.zshrc.async https://raw.githubusercontent.com/LuisPalacios/zsh-zshrc/main/.zshrc.async
fi

# Detectar si estoy dentro de una sesión VSCODE
# De momento todavía no hago nada con esta info.
export IS_VSCODE=false
if [[ $(printenv | grep -c "VSCODE_") -gt 0 ]]; then
    export IS_VSCODE=true
fi

# Detectar si estoy dentro de una sesión WSL2
# De momento todavía no hago nada con esta info.
export IS_WSL2=false
# Verificar si wslinfo --wsl-version existe y retorna 0
if wslinfo --wsl-version > /dev/null 2>&1; then
  export IS_WSL2=true
fi

# Ejecución de `tmux` (si está disponible y además existe ~/.tmux.conf)
#
# Esto podría haberlo configurado de dos formas. Cuando hago login con mi
# usuario y arranza zsh. He optado por la opcion (2)
#
# 1) REEMPLAZA zsh por tmux - Que zsh arranque pero inmediatamente sea
#    reemplazada por tmux
# 2) MANTENER zsh - Que zsh arranque y me quede en él, para arrancar tmux
#    manualmente cuando yo quiera.
#
# OPCION 1) REEMPLAZAR
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
# (Copia del script "t" en el PATH)
# ------- ------- ------- ------- ------- -------
# #!/usr/bin/env zsh
# #By LuisPa 2024
# #Ejecuto tmux si es que debo/puedo
# if [ -t 1 ] && (( $+commands[tmux] )) && \
#       [[ -f ~/.tmux.conf && \
#                $PPID != 1 && \
#                $$ != 1 && \
#                $TERM != dumb && \
#                $TERM != xterm && \
#                $TERM != linux && \
#                $TERM != screen* && \
#                $IS_VSCODE != true && \
#                -z $TMUX ]]; then
#     if (tmux has-session -t TMUX >/dev/null 2>&1); then
#         exec tmux attach -t TMUX >/dev/null 2>&1
#     else
#         exec tmux new -s TMUX >/dev/null 2>&1
#    fi
# fi
# ------- ------- ------- ------- ------- -------
#
# OPCION 2) MANTENER
# Como decía, podría haber dejado las líneas anteriores sin comentar que
# provocarían que se ejecute tmux reemplazando la shell actual.
# He optado por dejarlas comentadas y si necesito tmux lo ejecuto
# llamando al alias 't' (con exec) o 'tt' (sin exec).
#
# Esta opción me da más flexibilidad, puedo elegir cuándo uso
# tmux, lo cual es muy útil si me conecto a equipos linux remotos
# que tienen zsh y tmux (y copia de este .zshrc, .tmux.conf, etc)
alias t="exec ~/Nextcloud/priv/bin/t"
alias tt="~/Nextcloud/priv/bin/t"

# Detecto e inicializo el valor de la variable SHELL
#
# Si mi $SHELL acaba en */zsh o */zsh-static, no hago nada.
# En caso contrario, hago una sustitución compleja de la variable SHELL, poniendo
# el PATH absoluto de la shell
[[ -o interactive ]] && \
   case $SHELL in
      */zsh) ;;
      */zsh-static) ;;
      *) SHELL=${${0#-}:c:A}
   esac

# Para debug
#NORMAL="\033[0;39m"
#ROJO="\033[1;31m"
#VERDE="\033[1;32m"
#AMARILLO="\033[1;33m"
#AZUL="\033[1;34m"

# Personalización de los colores del tree de GNU
export TREE_COLORS=${LS_COLORS//04;}

# Personalización de los colores del comando 'ls'
# LS_COLORS se usan en ls de GNU,
export LS_COLORS='fi=00:mi=00:mh=00:ln=01;94:or=01;31:di=01;36:ow=04;01;34:st=34:tw=04;34:'
LS_COLORS+='pi=01;33:so=01;33:do=01;33:bd=01;33:cd=01;33:su=01;35:sg=01;35:ca=01;35:ex=01;32'
LS_COLORS+=':*.cmd=00;32:*.exe=01;32:*.com=01;32:*.bat=01;32:*.btm=01;32:*.dll=01;32'
LS_COLORS+=':*.tar=00;31:*.tbz=00;31:*.tgz=00;31:*.rpm=00;31:*.deb=00;31:*.arj=00;31'
LS_COLORS+=':*.taz=00;31:*.lzh=00;31:*.lzma=00;31:*.zip=00;31:*.zoo=00;31:*.z=00;31'
LS_COLORS+=':*.Z=00;31:*.gz=00;31:*.bz2=00;31:*.tb2=00;31:*.tz2=00;31:*.tbz2=00;31'
LS_COLORS+=':*.avi=01;35:*.bmp=01;35:*.fli=01;35:*.gif=01;35:*.jpg=01;35:*.jpeg=01;35'
LS_COLORS+=':*.mng=01;35:*.mov=01;35:*.mpg=01;35:*.pcx=01;35:*.pbm=01;35:*.pgm=01;35'
LS_COLORS+=':*.png=01;35:*.ppm=01;35:*.tga=01;35:*.tif=01;35:*.xbm=01;35:*.xpm=01;35'
LS_COLORS+=':*.dl=01;35:*.gl=01;35:*.wmv=01;35'
# mientras que LSCOLORS se usa en el ls de BSD
export CLICOLOR=1
export LSCOLORS='GxExDxDxCxDxDxFxFxexEx'

# No poner líneas de comando en la lista de historial si son duplicados
setopt HIST_IGNORE_DUPS
# Comparte el historial entre todas las instancias
setopt SHARE_HISTORY
# Que no pida Y/N cuando se hace un rm -fr
setopt RM_STAR_SILENT
# Habilitar expansión de parñametros en el prompt, necesario para
# mostrar información de branches de Git por ejemplo.
setopt PROMPT_SUBST

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"

# Permitir ganchos en diferentes puntos de la ejecución del shell,
# como antes o después de un comando, permitiendo a los usuarios o scripts
# añadir comportamientos personalizados en estos puntos.
autoload -Uz add-zsh-hook

# Async helpers
#
_vbe_vcs_async_start() {
    async_start_worker vcs_info
    async_register_callback vcs_info _vbe_vcs_info_done
}
_vbe_vcs_info() {
    cd -q $1
    vcs_info
    print ${vcs_info_msg_0_}
}
_vbe_vcs_info_done() {
    local job=$1
    local return_code=$2
    local stdout=$3
    local more=$6
    if [[ $job == '[async]' ]]; then
        if [[ $return_code -eq 2 ]]; then
            # Need to restart the worker. Stolen from
            # https://github.com/mengelbrecht/slimline/blob/master/lib/async.zsh
            _vbe_vcs_async_start
            return
        fi
    fi
    vcs_info_msg_0_=$stdout
    (( $more )) || zle reset-prompt
}
_vbe_vcs_chpwd() {
    vcs_info_msg_0_=
}
_vbe_vcs_precmd() {
    async_flush_jobs vcs_info
    async_job vcs_info _vbe_vcs_info $PWD
}

# PROMPT con vcs_info
#
# 1. Habilito vcs_info y prompt_subst
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:*+*:*' debug false
#setopt prompt_subst # Enable prompt substitution

# 2. Estados y variables, 5 posibles estados:
# Ver https://github.com/zsh-users/zsh/blob/master/Functions/VCS_Info/Backends/VCS_INFO_get_data_git
# lp_gituntracked  - true si hay algo en la WORKING area PENDIENTE DE STAGING (add) - COLOR BLUE
# gitstaged - de vcs_info, true si hay contenido en la staging area PENDIENTE DE COMMIT - COLOR GREEN
# gitunstaged - de vcs_info, true si se modificó en working y está PENDIENTE DE STAGING (add) - COLOR ROJO
# lp_gitunpushed - true si hay contenido PENDIENTE DE PUSH al origin - COLOR YELLOW/ORANGE
# Resto ... si todas las demas son falsas - COLOR BLANCO
lp_gituntrackedstr='%{%F{blue}%B%}●%{%b%f%}'
zstyle ':vcs_info:*' stagedstr '%{%F{green}%B%}●%{%b%f%}' # '+' # ver gitstaged, hay contenido en la staging area PENDIENTE DE COMMIT
zstyle ':vcs_info:*' unstagedstr '%{%F{red}%B%}●%{%b%f%}' # 'U' # ver gitunstaged, se modificó en working y está PENDIENTE DE STAGING
lp_gitunpushedstr='%{%F{yellow}%B%}●%{%b%f%}'

# 3. Preparo "formats" de la información vcs_info
#
# General Placeholders
# %b: Displays the current branch name.
# %c: Shows the number of changes that have been staged (added to the index) but not yet committed.
# %u: Indicates the number of unstaged changes.
# %r: Represents the name of the repository.
# %R: Provides the root directory of the repository.
# %s: The name of the VCS system in use (e.g., git, svn).
# %S: Shorthand for the VCS system name.
# %m: Displays the name of the current VCS action or mode (like REBASE, MERGE).
# %a: Shows the number of commits your repository is ahead of the tracked remote branch.
# %d: Indicates if there are any 'dirty' files (modified files).
# %i: Custom information that can be defined by specific vcs_info hooks or extensions.
# %I: Similar to %i but intended for more compact or alternate displays.
# %p: Shows the current patch or revision number.
# %P: Similar to %p but tailored for shorter displays.
# %n: Indicates the number of patches or revisions applied from a series.
# %N: A compact version of %n.
# %x: Used to display a user-defined message or data, often set in hooks.
# %X: Similar to %x but intended for alternate or additional user-defined data.
# %z: Typically used to show the state of a repository, such as whether it's in a bisect state.
# %Z: Can be used for a more detailed description of the repository state.
#
# Formatting and Conditional Modifiers
# %F{color} and %f: These are used to set the foreground color. %F{color} starts the color display, where color can be a name like red, green, blue, etc., or a numeric color code. %f resets the foreground color to the default terminal color.
# %K{color} and %k: Similar to %F and %f, but for the background color. %K{color} starts the background color, and %k resets it.
# %B and %b: Turn bold text on and off, respectively. %B enables bold formatting, and %b disables it.
# %U and %u: Control underline formatting. %U turns on underlining, and %u turns it off.
# %{...%}: Used to include literal escape sequences or to apply formatting codes
#          that do not consume physical space on the terminal. This is critical for color
#          codes or cursor movements that should not affect the width calculations of your prompt.
#
# Conditional modifiers
# %(!.primary.secondary): Displays primary if the shell is running with privileges (e.g., root user), and secondary otherwise. Useful for changing prompt elements based on user privileges.
# %(x.true.false): A conditional format that evaluates x (a shell parameter or state) and displays true if x is non-zero or non-empty, and false otherwise.
#
# Truncation and Padding
# ?
#
#zstyle ':vcs_info:*' formats " %F{cyan}%c%u(%b)%f" # formato del prompt cuando se está dentro de un repositorio
#zstyle ':vcs_info:*' formats ' (%b)-%u-%c-'
zstyle ':vcs_info:*' formats ' (%u%c%b%%b%f'

# 4. Preparo "actionformats" (NO PROBADO)
zstyle ':vcs_info:*' actionformats "A %F{cyan}%c%u(%b)%f %a" # Similar al anterior pero para acciones específicas (por ejemplo, durante un rebase)

# 5. Programar hooks
zstyle ':vcs_info:git*+set-message:*' hooks git-check-status
zstyle ':vcs_info:*+set-message:*' hooks home-path
function +vi-home-path() {
  # Replace $HOME with ~
  hook_com[base]="$(echo ${hook_com[base]} | sed "s/${HOME:gs/\//\\\//}/~/" )"
}
function __git_symbols() {
	# Symbols
	local ahead='↑'         # '↑' '�'
	local behind='↓'        # '↓' '�'
	local diverged='↕'      # '↕' '♦️' '�'
	#local up_to_date='|'    # '|' '✅'
	local no_remote='o'     # 'o' '⭕'
	local staged='+'        # '+' '�'
	local untracked='?'     # '?' '❓'
	local modified='!'      # '!' '❗'
	local moved='>'          # '>' '➡️'
	local deleted='x'       # 'x' '❌'
	local stashed='$'       # '$' '�'

	local output_symbols=''

	local git_status_v
	git_status_v="$(git status --porcelain=v2 --branch --show-stash 2>/dev/null)"

	# Parse de la información del branch
  local ahead_count behind_count

	# AHEAD, BEHIND, DIVERGED
	if echo $git_status_v | grep -q "^# branch.ab " ; then
		# One line of the git status output looks like this:
		# # branch.ab +1 -2
		# In the line below:
		# - we grep for the line starting with # branch.ab
		# - we grep for the numbers and output them on separate lines
		# - we remove the + and - signs
		# - we put the two numbers into variables, while telling read to use a newline as the delimiter for reading
		read -d "\n" -r ahead_count behind_count <<< $(echo "$git_status_v" | grep "^# branch.ab" | grep -o -E '[+-][0-9]+' | sed 's/[-+]//')
		# Show the ahead and behind symbols when relevant
		[[ $ahead_count != 0 ]] && output_symbols+="$ahead"
		[[ $behind_count != 0 ]] && output_symbols+="$behind"
		# Replace the ahead symbol with the diverged symbol when both ahead and behind
		output_symbols="${output_symbols//$ahead$behind/$diverged}"

		# If the branch is up to date, show the up to date symbol
		#[[ $ahead_count == 0 && $behind_count == 0 ]] && output_symbols+="$up_to_date"
	fi

	# STASHED
	echo $git_status_v | grep -q "^# stash " && output_symbols+="$stashed"

	# STAGED
	[[ $(git diff --name-only --cached) ]] && output_symbols+="$staged"

	# For the rest of the symbols, we use the v1 format of git status because it's easier to parse.
	local git_status

	symbols="$(git status --porcelain=v1 | cut -c1-2 | sed 's/ //g')"

	while IFS= read -r symbol; do
		case $symbol in
			??) output_symbols+="$untracked";;
			M) output_symbols+="$modified";;
			R) output_symbols+="$moved";;
			D) output_symbols+="$deleted";;
		esac
	done <<< "$symbols"

	# Remove duplicate symbols
	output_symbols="$(echo -n "$output_symbols" | tr -s "$untracked$modified$moved$deleted")"

	[[ -n $output_symbols ]] && echo -n "$output_symbols"
}
# Function to display Git status with symbols
function __git_info() {
	local git_info=''
	local git_branch_name=''

	if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
		# Get the Git branch name
		#git_branch_name="$(git symbolic-ref --short HEAD 2>/dev/null)"
		#if [[ -n "$git_branch_name" ]]; then
	  #  git_info+="$git_branch_name"
		#fi
		# Get the Git status
		git_info+="$(__git_symbols)"
    if [[ "$git_info" != "" ]]; then
      echo " $git_info)"
    else
      echo ")"
    fi
	fi
}

# Función para ver el estado de mi rama git
+vi-git-check-status(){

  # Check pending push, when we are ahead of remote.
  if [[ "$(git rev-parse --quiet --verify HEAD 2> /dev/null)" && \
        "$(git status --branch --short | head -n1 | grep ahead 2> /dev/null)" ]]; then
      lp_gitunpushed=1
      hook_com[staged]+=${lp_gitunpushedstr}
  else
      lp_gitunpushed=
  fi

  # Check untracked, when we untracked (not added) files or directories in our working area
  if [[ ( "$(git rev-parse --is-inside-work-tree 2> /dev/null)" == "true" && \
        "$(git status --porcelain 2> /dev/null | grep -q '^?? ')" != "" ) || \
      "$(git ls-files --other --exclude-standard 2> /dev/null | wc -l | tr -d ' ')" -gt 0 ]]; then
      lp_gituntracked=1
      hook_com[unstaged]="${lp_gituntrackedstr}${hook_com[unstaged]}"
  else
      hook_com[untracked]=''
      lp_gituntracked=
  fi

  ##  echo "Debug ---"
  #[[ ${querystaged} -eq 0 ]] && { echo "Querystaged: X";:; } || { echo "querystaged: ${AMARILLO}yes${NORMAL}" ; }
  #[[ ${git_patches_applied} -eq 0 ]] && { echo "git_patches_applied: X";:; } || { echo "git_patches_applied: ${AMARILLO}yes${NORMAL}" ; }
  #[[ ${git_patches_unapplied} -eq 0 ]] && { echo "git_patches_unapplied: X";:; } || { echo "git_patches_unapplied: ${AMARILLO}yes${NORMAL}" ; }
  #[[ ${gitaction} -eq 0 ]] && { echo "gitaction: X";:; } || { echo "gitaction: ${AMARILLO}yes${NORMAL}" ; }
  #[[ ${gitmisc} -eq 0 ]] && { echo "gitmisc: X";:; } || { echo "gitmisc: ${AMARILLO}yes${NORMAL}" ; }
  #[[ ${gitsha1} -eq 0 ]] && { echo "gitsha1: X";:; } || { echo "gitsha1: ${AMARILLO}yes${NORMAL}" ; }
  #[[ ${lp_gituntracked} -eq 0 ]] && { echo "Untracked: X";:; } || { echo "Untracked: ${AZUL}●${NORMAL}" ; }
  #[[ ${gitunstaged} -eq 0 ]] && { echo "Unstaged: X";:; } || { echo "Unstaged: ${ROJO}●${NORMAL}" ; }
  #[[ ${gitstaged} -eq 0 ]] && { echo "Staged: X";:; } || { echo "Staged: ${VERDE}●${NORMAL}" ; }
  #[[ ${lp_gituntracked} -eq 0 ]] && { echo "Untracked: X";:; } || { echo "Untracked: ${AZUL}●${NORMAL}" ; }
  #echo "----"

  # Precolor
  if [[ ${lp_gitunpushed} -ne 0 ]]; then
    hook_com[staged]+="%B%F{yellow} "
  elif [[ ${gitunstaged} -ne 0 ]]; then
    hook_com[staged]+="%B%F{red} "
  elif [[ ${gitstaged} -ne 0 ]]; then
    hook_com[staged]+="%B%F{green} "
  elif [[ ${lp_gituntracked} -ne 0 ]]; then
    hook_com[staged]+="%B%F{cyan} "
  fi

}

# Asynchronous VCS status
if [ "$IS_WSL2" = false ] ; then
  # Solo si no estoy en WSL2
  source ~/.zshrc.async
  async_init
  _vbe_vcs_async_start
  add-zsh-hook precmd _vbe_vcs_precmd
  add-zsh-hook chpwd _vbe_vcs_chpwd
fi

# Add VCS information to the prompt
_vbe_add_prompt_0vcs () {
    _vbe_prompt_segment cyan default ${vcs_info_msg_0_}
}

# Parámetros para la construcción del prompt
#
# Basic Components of Format Strings
# %b: Branch name. Displays the name of the current branch.
# %c: Number of commits ahead of remote.
# %u: Number of commits behind remote.
# %a: Action. This shows the current action, like 'MERGING', 'REBASING', etc.
# %r: Repository name. This is useful when working in a repo that's nested inside another.
# %R: Root directory of the repository. This shows the path to the top level of the repository.
# %s: Stash. This shows the number of stashes.
# %m: Whether the repo is "modified."
# %i: Information on whether there are staged changes.
# %I: More detailed information on the index state (staged changes).
# %n: Name of the repository if set.
#
# Use of Formatting Codes
# %F{color}: Sets the foreground color of the subsequent text (until %f or another %F is encountered). For example, %F{red} makes the text red.
# %f: Resets the foreground color to the default.
# %B: Start bold text.
# %b: Stop bold text.
# %U: Start underlined text.
# %u: Stop underlined text.
#

# Parse de Git mucho mas simplificado que usaré en entorno WSL2 que es más lento
#   local branch="$(git symbolic-ref --short HEAD 2>/dev/null)"
#    if [ -n "$branch" ]; then
# simple_parse_git_branch() {
#     # Verificar si hay cambios no confirmados
#     if ! git diff --quiet 2>/dev/null; then
#       echo " ($branch %F{red}●%f)"  # Cambios no confirmados
#     else
#       # Verificar si hay commits para hacer push
#       if [ $(git rev-list @{u}..HEAD 2>/dev/null | wc -l) -gt 0 ]; then
#         echo " ($branch %F{red}●%f)"  # Commits por hacer push
#       else
#         # Verificar si hay commits para hacer pull
#         if [ $(git rev-list HEAD..@{u} 2>/dev/null | wc -l) -gt 0 ]; then
#           echo " ($branch %F{red}●%f)"  # Commits por hacer pull
#         else
#           # Si no hay estado especial, agregar un ícono de check
#           echo " ($branch %F{green}✓%f)"
#         fi
#       fi
#     fi
#   else
#     echo ""
#   fi
# }

# Declarar y definir variables globales para el estado de git
export GIT_PROMPT_CACHE=""
GIT_PROMPT_LAST_UPDATE=0
LAST_GIT_DIR=""

wsl2_parse_git_branch_cached() {
  local branch="$(git symbolic-ref --short HEAD 2>/dev/null)"
  if [ -n "$branch" ]; then
    # Comprobar si es necesario actualizar el estado de git
    if [[ -z "$GIT_PROMPT_CACHE" || "$PWD" != "$LAST_GIT_DIR" || $(( $(date +%s) - GIT_PROMPT_LAST_UPDATE )) -ge 5 ]]; then
      LAST_GIT_DIR="$PWD"
      GIT_PROMPT_LAST_UPDATE=$(date +%s)
      # Verificar si hay cambios no confirmados
      if ! git diff --quiet 2>/dev/null; then
        GIT_PROMPT_CACHE=" ($branch %F{red}●%f)"  # Cambios no confirmados
      else
        # Verificar si hay commits para hacer push
        if [ $(git rev-list @{u}..HEAD 2>/dev/null | wc -l) -gt 0 ]; then
          GIT_PROMPT_CACHE=" ($branch %F{red}●%f)"  # Commits por hacer push
        else
          # Verificar si hay commits para hacer pull
          if [ $(git rev-list HEAD..@{u} 2>/dev/null | wc -l) -gt 0 ]; then
            GIT_PROMPT_CACHE=" ($branch %F{red}●%f)"  # Commits por hacer pull
          else
            # Si no hay estado especial, agregar un ícono de check
            GIT_PROMPT_CACHE=" ($branch %F{green}✓%f)"
          fi
        fi
      fi
    fi
  fi
}
precmd() {
  # Actualizar el estado de git en segundo plano
  wsl2_parse_git_branch_cached
}

# simple_parse_git_branch() {
#   # Obtener la rama actual, si existe
#   local branch
#   branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return

#   # Usar 'git status' para hacer una única llamada en lugar de varias llamadas a git
#   local git_status
#   git_status=$(git status --porcelain --branch 2>/dev/null)

#   if [[ $git_status == *"ahead"* ]] || [[ $git_status == *"behind"* ]] || [[ $git_status == *"?? "* ]] || [[ $git_status == *" M "* ]]; then
#     echo " ($branch %F{red}●%f)"
#   else
#     echo " ($branch %F{green}✓%f)"
#   fi
# }

# simple_parse_git_branch_cached() {
#   if [[ -z "$GIT_PROMPT_CACHE" || "$PWD" != "$LAST_GIT_DIR" || $(( $(date +%s) - $GIT_PROMPT_LAST_UPDATE )) -ge 5 ]]; then
#   echo x
#     LAST_GIT_DIR="$PWD"
#     GIT_PROMPT_LAST_UPDATE=$(date +%s)

#     local branch
#     branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return

#     local git_status
#     git_status=$(git status --porcelain --branch 2>/dev/null)

#     if [[ $git_status == *"ahead"* ]] || [[ $git_status == *"behind"* ]] || [[ $git_status == *"?? "* ]] || [[ $git_status == *" M "* ]]; then
#       GIT_PROMPT_CACHE=" ($branch %F{red}●%f)"
#     else
#       GIT_PROMPT_CACHE=" ($branch %F{green}✓%f)"
#     fi
#   fi

#   echo "$GIT_PROMPT_CACHE"
# }

# Parametrizo según OS
#
# Función para averiguar la opción de usar colores en el comando ls
function test-ls-args {
  local cmd="$1"          # ls, gls, colorls, ...
  local args="${@[2,-1]}" # los argumentos excepto el primero
  command "$cmd" "$args" /dev/null &>/dev/null
}

# Parametrizaciones según el OS
case "$OSTYPE" in

  # NetBSD
  netbsd*)
    # On NetBSD, test if `gls` (GNU ls) is installed (this one supports colors);
    # otherwise, leave ls as is, because NetBSD's ls doesn't support -G
    test-ls-args gls --color && alias ls='gls --color=tty'
    ;;

  # OpenBSD
  openbsd*)
    # On OpenBSD, `gls` (ls from GNU coreutils) and `colorls` (ls from base,
    # with color and multibyte support) are available from ports.
    # `colorls` will be installed on purpose and can't be pulled in by installing
    # coreutils (which might be installed for ), so prefer it to `gls`.
    test-ls-args gls --color && alias ls='gls --color=tty'
    test-ls-args colorls -G && alias ls='colorls -G'
    ;;

  # MacOS
  (darwin|freebsd)*)
    # This alias works by default just using $LSCOLORS
    test-ls-args ls -G && alias ls='ls -G'
    # Only use GNU ls if installed and there are user defaults for $LS_COLORS,
    # as the default coloring scheme is not very pretty
    zstyle -t ':omz:lib:theme-and-appearance' gnu-ls \
      && test-ls-args gls --color \
      && alias ls='gls --color=tty'

    # Deshabilito FLOW CONTROL en mi terminal para que CTRL-S, CTRL-Q funcionen normales
    stty -ixon

    # Mi PROMPT
    PROMPT='🍏 %F{green}%B%n%b@%F{yellow}%m%f:%B%F{cyan}%1~%f%b${vcs_info_msg_0_}$(__git_info) %# '

    # PATH
    export PATH=.:$HOME/Nextcloud/priv/bin:/usr/local/bin:/usr/local/sbin:/usr/local/go/bin:$PATH
    launchctl setenv PATH ".:$HOME/Nextcloud/priv/bin:/usr/local/bin:/usr/local/sbin:/usr/local/go/bin:$PATH"

    # Homebrew
    eval "$(/opt/homebrew/bin/brew shellenv)"                                          # Homebrew en Mac ARM
    #eval "$(/usr/local/bin/brew shellenv)"                                            # Homebrew en Mac Intel
    # Ruby y Gems
    export PATH="/opt/homebrew/opt/ruby/bin:~/.gems/bin:$PATH"   # Versión para Mac ARM
    #export PATH="/usr/local/opt/ruby/bin:~/.gems/bin:$PATH"     # Versión para Mac Intel

    # Utilizo CLANG 17 y lo he instalado vía Homebrew
    export PATH="/opt/homebrew/opt/llvm@17/bin:$PATH"
    export CPLUS_INCLUDE_PATH="/opt/homebrew/opt/llvm@17/include"
    export LIBRARY_PATH="/opt/homebrew/opt/llvm@17/lib"
    export CC="/opt/homebrew/opt/llvm@17/bin/clang"
    export CXX="/opt/homebrew/opt/llvm@17/bin/clang++"
    export LDFLAGS="-L/opt/homebrew/opt/llvm@17/lib"
    export CPPFLAGS="-I/opt/homebrew/opt/llvm@17/include"

    # ALIAS
    alias grep="/usr/bin/grep -d skip"
    alias e="/usr/local/bin/code"
    alias python="/opt/homebrew/bin/python3"
    alias pip="/opt/homebrew/bin/pip3"

    # Acelerar la navegación en recursos compartidos de red
    (defaults write com.apple.desktopservices DSDontWriteNetworkStores true &)

    # SSH - Lo arranco en el background porque tarda 1 o 2 segundos
    # De esta forma consigo el prompt inmediatamente.
    (ssh-add --apple-load-keychain >/dev/null 2>&1 &)

    ;;
  # Linux
  *)
    if test-ls-args ls --color; then
      alias ls='ls --color=tty'
    elif test-ls-args ls -G; then
      alias ls='ls -G'
    fi
    alias python="/usr/bin/python3"

    # Mi PROMPT
    if [[ $EUID -eq 0 ]]; then
      # En el caso de ser root
      PROMPT='[%B%F{white}root%f%b]@%m:%~%# '
    else
      if [ "$IS_WSL2" = true ] ; then

        # Al estar bajo WSL2 uso un prompt simplificado (mucho más rápido)
        PROMPT='⚡ %F{green}%B%n%b@%m%f:%B%F{cyan}%1~%f%b${GIT_PROMPT_CACHE} %# '
      else
        # Mi usuario normal con Git info en el prompt muy detallado
        PROMPT='⚡ %F{green}%B%n%b@%m%f:%B%F{cyan}%1~%f%b${vcs_info_msg_0_}$(__git_info) %# '
      fi
    fi

    # PATH
    export PATH=.:$HOME/Nextcloud/priv/bin:/usr/local/bin:/usr/local/sbin:/usr/local/go/bin:$PATH

    ;;
esac

# Las "gems" de Ruby se instalarán en ~/.gems
export GEM_HOME=~/.gems
export PATH=~/.gems/bin:$PATH

# Locales
export LANG=es_ES.UTF-8
export LC_CTYPE="es_ES.UTF-8"
export LC_NUMERIC="es_ES.UTF-8"
export LC_TIME="es_ES.UTF-8"
export LC_COLLATE="es_ES.UTF-8"
export LC_MONETARY="es_ES.UTF-8"
export LC_MESSAGES="es_ES.UTF-8"
export LC_PAPER="es_ES.UTF-8"
export LC_NAME="es_ES.UTF-8"
export LC_ADDRESS="es_ES.UTF-8"
export LC_TELEPHONE="es_ES.UTF-8"
export LC_MEASUREMENT="es_ES.UTF-8"
export LC_IDENTIFICATION="es_ES.UTF-8"
export LC_ALL="es_ES.UTF-8"



# *NEW* Implemento Starship para el prompt
# ==============================================================================
if which starship >/dev/null 2>&1; then
  #echo "El ejecutable existe"
  # Variables
  LOCAL_FILE=~/.config/starship.toml
  REMOTE_FILE_URL="https://raw.githubusercontent.com/LuisPalacios/zsh-zshrc/main/starship.toml"
  TEMP_REMOTE_FILE=/tmp/starship_remote.toml

  # Detectar el sistema operativo para usar el comando 'date' correcto
  case "$OSTYPE" in
    # MacOS
    (darwin|freebsd)*)
      ONE_DAY_AGO=$(date -v -1d +%s)
      ;;
    # Linux
    *)
      ONE_DAY_AGO=$(date -d '1 day ago' +%s)
      ;;
  esac

  # Comprobar si el archivo local no existe
  if [[ ! -a $LOCAL_FILE ]]; then
    #echo "El fichero local no existe. Descargando..."
    mkdir -p ~/.config
    curl --connect-timeout 2 --max-time 3 -LJs -o $LOCAL_FILE $REMOTE_FILE_URL
    touch $LOCAL_FILE
  else
    # Verificar si se ha descargado en el último día
    if [[ $(stat -c %Y $LOCAL_FILE 2>/dev/null || stat -f %m $LOCAL_FILE) -le $ONE_DAY_AGO ]]; then
      #echo "Más de un día desde la última verificación. Comprobando cambios..."
      # Descargar el archivo remoto temporalmente
      curl --connect-timeout 2 --max-time 3 -LJs -o $TEMP_REMOTE_FILE $REMOTE_FILE_URL

      # Comprobar si el archivo local es diferente del remoto
      if ! cmp -s $LOCAL_FILE $TEMP_REMOTE_FILE; then
        #echo "El fichero local es diferente. Actualizando..."
        mv $TEMP_REMOTE_FILE $LOCAL_FILE
      else
        #echo "El fichero local está actualizado."
        rm $TEMP_REMOTE_FILE
      fi

      # Actualizar la marca de tiempo del archivo de verificación
      touch $LOCAL_FILE
    #else
      #echo "La comprobación se hizo en la último día. No es necesario descargar."
    fi
  fi

  # Integro startship en mi shell
  eval "$(starship init zsh)"
fi
# ==============================================================================

# LuisPa: -------------------------------------------------------------- END

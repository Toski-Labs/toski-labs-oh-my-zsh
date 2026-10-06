# Toski — tema para Oh My Zsh, com as cores da Toski Labs.
# https://github.com/Toski-Labs/toski-labs-oh-my-zsh
#
#   ~/Docs/toskilabs/web on  main ⇡1 +2 !1 ?3 ··········  took  12s  at  14:37:39
#  🐾
#
# Opções: defina antes da linha `source $ZSH/oh-my-zsh.sh` no ~/.zshrc. Veja o README.

setopt prompt_subst
zmodload zsh/datetime 2>/dev/null
autoload -Uz add-zsh-hook

# ─── Opções ──────────────────────────────────────────────────────────────────

: ${TOSKI_COLORS:=auto}          # auto | ds | ansi
: ${TOSKI_MODE:=auto}            # auto | dark | light  (só vale para as cores do DS)
: ${TOSKI_ICONS:=true}           # ícones Nerd Font
: ${TOSKI_PROMPT_CHAR:=🐾}
: ${TOSKI_PROMPT_CHAR_ERROR:=}   # vazio = igual ao TOSKI_PROMPT_CHAR
: ${TOSKI_ADD_NEWLINE:=true}      # linha em branco entre um comando e o próximo prompt
: ${TOSKI_FILL_CHAR:=·}
: ${TOSKI_DIR_TRUNCATE:=0}       # 0 = caminho inteiro; 3 = só as 3 últimas pastas
: ${TOSKI_EXEC_TIME_MIN:=2}      # segundos
: ${TOSKI_TIME_FORMAT:=%H:%M:%S}
: ${TOSKI_SHOW_TIME:=true}
: ${TOSKI_SHOW_EXIT_CODE:=true}
: ${TOSKI_SHOW_NODE:=false}

# ─── Cores ───────────────────────────────────────────────────────────────────
# Mesmas cores do Toski DS e dos temas Toski para iTerm2 e VS Code.

typeset -gA _toski_ansi=(
  dir 3      muted 8   fill 8
  branch 5   staged 2  modified 1  untracked 6  sync 4  stash 8  conflict 9  action 11
  took 3     time 8    ok 3        error 1
  user 4     root 1    node 2      jobs 6
)
typeset -gA _toski_dark=(
  dir '#DB9A5B'    muted '#C2AE98'   fill '#43352B'
  branch '#CDA6D0' staged '#9CC48F'  modified '#F09A78'  untracked '#8CC7BA'
  sync '#8FB8C9'   stash '#A08B78'   conflict '#F09A78'  action '#E8C26B'
  took '#E8C26B'   time '#A08B78'    ok '#DB9A5B'        error '#F09A78'
  user '#8FB8C9'   root '#F09A78'    node '#A9C98F'      jobs '#8CC7BA'
)
typeset -gA _toski_light=(
  dir '#A9541F'    muted '#6B5648'   fill '#E6D8C4'
  branch '#7A4E8C' staged '#3F6E3B'  modified '#A3341A'  untracked '#2E7468'
  sync '#2F6185'   stash '#7D6858'   conflict '#A3341A'  action '#8A6A00'
  took '#8A6A00'   time '#7D6858'    ok '#A9541F'        error '#A3341A'
  user '#2F6185'   root '#A3341A'    node '#3F6E3B'      jobs '#2E7468'
)

typeset -gA _toski_color _toski_f
typeset -g _toski_mode_checked=0 _toski_mode_cache=dark

_toski_resolve_mode() {
  [[ $TOSKI_MODE != auto ]] && { REPLY=$TOSKI_MODE; return }
  # Consulta o modo do macOS no máximo a cada 5 s (o `defaults` é lento).
  if (( EPOCHSECONDS - _toski_mode_checked >= 5 )); then
    _toski_mode_checked=$EPOCHSECONDS
    if [[ $OSTYPE == darwin* ]]; then
      [[ $(defaults read -g AppleInterfaceStyle 2>/dev/null) == Dark ]] \
        && _toski_mode_cache=dark || _toski_mode_cache=light
    elif [[ ${COLORFGBG##*;} == <-> ]]; then
      (( ${COLORFGBG##*;} >= 7 && ${COLORFGBG##*;} != 8 )) \
        && _toski_mode_cache=light || _toski_mode_cache=dark
    fi
  fi
  REPLY=$_toski_mode_cache
}

_toski_load_colors() {
  local scheme=$TOSKI_COLORS
  if [[ $scheme == auto ]]; then
    [[ $COLORTERM == (truecolor|24bit) ]] && scheme=ds || scheme=ansi
  fi
  if [[ $scheme == ds ]]; then
    _toski_resolve_mode
    [[ $REPLY == light ]] && _toski_color=("${(@kv)_toski_light}") || _toski_color=("${(@kv)_toski_dark}")
  else
    _toski_color=("${(@kv)_toski_ansi}")
  fi
  # %F{...} pronto para cada papel: ${_toski_f[dir]}, ${_toski_f[muted]}…
  local k; _toski_f=()
  for k in ${(k)_toski_color}; do _toski_f[$k]="%F{${_toski_color[$k]}}"; done
}

# Uso: ${_toski_f[dir]} → %F{...}. Função curta porque aparece muito.
_c() { print -rn -- "%F{${_toski_color[$1]}}" }

# ─── Ícones (Nerd Font) ──────────────────────────────────────────────────────

if [[ $TOSKI_ICONS == true ]]; then
  typeset -gA _toski_icon=(
    dir $' '   home $' '  lock $' '
    branch $' ' tag $' '  commit $' '
    took $' '  time $' '
    node $' '  ssh $' '   jobs $' '  error $' '
  )
else
  typeset -gA _toski_icon=( error '✘ ' )
fi

# ─── Seções ──────────────────────────────────────────────────────────────────

_toski_esc() { REPLY=${1//\%/%%} }   # escapa % em textos vindos de fora

_toski_section_user() {
  [[ -n $SSH_CONNECTION || -n $SSH_TTY || $EUID == 0 ]] || return
  local c=user; [[ $EUID == 0 ]] && c=root
  REPLY="${_toski_f[$c]}${_toski_icon[ssh]}%n@%m%f ${_toski_f[muted]}in%f "
}

_toski_section_dir() {
  local icon=${_toski_icon[dir]} path_
  [[ $PWD == $HOME ]] && icon=${_toski_icon[home]}
  [[ -w $PWD ]] || icon=${_toski_icon[lock]}
  (( TOSKI_DIR_TRUNCATE > 0 )) && path_="%${TOSKI_DIR_TRUNCATE}~" || path_='%~'
  REPLY="%B${_toski_f[dir]}${icon}${path_}%f%b"
}

_toski_section_git() {
  REPLY=
  local gitdir
  gitdir=$(command git rev-parse --git-dir 2>/dev/null) || return

  local out
  out=$(command git -c core.quotepath=off status --porcelain=v2 --branch --show-stash \
        --ignore-submodules=dirty 2>/dev/null) \
  || out=$(command git -c core.quotepath=off status --porcelain=v2 --branch \
        --ignore-submodules=dirty 2>/dev/null) \
  || return

  local line head oid ab
  integer ahead=0 behind=0 staged=0 renamed=0 modified=0 deleted=0 untracked=0 conflicts=0 stash=0
  for line in ${(f)out}; do
    case $line in
      ('# branch.oid '*)  oid=${line#\# branch.oid } ;;
      ('# branch.head '*) head=${line#\# branch.head } ;;
      ('# branch.ab '*)   ab=${line#\# branch.ab }; ahead=${${ab%% *}#+}; behind=${${ab##* }#-} ;;
      ('# stash '*)       stash=${line#\# stash } ;;
      ([12]' '*)
        case ${line[3]} in
          (.) ;;
          (D) (( deleted++ )) ;;
          (R|C) (( renamed++ )) ;;
          (*) (( staged++ )) ;;
        esac
        case ${line[4]} in
          (M|T) (( modified++ )) ;;
          (D) (( deleted++ )) ;;
        esac ;;
      ('u '*) (( conflicts++ )) ;;
      ('? '*) (( untracked++ )) ;;
    esac
  done

  # Operação em andamento (rebase, merge…)
  local action step
  if [[ -d $gitdir/rebase-merge ]]; then
    action=rebase
    [[ -r $gitdir/rebase-merge/msgnum ]] && step="$(<$gitdir/rebase-merge/msgnum)/$(<$gitdir/rebase-merge/end)"
    [[ -r $gitdir/rebase-merge/head-name ]] && head=${$(<$gitdir/rebase-merge/head-name)#refs/heads/}
  elif [[ -d $gitdir/rebase-apply ]]; then
    [[ -f $gitdir/rebase-apply/applying ]] && action=am || action=rebase
    [[ -r $gitdir/rebase-apply/next ]] && step="$(<$gitdir/rebase-apply/next)/$(<$gitdir/rebase-apply/last)"
    [[ -r $gitdir/rebase-apply/head-name ]] && head=${$(<$gitdir/rebase-apply/head-name)#refs/heads/}
  elif [[ -f $gitdir/MERGE_HEAD ]];       then action=merge
  elif [[ -f $gitdir/CHERRY_PICK_HEAD ]]; then action=cherry-pick
  elif [[ -f $gitdir/REVERT_HEAD ]];      then action=revert
  elif [[ -f $gitdir/BISECT_LOG ]];       then action=bisect
  fi

  # Branch, tag ou commit solto
  local icon=${_toski_icon[branch]} name
  if [[ -z $head || $head == '(detached)' ]]; then
    if name=$(command git describe --tags --exact-match HEAD 2>/dev/null); then
      icon=${_toski_icon[tag]}
    else
      icon=${_toski_icon[commit]}; name=${oid[1,7]}
    fi
  else
    name=$head
  fi
  _toski_esc $name; name=$REPLY

  local s=" ${_toski_f[muted]}on%f ${_toski_f[branch]}${icon}${name}%f"
  [[ -n $action ]] && s+=" ${_toski_f[action]}${action}${step:+ $step}%f"

  local st=
  (( conflicts )) && st+=" ${_toski_f[conflict]}=$conflicts"
  (( ahead ))     && st+=" ${_toski_f[sync]}⇡$ahead"
  (( behind ))    && st+=" ${_toski_f[sync]}⇣$behind"
  (( staged ))    && st+=" ${_toski_f[staged]}+$staged"
  (( renamed ))   && st+=" ${_toski_f[staged]}»$renamed"
  (( modified ))  && st+=" ${_toski_f[modified]}!$modified"
  (( deleted ))   && st+=" ${_toski_f[modified]}✘$deleted"
  (( untracked )) && st+=" ${_toski_f[untracked]}?$untracked"
  (( stash ))     && st+=" ${_toski_f[stash]}\$$stash"
  [[ -n $st ]] && s+="${st}%f"

  REPLY=$s
}

_toski_section_node() {
  [[ $TOSKI_SHOW_NODE == true ]] || return
  [[ -f package.json || -f .nvmrc || -f .node-version ]] || return
  (( $+commands[node] )) || return
  local v=$(node -v 2>/dev/null)
  [[ -n $v ]] && REPLY=" ${_toski_f[muted]}via%f ${_toski_f[node]}${_toski_icon[node]}${v}%f"
}

_toski_format_time() {
  integer t=$1 h=$(( $1 / 3600 )) m=$(( $1 % 3600 / 60 )) s=$(( $1 % 60 ))
  if   (( h )); then REPLY="${h}h ${m}m ${s}s"
  elif (( m )); then REPLY="${m}m ${s}s"
  else               REPLY="${s}s"
  fi
}

# ─── Montagem ────────────────────────────────────────────────────────────────

typeset -g _toski_start= _toski_first=1 _toski_newline= _toski_line1= _toski_char=

_toski_preexec() { _toski_start=$EPOCHREALTIME }

_toski_width() {
  # Largura visível: tira %F{..}, %B etc., expande o resto e conta colunas.
  # Sem prompt_subst aqui: nomes de branch com $(...) não podem ser executados.
  setopt localoptions noprompt_subst
  local zero='%([BSUbfksu]|([FK]|){*})'
  local plain=${(S%%)1//$~zero/}
  REPLY=${(m)#plain}
}

_toski_precmd() {
  local -i exit=$?
  local ran=0
  [[ -n $_toski_start ]] && ran=1

  _toski_load_colors

  # Lado esquerdo
  local left= right=
  _toski_section_user;  left+=$REPLY; REPLY=
  _toski_section_dir;   left+=$REPLY; REPLY=
  _toski_section_git;   left+=$REPLY; REPLY=
  _toski_section_node;  left+=$REPLY; REPLY=

  # Lado direito
  if (( ran )); then
    local elapsed=$(( EPOCHREALTIME - _toski_start ))
    if (( elapsed >= TOSKI_EXEC_TIME_MIN )); then
      _toski_format_time ${elapsed%.*}
      right+=" ${_toski_f[muted]}took%f ${_toski_f[took]}${_toski_icon[took]}${REPLY}%f"
    fi
    if [[ $TOSKI_SHOW_EXIT_CODE == true ]] && (( exit )); then
      right+=" ${_toski_f[error]}${_toski_icon[error]}${exit}%f"
    fi
  fi
  right+="%(1j. ${_toski_f[jobs]}${_toski_icon[jobs]}%j%f.)"
  [[ $TOSKI_SHOW_TIME == true ]] && \
    right+=" ${_toski_f[muted]}at%f ${_toski_f[time]}${_toski_icon[time]}%D{${TOSKI_TIME_FORMAT}}%f"

  # Pontinhos entre os dois lados
  _toski_width "$left";  local -i lw=$REPLY
  _toski_width "$right"; local -i rw=$REPLY
  local -i gap=$(( COLUMNS - lw - rw - 2 ))
  if [[ -n $right ]] && (( gap >= 2 )); then
    local fill=${(pl:$gap::$TOSKI_FILL_CHAR:)}
    _toski_line1="${left} ${_toski_f[fill]}${fill}%f${right}"
  else
    _toski_line1=$left
  fi

  # Patinha (ou ❯) na segunda linha
  local char=$TOSKI_PROMPT_CHAR c=ok
  if (( ran && exit )); then
    c=error
    [[ -n $TOSKI_PROMPT_CHAR_ERROR ]] && char=$TOSKI_PROMPT_CHAR_ERROR
  fi
  _toski_esc $char
  _toski_char="${_toski_f[$c]}${REPLY}%f"

  if [[ $TOSKI_ADD_NEWLINE == true ]] && (( ! _toski_first )); then
    _toski_newline=$'\n'
  else
    _toski_newline=
  fi
  _toski_first=0
  _toski_start=
}

# Roda antes dos outros hooks para ler o $? certo.
add-zsh-hook preexec _toski_preexec
add-zsh-hook precmd _toski_precmd
precmd_functions=(_toski_precmd ${precmd_functions:#_toski_precmd})

PROMPT='${_toski_newline}${_toski_line1}
${_toski_char} '
RPROMPT=
PROMPT2="%F{8}·%f "

# O Toski já mostra o ambiente; desliga o prefixo padrão do virtualenv.
VIRTUAL_ENV_DISABLE_PROMPT=1

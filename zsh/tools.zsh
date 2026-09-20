# ---------------------------------------------------------------------------
# zen  -- open files / stdin in the browser (Zen, Flatpak)
# clip -- put files / stdin on the Wayland clipboard
# ---------------------------------------------------------------------------

# Where piped stdin gets materialised so the browser can read it.
: ${ZEN_CACHE:="${XDG_CACHE_HOME:-$HOME/.cache}/zen-open"}

# mime -> file extension, so Zen picks the right viewer
_zen_ext() {
  case "$1" in
    application/pdf)              echo pdf  ;;
    image/png)                    echo png  ;;
    image/jpeg)                   echo jpg  ;;
    image/gif)                    echo gif  ;;
    image/webp)                   echo webp ;;
    image/svg+xml)                echo svg  ;;
    text/html)                    echo html ;;
    application/json)             echo json ;;
    text/xml|application/xml)     echo xml  ;;
    text/csv)                     echo csv  ;;
    video/mp4)                    echo mp4  ;;
    video/webm)                   echo webm ;;
    audio/*)                      echo "${1#audio/}" ;;
    *)                            echo txt  ;;
  esac
}

zen() {
  emulate -L zsh
  local ext=""
  while [[ $1 == -* ]]; do
    case "$1" in
      -e|--ext) ext="${2#.}"; shift 2 ;;
      -h|--help)
        print -r -- "usage: zen [file|url ...]        open in browser
       cmd | zen [-e EXT]         open piped output in browser"
        return 0 ;;
      --) shift; break ;;
      *)  print -u2 "zen: unknown option $1"; return 2 ;;
    esac
  done

  # ---- piped stdin ----------------------------------------------------
  if (( $# == 0 )); then
    if [[ -t 0 ]]; then
      print -u2 "zen: nothing to open (give a file/url, or pipe into me)"
      return 2
    fi
    mkdir -p -- "$ZEN_CACHE"
    # prune anything older than a day so this never grows unbounded
    find "$ZEN_CACHE" -maxdepth 1 -type f -mtime +1 -delete 2>/dev/null

    local raw="$(mktemp "$ZEN_CACHE/stdin.XXXXXX")"
    cat > "$raw"
    if [[ ! -s $raw ]]; then
      rm -f -- "$raw"
      print -u2 "zen: stdin was empty"
      return 1
    fi
    [[ -n $ext ]] || ext="$(_zen_ext "$(file --mime-type -b -- "$raw")")"
    local target="$raw.$ext"
    mv -- "$raw" "$target"
    gio open "$target"
    return
  fi

  # ---- explicit arguments ---------------------------------------------
  local arg rc=0
  for arg in "$@"; do
    if [[ $arg == (http|https|file|about|data|mailto):* ]]; then
      gio open "$arg" || rc=1
    elif [[ -e $arg ]]; then
      gio open "${arg:A}" || rc=1     # absolute path -> document portal
    else
      print -u2 "zen: no such file: $arg"
      rc=1
    fi
  done
  return $rc
}

clip() {
  emulate -L zsh
  local as_uri=0
  while [[ $1 == -* ]]; do
    case "$1" in
      -f|--files) as_uri=1; shift ;;
      -o|--out)   shift; wl-paste "$@"; return ;;
      -h|--help)
        print -r -- "usage: clip FILE            copy file (image/pdf as-is, text as text)
       clip -f FILE ...     copy as file reference (paste into apps/uploads)
       cmd | clip           copy piped output as text
       clip -o              print clipboard to stdout"
        return 0 ;;
      --) shift; break ;;
      *)  print -u2 "clip: unknown option $1"; return 2 ;;
    esac
  done

  # ---- piped stdin ----------------------------------------------------
  if (( $# == 0 )); then
    if [[ -t 0 ]]; then
      print -u2 "clip: nothing to copy (give a file, or pipe into me)"
      return 2
    fi
    wl-copy
    return
  fi

  # ---- copy as file references (text/uri-list) ------------------------
  if (( as_uri )); then
    local -a uris
    local f
    for f in "$@"; do
      [[ -e $f ]] || { print -u2 "clip: no such file: $f"; return 1 }
      uris+=("file://${f:A}")
    done
    printf '%s\r\n' "${uris[@]}" | wl-copy --type text/uri-list
    return
  fi

  (( $# == 1 )) || { print -u2 "clip: one file only (use -f for several)"; return 2 }
  [[ -e $1 ]]   || { print -u2 "clip: no such file: $1"; return 1 }

  local mime="$(file --mime-type -b -- "$1")"
  if [[ $mime == text/* || $mime == application/json ]]; then
    wl-copy < "$1"                       # plain text, pastes into editors/chat
  elif [[ $mime == image/* && $mime != image/png ]]; then
    # most apps (browsers, Electron, clipse) only accept image/png on paste
    magick -- "$1" png:- | wl-copy --type image/png
  else
    wl-copy --type "$mime" < "$1"        # image/pdf bytes, pastes into GIMP/Slack/etc
  fi
}

# ---------------------------------------------------------------------------
# scratch -- throwaway drafts, autosaved by nvim (lua/gw/scratch.lua)
# note    -- named notes that drafts get filed into with :Note <name>
# ---------------------------------------------------------------------------

: ${SCRATCH_DIR:="$HOME/scratch"}
export SCRATCH_DIR

scratch() {
  emulate -L zsh
  local drafts="$SCRATCH_DIR/drafts"
  mkdir -p -- "$drafts" "$SCRATCH_DIR/notes"
  case "$1" in
    -l|--last)
      local -a last=("$drafts"/*(N.om[1]))
      (( $#last )) || { print -u2 "scratch: no drafts yet"; return 1 }
      nvim -- "$last[1]"
      ;;
    -f|--find)
      # Every line of every draft and note, newest file first; open at the hit.
      local hit
      hit="$(cd -- "$SCRATCH_DIR" && rg --line-number --no-heading --color=always \
               --sortr=modified '.' drafts notes |
             fzf --ansi --delimiter=: --nth=3.. --no-sort \
               --preview 'nl -ba {1} | tail -n +$(( {2} > 8 ? {2} - 8 : 1 )) | head -n 17')" || return
      nvim "+${${hit#*:}%%:*}" -- "$SCRATCH_DIR/${hit%%:*}"
      ;;
    -h|--help)
      print -r -- "usage: scratch        new draft in \$SCRATCH_DIR/drafts
       scratch -l     reopen the latest draft
       scratch -f     search drafts and notes
in nvim, :Note NAME files the draft into notes/NAME.md"
      ;;
    "")
      local file="$drafts/$(date +%F_%H%M).md"
      [[ -e $file ]] && file="$drafts/$(date +%F_%H%M%S).md"
      nvim +startinsert -- "$file"
      ;;
    *) print -u2 "scratch: unknown option $1"; return 2 ;;
  esac
}

note() {
  emulate -L zsh
  local notes="$SCRATCH_DIR/notes" name
  mkdir -p -- "$notes"
  if (( $# )); then
    name="$1"
  else
    # Pick an existing note, or type a new name and press enter.
    local picked
    picked="$(cd -- "$notes" && print -rl -- *(N.om:r) |
              fzf --print-query --prompt='note> ' --preview 'cat -- {}.md 2>/dev/null')"
    (( $? == 130 )) && return 1     # esc / ctrl-c
    local -a out=("${(@f)picked}")
    name="${out[2]:-$out[1]}"
    [[ -n $name ]] || return 1
  fi
  [[ $name == *.* ]] || name="$name.md"
  nvim -- "$notes/$name"
}

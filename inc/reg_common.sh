reg_print () {
  local reg_message=$1 reg_color=${2-}
  reg_message=${reg_message//\(%bs\)/$REG_BS$reg_color}
  reg_message=${reg_message//\(%bf\)/$REG_BF$reg_color}
  printf '%s%s%s\n' "$reg_color" "$reg_message" "$REG_BF"
}

reg_error () {
  printf 'reg: %s\n' "$*" >&2
  return 1
}

reg_valid_name () {
  [[ $1 =~ ^[a-zA-Z0-9_][a-zA-Z0-9_.-]*$ ]] || {
    reg_error "Invalid name: $1"
    return 1
  }
}

reg_get_cmd_by_name () {
  local reg_line reg_record
  while IFS= read -r reg_line || [[ -n $reg_line ]]; do
    reg_record=${reg_line#"$REG_RECORD_PREFIX"}
    if [[ ${reg_record%%;*} == "$1" ]]; then
      printf '%s\n' "$reg_line"
      return 0
    fi
  done < "$REG_FILE_NAME" || return 1
  return 1
}

# Replace matching lines through a temporary file; failed writes keep the original.
# shortcut: writers run one at a time; add locking before supporting concurrent writes.
reg_update_file () {
  local reg_file=$1 reg_match=$2 reg_replacement=${3-} reg_line reg_temp reg_link
  local reg_exact=${4-0} reg_obsolete=${5-}
  [[ -f $reg_file && -r $reg_file && -w $reg_file ]] || {
    reg_error "Cannot update $reg_file"
    return 1
  }
  while [[ -L $reg_file ]]; do
    reg_link=$(readlink "$reg_file") || return 1
    if [[ $reg_link == /* ]]; then
      reg_file=$reg_link
    else
      reg_file="$(dirname -- "$reg_file")/$reg_link"
    fi
  done
  reg_temp=$(mktemp "${reg_file}.XXXXXX") || return 1
  if ! (
    while IFS= read -r reg_line || [[ -n $reg_line ]]; do
      if [[ ( $reg_exact == 1 && $reg_line == "$reg_match" ) ||
            ( $reg_exact == 0 && $reg_line == "$reg_match"* ) ||
            ( -n $reg_obsolete && $reg_line == "$reg_obsolete" ) ]]; then
        continue
      fi
      printf '%s\n' "$reg_line" || return 1
    done < "$reg_file"
    if [[ -n $reg_replacement ]]; then
      printf '%s\n' "$reg_replacement"
    fi
  ) > "$reg_temp"; then
    rm -f -- "$reg_temp"
    return 1
  fi
  # Keep existing permissions (not mktemp's mode), especially for .bashrc.
  if ! chmod --reference="$reg_file" "$reg_temp" 2>/dev/null; then
    chmod 600 "$reg_temp" || { rm -f -- "$reg_temp"; return 1; }
  fi
  mv -f -- "$reg_temp" "$reg_file" || { rm -f -- "$reg_temp"; return 1; }
}

reg_update_bashrc () {
  if [[ ! -e ~/.bashrc ]]; then
    (umask 077; : > ~/.bashrc) || return 1
  fi
  reg_update_file ~/.bashrc "$@"
}

reg_reload () {
  source ~/.bashrc
}

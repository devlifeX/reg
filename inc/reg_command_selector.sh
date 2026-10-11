reg_command () {
  [[ $# -gt 0 ]] || { reg_man; return 1; }
  case $1 in
    add) reg_save "$@" ;;
    remove) reg_remove "$@" ;;
    man|-h|--help) reg_man ;;
    list) reg_show_list "$@" ;;
    alias) reg_alias "$@" ;;
    env) reg_env "$@" ;;
    reload) reg_reload ;;
    -v|--version) reg_version ;;
    *) reg_execute "$@" ;;
  esac
}

reg_execute () {

  is_exist=$(reg_is_command_exist $1);
  if [[ $is_exist = "false" ]]; then
    print "There is no command (%bs)$1(%bf)" $RED 
    exit;
  fi

  cmd=$(reg_get_cmd_by_name $1);
  IFS=$SEPRATOR_FOR_SAVE read -r -a args <<< "$cmd";

  for arg in "${args[@]:1}"; do
    cmd_genrator="$cmd_genrator && $arg";
  done
  cmd=${cmd_genrator:3:${#cmd_genrator}};
  cmd="$cmd;";
  eval $cmd;
}
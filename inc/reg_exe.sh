reg_execute () {

  is_exist=$(reg_is_command_exist $1);
  if [[ $is_exist = "false" ]]; then
    print "There is no command (%bs)$1(%bf)" $RED 
    return; 
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

reg_show_list () {
  if [[ $2 ]]; then
    item=$(reg_get_cmd_by_name $2);
    if [[ $3 == "-num" ]]; then
      item=$(reg_set_number_cmd $item);
    fi
    echo -e $item;
  else
   all=$(reg_get_all_cmd);
   echo -e $all;
 fi
}
reg_remove () {
  is_exist=$(reg_is_command_exist $2);
  if [[ $is_exist != "true" ]]; then
      echo -e "$RED The command '$BS$2$BF$RED' is not exist.";
    else
      line_of_cmd=$(reg_get_cmd_by_name $2);
      sed --in-place "/$line_of_cmd/d" reg.cmd;
     echo -e "$GREEN The command '$BS$2$BF$GREEN' removed.$BF";
  fi
}
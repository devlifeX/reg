reg_remove () {
  is_exist=$(reg_is_command_exist $2);
  if [[ $is_exist != "true" ]]; then
       print "The command '(%bs)$2(%bf)' is not exist." $RED
    else
      line_of_cmd=$(reg_get_cmd_by_name $2);
      sed --in-place "/$line_of_cmd/d" $FILE_NAME;
      print "The command '(%bs)$2(%bf)' removed." $GREEN
  fi
}
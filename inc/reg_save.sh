reg_save () {
  is_exist=$(reg_is_command_exist $2);
  if [[ $is_exist = "true" ]]; then
      print "The command (%bs)$2(%bf) is exist please pick another name." $RED
    else
      output_for_save=$(reg_select_args -s 0,1,2 "$@"); 
      echo  $output_for_save >> $FILE_NAME;
      print "The command '(%bs)$2(%bf)' saved." $GREEN
      print "now you can use '(%bs)$2(%bf)' command for run below command" $GREEN
      print "(%bs)$output_for_save(%bf)" $GREEN
  fi
}
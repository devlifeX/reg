reg_save () {
  is_exist=$(reg_is_command_exist $2);
  if [[ $is_exist = "true" ]]; then
      echo -e "$RED The command '$BS$2$BF$RED' is exist please pick another name";
    else
      output_for_save=$(reg_select_args -s 0,1,2 "$@"); 
      echo  $output_for_save >> "reg.cmd";  
      echo -e "$GREEN The command '$BS$2$BF$GREEN' saved.";
      echo -e "now you can use $BS$2$BF$GREEN command for run below command";
      echo -e "$BS$output_for_save$BF";
  fi
}
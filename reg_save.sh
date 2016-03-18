reg_save () {
  is_exist=$(reg_is_command_exist $2);
  if [[ $is_exist = "true" ]]; then
      echo -e "$RED The command '$BS$2$BF$RED' is exist please pick another name";
    else
      echo  "$@" >> "reg.cmd";  
      echo -e "$GREEN The command '$BS$2$BF$GREEN' saved.";
      echo -e "now you can use $BS$2$BF$GREEN command for run below command";
      echo -e "$BS$@$BF";
  fi
}
reg_save () {
  is_exist=$(reg_is_command_exist $1);
  if [[ $is_exist = "true" ]]; then
      echo -e "$RED The command '$BS$1$BF$RED' is exit please pick another name";
    else
      echo  "$@" >> "reg.cmd";  
      echo -e "$GREEN The command '$BS$1$BF$GREEN' saved.";
      echo -e "now you can use $BS$1$BF$GREEN command for run below command";
      echo -e "$BS$@$BF";
  fi
}
#!/bin/bash
  REG_CURRENT_PATH=$(pwd);

. $REG_CURRENT_PATH/inc/reg_var.sh
. $REG_CURRENT_PATH/inc/reg_common.sh
. $REG_CURRENT_PATH/inc/reg_command_selector.sh
. $REG_CURRENT_PATH/inc/reg_man.sh
. $REG_CURRENT_PATH/inc/reg_load.sh
. $REG_CURRENT_PATH/inc/reg_save.sh
. $REG_CURRENT_PATH/inc/reg_remove.sh
. $REG_CURRENT_PATH/inc/reg_exe.sh

reg () {
  reg_command "$@";
  return;
}



reg -h
# reg "pull" "git pull origin master" "vagrant provision" "gulp build" "gulp serve"
# reg "push" "git psuh origin master"
# reg "log" "git log --oneline"
# reg "s" "git status" "git log -p"
# reg add "ls" "ls -la" "pwd"
# reg remove "ls"
# reg ls;
# reg -s 0,1,2,5,6 "pull" "git pull origin master" "vagrant provision" "gulp build" "gulp serve"
# reg -s 5,3 "pull" "git pull origin master" "vagrant provision" "gulp build" "gulp serve"

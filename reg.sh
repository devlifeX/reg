#!/bin/bash

. inc/reg_var.sh
. inc/reg_common.sh
. inc/reg_command_selector.sh
. inc/reg_man.sh
. inc/reg_load.sh
. inc/reg_save.sh
. inc/reg_remove.sh
. inc/reg_exe.sh

reg () {
  reg_command "$@";
  return;
}



# reg -h
# reg "pull" "git pull origin master" "vagrant provision" "gulp build" "gulp serve"
# reg "push" "git psuh origin master"
# reg "log" "git log --oneline"
# reg "s" "git status" "git log -p"
# reg add "ls" "ls -la" "pwd"
# reg remove "ls"
# reg ls;
# reg -s 0,1,2,5,6 "pull" "git pull origin master" "vagrant provision" "gulp build" "gulp serve"
# reg -s 5,3 "pull" "git pull origin master" "vagrant provision" "gulp build" "gulp serve"

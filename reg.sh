#!/bin/bash
  REG_CURRENT_PATH=$(pwd);

. "$REG_CURRENT_PATH/inc/reg_var.sh"
. "$REG_CURRENT_PATH/inc/reg_common.sh"
. "$REG_CURRENT_PATH/inc/reg_command_selector.sh"
. "$REG_CURRENT_PATH/inc/reg_man.sh"
. "$REG_CURRENT_PATH/inc/reg_load.sh"
. "$REG_CURRENT_PATH/inc/reg_save.sh"
. "$REG_CURRENT_PATH/inc/reg_remove.sh"
. "$REG_CURRENT_PATH/inc/reg_exe.sh"
. "$REG_CURRENT_PATH/inc/reg_alias.sh"
. "$REG_CURRENT_PATH/inc/reg_env.sh"

reg () {
  reg_command "$@";
  return;
}
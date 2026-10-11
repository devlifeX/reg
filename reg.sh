#!/bin/bash
REG_CURRENT_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || return 1

. "$REG_CURRENT_PATH/inc/reg_var.sh" || return 1
. "$REG_CURRENT_PATH/inc/reg_common.sh" || return 1
. "$REG_CURRENT_PATH/inc/reg_command_selector.sh" || return 1
. "$REG_CURRENT_PATH/inc/reg_man.sh" || return 1
. "$REG_CURRENT_PATH/inc/reg_load.sh" || return 1
. "$REG_CURRENT_PATH/inc/reg_save.sh" || return 1
. "$REG_CURRENT_PATH/inc/reg_remove.sh" || return 1
. "$REG_CURRENT_PATH/inc/reg_exe.sh" || return 1
. "$REG_CURRENT_PATH/inc/reg_alias.sh" || return 1
. "$REG_CURRENT_PATH/inc/reg_env.sh" || return 1

reg () {
  reg_command "$@"
}

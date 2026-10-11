#!/bin/bash
set -euo pipefail
umask 077

REG_SOURCE_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REG_INSTALL_PATH="$HOME/.local/share/reg"
mkdir -p -- "$(dirname -- "$REG_INSTALL_PATH")"
REG_STAGING_PATH=$(mktemp -d "${REG_INSTALL_PATH}.install.XXXXXX")
REG_BACKUP_PATH=''
REG_PROMOTED=0

reg_install_cleanup () {
  local reg_status=$?
  if [[ $reg_status != 0 ]]; then
    if [[ $REG_PROMOTED == 1 ]]; then
      rm -rf -- "$REG_INSTALL_PATH"
    fi
    if [[ -n $REG_BACKUP_PATH && -d $REG_BACKUP_PATH ]]; then
      mv -- "$REG_BACKUP_PATH" "$REG_INSTALL_PATH" || printf 'Restore backup manually: %s\n' "$REG_BACKUP_PATH" >&2
    fi
  elif [[ -n $REG_BACKUP_PATH ]]; then
    rm -rf -- "$REG_BACKUP_PATH"
  fi
  rm -rf -- "$REG_STAGING_PATH"
}
trap reg_install_cleanup EXIT

cp -R -- "$REG_SOURCE_PATH/reg.sh" "$REG_SOURCE_PATH/installer.sh" \
  "$REG_SOURCE_PATH/inc" "$REG_SOURCE_PATH/storage" \
  "$REG_SOURCE_PATH/README.md" "$REG_SOURCE_PATH/LICENSE" "$REG_STAGING_PATH/"
if [[ -f $REG_INSTALL_PATH/storage/reg.cmd ]]; then
  cp -- "$REG_INSTALL_PATH/storage/reg.cmd" "$REG_STAGING_PATH/storage/reg.cmd"
elif [[ -f /usr/local/bin/reg/reg-master/storage/reg.cmd ]]; then
  cp -- /usr/local/bin/reg/reg-master/storage/reg.cmd "$REG_STAGING_PATH/storage/reg.cmd"
fi
chmod -R u=rwX,go= "$REG_STAGING_PATH"
(source "$REG_STAGING_PATH/reg.sh")

# Keep the old directory until installation and .bashrc updates both succeed.
if [[ -e $REG_INSTALL_PATH ]]; then
  REG_BACKUP_PATH=$(mktemp -d "${REG_INSTALL_PATH}.backup.XXXXXX")
  rmdir -- "$REG_BACKUP_PATH"
  mv -- "$REG_INSTALL_PATH" "$REG_BACKUP_PATH"
fi
mv -- "$REG_STAGING_PATH" "$REG_INSTALL_PATH"
REG_PROMOTED=1

source "$REG_INSTALL_PATH/inc/reg_common.sh"
REG_COMMAND_BASHRC=$(printf 'source %q' "$REG_INSTALL_PATH/reg.sh")
reg_update_bashrc "$REG_COMMAND_BASHRC" "$REG_COMMAND_BASHRC" 1 \
  'source /usr/local/bin/reg/reg-master/reg.sh'
printf 'Reg installed in %s\nRun: %s\n' "$REG_INSTALL_PATH" "$REG_COMMAND_BASHRC"

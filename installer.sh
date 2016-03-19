REG_INSTALL_PATH="/usr/local/bin/reg";

if [ -d $REG_INSTALL_PATH ]; then
  sudo rm -rf $REG_INSTALL_PATH;
fi


sudo wget -N https://github.com/devlifeX/reg/archive/master.zip;
sudo unzip master.zip -d $REG_INSTALL_PATH;

cd "$REG_INSTALL_PATH/reg-master";

sudo chmod -R 777 $REG_INSTALL_PATH;

REG_COMMAND_BASHRC="source $REG_INSTALL_PATH/reg-master/reg.sh";
sudo sed --in-place "/${REG_COMMAND_BASHRC//\//\\/}/d" ~/.bashrc;

sudo echo $REG_COMMAND_BASHRC >> ~/.bashrc;
exec bash;
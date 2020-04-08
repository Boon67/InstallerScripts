#!/usr/bin/env bash

#USERAGENT/PASSWORD for Linux Account
AGENTID='infa'
PASSWORD='<SUPERSPECIALPASSWORD>'

if [ "$EUID" -ne 0 ]
  then 
    echo "---------Permissions Error---------"
    echo "STOPPING: Please run as root or sudo"
    echo "-----------------------------------"
  exit
fi

echo "----Setting up User Account---"
userdel -r $AGENTID
useradd -m $AGENTID
echo "$AGENTID:$PASSWORD" | chpasswd

#Agent Download
sudo -u infa bash -c 'rm -rf ~/infaagent'
echo '-----Setting up Infraagent Requirements----'
sudo -H -u infa bash -c 'AGENTFILENAME=agent64_install_ng_ext.bin;cd ~;curl https://na1.dm-us.informaticacloud.com/saas/download/linux64/installer/agent64_install_ng_ext.bin --output $AGENTFILENAME;chmod +x ~/$AGENTFILENAME;~/$AGENTFILENAME -i silent'

#Agent Configuration
echo '-----Configuring Infa agent----'
sudo -H -u infa bash -c 'read -p "Enter Informatica User Login ID: " INFAUID;read -p "Enter Agent Auth Token: " AUTHTOKEN;cd ~/infaagent/apps/agentcore/; ./infaagent startup;sleep 15; ./consoleAgentManager.sh configureToken $INFAUID $AUTHTOKEN;./infaagent shutdown;'

#Connector Infrastructure for FileIO Connector
echo '-----Setting up FileIO Requirements----'
sudo -H -u infa bash -c 'FILEIOPARENT=~/infa_data; rm -rf $FILEIOPARENT; mkdir $FILEIOPARENT;touch $FILEIOPARENT/.infaccess;mkdir $FILEIOPARENT/error;mkdir $FILEIOPARENT/inprocess;mkdir $FILEIOPARENT/source;mkdir $FILEIOPARENT/success;mkdir $FILEIOPARENT/target'
echo '-----Infa Agent Install Complete----'

#SERVICE SETUP
echo '---------------------Creating Infa Agent service---------------------'
SYSTEMDPATH="/lib/systemd/system"
SYSTEMDSERVICENAME="infaagent.service"
SERVICENAME="Informatica Secure Agent Service"

cat >$SYSTEMDSERVICENAME <<EOF
[Unit]
Description=$SERVICENAME
[Service]
Type=forking
User=$AGENTID
Group=$AGENTID
WorkingDirectory=/home/$AGENTID/infaagent/apps/agentcore/
ExecStart=/home/$AGENTID/infaagent/apps/agentcore/infaagent startup
ExecStop=/home/$AGENTID/infaagent/apps/agentcore/infaagent shutdown
Restart=on-abort
TimeoutSec=30
RestartSec=30
StartLimitInterval=350
StartLimitBurst=10
[Install]
WantedBy=multi-user.target
EOF

echo '---------------------Placing service in systemd folder---------------------'
mv "$SYSTEMDSERVICENAME" "$SYSTEMDPATH"

# echo "---Setting Startup Options"
systemctl daemon-reload
systemctl enable $SYSTEMDSERVICENAME
systemctl start $SYSTEMDSERVICENAME


#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]
  then 
    echo "---------Permissions Error---------"
    echo "STOPPING: Please run as root or sudo"
    echo "-----------------------------------"
  exit
fi


read -p "Enter FrogIO Login: " RTE_LOGIN
read -p "Enter FrogIO Password: " RTE_PASSWORD

RTE_RELEASE='rte-2.0.5-centos7.tar.gz'

RTE_FILENAME='rte.tar.gz'
RTE_TARGETPATH='/usr/local/bin/sc'

curl -u $RTE_LOGIN:$RTE_PASSWORD https://sparkcognition.jfrog.io/artifactory/Darwin-RTE/latest/$RTE_RELEASE -o $RTE_FILENAME
rm -rf $RTE_TARGETPATH
mkdir $RTE_TARGETPATH
tar -xzf $RTE_FILENAME -C $RTE_TARGETPATH
echo 'Installation of RTE Complete'
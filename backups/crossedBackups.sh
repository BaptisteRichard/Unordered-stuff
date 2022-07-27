#!/bin/bash


if [ $# -ne  1 ] ; then
  (>&2 echo "Usage : crossedBackups.sh <target config>")
  exit
fi


config="./$1"

if [ ! -f $config ]; then
  (>&2 echo "No configuration file $config")
  exit;
fi

source $config
logfile=/tmp/crossed-$1.log
echo "[`date`] starting crossed backup $1 " > $logfile;

source='/mnt/private'

#select key
options="--encrypt-key $encryptionKey --full-if-older-than=$fullBackupInterval"

#Specific includes and excludes
options="${options} --include=${includes} --exclude=${excludes}"

echo duplicity $options $source $target

echo "[`date`] starting duplicity " >> $logfile;

duplicity $options $source $server 2> /tmp/duplicity-error.txt >> $logfile

errcode=$?
echo "[`date`] duplicity ended with return code $errcode " >> $logfile;


duplicity remove-all-but-n-full $maxFull --force $server 2>> /tmp/duplicity-error.txt >> $logfile
errcode=$(($? + $errcode))
echo "[`date`] duplicity full cleanup ended with return code $errcode " >> $logfile;

duplicity remove-all-inc-of-but-n-full $maxInc --force $server 2>> /tmp/duplicity-error.txt >> $logfile

errcode=$(($? + $errcode))

echo "[`date`] duplicity incremental cleanup ended with return code $errcode " >> $logfile;

if [ $errcode -ne 0 ];
then
echo "From:$from"> /tmp/mail-crossed.txt
echo "To:$errMailList " >> /tmp/mail-crossed.txt
echo "Subject:Cross-backup Backup failed for $1 " >> /tmp/mail-crossed.txt
echo "Script failed with exit status $errcode and error log : " >> /tmp/mail-crossed.txt
cat /tmp/duplicity-error.txt  >> /tmp/mail-crossed.txt

ssmtp $errMailList </tmp/mail-crossed.txt
fi;

echo "[`date`] End of run " >> $logfile;

exit

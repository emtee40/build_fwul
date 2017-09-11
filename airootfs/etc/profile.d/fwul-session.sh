#!/bin/bash
###########################################################################################
#
# session starter for FWUL
#
###########################################################################################

######
# Language & Locale
LANGFILE="$HOME/.dmrc"

# extract, fix and export $LANG
TEMPLANG=$(cat "$LANGFILE" | grep ^Language= | cut -d '=' -f 2 | sed 's/utf8/UTF8/')
[ ! -z "$TEMPLANG" ] && export LANG=$TEMPLANG

# convert $LANG to $LANGUAGE and export
SETLAYOUT="$(echo $LANG | cut -d '@' -f 1 | cut -d '.' -f 1 | cut -d '_' -f 1)"

setxkbmap -layout $SETLAYOUT

# set global locale
DMLANG=$(cat "$LANGFILE" | grep ^Language= | cut -d '=' -f 2)
echo "LANG=$DMLANG" > /tmp/locale.conf
# set fallback language
echo "LANGUAGE=en_US.utf8" >> /tmp/locale.conf
sudo mv /tmp/locale.conf /etc/locale.conf

######
# make more space available so we can install new software while running

# detect persistent mode
PERSMODE=0
grep "cow_label=" /proc/cmdline >> /dev/null 2>&1
[ $? -eq 0 ] && PERSMODE=1

# get free mem info (we will not use % of free ram because it could make problems later)
AVAILMEM=$(cat /proc/meminfo |grep MemFree| egrep -o '[0-9]*')
# take 2/3 of the free ram and convert it to MB
MEMMB=$((AVAILMEM*2/3/1024))

# remount (in forgetful mode only) with the new size when the value is valid
if [ $PERSMODE -eq 0 ] && [ "$MEMMB" -ge 700 ];then
  sudo mount -o remount,size=${MEMMB}m /run/archiso/cowspace
fi

# when in persistent unmount /tmp if RAM less than required min
if [ $PERSMODE -eq 1 ] && [ "$MEMMB" -lt 1024 ];then
   cp -a /tmp/* /var/tmp/
   sudo umount -l /tmp
   sudo mv /var/tmp/* /tmp/
fi

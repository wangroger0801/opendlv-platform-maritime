#!/bin/bash

echo Root password?
read root_password

echo Revere user password?
read user_password

hdd=/dev/`lsblk | grep disk | grep 30G | cut -d ' ' -f1`

wget https://raw.github.com/chalmers-revere/opendlv.os/master/x86/get.sh
sh get.sh

cp setup-available/setup-chroot-01-rtkernel.sh \
   setup-available/setup-chroot-02-ptpd.sh \
   setup-available/setup-post-01-router.sh \
   setup-available/setup-post-05-docker.sh \
   .

sed_arg="s/hostname=.*/hostname=revere-maritime-VM/; \
  s/user=( revere )/user=( VM )/; \
  s/root_password=.*/root_password=${root_password}/; \
  s/user_password=.*/user_password=( ${user_password} )/; \
  s/lan_dev=.*/lan_dev=enp0s3/; \
  s%hdd=.*%hdd=${hdd}%; \
  s/  uefi=true/  uefi=false/"
sed -i "$sed_arg" install-conf.sh

sed_arg="s/subnet=.*/subnet=10.44.44.0/; \
	s/dhcp_clients=.*/dhcp_clients=( \
	  'oxts-gps,70:b3:d5:af:03:73,80', )/"
sed -i "$sed_arg" setup-post-01-router.sh

chmod +x *.sh

su -c ./install.sh -s /bin/bash root

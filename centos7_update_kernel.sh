#!/bin/bash

rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
yum -y --enablerepo=elrepo-kernel install kernel-lt
echo "GRUB_DEFAULT=0" >> /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg

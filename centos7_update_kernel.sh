#!/bin/bash

yum install -y elrepo-release
yum -y --enablerepo=elrepo-kernel install kernel-lt
echo "GRUB_DEFAULT=0" >> /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg

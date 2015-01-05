#!/bin/bash

export LANG=en
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# ulimit
cat >>/etc/security/limits.conf <<EOF
*               soft    nofile          65535
*               hard    nofile          65535
*               soft    core            unlimited
EOF
sed -i 's/1024/10240/' /etc/security/limits.d/90-nproc.conf

# disable ipv6
cat >>/etc/sysctl.conf <<EOF
vm.swappiness = 0
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
EOF
sed -i 's/^NETWORKING_IPV6.*/NETWORKING_IPV6=no/' /etc/sysconfig/network


# ssh
sed -i 's/^#UseDNS yes$/UseDNS no/' /etc/ssh/sshd_config
sed -i 's/^X11Forwarding yes$/X11Forwarding yes/' /etc/ssh/sshd_config
sed -i 's/^GSSAPIAuthentication yes$/GSSAPIAuthentication no/' /etc/ssh/sshd_config

# selinux
sed -i -c 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

# service
SERVICE=$(chkconfig --list | grep '3:on' | awk '{print $1}')

for i in $SERVICE
do
    case $i in
        acpid | crond | irqbalance |  messagebus | network | sshd | rsyslog | udev-post)
            chkconfig --level 2345 $i on
        ;;
        *)
            chkconfig --level 2345 $i off
        ;;
    esac
done

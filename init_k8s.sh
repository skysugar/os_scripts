#!/bin/bash

#安装常用软件
yum update -y
yum install -y vim ntp bash-completion sysstat iptables-services conntrack ipvsadm jq libseccomp wget net-tools git

#禁用SELINUX
sed -i "/^SELINUX=/cSELINUX=disabled" /etc/sysconfig/selinux
sed -i "/^SELINUX=/cSELINUX=disabled" /etc/selinux/config

#设置时区 更新时间
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
systemctl enable ntpd
ntpdate time.apple.com
hwclock --systohc
systemctl start ntpd

#禁用启用系统服务
systemctl disable postfix
systemctl disable firewalld
: > /etc/sysconfig/iptables
systemctl disable iptables.service


cat >>/etc/security/limits.conf<<EOF
* soft nofile 65535
* hard nofile 65535
* soft nproc 65535
* hard nproc 65535
* soft core unlimited
* hard core unlimited
* soft fsize unlimited
* hard fsize unlimited
* soft data unlimited
* hard data unlimited
* soft nproc 65535
* hard nproc 63535
* soft stack unlimited
* hard stack unlimited
* soft nofile 409600
* hard nofile 409600
EOF

cat >>/etc/sysctl.d/99-sysctl.conf<<EOF

#关闭ipv6 
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1 

# 避免放大攻击
net.ipv4.icmp_echo_ignore_broadcasts = 1 

# 开启恶意icmp错误消息保护
net.ipv4.icmp_ignore_bogus_error_responses = 1

# 开启路由转发
net.ipv4.ip_forward = 1
net.ipv4.conf.all.send_redirects = 1
net.ipv4.conf.default.send_redirects = 1

#开启反向路径过滤
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

#处理无源路由的包
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

#关闭sysrq功能
kernel.sysrq = 0

#core文件名中添加pid作为扩展名
kernel.core_uses_pid = 1
net.ipv4.tcp_syncookies = 1

#修改消息队列长度
kernel.msgmnb = 65536
kernel.msgmax = 65536
 
#设置最大内存共享段大小bytes
kernel.shmmax = 68719476736
kernel.shmall = 4294967296

#timewait的数量，默认180000
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_rmem = 4096        87380   4194304
net.ipv4.tcp_wmem = 4096        16384   4194304
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 262144

#限制仅仅是为了防止简单的DoS 攻击
net.ipv4.tcp_max_orphans = 3276800

#未收到客户端确认信息的连接请求的最大值
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_timestamps = 0

#内核放弃建立连接之前发送SYNACK 包的数量
net.ipv4.tcp_synack_retries = 1

#内核放弃建立连接之前发送SYN 包的数量
net.ipv4.tcp_syn_retries = 1

#启用timewait 快速回收
net.ipv4.tcp_tw_recycle = 1

#开启重用。允许将TIME-WAIT sockets 重新用于新的TCP 连接
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_fin_timeout = 1
 
#当keepalive 起用的时候，TCP 发送keepalive 消息的频度。缺省是2 小时
net.ipv4.tcp_keepalive_time = 30

#允许系统打开的端口范围
net.ipv4.ip_local_port_range = 1024    65000

#修改防火墙表大小，默认65536
net.netfilter.nf_conntrack_max=655350
net.netfilter.nf_conntrack_tcp_timeout_established=1200

# 确保无人能修改路由表
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0

net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

mkdir /var/log/journal
mkdir /etc/systemd/journald.conf.d
cat > /etc/systemd/journald.conf.d/99-propbet.conf <<EOF
[Journal]
Storage=persistent
Compress=yes
SyncIntervalSec=5m
RateLimitInterval=30s
RateLimitBurst=1000
SystemMaxUse=10G
SystemMaxFileSize=200M
MaxRetentionSec=2week
ForwardToSyslog=no
EOF

modprobe br_netfilter
cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF
chmod 755 /etc/sysconfig/modules/ipvs.modules
bash /etc/sysconfig/modules/ipvs.modules
lsmod | grep -e ip_vs -e nf_conntrack_ipv4

yum install -y yum-utils device-mapper-persistent-data lvm2
#yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum-config-manager --add-repo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum update -y && yum install -y docker-ce
mkdir /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
"exec-opts": ["native.cgroupdriver=systemd" ],
"log-driver": "json-file",
"log-opts": {
    "max-size": "100m"
  }
}
EOF

systemctl start docker
systemctl enable docker

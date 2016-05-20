# 日常问题处理 Tips

## 一、kvm/OpenNebula

* `onehost sync --force`
    * [OpenNebula host sync](http://docs.opennebula.org/4.10/administration/hosts_and_clusters/host_guide.html#sync)
* messagebus 服务必须开启，否则添加节点会失败
    * chkconfig messagebus on
    * service messagebus start
* 节点添加或监控失败调试，所在节点执行以下命令调试
    * `cd /var/tmp/one/im;bash -x run_probes kvm /var/lib/one/datastores 4124 20 0 localhost`
* 网卡驱动推荐 `virtio`，提升网卡性能，默认 rtl8139
    * [KVM networking performance](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Virtualization_Administration_Guide/sect-Virtualization-Troubleshooting-KVM_networking_performance.html)
    * [Make the Network of Your VMs Fly With the Virtio Driver](http://www.sebastien-han.fr/blog/2012/07/19/make-the-network-of-your-vms-fly-with-virtio-driver/)

## 二、git/svn

* git 忽略文件 `.gitignore`
* [A guide for programming within version control.](https://github.com/thoughtbot/guides/tree/master/protocol/git)
* git 批量修改提交 user 和 email [修改git已提交的的author和email](http://lmbj.net/blog/how-do-i-change-the-author-of-a-commit-in-git/)
* git 删除历史大文件 [Removing files from a repository's history](https://help.github.com/articles/removing-files-from-a-repository-s-history/#platform-linux)

```
#!/bin/sh

git filter-branch -f --env-filter '

an="$GIT_AUTHOR_NAME"
am="$GIT_AUTHOR_EMAIL"
cn="$GIT_COMMITTER_NAME"
cm="$GIT_COMMITTER_EMAIL"

if [ "$GIT_COMMITTER_EMAIL" = "your@email.to.match" ]
then
    cn="Your New Committer Name"
    cm="Your New Committer Email"
fi
if [ "$GIT_AUTHOR_EMAIL" = "your@email.to.match" ]
then
    an="Your New Author Name"
    am="Your New Author Email"
fi

export GIT_AUTHOR_NAME="$an"
export GIT_AUTHOR_EMAIL="$am"
export GIT_COMMITTER_NAME="$cn"
export GIT_COMMITTER_EMAIL="$cm"
'
```

### Git 分支管理

* 列出分支
    * `git branch` 列出本地分支
        * `git branch -v`
    * `git branch -r` 列出远程分支
        * `git branch -r -v`
* 删除分支 「-D 表强制删除」
    * `git branch -d local-branch-name` 删除本地分支
    * `git branch -d -r remote-branch-name; git push origin :remote-branch-name` 删除远程分支
* 查看分支 merge 信息「-r 此处依然生效」
    * `git branch --merged` 已 merge 分支
    * `git branch --no-merged` 未 merge 分支
* Rebase
    * git fetch origin; git rebase origin/master

## 三、Linux

* rpm

查看软件 changelog

```
rpm -qp --changelog kernel-2.6.32-573.18.1.el6.centos.plus.x86_64.rpm
```

* grep

grep 匹配文件差异

```
➜  /tmp/test/ cat test1
9
10
a
b
c
➜  /tmp/test/ cat test2
6
9
10
c
x
y
z
➜  /tmp/test/ grep -F -v -f test1 test2
6
x
y
z
```

* blkid

查看设备 `UUID`

* [Find Out What Process Are Using Swap Space](http://www.cyberciti.biz/faq/linux-which-process-is-using-swap/)

```
for file in /proc/*/status ; do awk '/VmSwap|Name/{printf $2 " " $3}END{ print ""}' $file; done | sort -k 2 -n -r | less
```

### sed/awk

* sed 批量去除行尾空格和tab

```
sed -i 's/[ \t]*$//g' filename
```

### LVM

* [LVM HOWTO](http://www.tldp.org/HOWTO/LVM-HOWTO/index.html)
* [LVM (简体中文) ArchLinux](https://wiki.archlinux.org/index.php/LVM_%28%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87%29)

### route

```
route del -net 192.168.0.0 netmask 255.255.255.0 dev eth1   # 删除指定网段路由
route add -net 192.168.0.0 netmask 255.255.255.0 dev eth1   # 添加指定网段路由
route add default gw 192.168.0.1    # 增加默认路由
route del default                   # 删除默认路由
route add -net 192.168.1.0 netmask 255.255.255.0 gw 192.168.0.1     # 增加静态路由
route del -net 192.168.1.0 netmask 255.255.255.0 gw 192.168.0.1     # 删除静态路由
```

### ip route

```
ip route del 192.168.0.0/24 dev eth1    # 删除指定网段路由
ip route add 192.168.0.0/24 dev eth1    # 添加指定网段路由
ip route del via 10.2.255.254       # 删除默认路由
ip route add via 10.2.255.254       # 增加默认路由
ip route add 192.168.1.0/24 via 192.168.0.1  # 增加静态路由，192.168.0.1 为下一跳地址
ip route del 192.168.1.0/24 via 192.168.0.1  # 删除静态路由
```

### drop caches

Writing to this will cause thekernel to drop clean caches, dentries and inodes from memory, causing thatmemory to become free.

* To free pagecache:
    * echo 1 > /proc/sys/vm/drop_caches
* To free dentries and inodes:
    * echo 2 > /proc/sys/vm/drop_caches
* To free pagecache, dentries andinodes:
    * echo 3 > /proc/sys/vm/drop_caches
* Reference: [sysctl vm.txt](http://www.kernel.org/doc/Documentation/sysctl/vm.txt)

As this is a non-destructiveoperation and dirty objects are not freeable, the user should run `sync` first.

### swappiness

```
echo 0 > /proc/sys/vm/swappiness
```

默认值 60，对于服务器这是一个糟糕的默认值，这个值只对笔记本适用。服务器应该设置为 0。

### 桥接

* CentOS

```
# cat /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
TYPE=Ethernet
HWADDR=xx:xx:xx:xx:xx:xx
BOOTPROTO=none
ONBOOT=yes
NM_CONTROLLED=no
BRIDGE=br0
# cat /etc/sysconfig/network-scripts/ifcfg-br0
DEVICE=br0
TYPE=Bridge
IPADDR=xx.xx.xx.xx
NETMASK=xx.xx.xx.xx
GATEWAY=xx.xx.xx.xx
ONBOOT=yes
BOOTPROTO=none
NM_CONTROLLED=no
DELAY=0
# cat /etc/sysconfig/network-scripts/ifcfg-eth1
TYPE=Ethernet
DEVICE=eth1
ONBOOT=yes
BRIDGE=br1
# cat /etc/sysconfig/network-scripts/ifcfg-br1
DEVICE=br1
TYPE=Bridge
BOOTPROTO=none
ONBOOT=yes
```

* Ubuntu

```
# cat /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet manual

auto br0
iface br0 inet static
address xx.xx.xx.xx
netmask xx.xx.xx.xx
gateway xx.xx.xx.xx
bridge_ports eth0
bridge_stp off
bridge_fd 0
bridge_maxwait 0
dns-nameservers xx.xx.xx.xx
dns-search xxx.com
```

### CentOS 7/RHEL 7

* 主机名配置文件
    * /etc/hostname
* ifconfig
    * yum install net-tools -y
* eth0
    * 添加选项 `net.ifnames=0` `biosdevname=0` 到 `/etc/default/grub`
    * grub2-mkconfig -o /boot/grub2/grub.cfg
    * mv /etc/sysconfig/network-scripts/{ifcfg-eno16777736,ifcfg-eth0}
    * reboot

```
# cat /etc/default/grub
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="vconsole.keymap=us crashkernel=auto  vconsole.font=latarcyrheb-sun16 net.ifnames=0 biosdevname=0 rhgb quiet"
GRUB_DISABLE_RECOVERY="true"
# grub2-mkconfig -o /boot/grub2/grub.cfg
# mv /etc/sysconfig/network-scripts/{ifcfg-eno16777736,ifcfg-eth0}
# reboot
```

* diable ipv6
    * 加入 `ipv6.disable=1` 选项到 `/etc/default/grub` 配置文件中的 `GRUB_CMDLINE_LINUX= ... ` 行中

### 查看超级块信息

* mkfs

```
# mkfs.ext3 -n /dev/vda1        # 非挂载情况下查看
mke2fs 1.41.12 (17-May-2010)
文件系统标签=
操作系统:Linux
块大小=1024 (log=0)
分块大小=1024 (log=0)
Stride=0 blocks, Stripe width=0 blocks
51200 inodes, 204800 blocks
10240 blocks (5.00%) reserved for the super user
第一个数据块=1
Maximum filesystem blocks=67371008
25 block groups
8192 blocks per group, 8192 fragments per group
2048 inodes per group
Superblock backups stored on blocks:
    8193, 24577, 40961, 57345, 73729
```

* tune2fs

```
# tune2fs -l /dev/vda1         # 挂载非挂载情况都可以查看
tune2fs 1.41.12 (17-May-2010)
Filesystem volume name:   /boot/
Last mounted on:          /boot
Filesystem UUID:          eaa5734f-5937-47d8-b956-e1b186f4bcd1
Filesystem magic number:  0xEF53
Filesystem revision #:    1 (dynamic)
... ...
```

* dumpe2fs

```
# dumpe2fs /dev/vda1           # 可以获取更详细的信息
dumpe2fs 1.41.12 (17-May-2010)
Filesystem volume name:   /boot/
Last mounted on:          /boot
Filesystem UUID:          eaa5734f-5937-47d8-b956-e1b186f4bcd1
Filesystem magic number:  0xEF53
Filesystem revision #:    1 (dynamic)
```

### 国内 NTP 权威网站

* [www.pool.ntp.org](http://www.pool.ntp.org/zone/cn)

### 文件系统修复

* 强制重启 fsck 文件系统

```
touch /forcefsck
echo y > forcefsck
reboot
```

__注__: CentOS 5 可以使用 `shutdown -rF now` 强制修复文件系统，但是 CentOS 6 已经失效了，推荐采用上面的方式强制重启修复文件系统

* [How to Check and Repair EXT3/EXT4 Filesystem on Linux](http://www.vmexplore.com/check-repair-ext3-ext4-filesystem-oracle-linux/)

### Linux OOM

* [OOM Control and Notifications](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Resource_Management_Guide/sec-memory.html)
* [OOM Killer value always one less than set](http://unix.stackexchange.com/questions/128013/oom-killer-value-always-one-less-than-set)

### dmidecode && MegaCli

* 查看机器型号

```
# dmidecode | grep "Product"
```

* 查看厂商

```
# dmidecode| grep  "Manufacturer"
```

* 查看序列号

```
# dmidecode | grep  "Serial Number"
```

* 查看 CPU 信息

```
# dmidecode | grep  "CPU"
```

* 查看 CPU 个数

```
# dmidecode | grep  "Socket Designation: CPU" |wc –l
```

* 查看出厂日期

```
# dmidecode | grep "Date"
```

* 查看充电状态

```
# MegaCli -AdpBbuCmd -GetBbuStatus -aALL |grep "Charger Status"
```

* 显示 BBU 状态信息

```
# MegaCli -AdpBbuCmd -GetBbuStatus –aALL
```

* 显示 BBU 容量信息

```
# MegaCli -AdpBbuCmd -GetBbuCapacityInfo –aALL
```

* 显示 BBU 设计参数

```
# MegaCli -AdpBbuCmd -GetBbuDesignInfo –aALL
```

* 显示当前 BBU 属性

```
# MegaCli -AdpBbuCmd -GetBbuProperties –aALL
```

* 查看充电进度百分比

```
# MegaCli -AdpBbuCmd -GetBbuStatus -aALL |grep "Relative State of Charge"
```

* 查询 Raid 阵列数

```
# MegaCli -cfgdsply -aALL |grep "Number of DISK GROUPS:"
```

* 显示 Raid 卡型号，Raid 设置，Disk 相关信息

```
# MegaCli -cfgdsply –aALL
```

* 显示所有物理信息

```
# MegaCli -PDList -aALL
```

* 显示所有逻辑磁盘组信息

```
# MegaCli -LDInfo -LALL –aAll
```

* 查看物理磁盘重建进度(重要)

```
# MegaCli -PDRbld -ShowProg -PhysDrv [1:5] -a0
```

* 查看适配器个数

```
# MegaCli –adpCount
```

* 查看适配器时间

```
# MegaCli -AdpGetTime –aALL
```

* 显示所有适配器信息

```
# MegaCli -AdpAllInfo –aAll
```

* 查看 Cache 策略设置

```
# MegaCli -cfgdsply -aALL |grep Polic
```

更多参考:[DELL磁盘阵列控制卡（RAID卡）MegaCli常用管理命令汇总](http://zh.community.dell.com/techcenter/b/weblog/archive/2013/03/07/megacli-command-share)

### root ulimit

/etc/init.d/ 下 root 用户启动的服务还和 `/etc/sysconfig/init` 相关，默认 nofile `1024`「但是该文件不建议修改，可以考虑使用非 root 用户管理服务或者针对相应服务作修改」

### RubyGems

```
$ gem sources --remove https://rubygems.org/
$ gem sources -a https://ruby.taobao.org/
$ gem sources -l
*** CURRENT SOURCES ***

https://ruby.taobao.org
# 请确保只有 ruby.taobao.org
$ gem install rails
```

### ssh

* 通过 ssh 私钥获取公钥

```
ssh-keygen -y -f .ssh/id_rsa
```

* `~/.ssh/config`

```
➜  ~  cat ~/.ssh/config
HOST *
    Port 22
    User root
    controlmaster auto
    controlPath ~/.ssh/master-%r@%h:%p
    ServerAliveInterval 30
    StrictHostKeyChecking no
```

### SysVinit to Systemd Cheatsheet

* [SysVinit to Systemd Cheatsheet](https://fedoraproject.org/wiki/SysVinit_to_Systemd_Cheatsheet)

## 四、MySQL

### mysqldump

* 全备

```
mysqldump --hex-blob --single-transaction --alldatabase --master-data=1 > all.sql
```

Dump binary strings (BINARY, VARBINARY, BLOB) in hexadecimal format (for example, ′abc′ becomes 0x616263). The affected data types are BINARY, VARBINARY, the BLOB types, and BIT.

* mysqldump --ignore-database

```
mysqldump --databases `mysql -uroot --skip-column-names \
    -e "SELECT GROUP_CONCAT(schema_name SEPARATOR ' ') \
    FROM information_schema.schemata WHERE schema_name \
    NOT IN ('mysql','performance_schema','information_schema');"` \
    > backup.sql
```

OR

```
echo '[mysqldump]' > mydump.cnf
mysql -NBe "select concat('ignore-table=', table_schema, '.', table_name) \
    from information_schema.tables \
    where table_schema in ('mysql', 'personnel', 'buildings')" \
    >> mydump.cnf
```

Now the options file looks like this:

```
[mysqldump]
ignore-table=mysql.db
ignore-table=mysql.host
ignore-table=mysql.user
[...]
```

```
mysqldump --defaults-file=./mydump.cnf  -u $DBUSER -p$DBPWD --all-databases
```

* 只备份表结构 [--no-data] 选项

```
mysqldump --no-data --databases ... ...
```

### mysqlbinlog

* row 格式查看

```
mysqlbinlog -v -v --base64-output=DECODE-ROWS binlog文件名
```

### 从库跳过错误日志

```
mysql> STOP SLAVE;
mysql> SET GLOBAL SQL_SLAVE_SKIP_COUNTER = 1; # 1 表示跳过 1 个 events
mysql> START SLAVE;
```

### ROW_FORMAT

* 查看当前数据库下的所有表的 ROW_FORMAT

```
mysql> SELECT `table_name`, `row_format` FROM `information_schema`.`tables` WHERE `table_schema`=DATABASE();
```

* 查看指定表 ROW_FORMAT

```
mysql> SHOW TABLE STATUS LIKE 'table_name'\G
```

### MySQL 读取配置文件顺序

```
$ mysql --help | grep 'my.cnf' # 相同选项以最后一个配置文件选项为主
/etc/my.cnf /etc/mysql/my.cnf /usr/local/etc/my.cnf ~/.my.cnf
```

## 五、Nginx

* 域名子目录访问跳转到其它网站

```
server {
... ...
           location ^~ /test/ {
               rewrite ^/test/(.*) /$1 break;
               proxy_pass http://www.test.com;
           }
... ...
}
```

* 404 页面 301 重定向到主页

```
server {
... ...
           location / {
               error_page 404 =  @foobar;
           }

           location @foobar {
               rewrite  .*  / permanent;
           }
... ...
}
```

* Nginx 配置 ip 直接访问的默认站点

```
server {
    ... ...
    listen 80 default;
    ... ...
}
```

* uwsgi

```
server {
    listen   80;
    server_name www.test.com;

    location / {
        include uwsgi_params;
        uwsgi_pass 127.0.0.1:8000;
    }

    location /static {
        alias /data/www/project/app/static;
    }
    ... ...
}
```

## 六、Golang

### go get

* go get
    * 获取第三方包
* go get -u all
    * [update the third package](http://stackoverflow.com/questions/10383498/how-does-go-update-third-party-packages)
* [go get](https://github.com/hyper-carrot/go_command_tutorial/blob/master/0.3.md)

### go 命令标准教程

* [标准命令详解](https://github.com/hyper-carrot/go_command_tutorial/blob/master/catalog.md)

## 七、Other

### jekyll

* {{}} 转义

jekyll 在解析 Markdown 转义的时候会把 {{}} 识别为模板变量，所以需要通过转义解决这个问题：

```
{% raw %}Hello, my name is {{name}}.{% endraw %}
```

### Docker

* 国内 Docker 加速器
    * [阿里云Docker加速器](https://help.aliyun.com/knowledge_detail/5974865.html)
    * [DaoCloud](https://dashboard.daocloud.io/mirror)
    * [灵雀云加速](http://docs.alauda.cn/feature/accelerator.html)

### wiki

* [wiki.mikejung.biz](https://wiki.mikejung.biz/Main_Page)

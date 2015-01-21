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


## 三、Linux

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

## CentOS 7/RHEL 7

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
$ mysql --help | grep '/etc/my.cnf' # 相同选项以最后一个配置文件选项为主
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

## 六、Other

### jekyll

* {{}} 转义

jekyll 在解析 Markdown 转义的时候会把 {{}} 识别为模板变量，所以需要通过转义解决这个问题：

```
{% raw %}Hello, my name is {{name}}.{% endraw %}
```

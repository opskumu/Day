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

## 四、MySQL

### mysqldump

* 全备

```
mysqldump --hex-blob --single-transaction --alldatabase --master-data=1 > all.sql
```

Dump binary strings (BINARY, VARBINARY, BLOB) in hexadecimal format (for example, ′abc′ becomes 0x616263). The affected data types are BINARY, VARBINARY, the BLOB types, and BIT.

### mysqlbinlog

* row 格式查看

```
mysqlbinlog -v -v --base64-output=DECODE-ROWS binlog文件名
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

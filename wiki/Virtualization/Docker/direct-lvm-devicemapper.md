# Docker 使用 Direct-LVM devicemapper

## 一、Device Mapper: loop-lvm

默认 CentOS7 下 Docker 使用的 Device Mapper 设备默认使用 loopback 设备，后端为自动生成的稀疏文件，如下:

``` bash
# ls -lsh /var/lib/docker/devicemapper/devicemapper/
总用量 510M
508M -rw-------. 1 root root 100G 10月 30 00:00 data
1.9M -rw-------. 1 root root 2.0G 10月 30 00:00 metadata
```

data [存放数据] 和 metadata [存放元数据] 的大小从输出可以看出初始化默认为 100G 和 2G 大小，都是稀疏文件，使用多少占用多少。

Docker 在初始化的过程中，创建 data 和 metadata 这两个稀疏文件，并分别附加到回环设备 `/dev/loop0` 和 `/dev/loop1` 上，然后基于回环设备创建 [thin pool](https://www.kernel.org/doc/Documentation/device-mapper/thin-provisioning.txt)。 默认一个 container 最大存放数据不超过 10G[注：docker 1.8 之后默认的大小已经为 100G，建议生产环境针对 container pool 大小监控。]，如果需要调整则需要修改 `/etc/sysconfig/docker` 配置文件添加相关选项 `--storage-opt` 调整即可（详细参考 man docker 查看 STORAGE DRIVER OPTIONS 具体参数说明）。

``` bash
# docker info
Containers: 2
Images: 13
Storage Driver: devicemapper
 Pool Name: docker-253:1-100673362-pool
 Pool Blocksize: 65.54 kB
 Backing Filesystem: xfs
 Data file: /dev/loop0
 Metadata file: /dev/loop1
 Data Space Used: 533.5 MB
 Data Space Total: 107.4 GB
 Data Space Available: 40.75 GB
 Metadata Space Used: 1.221 MB
 Metadata Space Total: 2.147 GB
 Metadata Space Available: 2.146 GB
 Udev Sync Supported: true
 Data loop file: /var/lib/docker/devicemapper/devicemapper/data
 Metadata loop file: /var/lib/docker/devicemapper/devicemapper/metadata
... ...
# lsblk
... ...
loop0                                                                                         7:0    0  100G  0 loop
└─docker-253:1-100673362-pool                                                               252:0    0  100G  0 dm
  ├─docker-253:1-100673362-61f1302169c719e4f671942d6158bba061a0b5081c98d40e8ca9749f1a521ca4 252:1    0   10G  0 dm
  └─docker-253:1-100673362-79c4340c3e06584d4e3630ad4a9b3a768066a52b0a04c9cb7bffa0b45bec8747 252:2    0   10G  0 dm
loop1                                                                                         7:1    0    2G  0 loop
└─docker-253:1-100673362-pool                                                               252:0    0  100G  0 dm
  ├─docker-253:1-100673362-61f1302169c719e4f671942d6158bba061a0b5081c98d40e8ca9749f1a521ca4 252:1    0   10G  0 dm
  └─docker-253:1-100673362-79c4340c3e06584d4e3630ad4a9b3a768066a52b0a04c9cb7bffa0b45bec8747 252:2    0   10G  0 dm
... ...
```

## 二、Device Mapper: direct-lvm

direct-lvm 也是使用 LVM， device mapper the dm-thinp 内核模块，使用 direct-lvm 不再使用 loopback 设备，直接使用 raw 分区(no filesystem)，在中等负载和高密度环境下会有更好的性能优势，另外官方也是不建议生产环境系统使用默认的 LVM thin pool，至于两种类型具体的性能对比可以参考 [Comprehensive Overview of Storage Scalability in Docker](https://developerblog。redhat。com/2014/09/30/overview-storage-scalability-docker/) 这篇文章。

CentOS7 从 `docker-1.6.2-14.el7.centos.x86_64.rpm` 开始提供 `docker-storage-setup` 工具，方便配置 direct-lvm，所以推荐使用该工具配置。当然也可以手动配置 lvm，添加相关配置选项，不过过程较为繁琐一点，至于如何手动配置笔者没有尝试，不过本文附加了相关部署的参考文章，有需求的可以看看，这里只介绍使用 `docker-storage-setup` 配置 direct-lvm。

示例配置文件位置 `/usr/lib/docker-storage-setup/docker-storage-setup`，可以查看其中相关配置的详细说明，或者通过 `man docker-storage-setup` 获取帮助，以下介绍几个关键的选项：

* DATA_SIZE=40%FREE
    * 定义创建 DATA thin pool 的大小，默认为 VG 的 40%
* MIN_DATA_SIZE=2G
    * 定义 DATA pool 最小值，默认为 2G，如果 VG 小于 2G 则创建失败
* CHUNK_SIZE=512K
    * 定义 thin pool 的 CHUNK 大小，默认 512k
* AUTO_EXTEND_POOL=yes
    * 定义是否自动扩容 thin pool 大小，默认为自动扩容
* POOL_AUTOEXTEND_THRESHOLD=60
    * 定义自动扩容的百分比，默认为当前 pool 使用 60% 时自动扩容，100 表示 disable，最小为 50 [lvmthin — LVM thin provisioning](http://man7.org/linux/man-pages/man7/lvmthin.7.html)
* POOL_AUTOEXTEND_PERCENT=20
    * 定义每次扩容的大小，默认为 20%，即当前 pool 大小为 100G，那么自动扩容 20G，扩容后大小为 120G， 100 表示 disable

docker-storage-setup 设置之后自动扩容的实际配置在 `/etc/lvm/profile/` 目录下：

因为测试的 LVM 卷组名为 docker-vg，因此 docker-storage-setup 自动生成配置文件为 `/etc/lvm/profile/docker-vg--docker-pool-extend.profile`

```
# cat /etc/lvm/profile/docker-vg--docker-pool-extend.profile
activation {
        thin_pool_autoextend_threshold=60
        thin_pool_autoextend_percent=20
}
```

使用 `lvs -o+seg_monitor` 可验证监控状态。

### 示例

主机先添加一块设备，本例设备名为 `/dev/vdc`，添加 `docker-storage-setup` 配置文件：

``` bash
# systemctl stop docker # 停止当前运行的 docker
# cat /etc/sysconfig/docker-storage-setup
DEVS=/dev/vdc   # A quoted, space-separated list of devices to be used. 如果添加多个设备则以空格分隔 DEVS="/dev/sdc /dev/sdd /dev/sde"
VG=docker-vg    # The volume group to use for docker storage.
SETUP_LVM_THIN_POOL=yes
# docker-storage-setup  # 执行 setup 操作，相关 lvm 将自动创建
```

创建完成之后，可以查看相关的配置

``` bash
# cat /etc/sysconfig/docker-storage     # 配置已经自动修改
DOCKER_STORAGE_OPTIONS=-s devicemapper --storage-opt dm.fs=xfs --storage-opt dm.thinpooldev=/dev/mapper/docker--vg-docker--pool
# grep 'sysconfig/docker-storage' /usr/lib/systemd/system/docker.service
EnvironmentFile=-/etc/sysconfig/docker-storage  # 可以看出 docker 启动会自动加载该配置文件
```

删除源数据并启动 docker

``` bash
# cat /etc/sysconfig/docker-storage-setup
# DEVS=/dev/vdc     # 注释该行
VG=docker-vg
SETUP_LVM_THIN_POOL=yes
# rm -rf /var/lib/docker
# systemctl restart lvm2-monitor    # 确保 lvm2-monitor 服务运行
# systemctl start docker
```

``` bash
# docker info
Containers: 39
Images: 98
Storage Driver: devicemapper
 Pool Name: docker--vg-docker--pool     # 此处已经变为相关的设备文件
 Pool Blocksize: 524.3 kB
 Backing Filesystem: <unknown>
 Data file:
 Metadata file:
 Data Space Used: 14.16 GB
 Data Space Total: 64.35 GB
 Data Space Available: 50.19 GB
 Metadata Space Used: 4.702 MB
 Metadata Space Total: 109.1 MB
 Metadata Space Available: 104.3 MB
 Udev Sync Supported: true
 Library Version: 1.02.93-RHEL7 (2015-01-28)
... ...
```

## 三、参考

* Docker 官方文档：
    * [Docker and the Device Mapper storage driver](https://docs.docker.com/engine/userguide/storagedriver/device-mapper-driver/)
* 性能相关:
    * [random I/O performance improves when increasing thinp chunksize](https://github.com/projectatomic/docker-storage-setup/issues/31#issuecomment-104387530)
    * [Comprehensive Overview of Storage Scalability in Docker](https://developerblog.redhat.com/2014/09/30/overview-storage-scalability-docker/)
    * [Performance Tuning of Docker and RHEL Atomic](http://devconf.cz/files/slides2015/friday/Performance%20Tuning%20of%20Docker%20and%20RHEL%20Atomic.pdf)
* 部署相关:
    * [Managing Storage with Docker Formatted Containers on Red Hat Enterprise Linux and Red Hat Enterprise Linux Atomic Host](https://access.redhat.com/articles/1492923)
    * [Friends Don't Let Friends Run Docker on Loopback in Production](http://www.projectatomic.io/blog/2015/06/notes-on-fedora-centos-and-docker-storage-drivers/)
    * [docker-storage-setup](https://ekuric.wordpress.com/2015/07/17/docker-storage-setup/)
    * [Docker and devicemapper`s thinpool in RHEL 7](http://unpoucode.blogspot.hk/2015/06/docker-and-devicemappers-thinpool-in。html)
    * [Setting Up Storage](http://www.projectatomic.io/docs/docker-storage-recommendation/)

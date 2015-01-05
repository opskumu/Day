# 日常问题处理 Tips

## OpenNebula

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

## git/svn

* git 忽略文件 `.gitignore`

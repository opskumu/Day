# Keepalived

keepalived 原理图：

![Keepalived Software Design](http://www.keepalived.org/images/Software%20Design.gif)

## Keepalived + HAproxy HA 

* Master

```
! Configuration File for keepalived

global_defs {
    # notification email configure
    notification_email {
        x@test.com
    }
    notification_email_from alert@test.com
    smtp_server 127.0.0.1 
    smtp_connect_timeout 30
    smtp_alert			                        # 开启邮件通知
    router_id keepalived-192-168-0-9            # 节点唯一标识，便于邮件通知角色确认，推荐使用主机名代替
}

vrrp_script chk_haproxy {
    script "/etc/keepalived/check_haproxy.sh"	# 监测 HAproxy 是否正常运行
    interval 4					                # 监测间隔
}

vrrp_instance HA_V1 {
    state BACKUP 		    # 实例角色
    interface eth0	        # 心跳监测网卡（监测网卡需有 IP，VRRP 广播）
    virtual_router_id 89	# VRRP instance 实例唯一标识 ID（取值范围 1~255）
    priority 101		    # keepalived 权重设置
    nopreempt			    # 设置非抢占模式，只有 BACKUP state 生效
    advert_int 1		    # VRRP 监测间隔
    authentication {		# 认证设置
        auth_type PASS
        auth_pass 1111
    }

    track_script {		    # 监测脚本
        chk_haproxy
    }

    virtual_ipaddress {		# vip 绑定
    }

    # 因 virtual_ipaddress 20 vip 限制，启用该选项实现 vip > 20 (为减少回应 VRRP 的个数，发送的 VRRP 包中不含以下 IP)
    virtual_ipaddress_excluded {
        192.168.0.5 dev eth1
        192.168.0.6 dev eth1
    }
}
```

* BACKUP

```
! Configuration File for keepalived

global_defs {
    # notification email configure
    notification_email {
        x@test.com
    }
    notification_email_from alert@test.com
    smtp_server 127.0.0.1 
    smtp_connect_timeout 30
    smtp_alert			                        # 开启邮件通知
    router_id keepalived-192-168-0-10           # 节点唯一标识，便于邮件通知角色确认，推荐使用主机名代替
}

vrrp_script chk_haproxy {
    script "/etc/keepalived/check_haproxy.sh"	# 监测 HAproxy 是否正常运行
    interval 4					                # 监测间隔
}

vrrp_instance HA_V1 {
    state BACKUP 		    # 实例角色
    interface eth0	        # 心跳监测网卡（监测网卡需有 IP，VRRP 广播）
    virtual_router_id 89	# VRRP instance 实例唯一标识 ID（取值范围 1~255）
    priority 100		    # keepalived 权重设置
    nopreempt			    # 设置非抢占模式，只有 BACKUP state 生效
    advert_int 1		    # VRRP 监测间隔
    authentication {		# 认证设置
        auth_type PASS
        auth_pass 1111
    }

    track_script {		    # 监测脚本
        chk_haproxy
    }

    virtual_ipaddress {		# vip 绑定
    }

    # 因 virtual_ipaddress 20 vip 限制，启用该选项实现 vip > 20 (为减少回应 VRRP 的个数，发送的 VRRP 包中不含以下 IP)
    virtual_ipaddress_excluded {
        192.168.0.5 dev eth1
        192.168.0.6 dev eth1
    }
}
```

* `/etc/keepalived/check_haproxy.sh`

```
#!/bin/bash

if ! pidof haproxy &>/dev/null;then
    service haproxy start &>/dev/null
    sleep 1
    if ! pidof haproxy &>/dev/null;then
        service keepalived stop &>/dev/null
        exit 1
    fi
fi
```

> 注: 如果使用 `nopreempt` 模式，则 check_haproxy 脚本检测到 HAproxy 没有运行并启动失败，此时 weight 大小是不能控制 vip 漂移的，因此本脚本通过 stop keepalived 服务，才会做到 vip 漂移。

* [Keepalived UserGuide](http://www.keepalived.org/pdf/UserGuide.pdf)
* [How to Enable Email Alerts in Keepalived](http://tecadmin.net/how-to-enable-email-alerts-in-keepalived/)
* [Keepalived Notification and Tracking Scripts](https://docs.oracle.com/cd/E37670_01/E41138/html/section_hxz_zdw_pr.html)

更详细的解释:

* man keepalived.conf

# chrony

chrony 是 RHEL7 新增的一个 NTP 同步程序，[Configuring NTP Using the chrony Suite](Configuring NTP Using the chrony Suite)

```
# yum install chrony -y                     # 安装服务
# systemctl start chronyd                   # 启动 chronyd 服务
# systemctl status chronyd                  # 查看当前 chronyd 服务状态
# timedatectl  | grep "NTP synchronized"    # 查看 ntp 是否启用
# timedatectl set-ntp yes                   # 启用 ntp 同步
# vim /etc/chrony.conf                      # 配置文件，一般不用修改，国内 NTP 同步 Server http://www.pool.ntp.org/zone/cn
# chronyc tracking                          # 查看系统同步状态
Reference ID    : 202.112.29.82 (dns1.synet.edu.cn)
Stratum         : 3
Ref time (UTC)  : Wed Jul 27 08:57:53 2016
System time     : 0.000435557 seconds slow of NTP time
Last offset     : -0.000343253 seconds
RMS offset      : 0.001299361 seconds
Frequency       : 24.292 ppm slow
Residual freq   : -5.479 ppm
Skew            : 7.730 ppm
Root delay      : 0.042399 seconds
Root dispersion : 0.000968 seconds
Update interval : 64.5 seconds
Leap status     : Normal
# chronyc sources -v                        # 查看系统同步源
210 Number of sources = 3

  .-- Source mode  '^' = server, '=' = peer, '#' = local clock.
   / .- Source state '*' = current synced, '+' = combined , '-' = not combined,
   | /   '?' = unreachable, 'x' = time may be in error, '~' = time too variable.
   ||                                                 .- xxxx [ yyyy ] +/- zzzz
   ||      Reachability register (octal) -.           |  xxxx = adjusted offset,
   ||      Log2(Polling interval) --.      |          |  yyyy = measured offset,
   ||                                \     |          |  zzzz = estimated error.
   ||                                 |    |           \
   MS Name/IP address         Stratum Poll Reach LastRx Last sample
   ===============================================================================
   ^* dns1.synet.edu.cn             2   6   177    11   +452us[ +448us] +/-   23ms
   ^- ntp.mega.kg                   3   6   177    11    -19ms[  -19ms] +/-  258ms
   ^- time.iqnet.com                2   7   241     3    -11ms[  -11ms] +/-  297ms
# hwclock -w                                # 同步硬件时间与系统时间一致
```

# ntp

```
# grep -vE '^#|^$' /etc/ntp.conf
driftfile /var/lib/ntp/drift
restrict default kod nomodify notrap nopeer noquery
restrict -6 default kod nomodify notrap nopeer noquery
restrict 127.0.0.1
restrict -6 ::1
server 0.centos.pool.ntp.org
server 1.centos.pool.ntp.org
server 2.centos.pool.ntp.org
includefile /etc/ntp/crypto/pw
keys /etc/ntp/keys
```

* `driftfile` 选项， 则指定了用来保存系统时钟频率偏差的文件。 `ntpd` 程序使用它来自动地补偿时钟的自然漂移， 从而使时钟即使在切断了外来时源的情况下， 仍能保持相当的准确度。另外，`driftfile` 选项也保存上一次响应所使用的 NTP 服务器的信息。 这个文件包含了 NTP 的内部信息， 它不应被任何其他进程修改。
* `restrict default kod nomodify notrap nopeer noquery`  默认拒绝所有 NTP 客户端的操作 `restrict <IP 地址> <子网掩码>|<网段>[ignore|nomodiy|notrap|notrust|nknod]` 指定可以通信的 IP 地址和网段。如果没有指定选项，表示客户端访问 NTP 服务器没有任何限制
    * `ignore`:     关闭所有 NTP 服务
    * `nomodiy`:    表示客户端不能更改 NTP 服务器的时间参数，但可以通过 NTP 服务器进行时间同步
    * `notrust`:    拒绝没有通过认证的客户端
    * `knod`:       `kod` 技术阻止 "Kiss of Death" 包（一种 DOS 攻击）对服务器的破坏，使用 `knod` 开启功能
    * `nopeer`:     不与其它同一层的 NTP 服务器进行同步
* `server [IP|FQDN|prefer]` 指该服务器上层 NTP Server，使用 prefer 的优先级最高，没有使用 prefer 则按照配置文件顺序由高到低，默认情况下至少 15min 和上层 NTP 服务器进行时间校对
* `fudge`: 可以指定本地 NTP Server 层，如 `fudge 127.0.0.1 stratum 9`
* `broadcast 网段 子网掩码`: 指定 NTP 进行时间广播的网段，如 `broadcast 192.168.1.255`
* `logfile`: 可以指定 NTP Server 日志文件

几个与 NTP 相关的配置文件: `/usr/share/zoneinfo/`、`/etc/sysconfig/clock`、`/etc/localtime`

* `/usr/share/zoneinfo/`:  存放时区文件目录
* `/etc/sysconfig/clock`:  指定当前系统时区信息
* `/etc/localtime`:        相应的时区文件

如果需要修改当前时区，则可以从 `/usr/share/zoneinfo/` 目录拷贝相应时区文件覆盖 `/etc/localtime` 并修改 `/etc/sysconfig/clock` 即可

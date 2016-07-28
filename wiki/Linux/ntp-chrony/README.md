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

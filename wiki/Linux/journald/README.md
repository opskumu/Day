# jounald

## journalctl

```
# journalctl -f -u sshd                                                             # 动态获取当前服务日志
-- Logs begin at Mon 2016-05-23 19:12:05 CST. --
May 23 16:50:08 contiv-1 sshd[7376]: Failed password for root from 192.168.182.1 port 52648 ssh2
May 23 16:50:10 contiv-1 sshd[7376]: Accepted password for root from 192.168.182.1 port 52648 ssh2
# journalctl --since "2016-04-20 6:00:00" --until "2016-07-20 7:30:00" -u sshd      # 指定某个时间段的日志
# journalctl -p err -b                                                              # 只输出类型为错误的日志
```

## Configuring journald to make it persistent

journald 的缺点是在系统重启之后所有的日志都会丢失，可以通过如下方式让 journald 永久保存：

```
# mkdir /var/log/journal
# systemd-tmpfiles --create --prefix /var/log/journal/
# systemctl restart systemd-journald
```

可 reboot 通过以下命令确认：

```
# journalctl --boot=-1                                  # This will show us all journal information from the last boot.
```

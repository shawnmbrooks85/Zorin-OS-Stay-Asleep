# Stay Asleep

Exported on 2026-04-28 from this machine after fixing unwanted wake from sleep.

## What was fixed

- Disabled USB / PCI / ACPI wake sources that were waking the workstation.
- Installed a persistent systemd service: `mini-disable-wakeup.service`.
- Cleared the RTC wake alarm.
- Locked the session.
- Scheduled sleep immediately.

## Exported files

- `mini-disable-wakeup.service` - systemd unit installed at:
  `/etc/systemd/system/mini-disable-wakeup.service`
- `mini-disable-wakeup.sh` - wake-source disabling script installed at:
  `/usr/local/sbin/mini-disable-wakeup.sh`
- `commands.sh` - command record for reinstalling, running, checking, and sleeping.

## Current installed service

The service is enabled and installed at:

```bash
/etc/systemd/system/mini-disable-wakeup.service
```

It runs:

```bash
/usr/local/sbin/mini-disable-wakeup.sh
```

The service is configured to run after normal boot and after sleep-related targets:

```text
multi-user.target
suspend.target
hibernate.target
hybrid-sleep.target
suspend-then-hibernate.target
```

## Reinstall from this folder

From `/home/shawn/Desktop/Stay Asleep`:

```bash
sudo install -m 0755 mini-disable-wakeup.sh /usr/local/sbin/mini-disable-wakeup.sh
sudo install -m 0644 mini-disable-wakeup.service /etc/systemd/system/mini-disable-wakeup.service
sudo systemctl daemon-reload
sudo systemctl enable mini-disable-wakeup.service
sudo systemctl start mini-disable-wakeup.service
```

## Check status

```bash
systemctl status mini-disable-wakeup.service --no-pager
systemctl is-enabled mini-disable-wakeup.service
```

## Run the fix manually

```bash
sudo /usr/local/sbin/mini-disable-wakeup.sh
```

## Clear RTC wake alarm manually

```bash
echo 0 | sudo tee /sys/class/rtc/rtc0/wakealarm
```

## Lock and sleep now

```bash
loginctl lock-session
systemctl suspend
```

## Inspect wake sources

```bash
cat /proc/acpi/wakeup
find /sys/bus/pci/devices -path '*/power/wakeup' -print -exec cat {} \;
find /sys/bus/usb/devices -path '*/power/wakeup' -print -exec cat {} \;
```

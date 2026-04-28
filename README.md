# Zorin OS Stay Asleep

Persistent wake-source disabling for a Zorin OS / Ubuntu-based desktop that keeps waking immediately after suspend.

This repository exports the exact systemd service and shell script used to keep one workstation asleep by disabling problematic USB, PCI, and ACPI wake sources before and after sleep-related systemd targets.

## What This Fix Does

- Disables selected ACPI wake devices listed in `/proc/acpi/wakeup`.
- Disables selected PCI device wake flags under `/sys/bus/pci/devices/*/power/wakeup`.
- Clears the RTC wake alarm at `/sys/class/rtc/rtc0/wakealarm`.
- Installs a persistent systemd oneshot service so the settings are re-applied automatically.
- Provides simple commands to reinstall, run manually, check status, lock the session, and suspend.

## Why This Exists

Some Linux desktops wake up immediately after suspend because a USB controller, PCI root port, ACPI wake entry, or RTC alarm is allowed to wake the machine. These wake permissions can reset across boots or after suspend cycles.

The service in this repo reapplies the known-good wake settings automatically.

This was exported on `2026-04-28` after fixing unwanted wake behavior on a Zorin OS workstation.

## Files

| File | Purpose |
| --- | --- |
| `mini-disable-wakeup.service` | systemd service unit |
| `mini-disable-wakeup.sh` | script that disables the wake sources and clears RTC wake alarm |
| `commands.sh` | convenience command record for reinstalling and testing |
| `README.md` | documentation |

## Compatibility

Tested on Zorin OS, which is Ubuntu-based.

This may also work on other systemd-based Linux distributions, especially Ubuntu-family systems, but the PCI and ACPI device names in `mini-disable-wakeup.sh` are machine-specific. Review the device list before using it on different hardware.

## Install

Clone the repo:

```bash
git clone https://github.com/shawnmbrooks85/Zorin-OS-Stay-Asleep.git
cd Zorin-OS-Stay-Asleep
```

Install the script and service:

```bash
sudo install -m 0755 mini-disable-wakeup.sh /usr/local/sbin/mini-disable-wakeup.sh
sudo install -m 0644 mini-disable-wakeup.service /etc/systemd/system/mini-disable-wakeup.service
sudo systemctl daemon-reload
sudo systemctl enable mini-disable-wakeup.service
sudo systemctl start mini-disable-wakeup.service
```

## Check Status

```bash
systemctl status mini-disable-wakeup.service --no-pager
systemctl is-enabled mini-disable-wakeup.service
```

A successful run should exit with status `0/SUCCESS`. Because this is a `oneshot` service, it is normal for it to show as inactive/dead after it finishes.

## Run Manually

```bash
sudo /usr/local/sbin/mini-disable-wakeup.sh
```

## Lock And Suspend

```bash
loginctl lock-session
systemctl suspend
```

## Service Behavior

The service is installed at:

```text
/etc/systemd/system/mini-disable-wakeup.service
```

It runs:

```text
/usr/local/sbin/mini-disable-wakeup.sh
```

It is enabled for:

```text
multi-user.target
suspend.target
hibernate.target
hybrid-sleep.target
suspend-then-hibernate.target
```

## Inspect Wake Sources

Show ACPI wake entries:

```bash
cat /proc/acpi/wakeup
```

Show PCI wake settings:

```bash
find /sys/bus/pci/devices -path '*/power/wakeup' -print -exec cat {} \;
```

Show USB wake settings:

```bash
find /sys/bus/usb/devices -path '*/power/wakeup' -print -exec cat {} \;
```

Show the RTC wake alarm:

```bash
cat /sys/class/rtc/rtc0/wakealarm
```

Clear the RTC wake alarm:

```bash
echo 0 | sudo tee /sys/class/rtc/rtc0/wakealarm
```

## Customize For Another Machine

Edit `mini-disable-wakeup.sh` and adjust:

- ACPI device names in the first loop, such as `XHC`, `RP09`, or `PEG0`.
- PCI device paths under `/sys/bus/pci/devices/.../power/wakeup`.

Use these commands to discover wake-capable devices:

```bash
cat /proc/acpi/wakeup
find /sys/bus/pci/devices -path '*/power/wakeup' -print -exec cat {} \;
find /sys/bus/usb/devices -path '*/power/wakeup' -print -exec cat {} \;
```

After editing, reinstall and restart the service:

```bash
sudo install -m 0755 mini-disable-wakeup.sh /usr/local/sbin/mini-disable-wakeup.sh
sudo systemctl restart mini-disable-wakeup.service
```

## Disable Or Remove

Disable the service:

```bash
sudo systemctl disable --now mini-disable-wakeup.service
```

Remove installed files:

```bash
sudo rm -f /etc/systemd/system/mini-disable-wakeup.service
sudo rm -f /usr/local/sbin/mini-disable-wakeup.sh
sudo systemctl daemon-reload
```

## Notes

- These wake settings are hardware-specific.
- The script is intentionally defensive: missing paths are skipped.
- The service does not prevent manual wake by the power button.
- If the system still wakes unexpectedly, check firmware/BIOS wake settings, Wake-on-LAN, USB keyboard/mouse wake, scheduled RTC alarms, and desktop power-management tools.

## License

MIT License. Use, modify, and adapt for your own machine.

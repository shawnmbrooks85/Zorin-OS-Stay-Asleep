#!/usr/bin/env bash
set -euo pipefail

# Disable selected non-input wake sources.
#
# Keep USB controller wake enabled so keyboard, mouse, and power-button recovery
# still work after suspend. The earlier version disabled XHC/RP05/RP07 and could
# make this workstation difficult to wake.
for dev in RP09 RP02 RP17 RP21 PEG0; do
  if grep -q "^${dev}[[:space:]]" /proc/acpi/wakeup 2>/dev/null && grep "^${dev}[[:space:]]" /proc/acpi/wakeup | grep -q '\*enabled'; then
    echo "$dev" > /proc/acpi/wakeup || true
  fi
done

for path in \
  /sys/bus/pci/devices/0000:00:1d.0/power/wakeup \
  /sys/bus/pci/devices/0000:00:1c.1/power/wakeup \
  /sys/bus/pci/devices/0000:00:1b.0/power/wakeup \
  /sys/bus/pci/devices/0000:00:1b.4/power/wakeup; do
  if [ -w "$path" ]; then
    echo disabled > "$path" || true
  fi
done

# Preserve wake from the main USB controller, ASMedia USB controllers, and the
# physical power button.
for path in \
  /sys/bus/pci/devices/0000:00:14.0/power/wakeup \
  /sys/bus/pci/devices/0000:00:1c.4/power/wakeup \
  /sys/bus/pci/devices/0000:06:00.0/power/wakeup \
  /sys/bus/pci/devices/0000:00:1c.6/power/wakeup \
  /sys/bus/pci/devices/0000:07:00.0/power/wakeup \
  /sys/devices/LNXSYSTM:00/LNXPWRBN:00/power/wakeup \
  /sys/devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/power/wakeup; do
  if [ -w "$path" ]; then
    echo enabled > "$path" || true
  fi
done

# Clear RTC wake alarm if any userspace timer set one.
echo 0 > /sys/class/rtc/rtc0/wakealarm 2>/dev/null || true

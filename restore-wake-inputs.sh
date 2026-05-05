#!/usr/bin/env bash
set -euo pipefail

# Recovery helper: re-enable wake for USB input paths and physical power button.
for dev in XHC RP05 RP07; do
  if grep -q "^${dev}[[:space:]]" /proc/acpi/wakeup 2>/dev/null && grep "^${dev}[[:space:]]" /proc/acpi/wakeup | grep -q '\*disabled'; then
    echo "$dev" > /proc/acpi/wakeup || true
  fi
done

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

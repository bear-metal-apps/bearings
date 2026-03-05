#!/usr/bin/env bash
# install_release.sh
# Watches for a new ADB device and installs pawfinder release APK onto it.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APK="$SCRIPT_DIR/build/app/outputs/flutter-apk/app-release.apk"
POLL_INTERVAL=2  # seconds between device list checks

if ! command -v flutter &>/dev/null; then
    echo "ERROR: flutter not found in PATH"
    exit 1
fi

if ! command -v adb &>/dev/null; then
    echo "ERROR: adb not found in PATH"
    exit 1
fi

echo "Pawfinder Release Installer"
echo ""
echo "==> Building release APK..."
(cd "$SCRIPT_DIR" && flutter build apk --release)
echo "==> Build complete."
echo ""

if [[ ! -f "$APK" ]]; then
    echo "ERROR: APK not found at $APK after build"
    exit 1
fi

echo "APK: $APK"
echo "Waiting for a new device..."

# Snapshot of currently connected devices (serial numbers only)
get_devices() {
    adb devices 2>/dev/null \
        | awk 'NR>1 && $2=="device" { print $1 }'
}

KNOWN_DEVICES=()
while IFS= read -r dev; do
    KNOWN_DEVICES+=("$dev")
done < <(get_devices)

echo "Already connected (${#KNOWN_DEVICES[@]}): ${KNOWN_DEVICES[*]:-none}"
echo ""

while true; do
    sleep "$POLL_INTERVAL"

    CURRENT_DEVICES=()
    while IFS= read -r dev; do
        CURRENT_DEVICES+=("$dev")
    done < <(get_devices)

    # Find serials in CURRENT that are not in KNOWN
    for serial in "${CURRENT_DEVICES[@]:-}"; do
        [[ -z "$serial" ]] && continue
        already_known=false
        for known in "${KNOWN_DEVICES[@]:-}"; do
            [[ "$serial" == "$known" ]] && already_known=true && break
        done

        if [[ "$already_known" == false ]]; then
            echo "[$(date '+%H:%M:%S')] New device detected: $serial"
            echo "  Waiting for device to be ready..."
            adb -s "$serial" wait-for-device

            echo "  Installing $APK ..."
            if adb -s "$serial" install -r "$APK"; then
                echo "  Install succeeded on $serial"
            else
                echo "  Install FAILED on $serial (exit $?)"
            fi

            # Add to known so we don't re-install on the next poll
            KNOWN_DEVICES+=("$serial")
            echo ""
            echo "Watching for next new device..."
        fi
    done

    # Also prune disconnected devices from KNOWN so a reconnect triggers again
    PRUNED=()
    for known in "${KNOWN_DEVICES[@]:-}"; do
        still_there=false
        for cur in "${CURRENT_DEVICES[@]:-}"; do
            [[ "$known" == "$cur" ]] && still_there=true && break
        done
        $still_there && PRUNED+=("$known")
    done
    KNOWN_DEVICES=("${PRUNED[@]:-}")
done

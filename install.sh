#!/usr/bin/env bash

set -euo pipefail

readonly package_id="org.kde.plasma.pomodoro"
readonly archive_url="https://github.com/cromewar/kde-pomodoro/archive/refs/heads/main.tar.gz"
readonly notifyrc_name="$package_id.notifyrc"
readonly notifyrc_dir="${XDG_DATA_HOME:-$HOME/.local/share}/knotifications6"

for dependency in curl tar kpackagetool6; do
    if ! command -v "$dependency" >/dev/null 2>&1; then
        printf 'Error: required command not found: %s\n' "$dependency" >&2
        exit 1
    fi
done

temp_dir="$(mktemp -d)"
cleanup() {
    rm -rf -- "$temp_dir"
}
trap cleanup EXIT

archive_path="$temp_dir/kde-pomodoro.tar.gz"
package_path="$temp_dir/package"
mkdir -p "$package_path"

printf 'Downloading Pomodoro Focus...\n'
curl -fsSL "$archive_url" -o "$archive_path"
tar -xzf "$archive_path" -C "$package_path" --strip-components=1

if kpackagetool6 --type Plasma/Applet --show "$package_id" >/dev/null 2>&1; then
    printf 'Upgrading %s...\n' "$package_id"
    kpackagetool6 --type Plasma/Applet --upgrade "$package_path"
else
    printf 'Installing %s...\n' "$package_id"
    kpackagetool6 --type Plasma/Applet --install "$package_path"
fi

# Applies to both the install and the upgrade path above. The notification
# events cannot travel inside the plasmoid package: KNotifications only reads
# knotifications6/ under the XDG data directories, while kpackagetool6 installs
# to plasma/plasmoids/. Without this file KNotification finds no event config
# and drops the notification entirely — no popup, no sound.
notifyrc_source="$package_path/notifications/$notifyrc_name"
if [ ! -f "$notifyrc_source" ]; then
    printf 'Error: %s is missing from the downloaded package. The widget is installed, but\nwithout this file KNotification drops interval notifications entirely: no popup, no sound.\n' "$notifyrc_name" >&2
    exit 1
fi

printf 'Installing notification events...\n'
mkdir -p "$notifyrc_dir"
cp -f -- "$notifyrc_source" "$notifyrc_dir/$notifyrc_name"

printf "\nPomodoro Focus is ready. Add it from Plasma's widget picker.\n"

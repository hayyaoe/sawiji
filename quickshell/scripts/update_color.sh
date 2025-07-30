#!/usr/bin/bash

WALLPAPER="$1"

if [[ ! -f "$WALLPAPER" ]]; then
  echo "❌ File not found: $WALLPAPER"
  exit 1
fi

# Run wal (will auto-generate all templates in ~/.config/wal/templates/)
wal -i "$WALLPAPER"

# Move or copy the generated QML to your desired location
CACHE_QML="$HOME/.cache/wal/quickshell-colors.qml"
TARGET_QML="$HOME/.config/quickshell/config/Colors.qml"

if [[ -f "$CACHE_QML" ]]; then
  cp "$CACHE_QML" "$TARGET_QML"
  echo "✅ QML theme copied to $TARGET_QML"
else
  echo "❌ Expected file not found: $CACHE_QML"
fi

pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id:root

  readonly property Palette colors: Palette{}

  component Palette: QtObject{
    property color foreground: "#bfcbe2"
    property color background: "#060E10"

    property color color0: "#060E10"
    property color color1: "#2F72BE"
    property color color2: "#4B76AB"
    property color color3: "#87799A"
    property color color4: "#6087B9"
    property color color5: "#3C81CB"
    property color color6: "#6C93C8"
    property color color7: "#bfcbe2"
    property color color8: "#858e9e"
    property color color9: "#2F72BE"
    property color color10: "#4B76AB"
    property color color11: "#87799A"
    property color color12: "#6087B9"
    property color color13: "#3C81CB"
    property color color14: "#6C93C8"
    property color color15: "#bfcbe2"
  }
}

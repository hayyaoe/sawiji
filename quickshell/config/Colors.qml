pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property Palette colors: Palette {}

    component Palette: QtObject {
        property color foreground: "#d3d0bd"
        property color background: "#0d0c09"

        property color color0: "#0d0c09"
        property color color1: "#605D46"
        property color color2: "#6D694B"
        property color color3: "#86774E"
        property color color4: "#7E8273"
        property color color5: "#9B946A"
        property color color6: "#C0B06D"
        property color color7: "#d3d0bd"
        property color color8: "#939184"
        property color color9: "#605D46"
        property color color10: "#6D694B"
        property color color11: "#86774E"
        property color color12: "#7E8273"
        property color color13: "#9B946A"
        property color color14: "#C0B06D"
        property color color15: "#d3d0bd"
    }
}

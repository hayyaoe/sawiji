pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    readonly property Font font: Font {}
    readonly property Padding padding: Padding {}
    readonly property Spacing spacing: Spacing {}
    readonly property Margin margin: Margin {}

    component FontFamily: QtObject {
        readonly property string mono: "Iosevka"
        readonly property string material: "Lucide"
    }

    component FontSize: QtObject {
        readonly property int small: 10
        readonly property int normal: 12
        readonly property int large: 16
        readonly property int extraLarge: 20
    }

    component Font: QtObject {
        readonly property FontFamily family: FontFamily {}
        readonly property FontSize size: FontSize {}
    }

    component Padding: QtObject {
        readonly property int small: 6
        readonly property int normal: 8
        readonly property int large: 14
    }

    component Margin: QtObject {
        readonly property int small: 6
        readonly property int normal: 8
        readonly property int large: 14
    }

    component Spacing: QtObject {
        readonly property int small: 6
        readonly property int normal: 8
        readonly property int large: 14
    }
}

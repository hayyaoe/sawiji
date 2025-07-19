import "root:/utilities"

import Quickshell
import QtQuick


Row {
    id: root

    property real buttonHeight: 20
    property string fontFamily: "Iosevka"
    property int fontSize: 12

    Repeater {
        model: Hyprland.workspaces

        Rectangle {
            id: workspaceItem
            width: 24
            height: root.buttonHeight
            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: modelData.id.toString()
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                color: modelData.active ? "#282A36" : "#909090"
                font.pixelSize: root.fontSize
                font.family: root.fontFamily
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch("workspace " + modelData.id);
            }
        }
    }
}

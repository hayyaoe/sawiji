import "root:/utilities"

import Quickshell
import QtQuick


Row {
    id: workspaceWidgetRoot

    property real buttonHeight: 20

    readonly property var easternArabicNumerals: {
        "0": "٠", "1": "١", "2": "٢", "3": "٣", "4": "٤",
        "5": "٥", "6": "٦", "7": "٧", "8": "٨", "9": "٩"
    }

    function toEasternArabicNumbers(westernArabicNumberString) {
        let easternArabic = "";
        for (let i = 0; i < westernArabicNumberString.length; i++) {
            const digit = westernArabicNumberString[i];
            easternArabic += easternArabicNumerals[digit] || digit;
        }
        return easternArabic;
    }

    Repeater {
        model: Hyprland.workspaces

        Rectangle {
            id: workspaceItem
            width: 24
            height: workspaceWidgetRoot.buttonHeight
            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: workspaceWidgetRoot.toEasternArabicNumbers(modelData.id.toString())
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                color: modelData.active ? "#282A36" : "#909090"
                font.pixelSize: 24
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch("workspace " + modelData.id);
            }
        }
    }
}

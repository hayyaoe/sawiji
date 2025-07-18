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
            easternArabic += easternArabicNumerals[digit] || digit; // Fallback to original digit if not found
        }
        return easternArabic;
    }

    // The Repeater is now directly inside this Row.
    // It will create a Rectangle (our workspace item) for each item in the model.
    Repeater {
        model: Hyprland.workspaces // Access Hyprland's workspace data

        // This Rectangle is the delegate for each item in the Repeater's model.
        // It represents a single workspace button.
        Rectangle {
            id: workspaceItem
            width: 24 // Fixed width for each workspace button
            height: workspaceWidgetRoot.buttonHeight// Make the height of the rectangle match the height of the parent Row
            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: workspaceWidgetRoot.toEasternArabicNumbers(modelData.id.toString())
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                color: modelData.active ? "#282A36" : "#909090" // Text color changes for contrast
                font.pixelSize: 24 // Font size
                font.bold: true // Bold text
            }

            MouseArea {
                anchors.fill: parent // Make the mouse area fill its parent (the Rectangle)
                onClicked: Hyprland.dispatch("workspace " + modelData.id);
            }
        }
    }
}

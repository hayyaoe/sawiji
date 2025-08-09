import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "root:/config"

LazyLoader {
    id: brightnessPopup
    loading: true

    property var brightnessButton
    property var windowRoot
    property real brightnessLevel: 0.7 
    property bool blueLightFilterOn: true

    PopupWindow {
        id: brightnessPopupWindow

        anchor {
            window: windowRoot
            rect.x: brightnessButton.mapToGlobal(Qt.point(brightnessButton.width / 2, 0)).x - (brightnessPopupWindow.implicitWidth / 2)
            rect.y: brightnessButton.mapToGlobal(Qt.point(0, brightnessButton.height)).y + Appearance.margin.normal
        }

        implicitWidth: windowRoot.width / 8


        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onExited: windowRoot.restartTimer()
            onEntered: windowRoot.stopTimer()
        }

        Rectangle {
            anchors.fill: parent
            color: Colors.colors.background

            Column {
                anchors.centerIn: parent
                spacing: Appearance.spacing.large
                width: parent.width - Appearance.margin.normal * 2

                RowLayout {
                    width: parent.width
                    spacing: Appearance.spacing.large
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: Appearance.margin.large
                    anchors.rightMargin: Appearance.margin.large

                    Text {
                        text: ""
                        font.pixelSize: Appearance.font.size.extraLarge
                        color: Colors.colors.foreground
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: Appearance.font.size.small / 2
                        color: Colors.colors.color1
                        radius: height / 2
                        Layout.alignment: Qt.AlignVCenter

                        Rectangle {
                            width: parent.width * brightnessPopup.brightnessLevel
                            height: parent.height
                            color: Colors.colors.foreground
                            radius: height / 2
                        }
                    }
                }

                RowLayout {
                    width: parent.width
                    spacing: Appearance.spacing.large
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: Appearance.margin.large
                    anchors.rightMargin: Appearance.margin.large

                    Text {
                        text: "Bluelight Filter"
                        font.family: Appearance.font.family.mono
                        font.pixelSize: Appearance.font.size.large
                        color: Colors.colors.foreground
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: (brightnessPopup.blueLightFilterOn ? "ON" : "OFF")
                        font.family: Appearance.font.family.mono
                        font.pixelSize: Appearance.font.size.large
                        color: Colors.colors.foreground
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                    }
                }
            }
        }
    }
}

import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "root:/config"

LazyLoader {
    id: brightnessPopup
    loading: true

    property var brightnessButton
    property var windowRoot
    property real brightnessLevel: 0.7 // 0.0 to 1.0
    property bool blueLightFilterOn: true

    PopupWindow {
        id: brightnessPopupWindow

        Process {
            id: brightnessProc
            running: false
        }

        Process {
            id: blueLightProc
            running: false
        }

        function toggleBlueLightFilter() {
            if (blueLightFilterOn) {
                blueLightProc.command = ["hyprctl", "hyprsunset", "identity"];
                blueLightProc.running = true;
                blueLightFilterOn = false;
            } else {
                blueLightProc.command = ["hyprctl", "hyprsunset", "temperature", "3500"];
                blueLightProc.running = true;
                blueLightFilterOn = true;
            }
        }

        function setBrightness(level) {
            var value = Math.max(0, Math.min(1, level));
            brightnessLevel = value;

            var percent = Math.round(value * 100);
            brightnessProc.command = ["hyprctl", "hyprsunset", "gamma", percent.toString()];
            brightnessProc.running = true;
        }
        
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
                        id: sliderTrack
                        Layout.fillWidth: true
                        height: Appearance.font.size.small / 2
                        color: Colors.colors.color1
                        Layout.alignment: Qt.AlignVCenter

                        Rectangle {
                            id: sliderFill
                            width: sliderTrack.width * brightnessPopup.brightnessLevel
                            height: parent.height
                            color: Colors.colors.foreground
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            onPressed: function (mouse) {
                                updateBrightness(mouse.x);
                            }

                            onPositionChanged: function (mouse) {
                                if (pressed)
                                    updateBrightness(mouse.x);
                            }

                            function updateBrightness(mouseX) {
                                var level = Math.max(0, Math.min(1, mouseX / sliderTrack.width));
                                brightnessPopupWindow.setBrightness(level);
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: Appearance.font.size.large * 1.5
                    cursorShape: Qt.PointingHandCursor
                    onClicked: brightnessPopupWindow.toggleBlueLightFilter()

                    RowLayout {
                        anchors.fill: parent
                        spacing: Appearance.spacing.large
                        anchors.leftMargin: Appearance.margin.large
                        anchors.rightMargin: Appearance.margin.large

                        Text {
                            text: "Bluelight"
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
}

import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "root:/config"

LazyLoader {
    id: audioPopup
    loading: true

    property var audioButton
    property var windowRoot
    property real volumeLevel: 0.7 // 0.0 to 1.0
    property bool volumeOutput: true
    property real microphoneLevel: 0.7
    property bool microphoneInput: true

    PopupWindow {
        id: audioPopupWindow
        
        Process {
            id: volumeProc
            running: false
        }
        
        Process {
            id: microphoneProc
            running: false
        }
        
        function setVolume(level) {
            var value = Math.max(0, Math.min(1, level));
            volumeLevel = value;

            var percent = Math.round(value * 100);
            volumeProc.command = ["hyprctl", "hyprsunset", "gamma", percent.toString()];
            volumeProc.running = true;
        }
        
        anchor {
            window: windowRoot
            rect.x: audioButton.mapToGlobal(Qt.point(audioButton.width / 2, 0)).x - (audioPopupWindow.implicitWidth / 2)
            rect.y: audioButton.mapToGlobal(Qt.point(0, audioButton.height)).y + Appearance.margin.normal
        }
        implicitWidth: windowRoot.width / 6

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
                        text: ""
                        font.pixelSize: Appearance.font.size.large
                        color: Colors.colors.foreground
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                    }

                    Rectangle {
                        id: sliderTrack
                        Layout.fillWidth: true
                        height: Appearance.font.size.small / 3
                        color: Colors.colors.color1
                        Layout.alignment: Qt.AlignVCenter

                        Rectangle {
                            id: sliderFill
                            width: sliderTrack.width * audioPopup.volumeLevel
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
                                audioPopupWindow.setVolume(level);
                            }
                        }
                    }
                }
            }
        }
    }
}

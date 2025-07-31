import "root:/config"

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

Rectangle {
    width: 200
    height: 80
    color: Colors.colors.background
    radius: 6

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 12

        RowLayout {
            spacing: 10
            Layout.alignment: Qt.AlignVCenter

            Text {
                text: "\u{1F50A}"
                font.pixelSize: 16
                color: Colors.colors.foreground
                Layout.preferredWidth: 20
            }

            Rectangle {
                Layout.fillWidth: true
                height: 4
                color: Colors.colors.color1

                Rectangle {
                    width: parent.width * (volume / 100)
                    height: parent.height
                    color: Colors.colors.foreground
                }

                MouseArea {
                    anchors.fill: parent
                    drag.target: volumeHandle
                    onClicked: (mouse) => {
                        volume = Math.round((mouse.x / parent.width) * 100)
                        Process.execute(["pamixer", "--set-volume", `${volume}`])
                    }
                }
            }
        }

        RowLayout {
            spacing: 10
            Layout.alignment: Qt.AlignVCenter

            Text {
                text: "\u{1F3A4}" // microphone icon
                font.pixelSize: 16
                color: Colors.colors.foreground
                Layout.preferredWidth: 20
            }

            Rectangle {
                Layout.fillWidth: true
                height: 4
                color: Colors.colors.color1

                Rectangle {
                    width: parent.width * (micVolume / 100)
                    height: parent.height
                    color: Colors.colors.foreground
                }

                MouseArea {
                    anchors.fill: parent
                    drag.target: micHandle
                    onClicked: (mouse) => {
                        micVolume = Math.round((mouse.x / parent.width) * 100)
                        Process.execute(["pamixer", "--default-source", "--set-volume", `${micVolume}`])
                    }
                }
            }
        }
    }

    property int volume: 50
    property int micVolume: 50

    Component.onCompleted: {
        Process.execute(["pamixer", "--get-volume"], (code, stdout) => {
            if (code === 0) volume = parseInt(stdout)
        })
        Process.execute(["pamixer", "--default-source", "--get-volume"], (code, stdout) => {
            if (code === 0) micVolume = parseInt(stdout)
        })
    }
}

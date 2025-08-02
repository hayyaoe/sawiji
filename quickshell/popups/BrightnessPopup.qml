import Quickshell
import QtQuick
import QtQuick.Controls
import "root:/config"

LazyLoader {
    id: brightnessPopup
    loading: true

    property var brightnessButton
    property var windowRoot

    PopupWindow {
        id: brightnessPopupWindow

        anchor {
            window: windowRoot
            rect.x: brightnessButton.mapToGlobal(Qt.point(brightnessButton.width / 2, 0)).x
                    - (brightnessPopupWindow.implicitWidth / 2)
            rect.y: brightnessButton.mapToGlobal(Qt.point(0, brightnessButton.height)).y
                    + Appearance.margin.normal
        }

        implicitWidth: windowRoot.width / 8
        implicitHeight: windowRoot.width / 16

        Timer {
            id: hoverExitTimer
            interval: 1500
            repeat: false
            onTriggered: windowRoot.hideAllPopups()
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onExited: {
                hoverExitTimer.start()
            }

            onEntered: {
                hoverExitTimer.stop()
            }
        }

        Rectangle {
            anchors.fill: parent
            color: Colors.colors.background
            border.color: Colors.colors.foreground
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "Brightness Control"
                color: Colors.colors.foreground
            }
        }
    }
}

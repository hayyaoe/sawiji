import Quickshell
import QtQuick
import QtQuick.Controls
import "root:/config"

LazyLoader {
    id: audioPopup
    loading: true

    property var audioButton
    property var windowRoot

    PopupWindow {
        id: audioPopupWindow
        anchor {
            window: windowRoot
            rect.x: audioButton.mapToGlobal(Qt.point(audioButton.width / 2, 0)).x - (audioPopupWindow.implicitWidth / 2)
            rect.y: audioButton.mapToGlobal(Qt.point(0, audioButton.height)).y + Appearance.margin.normal
        }
        implicitWidth: windowRoot.width / 5
        implicitHeight: windowRoot.width / 8

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onExited: windowRoot.restartTimer()
            onEntered: windowRoot.stopTimer()
        }

        Rectangle {
            anchors.fill: parent
            color: Colors.colors.background
            border.color: Colors.colors.foreground
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "Audio"
                color: Colors.colors.foreground
            }
        }
    }
}

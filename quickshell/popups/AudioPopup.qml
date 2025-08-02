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
            rect.x: audioButton.mapToGlobal(Qt.point(audioButton.width / 2, 0)).x 
                    - (audioPopupWindow.implicitWidth / 2)
            rect.y: audioButton.mapToGlobal(Qt.point(0, audioButton.height)).y 
                    + Appearance.margin.normal
        }

        implicitWidth: windowRoot.width / 8
        implicitHeight: windowRoot.width / 16

        Rectangle {
            anchors.fill: parent
            color: Colors.colors.background
            border.color: Colors.colors.foreground
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "Audio Control"
                color: Colors.colors.foreground
            }
        }
    }
}

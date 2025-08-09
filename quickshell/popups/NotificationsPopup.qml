import Quickshell
import QtQuick
import QtQuick.Controls
import "root:/config"

LazyLoader {
    id: notificationsPopup
    loading: true

    property var notificationsButton
    property var windowRoot

    PopupWindow {
        id: notificationsPopupWindow
        anchor {
            window: windowRoot
            rect.x: notificationsButton.mapToGlobal(Qt.point(notificationsButton.width / 2, 0)).x - (notificationsPopupWindow.implicitWidth / 2)
            rect.y: notificationsButton.mapToGlobal(Qt.point(0, notificationsButton.height)).y + Appearance.margin.normal
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
                text: "Notifications"
                color: Colors.colors.foreground
            }
        }
    }
}

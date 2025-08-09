import Quickshell
import QtQuick
import QtQuick.Controls
import "root:/config"

LazyLoader {
    id: networkPopup
    loading: true

    property var networkButton
    property var windowRoot

    PopupWindow {
        id: networkPopupWindow

        anchor {
            window: windowRoot
            rect.x: networkButton.mapToGlobal(Qt.point(networkButton.width / 2, 0)).x - (networkPopupWindow.implicitWidth / 2)
            rect.y: networkButton.mapToGlobal(Qt.point(0, networkButton.height)).y + Appearance.margin.normal
        }

        implicitWidth: windowRoot.width / 6
        implicitHeight: windowRoot.width / 10

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
                text: "Network Settings"
                color: Colors.colors.foreground
            }
        }
    }
}

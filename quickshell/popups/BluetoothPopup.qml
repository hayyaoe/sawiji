import Quickshell
import QtQuick
import QtQuick.Controls
import "root:/config"

// Bluetooth Popup
      LazyLoader{
        id: bluetoothPopup
        loading: true


  property var bluetoothButton
  property var windowRoot
        PopupWindow {
          id: bluetoothPopupWindow
          anchor {
            window: windowRoot
            rect.x: bluetoothButton.mapToGlobal(Qt.point(bluetoothButton.width / 2, 0)).x - (bluetoothPopupWindow.implicitWidth / 2)
            rect.y: bluetoothButton.mapToGlobal(Qt.point(0, bluetoothButton.height)).y + Appearance.margin.normal
          }
          implicitWidth: windowRoot.width / 7
          implicitHeight: windowRoot.width / 12


          Rectangle {
            anchors.fill: parent
            color: Colors.colors.background
            border.color: Colors.colors.foreground
            border.width: 1 
            
            Text {
              anchors.centerIn: parent
              text: "Bluetooth Devices"
              color: Colors.colors.foreground
            }
          }
        }
      }

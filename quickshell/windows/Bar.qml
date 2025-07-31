import "root:/widgets"
import "root:/popups"
import "root:/config"

import Quickshell
import QtQuick
import QtQuick.Controls

Scope {
  
  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: root
      property var modelData
      property var currentPopup: null
      
      function showPopup(popup) {
        // If clicking the same button that's already open, close it
        if (currentPopup && currentPopup === popup.item) {
          currentPopup.visible = false
          currentPopup = null
          return
        }
        
        // Close current popup if it's different
        if (currentPopup && currentPopup !== popup.item) {
          currentPopup.visible = false
        }
        
        // Open the requested popup
        if (popup.item) {
          popup.item.visible = true
          currentPopup = popup.item
          // Give focus to the popup so it can detect focus loss
          popup.item.requestActivate
        }
      }
      
      function hideAllPopups() {
        if (currentPopup) {
          currentPopup.visible = false
          currentPopup = null
        }
      }

      screen: modelData
      anchors{
        top: true
        left: true
        right: true
      }

      implicitHeight: 36

      MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: root.hideAllPopups()
      }
      
      Rectangle{
        id: bar
        anchors.fill: parent
        color: Colors.colors.background

        Row{
          spacing: Appearance.spacing.normal
          height: parent.height

          anchors{
            verticalCenter: parent.verticalCenter
            left: parent.left
          }
          
          AppLauncherWidget{
            fontSize: Appearance.font.size.extraLarge
            fontFamily: Appearance.font.family.material
            buttonHeight: parent.height
            buttonWidth: parent.height
          }

          WorkspacesWidget{
            anchors.verticalCenter: parent.verticalCenter
            buttonHeight: parent.height
            buttonWidth: parent.height
          }
        }

        Row{
          spacing: Appearance.spacing.normal
          height: parent.height

          anchors{
            verticalCenter: parent.verticalCenter
            right: parent.right
          }

          // Network
          PopupButtonWidget{
            id: networkButton
            fontSize: Appearance.font.size.large
            fontFamily: Appearance.font.family.material
            buttonHeight: parent.height
            icon: ""
            onClicked: root.showPopup(networkPopup)
          }

          // Bluetooth
          PopupButtonWidget{
            id: bluetoothButton
            fontSize: Appearance.font.size.large
            fontFamily: Appearance.font.family.material
            buttonHeight: parent.height
            icon: ""
            onClicked: root.showPopup(bluetoothPopup)
          }

          // Audio
          PopupButtonWidget{
            id: audioButton
            fontSize: Appearance.font.size.large
            fontFamily: Appearance.font.family.material
            buttonHeight: parent.height
            icon: ""
            onClicked: root.showPopup(audioPopup)
          }

          // Brightness
          PopupButtonWidget{
            id: brightnessButton
            fontSize: Appearance.font.size.large
            fontFamily: Appearance.font.family.material
            buttonHeight: parent.height
            icon: ""
            onClicked: root.showPopup(brightnessPopup)
          }

          // Notifications
          PopupButtonWidget{
            id: notificationsButton
            fontSize: Appearance.font.size.large
            fontFamily: Appearance.font.family.material
            buttonHeight: parent.height
            icon: ""
            onClicked: root.showPopup(notificationsPopup)
          }
          
          ClockWidget {
            anchors{
              verticalCenter: parent.verticalCenter
            }
            font.pixelSize: Appearance.font.size.large
            font.family: Appearance.font.family.mono
            color: Colors.colors.foreground
          }

          PowerWidget{
            fontSize: Appearance.font.size.extraLarge
            fontFamily: Appearance.font.family.material
            buttonHeight: parent.height
            buttonWidth: parent.height
          }
        }
      }

      // Network Popup
      LazyLoader{
        id: networkPopup
        loading: true
        PopupWindow {
          id: networkPopupWindow
          anchor {
            window: root
            rect.x: networkButton.mapToGlobal(Qt.point(networkButton.width / 2, 0)).x - (networkPopupWindow.implicitWidth / 2)
            rect.y: networkButton.mapToGlobal(Qt.point(0, networkButton.height)).y + Appearance.margin.normal
          }
          implicitWidth: root.width / 6
          implicitHeight: root.width / 10
          
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
      
      // Bluetooth Popup
      LazyLoader{
        id: bluetoothPopup
        loading: true
        PopupWindow {
          id: bluetoothPopupWindow
          anchor {
            window: root
            rect.x: bluetoothButton.mapToGlobal(Qt.point(bluetoothButton.width / 2, 0)).x - (bluetoothPopupWindow.implicitWidth / 2)
            rect.y: bluetoothButton.mapToGlobal(Qt.point(0, bluetoothButton.height)).y + Appearance.margin.normal
          }
          implicitWidth: root.width / 7
          implicitHeight: root.width / 12


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
      
      // Audio Popup
      LazyLoader{
        id: audioPopup
        loading: true
        PopupWindow {
          id: audioPopupWindow
          anchor {
            window: root
            rect.x: audioButton.mapToGlobal(Qt.point(audioButton.width / 2, 0)).x - (audioPopupWindow.implicitWidth / 2)
            rect.y: audioButton.mapToGlobal(Qt.point(0, audioButton.height)).y + Appearance.margin.normal
          }
          implicitWidth: root.width / 8
          implicitHeight: root.width / 16

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
      
      // Brightness Popup
      LazyLoader{
        id: brightnessPopup
        loading: true
        PopupWindow {
          id: brightnessPopupWindow
          anchor {
            window: root
            rect.x: brightnessButton.mapToGlobal(Qt.point(brightnessButton.width / 2, 0)).x - (brightnessPopupWindow.implicitWidth / 2)
            rect.y: brightnessButton.mapToGlobal(Qt.point(0, brightnessButton.height)).y + Appearance.margin.normal
          }
          implicitWidth: root.width / 8
          implicitHeight: root.width / 16
          
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
      
      // Notifications Popup
      LazyLoader{
        id: notificationsPopup
        loading: true
        PopupWindow {
          id: notificationsPopupWindow
          anchor {
            window: root
            rect.x: notificationsButton.mapToGlobal(Qt.point(notificationsButton.width / 2, 0)).x - (notificationsPopupWindow.implicitWidth / 2)
            rect.y: notificationsButton.mapToGlobal(Qt.point(0, notificationsButton.height)).y + Appearance.margin.normal
          }
          implicitWidth: root.width / 5
          implicitHeight: root.width / 8
          
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
    }
  }
}

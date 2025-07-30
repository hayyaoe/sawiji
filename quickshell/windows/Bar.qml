import "root:/widgets"
import "root:/config"

import Quickshell
import QtQuick

Scope {
  
  Variants {
    model: Quickshell.screens

    PanelWindow {
      property var modelData
      screen: modelData

      anchors{
        top: true
        left: true
        right: true
      }

      implicitHeight: 36

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

          NetworkWidget{
            fontSize: Appearance.font.size.large
            fontFamily: Appearance.font.family.material
            buttonHeight: parent.height
          }
          
          BluetoothWidget{
            fontSize: Appearance.font.size.large
            fontFamily: Appearance.font.family.material
            buttonHeight: parent.height
          }
          
          AudioWidget{
            fontSize: Appearance.font.size.large
            fontFamily: Appearance.font.family.material
            buttonHeight: parent.height
          }
          
          BrightnessWidget{
            fontSize: Appearance.font.size.large
            fontFamily: Appearance.font.family.material
            buttonHeight: parent.height
          }
          
          NotificationsWidget{
            fontSize: Appearance.font.size.large
            fontFamily: Appearance.font.family.material
            buttonHeight: parent.height
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
    }
  }
}

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

      implicitHeight: 32

      Rectangle{
        id: bar
        anchors.fill: parent

        WorkspacesWidget{
          anchors{
            centerIn: parent
          }
          buttonHeight: parent.height
          fontFamily: Appearance.font.family.mono
          fontSize:  Appearance.font.size.large
        }

        Row{
          spacing: Appearance.spacing.normal

          anchors{
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: Appearance.margin.small
          }

          GPUWidget{
            anchors{
              verticalCenter: parent.verticalCenter
            }
            displayMode: "temp"
            font.pixelSize: Appearance.font.size.large
            font.family: Appearance.font.family.mono
          }
          
          CPUWidget{
            anchors{
              verticalCenter: parent.verticalCenter
            }
            displayMode: "temp"
            font.pixelSize: Appearance.font.size.large
            font.family: Appearance.font.family.mono
          }

          MemoryWidget {
            anchors{
              verticalCenter: parent.verticalCenter
            }
            displayMode: "percentage"
            font.pixelSize: Appearance.font.size.large
            font.family: Appearance.font.family.mono
          }

          ClockWidget {
            anchors{
              verticalCenter: parent.verticalCenter
            }
            font.pixelSize: Appearance.font.size.large
            font.family: Appearance.font.family.mono
          }
        }
      }
    }
  }
}

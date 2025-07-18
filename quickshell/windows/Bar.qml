import "root:/widgets"

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
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 8
          }
          buttonHeight: parent.height
        }

        Row{
          spacing: 12

          anchors{
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: 12
          }

          MemoryWidget {
            anchors{
              verticalCenter: parent.verticalCenter
              rightMargin: 8
            }
            font.pixelSize: 16
          }

          ClockWidget {
            anchors{
              verticalCenter: parent.verticalCenter
            }
            font.pixelSize: 16
          }
        }

        Rectangle {
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.bottom: parent.bottom
          height: 2
        }
      }
    }
  }
}

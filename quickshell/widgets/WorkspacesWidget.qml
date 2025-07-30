import "root:/config"

import QtQuick
import Quickshell
import Quickshell.Hyprland

Row {
    id: root
    spacing: Appearance.spacing.normal

    property int workspaceLength: 10
    property real buttonHeight: 20
    property real buttonWidth: 20

    signal workspaceAdded(HyprlandWorkspace workspace)

    Component.onCompleted: {
        Hyprland.workspaces.values.forEach(workspace => {
            workspaceAdded(workspace)
        });
    }

    Connections {
        target: Hyprland.workspaces

        function onObjectInsertedPost(workspace) {
            root.workspaceAdded(workspace)
        }
    }

    Repeater {
        model: workspaceLength

        Rectangle {
            id: workspaceItem
            anchors.verticalCenter: parent.verticalCenter

            readonly property int wsId: modelData + 1
            property HyprlandWorkspace workspace: null
            property bool isOccupied: workspace !== null
            property bool isActive: workspace?.active ?? false

            width:  isActive? root.buttonWidth/2 : isOccupied ? root.buttonWidth/6 : root.buttonWidth/6
            height: isActive? root.buttonHeight/4 : isOccupied ? root.buttonHeight/6 : root.buttonHeight/6

            color: isActive ? Colors.colors.foreground :
                   isOccupied ? Colors.colors.foreground :
                   Colors.colors.color1

            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch("workspace " + wsId)
                cursorShape: Qt.PointingHandCursor
            }

            Connections {
                target: root
                function onWorkspaceAdded(w) {
                    if (w.id === workspaceItem.wsId)
                        workspaceItem.workspace = w;
                }
              }

              Behavior on color {
                ColorAnimation {
                  duration: 200
                  easing.type: Easing.Linear
                }
              }


              Behavior on height {
                NumberAnimation {
                  duration: 40
                  easing.type: Easing.Linear
                }
              }
              
              Behavior on width {
                NumberAnimation {
                  duration: 40
                  easing.type: Easing.Linear
                }
              }
        }
    }
}

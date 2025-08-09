import "root:/popups"
import "root:/config"
import QtQuick

Rectangle {
    id: root

    property real buttonHeight: 20
    property real buttonWidth: 20
    property int fontSize: 12
    property string fontFamily: "lucide"
    property string icon: ""

    signal clicked

    width: buttonWidth
    height: buttonHeight
    color: Colors.colors.background

    Text {
        anchors.centerIn: parent
        text: icon
        font.family: fontFamily
        font.pixelSize: fontSize
        color: mouseArea.containsMouse ? Colors.colors.color1 : Colors.colors.foreground

        Behavior on color {
            ColorAnimation {
                duration: 100
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            root.clicked();
        }
    }
}

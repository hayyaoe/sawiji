import "root:/config"

import Quickshell
import QtQuick

Rectangle {
  id: root
  
  property real buttonHeight: 20
  property real buttonWidth: 20
  property int fontSize: 12
  property string fontFamily: "lucide"

  required property LazyLoader audioPopup

  width: buttonWidth
  height: buttonHeight
  color: Colors.colors.background

  Text{
    anchors.centerIn: parent
    text: ""
    font.family: fontFamily
    font.pixelSize: fontSize
    color: Colors.colors.foreground
  }

  MouseArea{
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor

    onClicked:{
        if (audioPopup.item) {
            audioPopup.item.visible = !audioPopup.item.visible
        }
    }
  }
}

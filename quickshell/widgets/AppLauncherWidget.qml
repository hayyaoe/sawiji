import "root:/config"

import Quickshell
import QtQuick

Rectangle {
  id: root
  
  property real buttonHeight: 20
  property real buttonWidth: 20
  property int fontSize: 12
  property string fontFamily: "Iosevka"

  width: buttonWidth
  height: buttonHeight
  color: Colors.colors.foreground

  Text{
    anchors.centerIn: parent
    text: "❄"
    font.family: fontFamily
    font.pixelSize: fontSize
    color: Colors.colors.background
  }
}

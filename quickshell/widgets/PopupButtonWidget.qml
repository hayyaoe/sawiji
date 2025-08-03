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
    property var popup: null
    property Component popupContent: null
    property string popupId: ""
    
    signal clicked()
    
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
          ColorAnimation { duration: 100 }
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            if (popupItem.show) {
                popupItem.show = false;
            } else {
                root.clicked();
                if (popupContent) {
                    popupItem.show = true;
                }
            }
        }
        
        onEntered: {
            if (!popupItem.show && popupContent) {
                    popupItem.show = true;
            }
        }
        
        onExited: {
                popupItem.show = false;
        }
    }
    
    PopupItem {
        id: popupItem
        popup: root.popup
        owner: root
        isMenu: true
        hangTime: 100
        
        show: false
        
        Rectangle {
            id: popupBackground
            anchors.fill: parent
            color: Colors.colors.background
            border.color: Colors.colors.foreground
            border.width: 1
            radius: 4
            
            Loader {
                anchors.fill: parent
                anchors.margins: 8
                sourceComponent: root.popupContent
                active: popupItem.visible
            }
        }
    }
}

import QtQuick

Item {
    id: root
    required property var popup;
    required property Item owner;
    property bool isMenu: false;
    property bool hoverable: isMenu;
    property bool animateSize: true;
    property bool show: false;
    property real targetRelativeY: owner.height / 2;
    property real hangTime: isMenu ? 0 : 200;
    
    signal close();
    
    readonly property alias contentItem: contentItem;
    default property alias data: contentItem.data;
    property Component backgroundComponent: null

    // Calculate popup X position based on owner
    function calculatePopupX() {
        const ownerGlobal = owner.mapToGlobal(Qt.point(owner.width / 2, 0));
        return ownerGlobal.x - implicitWidth / 2;
    }

    onShowChanged: {
        if (show) popup.setItem(this);
        else popup.removeItem(this);
    }

    property bool targetVisible: false
    property real targetOpacity: 0
    opacity: root.targetOpacity * (popup.scaleMul == 0 ? 0 : (1.0 / popup.scaleMul))

    Behavior on targetOpacity {
        id: opacityAnimation
        SmoothedAnimation { velocity: 5 }
    }

    function snapOpacity(opacity: real) {
        opacityAnimation.enabled = false;
        targetOpacity = opacity;
        opacityAnimation.enabled = true;
    }

    onTargetVisibleChanged: {
        if (targetVisible) {
            visible = true;
            targetOpacity = 1;
        } else {
            close()
            targetOpacity = 0;
        }
    }

    onTargetOpacityChanged: {
        if (!targetVisible && targetOpacity == 0) {
            visible = false;
            this.parent = null;
            if (popup) popup.onHidden(this);
        }
    }

    anchors.fill: parent
    visible: false

    implicitHeight: contentItem.implicitHeight + contentItem.anchors.margins * 2
    implicitWidth: contentItem.implicitWidth + contentItem.anchors.margins * 2

    readonly property Item item: contentItem;

    Loader {
        anchors.fill: parent
        active: root.backgroundComponent && (root.visible || root.preloadBackground)
        asynchronous: !root.visible && root.preloadBackground
        sourceComponent: backgroundComponent
    }

    Item {
        id: contentItem
        anchors.fill: parent
        anchors.margins: 8
        implicitHeight: children.length > 0 ? children[0].implicitHeight : 0
        implicitWidth: children.length > 0 ? children[0].implicitWidth : 0
    }
}

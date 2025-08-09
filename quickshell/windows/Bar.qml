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

            Timer {
                id: popupAutoCloseTimer
                interval: 1500
                repeat: false
                running: false
                onTriggered: root.hideAllPopups()
            }

            function showPopup(popup) {
                if (currentPopup && currentPopup === popup.item) {
                    currentPopup.visible = false;
                    currentPopup = null;
                    return;
                }

                if (currentPopup && currentPopup !== popup.item) {
                    currentPopup.visible = false;
                }

                if (popup.item) {
                    if (currentPopup) {
                      popupAutoCloseTimer.restart();
                      popupAutoCloseTimer.stop();
                    }

                    popup.item.visible = true;
                    currentPopup = popup.item;
                    popup.item.requestActivate;
                }
            }

            function hideAllPopups() {
                if (currentPopup) {
                    currentPopup.visible = false;
                    currentPopup = null;
                }
            }

            function stopTimer() {
                if (currentPopup) {
                    popupAutoCloseTimer.stop();
                }
            }

            function restartTimer() {
                if (currentPopup) {
                    popupAutoCloseTimer.restart();
                }
            }

            screen: modelData
            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 36

            Rectangle {
                id: bar
                anchors.fill: parent
                color: Colors.colors.background

                Row {
                    spacing: Appearance.spacing.normal
                    height: parent.height

                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                    }

                    AppLauncherWidget {
                        fontSize: Appearance.font.size.extraLarge
                        fontFamily: Appearance.font.family.material
                        buttonHeight: parent.height
                        buttonWidth: parent.height
                    }

                    WorkspacesWidget {
                        anchors.verticalCenter: parent.verticalCenter
                        buttonHeight: parent.height
                        buttonWidth: parent.height
                    }
                }

                Row {
                    spacing: Appearance.spacing.normal
                    height: parent.height

                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                    }

                    // Network
                    PopupButtonWidget {
                        id: networkButton
                        fontSize: Appearance.font.size.large
                        fontFamily: Appearance.font.family.material
                        buttonHeight: parent.height
                        icon: ""
                        onClicked: root.showPopup(networkPopup)
                    }

                    // Bluetooth
                    PopupButtonWidget {
                        id: bluetoothButton
                        fontSize: Appearance.font.size.large
                        fontFamily: Appearance.font.family.material
                        buttonHeight: parent.height
                        icon: ""
                        onClicked: root.showPopup(bluetoothPopup)
                    }

                    // Audio
                    PopupButtonWidget {
                        id: audioButton
                        fontSize: Appearance.font.size.large
                        fontFamily: Appearance.font.family.material
                        buttonHeight: parent.height
                        icon: ""
                        onClicked: root.showPopup(audioPopup)
                    }

                    // Brightness
                    PopupButtonWidget {
                        id: brightnessButton
                        fontSize: Appearance.font.size.large
                        fontFamily: Appearance.font.family.material
                        buttonHeight: parent.height
                        icon: ""
                        onClicked: root.showPopup(brightnessPopup)
                    }

                    // Notifications
                    PopupButtonWidget {
                        id: notificationsButton
                        fontSize: Appearance.font.size.large
                        fontFamily: Appearance.font.family.material
                        buttonHeight: parent.height
                        icon: ""
                        onClicked: root.showPopup(notificationsPopup)
                    }

                    ClockWidget {
                        anchors {
                            verticalCenter: parent.verticalCenter
                        }
                        font.pixelSize: Appearance.font.size.large
                        font.family: Appearance.font.family.mono
                        color: Colors.colors.foreground
                    }

                    PowerWidget {
                        fontSize: Appearance.font.size.extraLarge
                        fontFamily: Appearance.font.family.material
                        buttonHeight: parent.height
                        buttonWidth: parent.height
                    }
                }
            }

            NetworkPopup {
                id: networkPopup
                networkButton: networkButton
                windowRoot: root
            }

            BluetoothPopup {
                id: bluetoothPopup
                bluetoothButton: bluetoothButton
                windowRoot: root
            }

            AudioPopup {
                id: audioPopup
                audioButton: audioButton
                windowRoot: root
            }

            BrightnessPopup {
                id: brightnessPopup
                brightnessButton: brightnessButton
                windowRoot: root
            }

            NotificationsPopup {
                id: notificationsPopup
                notificationsButton: notificationsButton
                windowRoot: root
            }
        }
    }
}

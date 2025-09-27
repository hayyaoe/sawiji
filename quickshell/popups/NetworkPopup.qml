import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "root:/config"
import "root:/utilities"

LazyLoader {
    id: networkPopup
    loading: true

    property var networkButton
    property var windowRoot

    // state
    property bool   wifiEnabled: true
    property string currentSsid: ""
    property var    networks: []      // [{active:bool, ssid:string, signal:int, secure:bool}]

    // interaction flags
    property bool _busyAction: false
    property string _pendingSsid: ""

    // password sheet mode: "hidden" | "known" | "other"
    property string pwMode: "hidden"
    property string _inputSsid: ""
    property string _inputPassword: ""

    // styling
    readonly property int   lineH: Math.round(Appearance.font.size.large * 1.8)
    readonly property int   sidePad: Appearance.margin.large
    readonly property real  faded: 0.8

    // derived model
    property var listModel: {
        const rows = Array.isArray(networks) ? networks.slice(0, 30) : []
        return rows.concat([{ active:false, ssid:"Other", signal:0, secure:false, _other:true }])
    }

    PopupWindow {
        id: networkPopupWindow

        anchor {
            window: windowRoot
            rect.x: networkButton.mapToGlobal(Qt.point(networkButton.width / 2, 0)).x - (networkPopupWindow.implicitWidth / 2)
            rect.y: networkButton.mapToGlobal(Qt.point(0, networkButton.height)).y + Appearance.margin.normal
        }

        implicitWidth: Math.max(360, windowRoot.width / 6)
        implicitHeight: Math.max(380, Math.round(lineH * 9 + sidePad * 2))

        onVisibleChanged: if (visible) {
            refreshWifiState()
            scanProc.running = true
            scanTimer.restart()
        } else {
            pwMode = "hidden"
            _pendingSsid = ""
            _inputSsid = ""
            _inputPassword = ""
        }

        // ===== Poll (gentle) =====
        Timer {
            id: scanTimer
            interval: 4000
            running: networkPopupWindow.visible && !networkPopup._busyAction && networkPopup.wifiEnabled
            repeat: true
            onTriggered: scanProc.running = true
        }

        // ===== Processes =====
        Process {
            id: stateProc
            command: ["sh","-c",
                "nmcli -t -f WIFI g 2>/dev/null; " +
                "nmcli -t -f NAME,DEVICE c show --active 2>/dev/null | head -n1 | cut -d: -f1"
            ]
            running: false
            stdout: StdioCollector {
                onStreamFinished: {
                    const out = (this.text||"").trim().split('\n')
                    networkPopup.wifiEnabled = (out[0]||"").indexOf("enabled") === 0
                    networkPopup.currentSsid = out.length>1 ? out[1] : ""
                }
            }
        }

        Process {
            id: scanProc
            command: ["sh","-c",
                "nmcli dev wifi rescan >/dev/null 2>&1 || true; " +
                "nmcli -m multiline -e no -f IN-USE,SSID,SIGNAL,SECURITY dev wifi list 2>/dev/null"
            ]
            running: false
            stdout: StdioCollector {
                onStreamFinished: {
                    if (!networkPopup.wifiEnabled) { networkPopup.networks = []; return }

                    const text = String(this.text||"")
                    const lines = text.split('\n')
                    const rows = []
                    const seen = new Set()
                    let cur = null

                    function pushCur() {
                        if (!cur) return
                        let ssid = (cur.ssid || "").trim()
                        if (!ssid) { cur = null; return }
                        if (ssid === "--") ssid = "(Hidden network)"
                        if (!seen.has(ssid)) {
                            seen.add(ssid)
                            const sig = Math.max(0, Math.min(100, parseInt(cur.signal||0) || 0))
                            const sec = (cur.security && String(cur.security).trim() !== "--")
                            rows.push({ active: !!cur.active, ssid, signal: sig, secure: sec })
                        }
                        cur = null
                    }

                    for (let i=0;i<lines.length;i++) {
                        const ln = lines[i]
                        if (!ln || ln.trim()==="") { pushCur(); continue }
                        const idx = ln.indexOf(':'); if (idx < 0) continue
                        const key = ln.slice(0, idx).trim().toUpperCase()
                        const val = ln.slice(idx+1).trim()

                        if (key === "IN-USE") { pushCur(); cur = {}; cur.active = (val.indexOf('*') === 0) }
                        else { cur = cur || {}; if (key === "SSID") cur.ssid = val
                                                 else if (key === "SIGNAL") cur.signal = val
                                                 else if (key === "SECURITY") cur.security = val }
                    }
                    pushCur()

                    rows.sort((a,b)=>(b.active-a.active)||(b.signal-a.signal)||a.ssid.localeCompare(b.ssid))
                    networkPopup.networks = rows

                    // if pending SSID fell out of scan, keep the sheet but show label only
                }
            }
        }

        Process { id: connectOpenProc; running: false
            stdout: StdioCollector { onStreamFinished: finalizeAction() }
            stderr: StdioCollector { onStreamFinished: finalizeAction() }
        }
        Process { id: connectSecureProc; running: false
            stdout: StdioCollector { onStreamFinished: finalizeAction() }
            stderr: StdioCollector { onStreamFinished: finalizeAction() }
        }
        Process { id: disconnectProc; running: false
            stdout: StdioCollector { onStreamFinished: finalizeAction() }
            stderr: StdioCollector { onStreamFinished: finalizeAction() }
        }
        Process { id: toggleWifiProc; running: false
            stdout: StdioCollector { onStreamFinished: { refreshWifiState(); scanProc.running = true } }
            stderr: StdioCollector { onStreamFinished: { refreshWifiState(); scanProc.running = true } }
        }

        function refreshWifiState() { stateProc.running = true }
        function startAction() { networkPopup._busyAction = true }
        function finalizeAction() {
            networkPopup._busyAction = false
            pwMode = "hidden"
            _inputPassword = ""
            refreshWifiState()
            scanProc.running = true
        }
        function shellQuote(s) { return "'" + String(s).replaceAll("'", "'\"'\"'") + "'" }

        function connectTo(ssid, secure) {
            _pendingSsid = ssid
            if (secure) {
                pwMode = "known"
                _inputPassword = ""
            } else {
                startAction()
                connectOpenProc.command = ["sh","-c",
                    "nmcli c up id " + shellQuote(ssid) + " >/dev/null 2>&1 || " +
                    "nmcli dev wifi connect " + shellQuote(ssid)
                ]
                connectOpenProc.running = true
            }
        }
        function doConnectWithPassword(ssid, password) {
            startAction()
            connectSecureProc.command = ["sh","-c",
                "nmcli c up id " + shellQuote(ssid) + " >/dev/null 2>&1 || " +
                "nmcli dev wifi connect " + shellQuote(ssid) + " password " + shellQuote(password)
            ]
            connectSecureProc.running = true
        }
        function disconnectCurrent() {
            if (!currentSsid) return
            startAction()
            disconnectProc.command = ["sh","-c","nmcli c down id " + shellQuote(currentSsid)]
            disconnectProc.running = true
        }
        function toggleWifi() {
            startAction()
            toggleWifiProc.command = ["sh","-c","nmcli r wifi " + (wifiEnabled ? "off" : "on")]
            toggleWifiProc.running = true
        }

        function signalBars(pct) {
            if (pct >= 80) return "▮▮▮▮"
            if (pct >= 60) return "▮▮▮▯"
            if (pct >= 40) return "▮▮▯▯"
            if (pct >= 20) return "▮▯▯▯"
            return "▯▯▯▯"
        }

        // keep auto-close behavior
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            propagateComposedEvents: true
            onEntered:  windowRoot.stopTimer()
            onExited:   windowRoot.restartTimer()
            onPressed:  windowRoot.stopTimer()
            onWheel:    windowRoot.stopTimer()
        }

        Rectangle {
            anchors.fill: parent
            color: Colors.colors.background

            // ===== Header + list =====
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: sidePad
                spacing: Math.round(lineH * 0.4)

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    Text {
                        text: "Network"
                        color: Colors.colors.foreground
                        font.family: "monospace"
                        font.pixelSize: Appearance.font.size.large
                        font.letterSpacing: 1.2
                        Layout.alignment: Qt.AlignVCenter
                    }
                    Item { Layout.fillWidth: true; Layout.preferredHeight: 1 }
                    Text {
                        id: toggleText
                        text: wifiEnabled ? "ON" : "OFF"
                        color: Colors.colors.foreground
                        font.family: "monospace"
                        font.pixelSize: Appearance.font.size.large
                        font.letterSpacing: 1.2
                        opacity: _busyAction ? 0.5 : 1.0
                        Layout.alignment: Qt.AlignVCenter
                        MouseArea {
                            anchors.fill: parent
                            enabled: !_busyAction
                            cursorShape: Qt.PointingHandCursor
                            onClicked: toggleWifi()
                        }
                    }
                }

                ListView {
                    id: list
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: Math.round(lineH * 0.25)
                    boundsBehavior: Flickable.StopAtBounds
                    model: listModel

                    delegate: Item {
                        width: ListView.view.width
                        height: lineH

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.right: bars.left
                            anchors.rightMargin: 12
                            text: modelData.ssid
                            elide: Text.ElideRight
                            color: Colors.colors.foreground
                            font.family: "monospace"
                            font.pixelSize: Math.round(Appearance.font.size.large * 1.15)
                            font.letterSpacing: 1.2
                            opacity: modelData._other ? faded : (modelData.active ? 1.0 : 0.95)
                        }

                        Text {
                            id: bars
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            text: modelData._other ? "" : signalBars(modelData.signal)
                            font.family: "monospace"
                            font.pixelSize: Math.round(Appearance.font.size.large * 0.95)
                            color: Colors.colors.foreground
                            opacity: 0.9
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: !_busyAction && wifiEnabled
                            onClicked: {
                                if (modelData._other) {
                                    pwMode = "other"
                                    _inputSsid = ""
                                    _inputPassword = ""
                                } else if (modelData.active) {
                                    disconnectCurrent()
                                } else {
                                    if (modelData.ssid === "(Hidden network)") {
                                        pwMode = "other"; _inputSsid = ""; _inputPassword = ""
                                        return
                                    }
                                    connectTo(modelData.ssid, /*secure*/ modelData.secure)
                                }
                            }
                        }
                    }

                    ScrollBar.vertical: ScrollBar { interactive: true }
                }
            }

            // ===== Bottom sheet (password / other) =====
            FocusScope {
                id: sheet
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: sidePad
                visible: pwMode !== "hidden"
                height: visible ? content.implicitHeight + 12 : 0
                clip: true

                Behavior on height { NumberAnimation { duration: 180; easing.type: Easing.InOutCubic } }

                Rectangle {
                    anchors.fill: parent
                    radius: 10
                    color: Colors.colors.color1
                    opacity: 0.22
                    border.color: Colors.colors.foreground
                    border.width: 1
                }

                ColumnLayout {
                    id: content
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 10
                    spacing: 8

                    Text {
                        Layout.fillWidth: true
                        text: pwMode === "other"
                              ? "Join other network"
                              : ("Enter password for " + _pendingSsid)
                        color: Colors.colors.foreground
                        font.family: "monospace"
                        font.pixelSize: Math.round(Appearance.font.size.large * 0.95)
                        wrapMode: Text.WordWrap
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        TextField {
                            id: ssidField
                            Layout.fillWidth: pwMode === "other"
                            visible: pwMode === "other"
                            placeholderText: "Network name (SSID)"
                            text: _inputSsid
                            onTextChanged: _inputSsid = text
                            color: Colors.colors.foreground
                            background: Rectangle {
                                radius: 6; color: Colors.colors.background; opacity: 0.35
                                border.width: 1; border.color: Colors.colors.foreground
                            }
                        }

                        TextField {
                            id: pwField
                            Layout.fillWidth: true
                            placeholderText: "Wi-Fi password"
                            echoMode: showPw.checked ? TextInput.Normal : TextInput.Password
                            text: _inputPassword
                            onTextChanged: _inputPassword = text
                            enabled: !_busyAction
                            color: Colors.colors.foreground
                            background: Rectangle {
                                radius: 6; color: Colors.colors.background; opacity: 0.35
                                border.width: 1; border.color: Colors.colors.foreground
                            }
                            Component.onCompleted: forceActiveFocus()
                            Keys.onReturnPressed: {
                                if (!_busyAction) submit()
                            }
                            Keys.onEnterPressed: Keys.onReturnPressed(event)
                        }

                        CheckBox {
                            id: showPw
                            text: "Show"
                            checked: false
                            enabled: !_busyAction
                            contentItem: Text { text: showPw.text; color: Colors.colors.foreground; font.family: "monospace" }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Item { Layout.fillWidth: true; Layout.preferredHeight: 1 }

                        Button {
                            text: "Cancel"
                            enabled: !_busyAction
                            onClicked: { pwMode = "hidden"; _inputPassword = ""; _inputSsid = "" }
                            contentItem: Text { text: parent.text; color: Colors.colors.foreground; font.family: "monospace" }
                            background: Rectangle { radius: 8; color: Colors.colors.color1; opacity: 0.25; border.color: Colors.colors.foreground; border.width: 1 }
                        }

                        Button {
                            text: _busyAction ? "Connecting…" : "Connect"
                            enabled: !_busyAction && (
                                (pwMode === "other" && _inputSsid.length > 0) ||
                                (pwMode === "known" && _pendingSsid.length > 0)
                            ) && _inputPassword.length > 0
                            onClicked: submit()
                            contentItem: Text { text: parent.text; color: Colors.colors.foreground; font.family: "monospace" }
                            background: Rectangle { radius: 8; color: Colors.colors.color1; opacity: 0.35; border.color: Colors.colors.foreground; border.width: 1 }
                        }
                    }
                }

                Keys.onEscapePressed: { pwMode = "hidden"; _inputPassword = ""; _inputSsid = "" }

                function submit() {
                    if (pwMode === "other") {
                        doConnectWithPassword(_inputSsid, _inputPassword)
                    } else {
                        doConnectWithPassword(_pendingSsid, _inputPassword)
                    }
                }
            }
        }
    }
}

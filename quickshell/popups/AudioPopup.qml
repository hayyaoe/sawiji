import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "root:/config"
import "root:/utilities"

LazyLoader {
    id: audioPopup
    loading: true

    // external hooks
    property var audioButton
    property var windowRoot

    // state
    property real volumeLevel: 0.0        // 0..1
    property bool volumeMuted: false

    property real microphoneLevel: 0.0    // 0..1
    property bool micMuted: false
    property bool isMicrophoneAvailable: false

    // mic targeting (avoid .monitor sources)
    property string micTarget: "@DEFAULT_SOURCE@"
    property bool _resolvedMic: false

    // drag-state
    property bool _isAdjustingVolume: false
    property bool _isAdjustingMic: false

    // throttling + deltas
    readonly property real _eps: 0.005     // ignore <0.5% diffs when *reading*
    readonly property real _delta: 0.01    // only push if moved >=1% since last push
    property real _volPending: -1
    property real _volLastSent: -1
    property bool _volDirty: false
    property real _micPending: -1
    property real _micLastSent: -1
    property bool _micDirty: false

    PopupWindow {
        id: audioPopupWindow

        onVisibleChanged: if (visible) {
            if (!audioPopup._resolvedMic) micResolveProc.running = true
            volumeInfoProc.running = true
            microphoneInfoProc.running = true
        }

        // Keep UI in sync while visible (pause while dragging)
        Timer {
            interval: 750
            running: audioPopupWindow.visible
            repeat: true
            onTriggered: {
                if (!audioPopup._isAdjustingVolume)  volumeInfoProc.running     = true
                if (!audioPopup._isAdjustingMic)     microphoneInfoProc.running = true
            }
        }

        // Throttle: push volume during drag (max ~10/s), only if delta >= 1%
        Timer {
            id: volPushTimer
            interval: 100
            running: audioPopup._isAdjustingVolume
            repeat: true
            onTriggered: {
                if (!audioPopup._volDirty) return
                const v = Math.max(0, Math.min(1, audioPopup._volPending))
                if (audioPopup._volLastSent >= 0 && Math.abs(v - audioPopup._volLastSent) < audioPopup._delta)
                    return
                if (volumeProc.running) return
                const percent = Math.round(v * 100) + "%"
                volumeProc.command = ["sh","-c","pactl set-sink-volume @DEFAULT_SINK@ " + percent]
                audioPopup.volumeLevel = v
                audioPopup._volLastSent = v
                audioPopup._volDirty = false
                volumeProc.running = true
            }
        }

        // Throttle: push mic during drag (max ~10/s), only if delta >= 1%
        Timer {
            id: micPushTimer
            interval: 100
            running: audioPopup._isAdjustingMic
            repeat: true
            onTriggered: {
                if (!audioPopup._micDirty) return
                const v = Math.max(0, Math.min(1, audioPopup._micPending))
                if (audioPopup._micLastSent >= 0 && Math.abs(v - audioPopup._micLastSent) < audioPopup._delta)
                    return
                if (microphoneProc.running) return
                const percent = Math.round(v * 100) + "%"
                microphoneProc.command = ["sh","-c","pactl set-source-volume " + audioPopup.micTarget + " " + percent]
                audioPopup.microphoneLevel = v
                audioPopup._micLastSent = v
                audioPopup._micDirty = false
                microphoneProc.running = true
            }
        }

        // Gentle refresh shortly after release to reconcile with Pulse/WirePlumber
        Timer {
            id: releaseRefresh
            interval: 150
            repeat: false
            onTriggered: audioPopupWindow.refreshAll()
        }

        // ---------- Resolve a real capture source (not a .monitor) ----------
        Process {
            id: micResolveProc
            command: ["sh","-c",
                "def=$(pactl get-default-source 2>/dev/null || true); " +
                "name=$(printf '%s' \"$def\" | awk '{print $NF}'); " +
                "if printf '%s' \"$name\" | grep -q '\\.monitor$'; then " +
                "  pactl list short sources | awk '!/\\.monitor$/ {print $1; exit}'; " +
                "else " +
                "  printf '%s' \"$name\"; " +
                "fi"
            ]
            running: false
            stdout: StdioCollector {
                onStreamFinished: {
                    const cand = (this.text || "").trim()
                    audioPopup.micTarget = (cand.length > 0) ? cand : "@DEFAULT_SOURCE@"
                    audioPopup._resolvedMic = true
                }
            }
        }

        // ---------- READERS ----------
        Process {
            id: volumeInfoProc
            command: ["sh", "-c",
                "pactl get-sink-volume @DEFAULT_SINK@; pactl get-sink-mute @DEFAULT_SINK@"
            ]
            running: false
            stdout: StdioCollector {
                onStreamFinished: {
                    if (audioPopup._isAdjustingVolume) return
                    const out = String(this.text || "")
                    var m = out.match(/(\d+)\s*%/)
                    if (m) {
                        const v = Math.max(0, Math.min(1, parseInt(m[1],10)/100))
                        if (Math.abs(v - audioPopup.volumeLevel) > audioPopup._eps)
                            audioPopup.volumeLevel = v
                    }
                    var mm = out.match(/Mute:\s+(yes|no)/)
                    if (mm) audioPopup.volumeMuted = (mm[1] === "yes")
                }
            }
        }

        Process {
            id: microphoneInfoProc
            command: ["sh", "-c",
                "pactl get-source-volume " + audioPopup.micTarget + " 2>/dev/null; " +
                "pactl get-source-mute "   + audioPopup.micTarget + " 2>/dev/null"
            ]
            running: false
            stdout: StdioCollector {
                onStreamFinished: {
                    if (audioPopup._isAdjustingMic) return
                    const out = String(this.text || "")
                    var v = out.match(/(\d+)\s*%/)
                    audioPopup.isMicrophoneAvailable = !!v
                    if (v) {
                        const val = Math.max(0, Math.min(1, parseInt(v[1],10)/100))
                        if (Math.abs(val - audioPopup.microphoneLevel) > audioPopup._eps)
                            audioPopup.microphoneLevel = val
                    }
                    var mm = out.match(/Mute:\s+(yes|no)/)
                    if (mm) audioPopup.micMuted = (mm[1] === "yes")
                }
            }
        }

        // ---------- WRITERS ----------
        Process {
            id: volumeProc
            running: false
            onExited: { if (!audioPopup._isAdjustingVolume) audioPopupWindow.refreshAll() }
        }
        Process {
            id: microphoneProc
            running: false
            onExited: { if (!audioPopup._isAdjustingMic) audioPopupWindow.refreshAll() }
        }

        function refreshAll() {
            if (!audioPopup._isAdjustingVolume) volumeInfoProc.running = true
            if (!audioPopup._isAdjustingMic)    microphoneInfoProc.running = true
        }

        function setVolume(level) {
            const v = Math.max(0, Math.min(1, level))
            const percent = Math.round(v * 100) + "%"
            volumeProc.command = ["sh", "-c", "pactl set-sink-volume @DEFAULT_SINK@ " + percent]
            audioPopup._volLastSent = v
            volumeProc.running = true
        }

        function setMicrophone(level) {
            const v = Math.max(0, Math.min(1, level))
            const percent = Math.round(v * 100) + "%"
            microphoneProc.command = ["sh", "-c", "pactl set-source-volume " + audioPopup.micTarget + " " + percent]
            audioPopup._micLastSent = v
            microphoneProc.running = true
        }

        function toggleVolumeMute() {
            volumeProc.command = ["sh", "-c", "pactl set-sink-mute @DEFAULT_SINK@ toggle"]
            audioPopup.volumeMuted = !audioPopup.volumeMuted
            volumeProc.running = true
        }

        function toggleMicMute() {
            microphoneProc.command = ["sh", "-c", "pactl set-source-mute " + audioPopup.micTarget + " toggle"]
            audioPopup.micMuted = !audioPopup.micMuted
            microphoneProc.running = true
        }

        // ---------- layout ----------
        anchor {
            window: windowRoot
            rect.x: audioButton.mapToGlobal(Qt.point(audioButton.width / 2, 0)).x - (audioPopupWindow.implicitWidth / 2)
            rect.y: audioButton.mapToGlobal(Qt.point(0, audioButton.height)).y + Appearance.margin.normal
        }
        implicitWidth: windowRoot.width / 6

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onExited: windowRoot.restartTimer()
            onEntered: windowRoot.stopTimer()
        }

        Rectangle {
            anchors.fill: parent
            color: Colors.colors.background

            Column {
                anchors.centerIn: parent
                spacing: Appearance.spacing.large
                width: parent.width - Appearance.margin.normal * 2

                // --------- OUTPUT (speaker) ----------
                RowLayout {
                    width: parent.width
                    spacing: Appearance.spacing.large
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: Appearance.margin.large
                    anchors.rightMargin: Appearance.margin.large

                    Text {
                        text: audioPopup.volumeMuted ? "" : ""
                        font.pixelSize: Appearance.font.size.large
                        color: Colors.colors.foreground
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                        Layout.preferredWidth: 20
                        Layout.minimumWidth: 20

                        MouseArea {
                            anchors.fill: parent
                            onPressed: toggleVolumeMute()
                        }
                    }

                    Rectangle {
                        id: sliderTrackVolume
                        Layout.fillWidth: true
                        height: Appearance.font.size.small / 3
                        color: Colors.colors.color1
                        Layout.alignment: Qt.AlignVCenter

                        Rectangle {
                            id: sliderFillVolume
                            width: sliderTrackVolume.width * audioPopup.volumeLevel
                            height: parent.height
                            color: Colors.colors.foreground
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            onPressed: function (mouse) {
                                audioPopup._isAdjustingVolume = true
                                setLocal(mouse.x)
                            }
                            onPositionChanged: function (mouse) {
                                if (pressed) setLocal(mouse.x)
                            }
                            onReleased: function (mouse) {
                                setLocal(mouse.x)
                                // ensure final value pushed even if delta small / proc busy
                                if (!volumeProc.running) {
                                    audioPopupWindow.setVolume(audioPopup._volPending >= 0 ? audioPopup._volPending : audioPopup.volumeLevel)
                                } else {
                                    audioPopup._volDirty = true
                                }
                                audioPopup._isAdjustingVolume = false
                                releaseRefresh.start()
                            }

                            function setLocal(mouseX) {
                                const level = Math.max(0, Math.min(1, mouseX / sliderTrackVolume.width))
                                audioPopup.volumeLevel = level
                                audioPopup._volPending = level
                                audioPopup._volDirty = true
                            }
                        }
                    }
                }

                // --------- INPUT (microphone) ----------
                RowLayout {
                    width: parent.width
                    visible: audioPopup.isMicrophoneAvailable
                    spacing: Appearance.spacing.large
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: Appearance.margin.large
                    anchors.rightMargin: Appearance.margin.large

                    Text {
                        text: audioPopup.micMuted ? "" : ""
                        font.pixelSize: Appearance.font.size.large
                        color: Colors.colors.foreground
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                        Layout.preferredWidth: 20
                        Layout.minimumWidth: 20

                        MouseArea {
                            anchors.fill: parent
                            onPressed: toggleMicMute()
                        }
                    }

                    Rectangle {
                        id: sliderTrackMicrophone
                        Layout.fillWidth: true
                        height: Appearance.font.size.small / 3
                        color: Colors.colors.color1
                        Layout.alignment: Qt.AlignVCenter

                        Rectangle {
                            id: sliderFillMicrophone
                            width: sliderTrackMicrophone.width * audioPopup.microphoneLevel
                            height: parent.height
                            color: Colors.colors.foreground
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            onPressed: function (mouse) {
                                audioPopup._isAdjustingMic = true
                                setLocal(mouse.x)
                            }
                            onPositionChanged: function (mouse) {
                                if (pressed) setLocal(mouse.x)
                            }
                            onReleased: function (mouse) {
                                setLocal(mouse.x)
                                if (!microphoneProc.running) {
                                    audioPopupWindow.setMicrophone(audioPopup._micPending >= 0 ? audioPopup._micPending : audioPopup.microphoneLevel)
                                } else {
                                    audioPopup._micDirty = true
                                }
                                audioPopup._isAdjustingMic = false
                                releaseRefresh.start()
                            }

                            function setLocal(mouseX) {
                                const level = Math.max(0, Math.min(1, mouseX / sliderTrackMicrophone.width))
                                audioPopup.microphoneLevel = level
                                audioPopup._micPending = level
                                audioPopup._micDirty = true
                            }
                        }
                    }
                }
            }
        }
    }
}

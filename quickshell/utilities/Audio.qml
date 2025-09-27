pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property int outputVolume: 0
    property bool outputMuted: false

    property int inputVolume: 0
    property bool inputMuted: false
    property bool micAvailable: false

    signal updated() // emitted when info is refreshed

    function refresh() {
        audioInfoProc.running = true
    }

    Process {
        id: audioInfoProc
        command: ["sh", "-c", "pactl list sinks && pactl list sources"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                var output = this.text;

                var sinkVolumeMatch = output.match(/Sink #\d+[\s\S]*?Volume:.*?(\d+)%/);
                if (sinkVolumeMatch) root.outputVolume = parseInt(sinkVolumeMatch[1]);

                var sinkMuteMatch = output.match(/Sink #\d+[\s\S]*?Mute:\s+(yes|no)/);
                if (sinkMuteMatch) root.outputMuted = (sinkMuteMatch[1] === "yes");

                var sourceVolumeMatch = output.match(/Source #\d+[\s\S]*?Volume:.*?(\d+)%/);
                if (sourceVolumeMatch) {
                    root.inputVolume = parseInt(sourceVolumeMatch[1]);
                    root.micAvailable = true;
                } else {
                    root.micAvailable = false;
                }

                var sourceMuteMatch = output.match(/Source #\d+[\s\S]*?Mute:\s+(yes|no)/);
                if (sourceMuteMatch) root.inputMuted = (sourceMuteMatch[1] === "yes");

                root.updated();
            }
        }
    }
}

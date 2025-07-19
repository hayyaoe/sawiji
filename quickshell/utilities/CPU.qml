pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  property string cpuTemp
  property string cpuUsage

  Process {
    id: tempCpu
    command: ["sh", "-c", "sensors | grep -m 1 -oP 'Package id 0:\\s+\\+\\K[0-9.]+' | awk '{printf \"%d\", ($1 + 0.5)}'"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: {
        root.cpuTemp = this.text
      }
    }
  }

  Process {
    id: usageCpu
    command: ["sh", "-c", "top -bn1 | awk '/Cpu\\(s\\)/ {printf \"%.0f\", 100 - \$8}'"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: {
        root.cpuUsage = this.text
      }
    }
  }

  Timer {
    interval: 5000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      usageCpu.running = true
      tempCpu.running = true
    }
  }
}

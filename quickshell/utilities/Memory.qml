pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  property string memoryTotal
  property string memoryAvailable

  Process {
    id: totalMemory
    command: ["awk","/MemTotal/ {print $2}", "/proc/meminfo"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: {
        root.memoryTotal = this.text
      }
    }
  }

  Process {
    id: availableMemory
    command: ["awk","/MemAvailable/ {print $2}", "/proc/meminfo"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: {
        root.memoryAvailable = this.text
      }
    }
  }

  Timer {
    interval: 5000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      availableMemory.running = true
      totalMemory.running = true
    }
  }
}

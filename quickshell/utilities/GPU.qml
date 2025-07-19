pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  property string gpuTemp
  property string gpuUsage
  property string gpuBrand: "radeon"

  Process {
    id: tempGpu
    command: ["sh", "-c", "for f in /sys/class/hwmon/hwmon*/name; do if grep -qiE 'amdgpu|nvidia' $f; then cat $(dirname $f)/temp1_input; fi; done | awk '{printf \"%d\", $1 / 1000}'"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: {
        root.gpuTemp = this.text
      }
    }
  }

  Process {
    id: usageGpu
    command: ["sh", "-c", "radeontop -d - -l 1 | grep -o 'gpu [0-9.]*%' | sed -E 's/gpu ([0-9.]+)%/\\1/' | cut -d'.' -f1 | tr -d '\n'"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: {
        root.gpuUsage = this.text
      }
    }
  }

  Timer {
    interval: 5000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      usageGpu.running = true
      tempGpu.running = true
    }
  }
}

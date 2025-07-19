import "root:/utilities"

import Quickshell
import QtQuick

Text{
  property string displayMode: "temp"

  text:{
      if (displayMode === "temp") {
          return `GPU:${GPU.gpuTemp}C`
      } else if (displayMode === "percentage") {
          return `GPU:${GPU.gpuUsage}%`
      } else {
          return "Invalid GPU Output Mode"
      }
  }
}

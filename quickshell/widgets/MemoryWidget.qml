import "root:/utilities"

import QtQuick

Text {

  property string displayMode: "usage"
  property int total: parseInt(Memory.memoryTotal)
  property int available: parseInt(Memory.memoryAvailable)
  property int used: total - available

  property double totalGb: (total / 1024000)
  property double usedGb: (used / 1024000)
  property int percent: Math.round((used / total) * 100)
  
  text: {
      if (displayMode === "usage") {
          return `${usedGb.toFixed(2)} / ${totalGb.toFixed(2)} GB`
      } else if (displayMode === "percentage") {
          return `MEM:${percent}%`
      } else {
          return "Invalid Memory Output Mode"
      }
  }
}

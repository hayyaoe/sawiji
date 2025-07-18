import "root:/utilities"

import QtQuick

Text {
  property int total: parseInt(Memory.memoryTotal)
  property int available: parseInt(Memory.memoryAvailable)
  property int used: total - available

  property double totalGb: (total / 1024000)
  property double usedGb: (used / 1024000)
  
  text: `${usedGb.toFixed(2)} / ${totalGb.toFixed(2)} GB`
}

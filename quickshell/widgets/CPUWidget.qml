import "root:/utilities"

import Quickshell
import QtQuick

Text {
    property string displayMode: "temp"

    text: {
        if (displayMode === "temp") {
            return `CPU:${CPU.cpuTemp}C`;
        } else if (displayMode === "percentage") {
            return `CPU:${CPU.cpuUsage}%`;
        } else {
            return "Invalid CPU Output Mode";
        }
    }
}

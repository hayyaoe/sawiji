pragma Singleton

import Quickshell
import QtQuick
import Quickshell.Hyprland

Singleton {
  id: root
  
  readonly property var workspaces: Hyprland.workspaces
  readonly property var monitors: Hyprland.monitors

  readonly property HyprlandWorkspace focusedWorkspace: Hyprland.focusedWorkspace
  readonly property HyprlandMonitor focusedMonitor: Hyprland.focusedMonitor
  readonly property int activeWsId: focusedWorkspace?.id ?? 1

  function dispatch(request: string): void {
    Hyprland.dispatch(request)
  }

}

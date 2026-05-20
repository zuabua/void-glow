// VOID GLOW - B2 drop zone. Visibility driven by a state file
// (~/.cache/voidglow-b2-shown). File-watch works across all
// Quickshell versions - no SignalHandler/IPC type fragility.
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

ShellRoot {
    id: root
    property bool shown: false

    // Poll a state file every 300ms; "1" = shown, anything else = hidden.
    
    FileView {
        id: stateFile
        path: "/home/zua/.cache/voidglow-b2-shown"
        watchChanges: true
        onLoaded: root.shown = (stateFile.text().trim() === "1")
        onFileChanged: { stateFile.reload(); root.shown = (stateFile.text().trim() === "1") }
    }

    PanelWindow {
        visible: root.shown
        anchors { top: true }
        implicitWidth: 320
        implicitHeight: 200
        exclusiveZone: 0
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Top

        Rectangle {
            anchors.fill: parent
            radius: 12
            color: "#131318"               // VOID_SURFACE
            border.color: "#5eead4"        // VOID_ACCENT_TEAL
            border.width: 2
            Column {
                anchors.centerIn: parent
                spacing: 8
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "\u2601"
                    color: "#5eead4"
                    font.family: "JetBrainsMono Nerd Font Mono"
                    font.pixelSize: 32
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "B2 Drop Zone"
                    color: "#e2e8f0"
                    font.family: "JetBrainsMono Nerd Font Mono"
                    font.pixelSize: 13
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "drag a file here"
                    color: "#64748b"
                    font.family: "JetBrainsMono Nerd Font Mono"
                    font.pixelSize: 10
                }
            }
        }
    }
}

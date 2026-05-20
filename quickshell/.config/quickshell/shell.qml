// VOID GLOW - B2 drop zone, full UI
// Toggled by ~/.cache/voidglow-b2-shown (Waybar button writes 1/0)
// Upload via b2-upload.sh; status read from ~/.cache/voidglow-b2-status
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

ShellRoot {
    id: root
    property bool shown: false
    property string selectedCategory: "Misc"   // default destination
    readonly property var categories: ["Pictures", "Videos", "Documents", "Code", "HTB", "Misc"]

    // Visibility state file (toggle from Waybar)
    FileView {
        id: stateFile
        path: "/home/zua/.cache/voidglow-b2-shown"
        watchChanges: true
        onLoaded: root.shown = (stateFile.text().trim() === "1")
        onFileChanged: { stateFile.reload(); root.shown = (stateFile.text().trim() === "1") }
    }

    // Status file (script writes results here)
    FileView {
        id: statusFile
        path: "/home/zua/.cache/voidglow-b2-status"
        watchChanges: true
        property string line: ""
        onLoaded:       line = statusFile.text().trim()
        onFileChanged:  { statusFile.reload(); line = statusFile.text().trim() }
    }

    // Process runner — picker + upload script
    Process {
        id: pickAndUpload
        // bash -c so we can chain zenity output into the uploader
        command: ["bash", "-c",
            "p=$(zenity --file-selection --title='Upload to B2: " + root.selectedCategory + "') " +
            "&& ~/.config/quickshell/b2-upload.sh '" + root.selectedCategory + "' \"$p\""
        ]
        running: false
    }

    Process {
        id: pickAndUploadFolder
        command: ["bash", "-c",
            "p=$(zenity --file-selection --directory --title='Upload folder to B2: " + root.selectedCategory + "') " +
            "&& ~/.config/quickshell/b2-upload.sh '" + root.selectedCategory + "' \"$p\""
        ]
        running: false
    }

    PanelWindow {
        visible: root.shown
        anchors { top: true }
        margins.top: 44
        implicitWidth: 380
        implicitHeight: 320
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Top
        exclusiveZone: 0

        Rectangle {
            anchors.fill: parent
            radius: 12
            color: "#131318"               // VOID_SURFACE
            border.color: "#5eead4"        // VOID_ACCENT_TEAL - glow edge
            border.width: 2

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 12

                // ── Title ──────────────────────────────────────
                Text {
                    text: "\uf0c2  B2 Drop Zone"
                    color: "#e2e8f0"        // VOID_TEXT
                    font.family: "JetBrainsMono Nerd Font Mono"
                    font.pixelSize: 14
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                // ── Category pills ─────────────────────────────
                Flow {
                    Layout.fillWidth: true
                    spacing: 6
                    Repeater {
                        model: root.categories
                        Rectangle {
                            property bool active: modelData === root.selectedCategory
                            radius: 6
                            color: active ? "#5eead4" : "#1c1c24"   // TEAL : OVERLAY
                            border.color: active ? "#5eead4" : "#1c1c24"
                            width: catLabel.implicitWidth + 18
                            height: 26
                            Text {
                                id: catLabel
                                anchors.centerIn: parent
                                text: modelData
                                color: parent.active ? "#0d0d0f" : "#e2e8f0"  // BASE-on-TEAL : TEXT
                                font.family: "JetBrainsMono Nerd Font Mono"
                                font.pixelSize: 11
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: root.selectedCategory = modelData
                            }
                        }
                    }
                }

                // ── Drop / instruction area ────────────────────
                Rectangle {
                    id: dropWell
                    Layout.fillWidth: true
                    Layout.preferredHeight: 90
                    radius: 8
                    color: "#0d0d0f"               // VOID_BASE
                    property bool busy: pickAndUpload.running || pickAndUploadFolder.running
                    border.color: busy ? "#5eead4" : "#1c1c24"   // pulse to TEAL while busy
                    border.width: busy ? 2 : 1
                    Behavior on border.color { ColorAnimation { duration: 250 } }
                    Behavior on border.width { NumberAnimation { duration: 250 } }

                    // Pulse animation only while busy
                    SequentialAnimation on opacity {
                        running: dropWell.busy
                        loops: Animation.Infinite
                        NumberAnimation { from: 1.0; to: 0.55; duration: 700; easing.type: Easing.InOutSine }
                        NumberAnimation { from: 0.55; to: 1.0; duration: 700; easing.type: Easing.InOutSine }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: dropWell.busy ? "\uf021  Uploading..." : "Drag here, or use buttons below"
                        color: dropWell.busy ? "#5eead4" : "#64748b"   // TEAL when busy, SUBTEXT idle
                        font.family: "JetBrainsMono Nerd Font Mono"
                        font.pixelSize: 11
                    }
                }

                // ── Action buttons ─────────────────────────────
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        Layout.fillWidth: true
                        height: 30
                        radius: 6
                        color: "#1c1c24"           // VOID_OVERLAY
                        border.color: "#5eead4"    // VOID_ACCENT_TEAL
                        border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text: "Pick file"
                            color: "#5eead4"        // TEAL
                            font.family: "JetBrainsMono Nerd Font Mono"
                            font.pixelSize: 11
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: pickAndUpload.running = true
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 30
                        radius: 6
                        color: "#1c1c24"           // VOID_OVERLAY
                        border.color: "#818cf8"    // VOID_ACCENT_INDIGO - secondary action
                        border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text: "Pick folder"
                            color: "#818cf8"        // INDIGO
                            font.family: "JetBrainsMono Nerd Font Mono"
                            font.pixelSize: 11
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: pickAndUploadFolder.running = true
                        }
                    }
                }

                // ── Status line ────────────────────────────────
                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideMiddle
                    text: statusFile.line === "" ? "ready" : statusFile.line
                    color: statusFile.line.indexOf("ERR") === 0 ? "#f87171"   // VOID_RED on err
                         : statusFile.line.indexOf("OK") === 0  ? "#5eead4"   // VOID_ACCENT_TEAL ok
                                                                : "#64748b"   // VOID_SUBTEXT
                    font.family: "JetBrainsMono Nerd Font Mono"
                    font.pixelSize: 10
                }
            }
        }
    }
}

// VOID GLOW - B2 widget, full UI (upload + manage + fetch)
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

ShellRoot {
    id: root
    property bool shown: false
    property bool manageOpen: false
    property string selectedCategory: "Misc"
    readonly property var categories: ["Pictures", "Videos", "Documents", "Code", "HTB", "Misc"]

    // ── State files ─────────────────────────────────────────
    FileView {
        id: stateFile
        path: "/home/zua/.cache/voidglow-b2-shown"
        watchChanges: true
        onLoaded: root.shown = (stateFile.text().trim() === "1")
        onFileChanged: { stateFile.reload(); root.shown = (stateFile.text().trim() === "1") }
    }
    FileView {
        id: statusFile
        path: "/home/zua/.cache/voidglow-b2-status"
        watchChanges: true
        property string line: ""
        onLoaded:      line = statusFile.text().trim()
        onFileChanged: { statusFile.reload(); line = statusFile.text().trim() }
    }
    FileView {
        id: listFile
        path: "/home/zua/.cache/voidglow-b2-list"
        watchChanges: true
        property var items: []
        onLoaded:      items = listFile.text().split("\n").filter(s => s.length > 0)
        onFileChanged: { listFile.reload(); items = listFile.text().split("\n").filter(s => s.length > 0) }
    }

    // ── Processes ───────────────────────────────────────────
    Process {
        id: pickAndUpload
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
    Process {
        id: refreshList
        command: ["bash", "-c", "~/.config/quickshell/b2-list.sh"]
        running: false
    }
    Process {
        id: deleteOne
        property string target: ""
        command: ["bash", "-c",
            "zenity --question --title='Delete from B2?' --text=\"Delete: $TARGET\\n\\nThis cannot be undone.\" " +
            "&& ~/.config/quickshell/b2-delete.sh \"$TARGET\" " +
            "&& ~/.config/quickshell/b2-list.sh"
        ]
        environment: ({ "TARGET": deleteOne.target })
        running: false
    }
    Process {
        id: fetchOne
        property string source: ""
        command: ["bash", "-c",
            "d=$(zenity --file-selection --directory --title='Save to which directory?') " +
            "&& ~/.config/quickshell/b2-fetch.sh \"$SOURCE\" \"$d\""
        ]
        environment: ({ "SOURCE": fetchOne.source })
        running: false
    }

    PanelWindow {
        visible: root.shown
        anchors { top: true }
        margins.top: 44
        implicitWidth: 420
        implicitHeight: root.manageOpen ? 560 : 320
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Top
        exclusiveZone: 0

        Rectangle {
            anchors.fill: parent
            radius: 12
            color: "#131318"               // VOID_SURFACE
            border.color: "#5eead4"        // VOID_ACCENT_TEAL
            border.width: 2

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                // ── Title ─────────────────────────────────
                Text {
                    text: "\uf0c2  B2 Drop Zone"
                    color: "#e2e8f0"
                    font.family: "JetBrainsMono Nerd Font Mono"
                    font.pixelSize: 14
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                // ── Category pills ────────────────────────
                Flow {
                    Layout.fillWidth: true
                    spacing: 6
                    Repeater {
                        model: root.categories
                        Rectangle {
                            property bool active: modelData === root.selectedCategory
                            radius: 6
                            color: active ? "#5eead4" : "#1c1c24"
                            width: catLabel.implicitWidth + 18
                            height: 26
                            Text {
                                id: catLabel
                                anchors.centerIn: parent
                                text: modelData
                                color: parent.active ? "#0d0d0f" : "#e2e8f0"
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

                // ── Drop / busy well ──────────────────────
                Rectangle {
                    id: dropWell
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    radius: 8
                    color: "#0d0d0f"
                    property bool busy: pickAndUpload.running || pickAndUploadFolder.running
                    border.color: busy ? "#5eead4" : "#1c1c24"
                    border.width: busy ? 2 : 1
                    Behavior on border.color { ColorAnimation { duration: 250 } }
                    Behavior on border.width { NumberAnimation { duration: 250 } }
                    SequentialAnimation on opacity {
                        running: dropWell.busy
                        loops: Animation.Infinite
                        NumberAnimation { from: 1.0; to: 0.55; duration: 700; easing.type: Easing.InOutSine }
                        NumberAnimation { from: 0.55; to: 1.0; duration: 700; easing.type: Easing.InOutSine }
                    }
                    Text {
                        anchors.centerIn: parent
                        text: dropWell.busy ? "\uf021  Uploading..." : "Drag here, or use buttons below"
                        color: dropWell.busy ? "#5eead4" : "#64748b"
                        font.family: "JetBrainsMono Nerd Font Mono"
                        font.pixelSize: 11
                    }
                }

                // ── Action buttons ────────────────────────
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Rectangle {
                        Layout.fillWidth: true; height: 30; radius: 6
                        color: "#1c1c24"; border.color: "#5eead4"; border.width: 1
                        Text { anchors.centerIn: parent; text: "Pick file"; color: "#5eead4"
                               font.family: "JetBrainsMono Nerd Font Mono"; font.pixelSize: 11 }
                        MouseArea { anchors.fill: parent; onClicked: pickAndUpload.running = true }
                    }
                    Rectangle {
                        Layout.fillWidth: true; height: 30; radius: 6
                        color: "#1c1c24"; border.color: "#818cf8"; border.width: 1
                        Text { anchors.centerIn: parent; text: "Pick folder"; color: "#818cf8"
                               font.family: "JetBrainsMono Nerd Font Mono"; font.pixelSize: 11 }
                        MouseArea { anchors.fill: parent; onClicked: pickAndUploadFolder.running = true }
                    }
                }

                // ── Status line ───────────────────────────
                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideMiddle
                    text: statusFile.line === "" ? "ready" : statusFile.line
                    color: statusFile.line.indexOf("ERR") === 0 ? "#f87171"
                         : statusFile.line.indexOf("OK") === 0  ? "#5eead4"
                                                                : "#64748b"
                    font.family: "JetBrainsMono Nerd Font Mono"
                    font.pixelSize: 10
                }

                // ── Manage toggle (recessive) ─────────────
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: root.manageOpen ? "\u2715  hide manage" : "\u22ef  manage bucket"
                    color: "#64748b"
                    font.family: "JetBrainsMono Nerd Font Mono"
                    font.pixelSize: 10
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.manageOpen = !root.manageOpen
                            if (root.manageOpen) refreshList.running = true
                        }
                    }
                }

                // ── Manage panel (collapsible) ────────────
                Rectangle {
                    visible: root.manageOpen
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 8
                    color: "#0d0d0f"
                    border.color: "#1c1c24"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 6

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                Layout.fillWidth: true
                                text: listFile.items.length + " items"
                                color: "#64748b"
                                font.family: "JetBrainsMono Nerd Font Mono"
                                font.pixelSize: 10
                            }
                            Rectangle {
                                width: 60; height: 22; radius: 4
                                color: "#1c1c24"; border.color: "#5eead4"; border.width: 1
                                Text { anchors.centerIn: parent; text: "refresh"; color: "#5eead4"
                                       font.family: "JetBrainsMono Nerd Font Mono"; font.pixelSize: 9 }
                                MouseArea { anchors.fill: parent; onClicked: refreshList.running = true }
                            }
                        }

                        ListView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            model: listFile.items
                            spacing: 2
                            delegate: Rectangle {
                                width: ListView.view ? ListView.view.width : 0
                                height: 22
                                color: "transparent"
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 4
                                    anchors.rightMargin: 4
                                    spacing: 4
                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData
                                        color: "#e2e8f0"
                                        elide: Text.ElideMiddle
                                        font.family: "JetBrainsMono Nerd Font Mono"
                                        font.pixelSize: 10
                                    }
                                    // Download (indigo, secondary)
                                    Rectangle {
                                        width: 22; height: 18; radius: 3
                                        property bool busy: deleteOne.running || fetchOne.running
                                        opacity: busy ? 0.35 : 1.0
                                        color: "transparent"
                                        border.color: "#818cf8"
                                        border.width: 1
                                        Behavior on opacity { NumberAnimation { duration: 150 } }
                                        Text {
                                            anchors.centerIn: parent
                                            text: "\uf019"
                                            color: "#818cf8"
                                            font.family: "JetBrainsMono Nerd Font Mono"
                                            font.pixelSize: 9
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: parent.busy ? Qt.ForbiddenCursor : Qt.PointingHandCursor
                                            enabled: !parent.busy
                                            onClicked: {
                                                fetchOne.source = modelData
                                                fetchOne.running = true
                                            }
                                        }
                                    }
                                    // Delete (red, destructive)
                                    Rectangle {
                                        width: 22; height: 18; radius: 3
                                        property bool busy: deleteOne.running || fetchOne.running
                                        opacity: busy ? 0.35 : 1.0
                                        color: "transparent"
                                        border.color: "#f87171"
                                        border.width: 1
                                        Behavior on opacity { NumberAnimation { duration: 150 } }
                                        Text {
                                            anchors.centerIn: parent
                                            text: "\uf1f8"
                                            color: "#f87171"
                                            font.family: "JetBrainsMono Nerd Font Mono"
                                            font.pixelSize: 9
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: parent.busy ? Qt.ForbiddenCursor : Qt.PointingHandCursor
                                            enabled: !parent.busy
                                            onClicked: {
                                                deleteOne.target = modelData
                                                deleteOne.running = true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

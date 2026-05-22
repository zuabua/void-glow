// VOID GLOW — SDDM login screen
// Palette mirrors ~/.config/theme/colors.sh
import QtQuick 2.15
import QtQuick.Controls 2.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#0d0d0f"               // VOID_BASE — the void

    Image {
        anchors.fill: parent
        source: "background.png"
        fillMode: Image.PreserveAspectCrop
        smooth: true
        asynchronous: true
    }

    // ── Clock (top-right, subtle) ───────────────────────
    Text {
        id: clock
        anchors { top: parent.top; right: parent.right; margins: 32 }
        color: "#64748b"           // VOID_SUBTEXT
        font.family: "JetBrainsMono Nerd Font Mono"
        font.pixelSize: 18
        text: Qt.formatDateTime(new Date(), "ddd dd MMM  HH:mm")
        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: clock.text = Qt.formatDateTime(new Date(), "ddd dd MMM  HH:mm")
        }
    }

    // ── Centered login card ─────────────────────────────
    Rectangle {
        anchors.centerIn: parent
        width: 380
        height: 240
        radius: 12
        color: "#131318"            // VOID_SURFACE — one layer up
        border.color: "#5eead4"     // VOID_ACCENT_TEAL — the glow edge
        border.width: 2

        Column {
            anchors.fill: parent
            anchors.margins: 28
            spacing: 18

            // Title
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "void glow"
                color: "#e2e8f0"        // VOID_TEXT
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 16
                font.bold: true
            }

            // Username label
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: userModel.lastUser !== "" ? userModel.lastUser : "user"
                color: "#5eead4"        // VOID_ACCENT_TEAL — your identity glows
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 13
            }

            // Password field
            Rectangle {
                width: parent.width
                height: 34
                radius: 6
                color: "#1c1c24"        // VOID_OVERLAY — inset depth
                border.color: passwordInput.activeFocus ? "#5eead4" : "#1c1c24"
                border.width: 1
                Behavior on border.color { ColorAnimation { duration: 150 } }

                TextInput {
                    id: passwordInput
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    verticalAlignment: TextInput.AlignVCenter
                    color: "#e2e8f0"
                    font.family: "JetBrainsMono Nerd Font Mono"
                    font.pixelSize: 13
                    echoMode: TextInput.Password
                    focus: true
                    passwordCharacter: "\u2022"
                    selectionColor: "#5eead4"
                    selectedTextColor: "#0d0d0f"
                    Keys.onReturnPressed: sddm.login(
                        userModel.lastUser !== "" ? userModel.lastUser : "",
                        passwordInput.text,
                        sessionModel.lastIndex
                    )
                    // Placeholder text when empty
                    Text {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        text: "password"
                        color: "#64748b"
                        font: parent.font
                        visible: !passwordInput.text && !passwordInput.activeFocus
                    }
                }
            }

            // Status / error line
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                id: statusText
                text: ""
                color: "#f87171"        // VOID_RED — semantic, errors only
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 10
            }
        }
    }

    // ── Power controls (bottom-right, recessive) ────────
    Row {
        anchors { bottom: parent.bottom; right: parent.right; margins: 32 }
        spacing: 14

        Text {
            text: "\uf186  sleep"          // moon glyph
            color: "#64748b"               // VOID_SUBTEXT — recede
            font.family: "JetBrainsMono Nerd Font Mono"
            font.pixelSize: 11
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: sddm.suspend()
            }
        }
        Text {
            text: "\uf021  reboot"
            color: "#64748b"
            font.family: "JetBrainsMono Nerd Font Mono"
            font.pixelSize: 11
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: sddm.reboot()
            }
        }
        Text {
            text: "\uf011  power off"
            color: "#f87171"               // VOID_RED — destructive
            font.family: "JetBrainsMono Nerd Font Mono"
            font.pixelSize: 11
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: sddm.powerOff()
            }
        }
    }

    // ── Wire SDDM signals to UI feedback ────────────────
    Connections {
        target: sddm
        function onLoginFailed() {
            statusText.text = "login failed"
            passwordInput.text = ""
            passwordInput.focus = true
        }
        function onLoginSucceeded() {
            statusText.text = ""
        }
    }
}

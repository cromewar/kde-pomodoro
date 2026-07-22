import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.SimpleKCM {
    id: page

    property alias cfg_focusMinutes: focusMinutes.value
    property alias cfg_shortBreakMinutes: shortBreakMinutes.value
    property alias cfg_longBreakMinutes: longBreakMinutes.value
    property alias cfg_sessionsUntilLongBreak: sessionsUntilLongBreak.value
    property alias cfg_focusDescription: focusDescription.text

    Kirigami.FormLayout {
        anchors.left: parent.left
        anchors.right: parent.right

        QQC2.TextField {
            id: focusDescription

            Kirigami.FormData.label: i18n("Current focus:")
            placeholderText: i18n("What are you focusing on?")
            maximumLength: 120
        }

        QQC2.SpinBox {
            id: focusMinutes

            Kirigami.FormData.label: i18n("Focus interval:")
            from: 1
            to: 180
            editable: true
        }

        QQC2.SpinBox {
            id: shortBreakMinutes

            Kirigami.FormData.label: i18n("Short break:")
            from: 1
            to: 180
            editable: true
        }

        QQC2.SpinBox {
            id: sessionsUntilLongBreak

            Kirigami.FormData.label: i18n("Focuses before long break:")
            from: 1
            to: 12
            editable: true
        }

        QQC2.SpinBox {
            id: longBreakMinutes

            Kirigami.FormData.label: i18n("Long break:")
            from: 1
            to: 180
            editable: true
        }

        QQC2.Label {
            Kirigami.FormData.isSection: true
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: i18n("The same settings are available directly in the widget popup. A running interval keeps its original deadline; changes apply when it is paused or restarted.")
            color: Kirigami.Theme.disabledTextColor
        }
    }
}

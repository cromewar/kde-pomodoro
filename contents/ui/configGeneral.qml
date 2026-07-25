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
    property alias cfg_autoStartBreaks: autoStartBreaks.checked
    property alias cfg_autoStartFocus: autoStartFocus.checked

    Kirigami.FormLayout {
        anchors.left: parent.left
        anchors.right: parent.right

        DurationEditor {
            id: focusMinutes

            Kirigami.FormData.label: i18n("Focus interval:")
        }

        DurationEditor {
            id: shortBreakMinutes

            Kirigami.FormData.label: i18n("Short break:")
        }

        QQC2.SpinBox {
            id: sessionsUntilLongBreak

            Kirigami.FormData.label: i18n("Focuses before long break:")
            from: 1
            to: 12
            editable: true
        }

        DurationEditor {
            id: longBreakMinutes

            Kirigami.FormData.label: i18n("Long break:")
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Behaviour")
        }

        QQC2.CheckBox {
            id: autoStartBreaks

            Kirigami.FormData.label: i18n("Auto-start:")
            text: i18n("Start breaks automatically")
        }

        QQC2.CheckBox {
            id: autoStartFocus

            text: i18n("Start focus intervals automatically")
        }

        QQC2.Label {
            Kirigami.FormData.isSection: true
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: i18n("Timer durations are configured here. A running interval keeps its original deadline; changes apply when it is paused or restarted.")
            color: Kirigami.Theme.disabledTextColor
        }
    }
}

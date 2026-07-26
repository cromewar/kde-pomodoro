import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

RowLayout {
    id: editor

    property alias value: spinBox.value
    property alias from: spinBox.from
    property alias to: spinBox.to
    // Set to "" for a row that counts something other than minutes. The suffix
    // column keeps its width either way, so a suffix-less row still lines its
    // spin box up with the duration rows above and below it instead of sliding
    // right by the width of "min".
    property string suffix: i18nc("Abbreviation for minutes", "min")

    signal valueEdited(int value)

    spacing: Kirigami.Units.smallSpacing

    QQC2.SpinBox {
        id: spinBox

        from: 1
        to: 180
        editable: true
        onValueModified: editor.valueEdited(value)
    }

    QQC2.Label {
        text: editor.suffix
        color: Kirigami.Theme.disabledTextColor
        Layout.preferredWidth: suffixWidth.width

        TextMetrics {
            id: suffixWidth

            font: parent.font
            text: i18nc("Abbreviation for minutes", "min")
        }
    }
}

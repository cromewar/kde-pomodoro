import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

RowLayout {
    id: editor

    property alias value: spinBox.value
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
        text: i18nc("Abbreviation for minutes", "min")
        color: Kirigami.Theme.disabledTextColor
    }
}

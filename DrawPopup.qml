import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

BottomPopup {
    property Item slider_axes: slider_axes
    property alias isSymmetry: switch_symmetry.checked

    ColumnLayout {
        width: parent.width
        x: 0
        y: parent.height - height


        RowLayout {
            width: parent.width

            Label {
                text: qsTr("symmetry: ") + switch_symmetry.checked
                Layout.alignment: Qt.AlignCenter
            }

            Switch {
                id: switch_symmetry
                Layout.alignment: Qt.AlignCenter
            }
        }

        Label {
            text: qsTr("number of axes: ") + slider_axes.value
        }

        SliderBtn
        {
            id:slider_axes
            from: 1
            to: 256
            stepSize: 1
            value: 3
        }
    }
}

import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12


BottomPopup {

    property alias hexColor: colorpicker.hexColor
    property alias slider_aColor: colorpicker.a_slider
    property alias slider_hColor: colorpicker.h_slider
    property alias slider_sColor: colorpicker.s_slider
    property alias slider_lColor: colorpicker.l_slider


    ColumnLayout {
        width: parent.width
        x: 0
        y: parent.height - height
        Label {
            text: qsTr("color")
        }

        CustomColorPicker {
            id: colorpicker
        }
    }
}

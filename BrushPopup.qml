import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

BottomPopup {
    property Item slider: brush_size_slider

    ColumnLayout {
        width: parent.width
        x: 0
        y: parent.height - height
        Label {
            text: qsTr("brush size: ") + brush_size_slider.value
        }
        SliderBtn
        {
            id:brush_size_slider
            from: 1
            to: 100
            stepSize: 1
            value: 1
        }
    }
}

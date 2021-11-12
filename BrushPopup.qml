import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

BottomPopup {
    property Item slider: slider_brush_size

    ColumnLayout {
        width: parent.width
        x: 0
        y: parent.height - height
        Label {
            text: qsTr("brush size") + ": " + slider_brush_size.value
        }
        SliderBtn
        {
            id:slider_brush_size
            from: 1
            to: 100
            stepSize: 1
            value: 1
            doubleclickValue: 1
        }
    }
}

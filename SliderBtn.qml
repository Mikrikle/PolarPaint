import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

RowLayout {

    property alias from: slider.from
    property alias to: slider.to
    property alias stepSize: slider.stepSize
    property alias value: slider.value
    property alias background: slider.background

    width: parent.width
    RoundButton{
        icon.source: "qrc:/images/arrow_left"
        onClicked: {
            slider.decrease();
        }
    }
    Slider{
        id: slider
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
    }
    RoundButton{
        icon.source: "qrc:/images/arrow_right"
        onClicked: {
            slider.increase();
        }
    }
}

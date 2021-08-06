import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Popup {
    id: popup
    property var cvs: null

    parent: Overlay.overlay
    focus: true
    width: parent.width - 10;

    x: Math.round((parent.width - width) / 2)
    y: parent.height - height - bottomMenu.height

    function updateColor()
    {

        function hslToHex(h, s, l) {
            l /= 100;
            const a = s * Math.min(l, 1 - l) / 100;
            const f = n => {
                const k = (n + h / 30) % 12;
                const color = l - a * Math.max(Math.min(k - 3, 9 - k, 1), -1);
                return Math.round(255 * color).toString(16).padStart(2, '0');
            };
            return `#${f(0)}${f(8)}${f(4)}`;
        }

        cvs.brushColor = hslToHex(h_slider.value, s_slider.value, l_slider.value);
    }

    ColumnLayout {
        width: parent.width
        x: 0
        y: parent.height - height
        Label {
            text: qsTr("color")
        }
        RowLayout {
            width: parent.width
            Item {
                Label {
                    anchors.centerIn: parent
                    text: "h"
                }
                width: 10
            }


            RoundButton{
                //text: "<-"
                icon.source: "qrc:/images/arrow-back.png"
                onClicked: {
                    h_slider.decrease();
                    updateColor();
                }
            }
            Slider{
                id: h_slider
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                onMoved: {
                    updateColor();
                }
                from: 0
                value: 100
                stepSize: 1
                to: 360
            }
            RoundButton{
                //text: "->"
                icon.source: "qrc:/images/arrow-forward.png"
                onClicked: {
                    h_slider.increase();
                    updateColor();
                }
            }

        }
        RowLayout {
            width: parent.width
            Item {
                Label {
                    anchors.centerIn: parent
                    text: "s"
                }
                width: 10
            }
            RoundButton{
                //text: "<-"
                icon.source: "qrc:/images/arrow-back.png"
                onClicked: {
                    s_slider.decrease();
                    updateColor();
                }
            }
            Slider{
                id: s_slider
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                onMoved: {
                    updateColor();
                }
                from: 0
                value: 100
                stepSize: 1
                to: 100
            }
            RoundButton{
                //text: "->"
                icon.source: "qrc:/images/arrow-forward.png"
                onClicked: {
                    s_slider.increase();
                    updateColor();
                }
            }
        }
        RowLayout {
            width: parent.width
            Item {
                Label {
                    anchors.centerIn: parent
                    text: "l"
                }
                width: 10
            }
            RoundButton{
                //text: "<-"
                icon.source: "qrc:/images/arrow-back.png"
                onClicked: {
                    l_slider.decrease();
                    updateColor();
                }
            }
            Slider{
                id: l_slider
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                onMoved: {
                    updateColor();
                }
                from: 0
                value: 50
                stepSize: 1
                to: 100
            }
            RoundButton{
                //text: "->"
                icon.source: "qrc:/images/arrow-forward.png"
                onClicked: {
                    l_slider.increase();
                    updateColor();
                }
            }

        }
    }

    background: Rectangle {
        color:"transparent"
        Rectangle {
            width: 1
            anchors.fill: parent
            radius: 10
            color: "#414141"
        }

    }

}

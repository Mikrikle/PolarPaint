import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12


BottomPopup {
    property string hexColor: "#" + a_slider.value.toString(16) + hslToHex(h_slider.value, s_slider.value, l_slider.value);

    property Item slider_aColor: a_slider
    property Item slider_hColor: h_slider
    property Item slider_sColor: s_slider
    property Item slider_lColor: l_slider

    function hslToHex(h, s, l) {
        l /= 100;
        const a = s * Math.min(l, 1 - l) / 100;
        const f = n => {
            const k = (n + h / 30) % 12;
            const color = l - a * Math.max(Math.min(k - 3, 9 - k, 1), -1);
            return Math.round(255 * color).toString(16).padStart(2, '0');
        };
        return `${f(0)}${f(8)}${f(4)}`;
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

            Label {
                text: "a"
                Layout.alignment: Qt.AlignCenter
            }


            SliderBtn
            {
                id:a_slider
                from: 17
                to: 255
                stepSize: 1
                value: 255
            }

        }


        RowLayout {
            width: parent.width

            Label {
                text: "h"
                Layout.alignment: Qt.AlignCenter
            }

            SliderBtn
            {
                id:h_slider
                from: 0
                to: 360
                stepSize: 1
                value: 100
            }

        }
        RowLayout {
            width: parent.width

            Label {
                text: "s"
                Layout.alignment: Qt.AlignCenter
            }

            SliderBtn
            {
                id:s_slider
                from: 0
                to: 100
                stepSize: 1
                value: 100
            }

        }
        RowLayout {
            width: parent.width

            Label {
                text: "l"
                Layout.alignment: Qt.AlignCenter
            }

            SliderBtn
            {
                id:l_slider
                from: 0
                to: 100
                stepSize: 1
                value: 50
            }

        }
    }
}

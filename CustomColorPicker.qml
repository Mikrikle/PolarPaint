import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

ColumnLayout {
    property string hexColor: "#" + a_slider.value.toString(16) + hslToHex(h_slider.value, s_slider.value, l_slider.value);

    property Item a_slider: a_slider
    property Item h_slider: h_slider
    property Item s_slider: s_slider
    property Item l_slider: l_slider

    property var defaultValues: {'a':255, 'h':100,'s':0, 'l':0}

    width: parent.width

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
            value: defaultValues.a

            background: Rectangle{
                width: parent.height * 0.4
                height: parent.width
                anchors.centerIn: parent
                rotation: 270
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#17" + hslToHex(h_slider.value, s_slider.value, l_slider.value) }
                    GradientStop { position: 1.0; color: hexColor }
                }
                radius: 8
            }

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
            value: defaultValues.h


            background: Rectangle{
                width: parent.height * 0.4
                height: parent.width
                anchors.centerIn: parent
                rotation: 270
                gradient: Gradient {
                    GradientStop {
                        position: 0.000
                        color: "#" + hslToHex(0, s_slider.value, l_slider.value)
                    }
                    GradientStop {
                        position: 0.167
                        color: "#" + hslToHex(360 * 0.167, s_slider.value, l_slider.value)
                    }
                    GradientStop {
                        position: 0.333
                        color: "#" + hslToHex(360 * 0.333, s_slider.value, l_slider.value)
                    }
                    GradientStop {
                        position: 0.500
                        color: "#" + hslToHex(360 * 0.500, s_slider.value, l_slider.value)
                    }
                    GradientStop {
                        position: 0.667
                        color: "#" + hslToHex(360 * 0.667, s_slider.value, l_slider.value)
                    }
                    GradientStop {
                        position: 0.833
                        color: "#" + hslToHex(360 * 0.833, s_slider.value, l_slider.value)
                    }
                    GradientStop {
                        position: 1.000
                        color: "#" + hslToHex(360, s_slider.value, l_slider.value)
                    }
                }
                radius: 8
            }
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
            value: defaultValues.s

            background: Rectangle{
                width: parent.height * 0.4
                height: parent.width
                anchors.centerIn: parent
                rotation: 270
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#" + hslToHex(h_slider.value, 0, l_slider.value) }
                    GradientStop { position: 1.0; color: "#" + hslToHex(h_slider.value, 100, l_slider.value) }
                }
                radius: 8
            }
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
            value: defaultValues.l

            background: Rectangle{
                width: parent.height * 0.4
                height: parent.width
                anchors.centerIn: parent
                rotation: 270
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#" + hslToHex(h_slider.value, s_slider.value, 0) }
                    GradientStop { position: 0.5; color: "#" + hslToHex(h_slider.value, s_slider.value, 50) }
                    GradientStop { position: 1.0; color: "#" + hslToHex(h_slider.value, s_slider.value, 100) }
                }
                radius: 8
            }

        }

    }
}


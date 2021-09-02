import QtQuick 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.12
import Qt.labs.platform 1.1

import com.cpp.JsonSettings 1.0

Window {
    id: main_window
    visible: true
    minimumWidth: 300
    width: 400
    minimumHeight: 300
    height: 600
    title: qsTr("paint")

    Material.theme: Material.Dark
    Material.accent: Material.Green

    /*---------SAVE AND RESTORE APP STATE----------*/
    JsonSettings
    {
        id: settings

        function getStrSettings() // create json with all items states
        {
            let data = {
                slider_brushSize: popup_brush.slider.value,
                property_isSymmetry: popup_draw.isSymmetry,
                slider_nAxes: popup_draw.slider_axes.value,
                slider_aColor: popup_color.slider_aColor.value,
                slider_hColor: popup_color.slider_hColor.value,
                slider_sColor: popup_color.slider_sColor.value,
                slider_lColor: popup_color.slider_lColor.value,
                slider_BgAColor: bgColorPicker.a_slider.value,
                slider_BgHColor: bgColorPicker.h_slider.value,
                slider_BgSColor: bgColorPicker.s_slider.value,
                slider_BgLColor: bgColorPicker.l_slider.value,

            }
            return JSON.stringify(data);
        }

        Component.onCompleted: {
            let json = JSON.parse(settings.load("/settings.json"));
            popup_brush.slider.value = json.slider_brushSize;
            popup_draw.isSymmetry = json.property_isSymmetry;
            popup_draw.slider_axes.value = json.slider_nAxes;
            popup_color.slider_aColor.value = json.slider_aColor;
            popup_color.slider_hColor.value = json.slider_hColor;
            popup_color.slider_sColor.value = json.slider_sColor;
            popup_color.slider_lColor.value = json.slider_lColor;
            bgColorPicker.a_slider.value = json.slider_BgAColor;
            bgColorPicker.h_slider.value = json.slider_BgHColor;
            bgColorPicker.s_slider.value = json.slider_BgSColor;
            bgColorPicker.l_slider.value = json.slider_BgLColor;
        }

        Component.onDestruction: {
            settings.save(getStrSettings());
        }

    }

    /*---------ANIMATIONS OF EXPAND AND REDUCE----------*/
    Item {
        id: anim_interface_state_switcher
        states: [
            State{
                name: "state_normal_interface"
                PropertyChanges{
                    target: menu_top
                    y: 0
                }
                PropertyChanges{
                    target: menu_bottom;
                    y: parent.height - menu_bottom.height
                }
                PropertyChanges{
                    target: btn_interface_states_switcher
                    rotation: 0
                }
                PropertyChanges{
                    target: menu_right
                    scale: 1
                }
            },

            State{
                name: "state_minimal_interface"
                PropertyChanges{
                    target: menu_top
                    y: -menu_top.height
                }
                PropertyChanges{
                    target: menu_bottom
                    y: parent.height

                }
                PropertyChanges{
                    target: btn_interface_states_switcher
                    rotation: 180
                }
                PropertyChanges{
                    target: menu_right
                    scale: 0.8
                }
            }
        ]


        transitions: [
            Transition {
                from: "*"
                to: "*"
                PropertyAnimation {
                    targets: [menu_top, menu_bottom]
                    properties: "y"
                    easing.type: Easing.OutBack
                    duration: 500
                }

            }
        ]

    }


    /*---------MAIN CANVAS WITH BACKGROUND----------*/
    Item {
        anchors.fill: parent
        Rectangle {
            id: background
            anchors.fill: canvas
            color: canvas.bgColor
        }

        PolarCanvas {
            id: canvas
            anchors.fill: parent
            brushSize: popup_brush.slider.value
            brushColor: popup_color.hexColor
            symmetry: popup_draw.isSymmetry
            axes: popup_draw.slider_axes.value
            bgColor: bgColorPicker.hexColor
            pixelRatio: Screen.devicePixelRatio
            isSaveWithBg: popup_menu.isSaveWithBg;
            isDrawCenterPoint: popup_menu.isDrawCenterPoint
        }
    }


    /*---------TOP TOOLBAR (tools) ----------*/
    RowLayout {
        id: menu_top
        width: parent.width > 600 ? 600 : parent.width
        x: parent.width / 2 - this.width / 2
        y: 0
        Item { width: 10 }

        DelayButton {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Material.accent: "#FF0000"
            icon.width: 10
            icon.height: 10
            delay: 200
            onActivated:
            {
                checked = false;
                progress = 0;
                canvas.clear();
            }

            Image {
                anchors.centerIn: parent
                height: 24
                width: 24
                source: "qrc:/images/delete"
            }

        }

        Item { width: 10 }

        Button {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            icon.source: "qrc:/images/undo"
            onClicked: {
                canvas.undo();
            }
        }
        Button {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            icon.source: "qrc:/images/redo"
            onClicked: {
                canvas.redo();
            }
        }

        Item { width: 10 }

        Button {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            icon.source: "qrc:/images/menu"
            onClicked: popup_menu.open()
            MenuPopup {
                id: popup_menu
                canvas: canvas

                Popup {
                    id: popup_bgColor
                    width: parent.width - 10;
                    x: Math.round((parent.width - width) / 2)
                    y: parent.height - height - menu_bottom.height
                    focus: true
                    CustomColorPicker {
                        id: bgColorPicker
                        isUseAlpha: false;
                    }
                }
            }
        }

        Item { width: 10 }
    }


    /*---------BOTTOM TOOLBAR (setting up drawing) ----------*/
    RowLayout {
        id: menu_bottom
        width: parent.width > 600 ? 600 : parent.width
        x: parent.width / 2 - this.width / 2
        y: parent.height - height
        Item { width: 10 }

        Button {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            icon.source: "qrc:/images/tune"
            onClicked: {
                settings.save(settings.getStrSettings());
                popup_draw.visible = !popup_draw.visible
            }
            DrawPopup {
                id: popup_draw
            }
        }

        Button {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            icon.source: "qrc:/images/brush"
            onClicked: {
                settings.save(settings.getStrSettings());
                popup_brush.visible = !popup_brush.visible
            }
            BrushPopup {
                id: popup_brush
            }
        }

        Button {
            id: btn_color_indicator
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignHCenter
            onClicked: {
                settings.save(settings.getStrSettings());
                popup_color.visible = !popup_color.visible
            }
            ColorPopup {
                id: popup_color
            }
            background: Rectangle {
                implicitWidth: 50
                Rectangle{
                    anchors.fill: parent
                    Repeater {
                        model: [[0, 0,"#808080"], [parent.width/3, 0, "#C8C8C8"], [parent.width/3 * 2, 0, "#808080"],
                            [0, parent.height/2, "#C8C8C8"], [parent.width/3, parent.height/2, "#808080"], [parent.width/3 * 2, parent.height/2, "#C8C8C8"]
                        ]
                        Rectangle {
                            x: modelData[0]
                            y: modelData[1]
                            width: parent.width/3
                            height: parent.height/2
                            color: modelData[2]
                        }
                    }
                }
                Rectangle{
                    anchors.fill: parent
                    color: canvas.brushColor
                    opacity: btn_color_indicator.down ? 0.5 : 1.0
                    border.color: "#" + canvas.brushColor.slice(3)
                    border.width: 3
                }
            }
        }

        Item { width: 10 }
    }


    /*---------RIGHT TOOLBAR (setting position and scale)----------*/
    ColumnLayout
    {
        id: menu_right
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        RoundButton {
            scale: 0.75
            icon.source: "qrc:/images/resize"
            onClicked: {
                canvas.scalingFactor = 1.0;
                canvas.moveCenter();
                canvas.moveMod = false;
                canvas.update();
                timer_increase_scale.stop();
                timer_decrease_scale.stop();
            }
        }

        Label{
            Layout.alignment: Qt.AlignCenter
            text: Math.round(canvas.scalingFactor * 100) + "%"
        }

        RoundButton {
            id: btn_increase_scale
            scale: 0.75
            icon.source: "qrc:/images/plus"
            onPressed: {
                timer_decrease_scale.start();
            }
            onReleased: {
                timer_decrease_scale.stop();
            }
            onClicked: {
                if(canvas.scalingFactor <= 9.9)
                    canvas.changeScaleWithCentering(0.1);
                canvas.update();
            }
        }

        Timer {
            id: timer_decrease_scale
            repeat: true
            interval: 10
            onTriggered: {
                if(canvas.scalingFactor <= 9.95 && btn_increase_scale.down)
                    canvas.changeScaleWithCentering(0.01);
                else
                    timer_decrease_scale.stop();
                canvas.update();
            }
        }

        RoundButton {
            id: btn_decrease_scale
            scale: 0.75
            icon.source: "qrc:/images/minus"
            onPressed: {
                timer_increase_scale.start();
            }
            onReleased: {
                timer_increase_scale.stop();
            }
            onClicked: {
                if(canvas.scalingFactor > 0.1)
                    canvas.changeScaleWithCentering(-0.1);
                canvas.update();
            }
        }

        Timer {
            id: timer_increase_scale
            repeat: true
            interval: 10
            onTriggered: {
                if(canvas.scalingFactor > 0.05 && btn_decrease_scale.down)
                   canvas.changeScaleWithCentering(-0.01);
                else
                    timer_increase_scale.stop();
                canvas.update();
            }
        }

        RoundButton {
            scale: 0.75
            icon.source: "qrc:/images/move"
            highlighted: canvas.moveMod
            onClicked: {
                canvas.moveMod = !canvas.moveMod;
                timer_increase_scale.stop();
                timer_decrease_scale.stop();
            }
        }
    }

    /*---------EXPAND/REDUCE TOOLBARS----------*/
    RoundButton {
        anchors.bottom: menu_bottom.top
        anchors.right: parent.right
        id: btn_interface_states_switcher
        icon.source: "qrc:/images/expand"

        onClicked: {
            anim_interface_state_switcher.state = (anim_interface_state_switcher.state.toString() === "state_normal_interface") ? "state_minimal_interface":"state_normal_interface";
        }
    }
}



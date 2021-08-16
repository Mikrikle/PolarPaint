import QtQuick 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.12
import Qt.labs.platform 1.1


Window {
    id: main_window
    visible: true
    minimumWidth: 400
    minimumHeight: 600
    title: qsTr("paint")

    Material.theme: Material.Dark
    Material.accent: Material.Green

    Item {
        anchors.fill: parent
        Rectangle {
            id: background_rect
            anchors.fill: canvas

            Canvas {
                id: background
                anchors.fill: parent

                onPaint: {
                    let ctx = getContext("2d");
                    ctx.fillStyle = "#202020";
                    ctx.fillRect(0, 0, width, height);
                }
            }
        }

        PolarCanvas {
            id: canvas
            anchors.fill: parent
            brushSize: popup_brush.slider.value
            brushColor: popup_color.hexColor
            symmetry: popup_draw.isSymmetry
            axes: popup_draw.axes_slider.value
        }
    }

    Item {
        id: anim_menu
        states: [
            State{
                name: "state_active"
                PropertyChanges{
                    target: topMenu
                    y: 0

                }
                PropertyChanges{
                    target: bottomMenu;
                    y: parent.height - bottomMenu.height
                }
                PropertyChanges{
                    target: menuSwitch
                    rotation: 0
                }
            },

            State{
                name: "state_disabled"
                PropertyChanges{
                    target: topMenu
                    y: -topMenu.height
                }
                PropertyChanges{
                    target: bottomMenu
                    y: parent.height

                }
                PropertyChanges{
                    target: menuSwitch
                    rotation: 180
                }
            }
        ]


        transitions: [
            Transition {
                from: "*"
                to: "*"
                PropertyAnimation {
                    targets: [topMenu, bottomMenu]
                    properties: "y"
                    easing.type: Easing.OutBack
                    duration: 500
                }

            }
        ]

    }

    RowLayout {
        id: topMenu
        width: parent.width
        x: 0
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
            }
        }

        Item { width: 10 }
    }

    RowLayout {
        id: bottomMenu
        width: parent.width
        x: 0
        y: parent.height - height
        Item { width: 10 }

        Button {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            icon.source: "qrc:/images/tune"
            onClicked: {
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


    RoundButton {
        anchors.bottom: bottomMenu.top
        anchors.right: parent.right
        id: menuSwitch
        icon.source: "qrc:/images/expand"

        onClicked: {
            anim_menu.state = (anim_menu.state.toString() === "state_active") ? "state_disabled":"state_active";
        }
    }
}



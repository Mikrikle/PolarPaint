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

    PolarCanvas {
        id: polarcanvas
        property Item canvas : cvs
        anchors.fill: parent
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
            text: "X"
            delay: 400
            onActivated:
            {
                checked = false;
                progress = 0;
                polarcanvas.canvas.clear();
            }
        }

        Item { width: 10 }

        Button {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            text: "<-"
            onClicked: {
                polarcanvas.canvas.undo();
            }
        }
        Button {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            text: "->"
            onClicked: {
                polarcanvas.canvas.redo();
            }
        }

        Item { width: 10 }

        Button {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            text: "Menu"
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
            text: "Draw"
            onClicked: {
                popup_draw.visible = !popup_draw.visible
            }
            DrawPopup {
                id: popup_draw
                cvs: polarcanvas.canvas
            }
        }

        Button {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            text: "Brush"
            onClicked: {
                popup_brush.visible = !popup_brush.visible
            }
            BrushPopup {
                id: popup_brush
                cvs: polarcanvas.canvas
            }
        }

        Button {
            id: btn_color_indicator
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            highlighted: true
            Material.accent: polarcanvas.canvas.brushColor
            onClicked: {
                popup_color.visible = !popup_color.visible
            }
            ColorPopup {
                id: popup_color
                cvs: polarcanvas.canvas
            }
        }

        Item { width: 10 }
    }


    RoundButton {
        anchors.bottom: bottomMenu.top
        anchors.right: parent.right
        id: menuSwitch
        text: "<->"

        onClicked: {
            anim_menu.state = (anim_menu.state.toString() === "state_active") ? "state_disabled":"state_active";
        }
    }
}



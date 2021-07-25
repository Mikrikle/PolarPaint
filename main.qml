import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Window {
    visible: true
    minimumWidth: 400
    minimumHeight: 400
    title: qsTr("paint")

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
        Item { width: 25 }
        Button {
            text: "<-"
            onClicked: {
                polarcanvas.canvas.undo();
            }
        }
        Button {
            text: "->"
        }
        Button {
            text: "X"
            onClicked:
            {
                polarcanvas.canvas.clear();
            }
        }

        Item { width: 25 }
    }

    RowLayout {
        id: bottomMenu
        width: parent.width
        x: 0
        y: parent.height - height
        Item { width: 25 }
        Button {
            text: "Ok"
        }
        Button {
            text: "Cancel"
        }
        Item { width: 25 }
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



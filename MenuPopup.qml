import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Popup {
    id: popup
    property Item canvas: null
    property alias isSaveWithBg: switch_is_save_with_bg.checked
    property alias isDrawCenterPoint: switch_is_draw_center.checked

    parent: Overlay.overlay
    closePolicy: Popup.NoAutoClose
    modal: true
    focus: true
    width: parent.width > 600 ? 500 : (parent.width>400?parent.width-100:parent.width-10)
    height: parent.height - 100;
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)

    scale: 0

    function hide() {
        close();
        scale = 0.00;
        opacity = 0.00;
    }

    function show() {
        scale = 1.00;
        opacity = 0.9;
    }

    onOpened: {
        show();
    }

    Behavior on scale {
        NumberAnimation {
            duration: 200
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 200
        }
    }

    Dialog {
        id: dialog_save
        modal: true
        standardButtons: Dialog.Ok
    }

    Popup {
        width: parent.width - 10;
        x: Math.round((parent.width - width) / 2)
        y: parent.height - height - menu_bottom.height
        id: popup_setBg
        focus: true
        CustomColorPicker {
            id: bgColorPicker
        }
    }

    SwipeView {
        id: view

        clip: true
        currentIndex: 1
        anchors.fill: parent

        Item {
            id: firstPage
            ColumnLayout {
                width: parent.width
                Label{
                    Layout.alignment: Qt.AlignCenter
                    text: qsTr("screen size: ")
                          + Math.round(main_window.width * Screen.devicePixelRatio)
                          + "x"
                          + Math.round(main_window.height * Screen.devicePixelRatio)
                }
                SliderBtn{
                    id: slider_size
                    implicitWidth: firstPage.width - 110
                    Layout.alignment: Qt.AlignCenter
                    from: 100
                    to: 8000
                    stepSize: 100
                    value: 2000
                    onValueChanged: {
                        if(canvas)
                            canvas.setCvsSize(this.value);
                    }
                }
                Label{
                    Layout.alignment: Qt.AlignCenter
                    text: qsTr("canvas size: ") + slider_size.value + "x" + slider_size.value
                }

                Switch {
                    id: switch_is_draw_center
                    text: qsTr("draw point at center")
                    checked: true
                    onCheckedChanged: {
                        canvas.update();
                    }
                }
            }
        }

        Item {
            id: secondPage

            ColumnLayout {
                width: parent.width

                Button {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    icon.source: "qrc:/images/close"

                    onClicked: {
                        popup.hide();
                    }
                }

                Row {
                    Button {
                        text: qsTr("save")
                        onClicked: {
                            item_wait.visible = true;
                            timer_save.start();
                        }
                    }
                    Switch {
                        id: switch_is_save_with_bg
                        text: qsTr("background")
                        checked: true
                    }
                }
                Button {
                    text: qsTr("Backround color")
                    onClicked: {
                        popup.close();
                        popup_bgColor.open();
                    }
                }
            }
        }
        Item {
            id: thirdPage
            ColumnLayout {
                Text  {
                    color: "#FFFFFF"
                    textFormat: Text.RichText
                    text: "<h1>About</h1>"
                }
            }
        }
    }

    PageIndicator {
        id: indicator

        count: view.count
        currentIndex: view.currentIndex

        anchors.top: view.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Timer{
        id: timer_save
        interval: 16
        running: false
        repeat: false
        onTriggered: {
            if(canvas.save())
            {
                dialog_save.title = "Successfully saved";
            }
            else
            {
                dialog_save.title = "Error: unable to save";
            }
            dialog_save.open();
            item_wait.visible = false;
        }
    }

    Item {
        id: item_wait
        visible: false
        anchors.centerIn: parent

        Rectangle{
            anchors.centerIn: parent
            width: 100
            height: 100
            color: "#000000"
            radius: 20
        }

        Image {
            anchors.centerIn: parent
            height: 24
            width: 24
            source: "qrc:/images/wait"
        }

    }

}

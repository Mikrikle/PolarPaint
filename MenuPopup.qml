import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Popup {
    id: popup
    property Item canvas: null
    property alias isSaveWithBg: switch_is_save_with_bg.checked
    property alias isDrawAxes: switch_is_draw_axes.checked
    property alias slider_axesOpacity: slider_axesOpacity
    property alias slider_cvsSize: slider_cvsSize

    parent: Overlay.overlay
    closePolicy: Popup.NoAutoClose
    modal: true
    focus: true
    width: parent.width > 600 ? 500 : (parent.width>400?parent.width-100:parent.width-10)
    height: parent.height - 100;
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)

    scale: 0

    background: Rectangle {
        color:"transparent"
        Rectangle {
            width: 1
            anchors.fill: parent
            radius: 10
            color: Material.background
        }
    }

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
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        standardButtons: Dialog.Ok
    }

    Popup {
        id: popup_setBg
        width: parent.width - 10;
        x: Math.round((parent.width - width) / 2)
        y: parent.height - height - menu_bottom.height
        focus: true
        CustomColorPicker {
            id: bgColorPicker
        }
    }

    SwipeView {
        id: view

        clip: true
        interactive: false
        currentIndex: 1
        anchors.fill: parent

        ScrollView {
            id: firstPage
            clip: true
            Flickable {
                anchors.left: parent.left
                contentWidth: parent.width - 25; contentHeight: infmenuCol.height + 100
                boundsBehavior: Flickable.StopAtBounds

                ColumnLayout {
                    id: infmenuCol
                    width: parent.width

                    RowLayout{
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter

                        Button {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter
                            icon.source: "qrc:/images/arrow_right"
                            onClicked: {
                                view.currentIndex  = 1;
                            }
                        }
                    }
                    Text  {
                        color: "#FFFFFF"
                        textFormat: Text.RichText
                        text: "<h1>About</h1>"
                    }
                }

                ScrollBar.vertical: ScrollBar {
                    id: vbar2
                    active: true
                    policy: ScrollBar.AlwaysOn
                }
            }
        }


        ScrollView {
            id: secondPage
            clip: true
            Flickable {
                anchors.left: parent.left
                contentWidth: parent.width - 25; contentHeight: lmenuCol.height + 100
                boundsBehavior: Flickable.StopAtBounds
                ColumnLayout {
                    id: lmenuCol
                    width: parent.width
                    spacing: 10
                    RowLayout{
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter

                        Button {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter
                            icon.source: "qrc:/images/arrow_left"

                            onClicked: {
                                view.currentIndex  = 0;
                            }
                        }

                        Button {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter
                            icon.source: "qrc:/images/close"

                            onClicked: {
                                popup.hide();
                            }
                        }
                    }

                    Pane {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        Material.elevation: 6
                        ColumnLayout{
                            anchors.fill: parent
                            Switch {
                                id: switch_is_draw_axes
                                text: qsTr("Show axes")
                                checked: true
                            }

                            Label{
                                Layout.alignment: Qt.AlignCenter
                                text: qsTr("Axes opacity") + ": " + (Math.round(slider_axesOpacity.value / 255 * 100)) + "%"
                            }
                            SliderBtn{
                                id: slider_axesOpacity
                                implicitWidth: firstPage.width - 110
                                Layout.alignment: Qt.AlignCenter
                                from: 17
                                to: 255
                                stepSize: 1
                                value: 64
                                doubleclickValue: 64
                            }
                        }
                    }

                    Pane {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        Material.elevation: 6
                        ColumnLayout{
                            anchors.fill: parent
                            Button {
                                text: qsTr("Save")
                                onClicked: {
                                    item_wait.visible = true;
                                    timer_save.start();
                                }
                            }
                        }
                    }

                    Pane {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        Material.elevation: 6
                        ColumnLayout{
                            anchors.fill: parent
                            Switch {
                                id: switch_is_save_with_bg
                                text: qsTr("Save with background")
                                checked: true
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

                    Pane {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        Material.elevation: 6
                        ColumnLayout{
                            anchors.fill: parent
                            Label{
                                Layout.alignment: Qt.AlignCenter
                                text: qsTr("Screen size") + ": "
                                      + Math.round(main_window.width * Screen.devicePixelRatio)
                                      + "x"
                                      + Math.round(main_window.height * Screen.devicePixelRatio)
                            }
                            SliderBtn{
                                id: slider_cvsSize
                                implicitWidth: firstPage.width - 110
                                Layout.alignment: Qt.AlignCenter
                                from: 100
                                to: 8000
                                stepSize: 100
                                value: 2000
                                doubleclickValue: 2000
                            }
                            Label{
                                Layout.alignment: Qt.AlignCenter
                                text: qsTr("Canvas size") + ": " + slider_cvsSize.value + "x" + slider_cvsSize.value
                            }
                        }
                    }
                }

                ScrollBar.vertical: ScrollBar {
                    id: vbar
                    active: true
                    policy: ScrollBar.AlwaysOn
                }

                focus: true
            }
        }
    }

    PageIndicator {
        id: indicator

        count: view.count
        currentIndex: view.currentIndex

        anchors.bottom: view.bottom
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
                dialog_save.title = qsTr("Successfully saved");
            }
            else
            {
                dialog_save.title = qsTr("Error: unable to save");
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

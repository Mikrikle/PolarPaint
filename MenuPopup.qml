import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Popup {

    id: popup
    property var cvs: null

    parent: Overlay.overlay
    closePolicy: Popup.NoAutoClose
    modal: true
    focus: true
    width: parent.width - 100;
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

    SwipeView {
        id: view

        clip: true
        currentIndex: 1
        anchors.fill: parent

        Item {
            id: firstPage
            ColumnLayout {
                Button{}
                Button{}
                Button{}
            }
        }
        Item {
            id: secondPage
            ColumnLayout {
                Button{}
                Button{}
                Button{}
            }
        }
        Item {
            id: thirdPage
            ColumnLayout {
                Button{}
                Button{}
                Button{}
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

    RoundButton {
        anchors.right: parent.right
        text: "X"

        onClicked: {
            popup.hide();
        }
    }

}

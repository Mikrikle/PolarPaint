import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

ApplicationWindow {
    visible: true
    width: 800
    height: 800
    title: qsTr("paint")

    Canvas {
        id: canvas
        anchors.fill: parent

        property int lastX: 0
        property int lastY: 0

        function clear()
        {
            let ctx = getContext("2d");
            ctx.reset();
            canvas.requestPaint();
        }

        MouseArea {
            id: area
            anchors.fill: parent

            onPressed: {
                canvas.lastX = mouseX;
                canvas.lastY = mouseY;
            }

            onPositionChanged: {
                canvas.requestPaint();
            }
        }

        onPaint: {
            let ctx = getContext("2d");
            ctx.lineCap = "round";
            ctx.lineWidth = 1;
            ctx.beginPath();
            ctx.moveTo(lastX, lastY);
            lastX = area.mouseX;
            lastY = area.mouseY;
            ctx.lineTo(lastX, lastY);
            ctx.stroke();
        }
    }

}



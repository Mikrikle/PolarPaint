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
        renderStrategy: Canvas.Threaded
        renderTarget: Canvas.FramebufferObject

        property bool symmetry: true
        property int axes: 8
        property int brushSize: 1
        property int nPointIndex: 0

        property int lastX: 0
        property int lastY: 0

        function clear()
        {
            let ctx = getContext("2d");
            ctx.reset();
            canvas.requestPaint();
        }



        MultiPointTouchArea {
            id: area
            anchors.fill: parent

            minimumTouchPoints: 1
            maximumTouchPoints: 5
            touchPoints: [
                TouchPoint {},
                TouchPoint {},
                TouchPoint {},
                TouchPoint {},
                TouchPoint {}
            ]

            onPressed: {
                canvas.lastX = this.touchPoints[0].x;
                canvas.lastY = this.touchPoints[0].y;

                canvas.requestPaint();
            }

            onTouchUpdated: {
                canvas.requestPaint();
            }

        }



        function getPolarCoords(x, y)
        {
            let pos = Qt.vector2d(x - width / 2, y - height / 2);
            let radius = pos.length();

            let f = Math.atan(pos.y / pos.x);
            if(pos.x < 0)
            {
                f += Math.PI;
            }

            let obj = {
                radius:  radius,
                angle: f
            }

            return obj;
        }

        onPaint: {
            let ctx = getContext("2d");
            ctx.lineCap = "round";
            ctx.lineWidth = brushSize;
            ctx.beginPath();

            for(let i = 0; i <= nPointIndex; ++i)
            {
                let angle = Math.PI / 180 * (360.0 / axes);
                let old_pos = getPolarCoords(lastX, lastY);
                lastX = area.touchPoints[0].x;
                lastY = area.touchPoints[0].y;
                let new_pos = getPolarCoords(lastX, lastY);

                for(let axe = 0; axe < axes; ++axe)
                {
                    if(new_pos.radius < height / 2)
                    {
                        let start = Qt.point(width / 2 +  Math.cos(old_pos.angle + (angle * axe)) * old_pos.radius,
                                             height / 2 +  Math.sin(old_pos.angle + (angle * axe)) * old_pos.radius);
                        let end = Qt.point(width / 2 +  Math.cos(new_pos.angle + (angle * axe)) * new_pos.radius,
                                           height / 2 + Math.sin(new_pos.angle + (angle * axe)) * new_pos.radius);

                        ctx.moveTo(start.x, start.y);
                        ctx.lineTo(end.x, end.y);

                        if(symmetry)
                        {
                            start = Qt.point(width / 2 +  Math.sin(old_pos.angle + (angle * axe + angle)) * old_pos.radius,
                                             height / 2 +  Math.cos(old_pos.angle + (angle * axe + angle)) * old_pos.radius);
                            end = Qt.point(width / 2 +  Math.sin(new_pos.angle + (angle * axe + angle)) * new_pos.radius,
                                           height / 2 + Math.cos(new_pos.angle + (angle * axe + angle)) * new_pos.radius);

                            ctx.moveTo(start.x, start.y);
                            ctx.lineTo(end.x, end.y);
                        }
                    }

                }
            }
            ctx.stroke();
        }
    }

}



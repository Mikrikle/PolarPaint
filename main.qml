import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

ApplicationWindow {
    visible: true
    minimumWidth: 400
    minimumHeight: 400
    title: qsTr("paint")

    Canvas {
        id: canvas
        anchors.fill: parent
        renderStrategy: Canvas.Threaded
        renderTarget: Canvas.FramebufferObject

        property bool symmetry: true
        property int axes: 5
        property int brushSize: 1
        property int nPointIndex: 0

        property var color: {'h':110, 's':110, 'l':110}
        property var listlastX: [0]
        property var listlastY: [0]

        function clear()
        {
            let ctx = getContext("2d");
            ctx.reset();
            canvas.requestPaint();
        }



        MultiPointTouchArea {
            id: area
            anchors.fill: parent

            property var listX: [0]
            property var listY: [0]

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
                canvas.nPointIndex = 0;
                for(let i = 0; i < 5; ++i)
                {
                    if(this.touchPoints[i].pressed)
                    {
                        listX[i] = this.touchPoints[i].x;
                        listY[i] = this.touchPoints[i].y;
                        canvas.listlastX[i] = this.touchPoints[i].x;
                        canvas.listlastY[i] = this.touchPoints[i].y;
                        canvas.nPointIndex = i;
                    }
                    else
                    {
                        break;
                    }
                }
            }

            onTouchUpdated: {
                for(let i = 0; i < 5; ++i)
                {
                    if(this.touchPoints[i].pressed)
                    {
                        listX[i] = this.touchPoints[i].x;
                        listY[i] = this.touchPoints[i].y;
                    }
                    else
                    {
                        break;
                    }
                }
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
            ctx.strokeStyle  = `hsl( ${color.h}, ${color.s}, ${color.l})`;

            ctx.beginPath();

            for(let i = 0; i <= nPointIndex; ++i)
            {

                if(axes > 1 || symmetry)
                {
                    let angle = Math.PI / 180 * (360.0 / axes);
                    let old_pos = getPolarCoords(listlastX[i], listlastY[i]);
                    listlastX[i] = area.listX[i];
                    listlastY[i] = area.listY[i];
                    let new_pos = getPolarCoords(listlastX[i], listlastY[i]);

                    for(let axe = 0; axe < axes; ++axe)
                    {
                        let start = Qt.point(width / 2 +  Math.cos(old_pos.angle + (angle * axe)) * old_pos.radius,
                                             height / 2 +  Math.sin(old_pos.angle + (angle * axe)) * old_pos.radius);
                        let end = Qt.point(width / 2 +  Math.cos(new_pos.angle + (angle * axe)) * new_pos.radius,
                                           height / 2 + Math.sin(new_pos.angle + (angle * axe)) * new_pos.radius);

                        ctx.moveTo(start.x, start.y);
                        ctx.lineTo(end.x, end.y);

                        if(symmetry)
                        {
                            start = Qt.point(width / 2 +  Math.cos( (Math.PI - old_pos.angle + (angle * axe))) * old_pos.radius,
                                                 height / 2 +  Math.sin( (Math.PI - old_pos.angle + (angle * axe))) * old_pos.radius);
                            end = Qt.point(width / 2 +  Math.cos( (Math.PI - new_pos.angle + (angle * axe))) * new_pos.radius,
                                               height / 2 + Math.sin( (Math.PI - new_pos.angle + (angle * axe))) * new_pos.radius);

                            ctx.moveTo(start.x, start.y);
                            ctx.lineTo(end.x, end.y);
                        }
                    }
                }
                else
                {
                    ctx.moveTo(listlastX[i], listlastY[i]);
                    listlastX[i] = area.listX[i];
                    listlastY[i] = area.listY[i];
                    ctx.lineTo(listlastX[i], listlastY[i]);
                }
            }
            ctx.stroke();
        }
    }

}



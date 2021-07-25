import QtQuick 2.0

Item {

    property Item cvs : canvas

    Rectangle {
        id: background
        color: canvas.backgroundColor
        anchors.fill: canvas
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        renderStrategy: Canvas.Threaded
        renderTarget: Canvas.FramebufferObject

        property bool symmetry: true
        property int axes: 6
        property int brushSize: 1

        property var brushColor: {'h':110, 's':110, 'l':110}
        property string backgroundColor: "#202020"

        property var line: {"points": [], "size":null, "color": null }
        property var listLines: [{"points": [], "size":brushSize, "color": brushColor }]
        property int nLines: 0
        property int bufX: 0
        property int bufY: 0
        property bool isNeedNewLine: false

        function clear()
        {
            let ctx = getContext("2d");
            ctx.reset();
            this.requestPaint();
        }


        function undo()
        {
            if(listLines.length > 0)
            {
                this.listLines.pop();
            }
        }

        MultiPointTouchArea {
            id: area
            anchors.fill: parent

            property var pointBuffer: []

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

                canvas.bufX = this.touchPoints[0].x;
                canvas.bufY = this.touchPoints[0].y;

                if(canvas.isNeedNewLine)
                {
                    canvas.listLines.push({"points": [], "size":null, "color": null });
                    canvas.listLines[canvas.nLines].size = canvas.brushSize;
                    canvas.listLines[canvas.nLines].color = canvas.brushColor;
                    canvas.listLines[canvas.nLines].points = [{"x":this.touchPoints[0].x, "y":this.touchPoints[0].y}];
                    canvas.isNeedNewLine = false;
                }

                pointBuffer[0] = {"x":this.touchPoints[0].x, "y":this.touchPoints[0].y};
                for(let i = 1; i < 5; ++i)
                {
                    if(this.touchPoints[i].pressed)
                    {
                        canvas.listLines[canvas.nLines].points.push({"x":this.touchPoints[i].x, "y":this.touchPoints[i].y});
                        pointBuffer[i] = {"x":this.touchPoints[0].x, "y":this.touchPoints[0].y};
                    }
                    else
                    {
                        break;
                    }
                }
                canvas.requestPaint();
            }

            onReleased:
            {
                pointBuffer = [];
                let isAllReleased = true
                for(let i = 0; i < 5; ++i)
                {
                    if(this.touchPoints[i].pressed)
                    {
                        isAllReleased = false;
                        break;
                    }
                }
                if(isAllReleased)
                {
                    canvas.isNeedNewLine = true;
                    ++canvas.nLines;
                }
            }

            onTouchUpdated: {
                for(let i = 0; i < 5; ++i)
                {
                    if(this.touchPoints[i].pressed)
                    {
                        canvas.listLines[canvas.nLines].points.push({"x":this.touchPoints[i].x, "y":this.touchPoints[i].y})
                        pointBuffer[i] = {"x":this.touchPoints[i].x, "y":this.touchPoints[i].y};
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

            ctx.beginPath();

            let current_line = this.listLines[this.listLines.length - 1];

            ctx.lineWidth = current_line.size;
            ctx.strokeStyle  = `hsl( ${current_line.color.h}, ${current_line.color.s}, ${current_line.color.l})`;


            for(let point = 0; point < area.pointBuffer.length; ++point)
            {
                let old_pos = {'x' :this.bufX, 'y': this.bufY};
                this.bufX = area.pointBuffer[point].x;
                this.bufY= area.pointBuffer[point].y;
                let new_pos = {'x' :this.bufX, 'y': this.bufY};

                ctx.moveTo(old_pos.x, old_pos.y);
                ctx.lineTo(new_pos.x, new_pos.y);
            }




            /* for(let i = 0; i < this.listLines.length; ++i)
            {
                let current_line = this.listLines[i];
                if(current_line.points !== undefined)
                {
                    ctx.lineWidth = current_line.size;
                    ctx.strokeStyle  = `hsl( ${current_line.color.h}, ${current_line.color.s}, ${current_line.color.l})`;

                    for(let nPoint = 0; nPoint < current_line.points.length - 1; ++nPoint)
                    {
                        ctx.moveTo(current_line.points[nPoint].x, current_line.points[nPoint].y);
                        ctx.lineTo(current_line.points[nPoint + 1].x, current_line.points[nPoint + 1].y);
                    }
                }
            }*/



            /*
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
            */
            ctx.stroke();
        }
    }


}

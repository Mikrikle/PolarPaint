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

        /* properties that the user can change */
        property bool symmetry: false
        property int axes: 2
        property int brushSize: 2
        property var brushColor: {'h':110, 's':110, 'l':110}
        property string backgroundColor: "#202020"

        /* system properties */
        property bool isRepaint: false
        property var line: {"points": [], "size":null, "color": null, "symmetry": false, "axes":1}
        property var listLines: [{"points": [], "size":brushSize, "color": brushColor }]
        property var deletedLines: []
        property int nLines: 0
        property int bufX: 0
        property int bufY: 0
        property bool isNeedNewLine: false

        function clear()
        {
            this.line =  {"points": [], "size":null, "color": null, "symmetry": false, "axes":1};
            this.listLines = [];
            this.deletedLines = [];
            this.nLines = 0;
            this.isNeedNewLine = true
            let ctx = getContext("2d");
            ctx.reset();
            this.requestPaint();
        }


        function undo()
        {
            if(this.listLines.length > 0)
            {
                this.deletedLines.unshift(this.listLines.pop());
                --this.nLines;
                this.isRepaint = true;
                this.requestPaint();
            }
        }

        function redo()
        {
            if(this.deletedLines.length > 0)
            {
                this.listLines.push(this.deletedLines.shift());
                ++this.nLines;
                this.isRepaint = true;
                this.requestPaint();
            }
        }

        MultiPointTouchArea {
            id: area
            anchors.fill: parent

            // points to draw at the moment
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

                // updating canvas
                canvas.bufX = this.touchPoints[0].x;
                canvas.bufY = this.touchPoints[0].y;
                canvas.deletedLines = [];

                if(canvas.isNeedNewLine)
                {
                    // create new line obj
                    canvas.listLines.push({"points": [], "size":null, "color": null });
                    canvas.listLines[canvas.nLines].size = canvas.brushSize;
                    canvas.listLines[canvas.nLines].color = canvas.brushColor;
                    canvas.listLines[canvas.nLines].points = [{"x":this.touchPoints[0].x, "y":this.touchPoints[0].y}];
                    canvas.listLines[canvas.nLines].symmetry = canvas.symmetry;
                    canvas.listLines[canvas.nLines].axes = canvas.axes;
                    canvas.isNeedNewLine = false;
                }

                // updating area
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
                // a new line is created only if the drawing is stopped
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

        function draw(old_pos, new_pos, ctx, symmetry, axes)
        {
            let angle = Math.PI / 180 * (360.0 / axes);
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

        onPaint: {
            let ctx = getContext("2d");
            ctx.lineCap = "round";

            ctx.beginPath();


            if(this.isRepaint)
            {
                ctx.reset();
                isRepaint = false;

                for(let i = 0; i < nLines; ++i)
                {
                    let temp_line = this.listLines[i];
                    ctx.lineWidth = temp_line.size;
                    ctx.strokeStyle  = `hsl( ${temp_line.color.h}, ${temp_line.color.s}, ${temp_line.color.l})`;
                    for(let nPoint = 0; nPoint < temp_line.points.length - 1; ++nPoint)
                    {
                        let old_pos = getPolarCoords(temp_line.points[nPoint].x, temp_line.points[nPoint].y);
                        let new_pos = getPolarCoords(temp_line.points[nPoint + 1].x, temp_line.points[nPoint + 1].y);
                        draw(old_pos, new_pos, ctx, this.symmetry, this.axes);
                    }
                }
            }
            else
            {
                if(this.listLines.length > 0)
                {
                    let current_line = this.listLines[this.listLines.length - 1];
                    ctx.lineWidth = current_line.size;
                    ctx.strokeStyle  = `hsl( ${current_line.color.h}, ${current_line.color.s}, ${current_line.color.l})`;
                }
            }

            for(let point = 0; point < area.pointBuffer.length; ++point)
            {

                if(axes > 1 || symmetry)
                {
                    let old_pos = getPolarCoords(this.bufX, this.bufY);
                    this.bufX = area.pointBuffer[point].x;
                    this.bufY= area.pointBuffer[point].y;
                    let new_pos = getPolarCoords(this.bufX, this.bufY);
                    draw(old_pos, new_pos, ctx, this.symmetry, this.axes);
                }
                else
                {
                    ctx.moveTo(this.bufX, this.bufY);
                    this.bufX = area.pointBuffer[point].x;
                    this.bufY= area.pointBuffer[point].y;
                    ctx.lineTo(this.bufX, this.bufY);
                }
            }

            ctx.stroke();
        }
    }


}

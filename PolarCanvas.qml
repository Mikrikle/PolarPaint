import QtQuick 2.0

Item {

    property Item cvs : canvas
    property Item bg : background

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
        property int axes: 3
        property int brushSize: 1
        property string brushColor: "#55FF00"
        property string backgroundColor: "#202020"

        /* system properties */
        property int bufX: 0
        property int bufY: 0
        property var prev_cvs: ({});
        property var current_cvs: ({});
        property bool isUndo: false;
        property bool isRedo: false;


        function clear()
        {
            let ctx = getContext("2d");
            ctx.reset();
            this.requestPaint();
        }


        function undo()
        {
            isUndo = true;
            clear();
        }

        function redo()
        {
            isRedo = true;
            clear();
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

                // save canvas
                let ctx = canvas.getContext("2d");
                canvas.prev_cvs = ctx.getImageData(0, 0, width, height);

                // updating canvas
                canvas.bufX = this.touchPoints[0].x;
                canvas.bufY = this.touchPoints[0].y;

                // updating area
                pointBuffer[0] = {"x":this.touchPoints[0].x, "y":this.touchPoints[0].y};
                for(let i = 1; i < 5; ++i)
                {
                    if(this.touchPoints[i].pressed)
                    {
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
                // save canvas
                let ctx = canvas.getContext("2d");
                canvas.current_cvs = ctx.getImageData(0, 0, width, height);

                pointBuffer = [];
            }

            onTouchUpdated: {
                for(let i = 0; i < 5; ++i)
                {
                    if(this.touchPoints[i].pressed)
                    {
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
            if(isUndo)
            {
                let ctx = getContext("2d");
                ctx.drawImage(prev_cvs, 0, 0);
                isUndo = false;
                return;
            }

            if(isRedo)
            {
                let ctx = getContext("2d");
                ctx.drawImage(current_cvs, 0, 0);
                isRedo = false;
                return;
            }

            let ctx = getContext("2d");
            ctx.lineCap = "round";
            ctx.beginPath();

            ctx.lineWidth = this.brushSize;
            ctx.strokeStyle  = this.brushColor;
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

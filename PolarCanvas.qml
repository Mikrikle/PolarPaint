import QtQuick 2.0
import com.cpp.MirroredCanvas 1.0

MirroredCanvas
{
    id:canvas
    anchors.fill: parent

    MultiPointTouchArea {
        id: area
        anchors.fill: parent

        property var pointBuffer: []
        property var prevPos: ({})

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
            if(!canvas.moveMod)
            {
                canvas.startLine();
                canvas.previousPoint = canvas.getCorrectPos(Qt.point(this.touchPoints[0].x, this.touchPoints[0].y));

                pointBuffer[0] = canvas.getCorrectPos(Qt.point(this.touchPoints[0].x, this.touchPoints[0].y));
                for(let i = 1; i < 5; ++i)
                {
                    if(this.touchPoints[i].pressed)
                    {
                        pointBuffer[i] = canvas.getCorrectPos(Qt.point(this.touchPoints[i].x, this.touchPoints[i].y));
                    }
                    else
                    {
                        break;
                    }
                }

                canvas.continueLine(pointBuffer);
            }
            else
            {
                pointBuffer[0] = Qt.point(this.touchPoints[0].x, this.touchPoints[0].y)
                prevPos = this.pointBuffer[0];
            }
        }

        onReleased:
        {
            pointBuffer = [];
        }

        onTouchUpdated: {
            if(!canvas.moveMod)
            {
                for(let i = 0; i < 5; ++i)
                {
                    if(this.touchPoints[i].pressed)
                    {
                        pointBuffer[i] = canvas.getCorrectPos(Qt.point(this.touchPoints[i].x, this.touchPoints[i].y));
                    }
                    else
                    {
                        break;
                    }
                }

                canvas.continueLine(pointBuffer);
            }
            else
            {
                pointBuffer[0] = Qt.point(this.touchPoints[0].x, this.touchPoints[0].y)
                canvas.move(Qt.point(this.pointBuffer[0].x - prevPos.x, this.pointBuffer[0].y - prevPos.y));
                canvas.update();
                prevPos = pointBuffer[0];
            }
        }

    }
}



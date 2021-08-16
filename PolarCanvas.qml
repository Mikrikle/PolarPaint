import QtQuick 2.0
import com.cpp.MirroredCanvas 1.0

MirroredCanvas
{
    id:canvas
    anchors.fill: parent

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
            canvas.startLine();
            canvas.previousPoint = Qt.point(this.touchPoints[0].x, this.touchPoints[0].y);

            // updating area
            pointBuffer[0] = Qt.point(this.touchPoints[0].x, this.touchPoints[0].y);
            for(let i = 1; i < 5; ++i)
            {
                if(this.touchPoints[i].pressed)
                {
                    pointBuffer[i] = Qt.point(this.touchPoints[i].x, this.touchPoints[i].y);
                }
                else
                {
                    break;
                }
            }

            canvas.continueLine(pointBuffer);
        }

        onReleased:
        {
            pointBuffer = [];
        }

        onTouchUpdated: {
            for(let i = 0; i < 5; ++i)
            {
                if(this.touchPoints[i].pressed)
                {
                    pointBuffer[i] = Qt.point(this.touchPoints[i].x, this.touchPoints[i].y);
                }
                else
                {
                    break;
                }
            }

            canvas.continueLine(pointBuffer);
        }

    }
}



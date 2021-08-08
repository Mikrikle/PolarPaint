import QtQuick 2.0
import com.cpp.MirroredCanvas 1.0

Item {

    property Item cvs : canvas
    property Item bg : background

    Rectangle {
        id: background_rect
        anchors.fill: canvas

        Canvas {
            id: background
            anchors.fill: parent

            onPaint: {
                let ctx = getContext("2d");
                ctx.fillStyle = "#202020";
                ctx.fillRect(0, 0, width, height);
            }
        }
    }

    MirroredCanvas
    {
        id:canvas
        anchors.centerIn: parent

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
                // let ctx = canvas.getContext("2d");
                // canvas.prev_cvs = ctx.getImageData(0, 0, width, height);

                // updating canvas
                canvas.bufPoint = Qt.point(this.touchPoints[0].x, this.touchPoints[0].y);
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

                canvas.draw(pointBuffer);
            }

            onReleased:
            {
                // save canvas
                // let ctx = canvas.getContext("2d");
                // canvas.current_cvs = ctx.getImageData(0, 0, width, height);

                //pointBuffer = [];
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
                canvas.draw(pointBuffer);
            }

        }

    }


}

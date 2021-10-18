import QtQuick 2.0
import com.cpp.MirroredCanvas 1.0

MirroredCanvas
{
    id:canvas
    anchors.fill: parent

    MultiPointTouchArea {
        id: area
        anchors.fill: parent

        // draw
        property var pointBuffer: []

        // move
        property var prevTouchPoints: []
        property var scalingCenter: ({})
        property bool blockUpdate: false

        minimumTouchPoints: 1
        maximumTouchPoints: 5
        touchPoints: [
            TouchPoint {},
            TouchPoint {},
            TouchPoint {},
            TouchPoint {},
            TouchPoint {}
        ]

        Timer{
            id:dbltimer
            repeat: false
            running: false
            interval: 200
        }


        function updatePrevTouchPoints()
        {
            for(let i = 0; i < this.touchPoints.length; ++i)
            {
                if(this.touchPoints[i].pressed)
                {
                    prevTouchPoints[i] = Qt.point(this.touchPoints[i].x, this.touchPoints[i].y);
                }
                else
                    break;
            }
        }

        function getDistanceBetweenPoints(point1, point2)
        {
            let vec = Qt.vector2d(point2.x - point1.x, point2.y - point1.y);
            return vec.length();
        }

        function getCenterPointBetween(point1, point2)
        {
            let vec = Qt.vector2d(point2.x - point1.x, point2.y - point1.y);
            return Qt.point(point1.x + vec.x / 2, point1.y + vec.y / 2);
        }

        onPressed: {
            if(!canvas.moveMod)
            {
                canvas.startLine();

                pointBuffer[0] = canvas.getLocalPosFromReal(Qt.point(this.touchPoints[0].x, this.touchPoints[0].y));
                canvas.previousPoint = pointBuffer[0];
                for(let i = 1; i < this.touchPoints.length; ++i)
                {
                    if(this.touchPoints[i].pressed)
                    {
                        pointBuffer[i] = canvas.getLocalPosFromReal(Qt.point(this.touchPoints[i].x, this.touchPoints[i].y));
                    }
                    else
                        break;
                }

                canvas.continueLine(pointBuffer);
            }
            else
            {
                if(this.touchPoints.length > 1)
                {
                    scalingCenter = canvas.getLocalPosFromReal(getCenterPointBetween(this.touchPoints[0], this.touchPoints[1]));
                }

                updatePrevTouchPoints();
            }

        }

        onReleased:
        {

            if(canvas.moveMod && prevTouchPoints.length == 1)
            {
                if(dbltimer.running)
                {
                    canvas.moveMod = false;
                    blockUpdate = true;
                    dbltimer.stop();
                }
                else
                {
                    dbltimer.start();
                }
            }

            pointBuffer = [];
            prevTouchPoints = [];
            scalingCenter = ({});
        }

        onTouchUpdated: {
            if(!blockUpdate)
            {
                if(!canvas.moveMod)
                {
                    for(let i = 0; i < this.touchPoints.length; ++i)
                    {
                        if(this.touchPoints[i].pressed)
                        {
                            pointBuffer[i] = canvas.getLocalPosFromReal(Qt.point(this.touchPoints[i].x, this.touchPoints[i].y));
                        }
                        else
                            break;
                    }

                    canvas.continueLine(pointBuffer);
                }
                else
                {
                    if(prevTouchPoints.length == 1)
                    {
                        canvas.move(Qt.point(this.touchPoints[0].x - prevTouchPoints[0].x, this.touchPoints[0].y - prevTouchPoints[0].y));
                        canvas.setTempCenterPos();
                    }
                    else if(prevTouchPoints.length > 1)
                    {
                        let old_distance = getDistanceBetweenPoints(prevTouchPoints[0], prevTouchPoints[1]);
                        let new_distance = getDistanceBetweenPoints(this.touchPoints[0], this.touchPoints[1]);
                        let zoom = (new_distance - old_distance) / (canvas.width / 2.0);
                        canvas.changeScaleWithCentering(zoom);
                        canvas.moveScalingCenterTo(scalingCenter, zoom)
                    }
                    canvas.update();
                    updatePrevTouchPoints();
                }
            }
            else
            {
                blockUpdate = false;
            }
        }
    }
}



#include "cCanvas.h"

cCanvas::cCanvas(QQuickItem *pqi) : QQuickPaintedItem(pqi)
    , m_brushSize(1)
    , m_brushColor("#55FF00")
    , m_symmetry(false)
    , m_nAxes(5)
{
    this->setWidth(2000);
    this->setHeight(2000);
    cvs = new QImage(width(), height(), QImage::Format_ARGB32);
}

cCanvas::~cCanvas()
{
    delete cvs;
}

QPointF cCanvas::getPolarCoords(QPoint coords)
{
    QVector2D pos(coords.x() - width() / 2, coords.y() - height() / 2);
    float radius = pos.length();
    float f = atan(static_cast<float>(pos.y()) / pos.x());
    if (pos.x() < 0)
        f += M_PI;
    return QPointF(radius, f);
}


void cCanvas::draw(const QList<QPoint> &points)
{

    //QElapsedTimer timer;
    //timer.start();

    QPainter painter(cvs);

    auto pen = QPen(QColor(m_brushColor));
    pen.setWidth(m_brushSize);

    painter.setPen(pen);

    float angle = M_PI / 180 * (360.0 / m_nAxes);
    for(auto &point : points)
    {
        if(m_nAxes > 1 || m_symmetry)
        {
            QPointF old_pos = getPolarCoords(m_bufPoint);
            QPointF new_pos = getPolarCoords(point);
            for(int axe = 0; axe < m_nAxes; ++axe)
            {
                QPoint start(width()/2 + cos(old_pos.y() + (angle * axe)) * old_pos.x(),
                             height()/2 + sin(old_pos.y() + (angle * axe)) * old_pos.x());
                QPoint end(width()/2 + cos(new_pos.y() + (angle * axe)) * new_pos.x(),
                           height()/2 + sin(new_pos.y() + (angle * axe)) * new_pos.x());
                painter.drawLine(start, end);
                if(m_symmetry)
                {
                    QPoint start(width()/2 + cos((M_PI - old_pos.y() + (angle * axe))) * old_pos.x(),
                                 height()/2 + sin((M_PI - old_pos.y() + (angle * axe))) * old_pos.x());
                    QPoint end(width()/2 + cos((M_PI - new_pos.y() + (angle * axe))) * new_pos.x(),
                               height()/2 + sin((M_PI - new_pos.y() + (angle * axe))) * new_pos.x());
                    painter.drawLine(start, end);
                }
            }
        }
        else
        {
            painter.drawLine(m_bufPoint, point);
        }
        m_bufPoint = point;
    }

    update();

    //qDebug() << "The slow operation took" << timer.elapsed() << "milliseconds";

}

void cCanvas::clear()
{
    cvs->fill(Qt::transparent);
    update();
}

void cCanvas::paint(QPainter *ppainter)
{
    ppainter->drawImage(QPoint(0, 0), *cvs);
}


#include "cCanvas.h"

cCanvas::cCanvas(QQuickItem *pqi) : QQuickPaintedItem(pqi)
    , m_brushSize(2)
    , m_brushColor("#FF55FF00")
    , m_symmetry(false)
    , m_nAxes(3)
    , isMayUndo(false)
    , isMayRedo(false)
{
    auto r = QGuiApplication::screens().at(0)->availableSize();
    cvs = new QImage(r.width(), r.height(), QImage::Format_ARGB32_Premultiplied);
}

cCanvas::~cCanvas()
{
    delete cvs;
}

void cCanvas::redo()
{
    if(!canceled_cvs.isNull() && isMayRedo)
    {
        *cvs = canceled_cvs.copy();
        update();
        isMayRedo = false;
        isMayUndo = true;
    }
}

void cCanvas::undo()
{
    if(!prev_cvs.isNull() && isMayUndo)
    {
        canceled_cvs = cvs->copy();
        *cvs = prev_cvs.copy();
        update();
        isMayUndo = false;
        isMayRedo = true;
    }
}

void cCanvas::memorizeCanvas()
{
    prev_cvs = cvs->copy();
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
    isMayUndo = true;
    QPainter painter(cvs);
    painter.setRenderHint(QPainter::Antialiasing, true);
    auto pen = QPen(QColor(m_brushColor));
    pen.setCapStyle(Qt::RoundCap);
    pen.setJoinStyle(Qt::RoundJoin);
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


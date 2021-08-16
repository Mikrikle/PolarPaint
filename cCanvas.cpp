#include "cCanvas.h"

cCanvas::cCanvas(QQuickItem *pqi) : QQuickPaintedItem(pqi)
    , m_brushSize(1)
    , m_brushColor("#FF00FF00")
    , m_isSymmetry(false)
    , m_nAxes(1)
    , m_maxNumSavedLines(10)
{
    auto r = QGuiApplication::screens().at(0)->availableSize();
    m_cvs = new QImage(r.width(), r.height(), QImage::Format_ARGB32_Premultiplied);
    m_savedCvs = new QImage(r.width(), r.height(), QImage::Format_ARGB32_Premultiplied);
}

cCanvas::~cCanvas()
{
    delete m_cvs;
    delete m_savedCvs;
}

void cCanvas::redo()
{
    if(m_deletedLines.length() > 0)
    {
        m_savedLines.push_back(m_deletedLines.pop());
        m_redrawCvs();
    }
}

void cCanvas::undo()
{
    if(m_savedLines.length() > 0)
    {
        m_deletedLines.push(m_savedLines[m_savedLines.length() - 1]);
        m_savedLines.pop_back();
        m_redrawCvs();
    }
}

void cCanvas::m_redrawCvs()
{
    m_cvs->fill(Qt::transparent);
    *m_cvs = m_savedCvs->copy();
    for(auto& line : m_savedLines)
    {
        m_drawLine(line, m_cvs);
    }
    update();
}

void cCanvas::m_drawLine(const LineObj &line, QImage *cvs)
{
    auto saved_m_bufPoint = m_previuosPoint;
    auto saved_m_brushSize = m_brushSize;
    auto saved_m_brushColor = m_brushColor;
    auto saved_m_isSymmetry = m_isSymmetry;
    auto saved_m_nAxes = m_nAxes;

    m_previuosPoint = line.path[0][0];
    m_brushSize = line.size;
    m_brushColor = line.color;
    m_isSymmetry = line.symmetry;
    m_nAxes = line.nAxes;
    for(auto& points : line.path)
    {
        m_drawPoints(points, cvs);
    }

    m_previuosPoint = saved_m_bufPoint;
    m_brushSize = saved_m_brushSize;;
    m_brushColor = saved_m_brushColor;
    m_isSymmetry = saved_m_isSymmetry;
    m_nAxes = saved_m_nAxes;

}

void cCanvas::startLine()
{
    m_deletedLines.clear();
    if(m_savedLines.length() > m_maxNumSavedLines)
    {
        m_drawLine(m_savedLines[0], m_savedCvs);
        m_savedLines.pop_front();
    }
    LineObj line{{}, m_brushSize, m_brushColor, m_nAxes, m_isSymmetry};
    m_savedLines.push_back(line);
}

void cCanvas::continueLine(const QList<QPoint> &points)
{
    m_savedLines[m_savedLines.length() - 1].path.push_back(points);
    m_drawPoints(points, m_cvs);
}

QPointF cCanvas::m_getPolarCoords(QPoint coords)
{
    QVector2D pos(coords.x() - width() / 2, coords.y() - height() / 2);
    float radius = pos.length();
    float f = atan(static_cast<float>(pos.y()) / pos.x());
    if (pos.x() < 0)
        f += M_PI;
    return QPointF(radius, f);
}


void cCanvas::m_drawPoints(const QList<QPoint> &points, QImage *cvs)
{
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
        if(m_nAxes > 1 || m_isSymmetry)
        {
            QPointF posFrom = m_getPolarCoords(m_previuosPoint);
            QPointF posTo = m_getPolarCoords(point);
            for(int axis = 0; axis < m_nAxes; ++axis)
            {
                QPoint start(width()/2 + cos(posFrom.y() + (angle * axis)) * posFrom.x(),
                             height()/2 + sin(posFrom.y() + (angle * axis)) * posFrom.x());
                QPoint end(width()/2 + cos(posTo.y() + (angle * axis)) * posTo.x(),
                           height()/2 + sin(posTo.y() + (angle * axis)) * posTo.x());
                painter.drawLine(start, end);
                if(m_isSymmetry)
                {
                    QPoint start(width()/2 + cos((M_PI - posFrom.y() + (angle * axis))) * posFrom.x(),
                                 height()/2 + sin((M_PI - posFrom.y() + (angle * axis))) * posFrom.x());
                    QPoint end(width()/2 + cos((M_PI - posTo.y() + (angle * axis))) * posTo.x(),
                               height()/2 + sin((M_PI - posTo.y() + (angle * axis))) * posTo.x());
                    painter.drawLine(start, end);
                }
            }
        }
        else
        {
            painter.drawLine(m_previuosPoint, point);
        }
        m_previuosPoint = point;
    }

    update();
}

void cCanvas::clear()
{
    m_deletedLines.clear();
    m_savedLines.clear();
    m_cvs->fill(Qt::transparent);
    update();
}

void cCanvas::paint(QPainter *ppainter)
{
    ppainter->drawImage(QPoint(0, 0), *m_cvs);
}


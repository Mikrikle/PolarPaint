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
    if(m_undoLines.length() > 0)
    {
        m_savedLines.push_back(m_undoLines.pop());
        m_restoreCvs();
    }
}

void cCanvas::undo()
{
    if(m_savedLines.length() > 0)
    {
        m_undoLines.push(m_savedLines[m_savedLines.length() - 1]);
        m_savedLines.pop_back();
        m_restoreCvs();
    }
}

void cCanvas::m_restoreCvs()
{
    m_cvs->fill(Qt::transparent);
    *m_cvs = m_savedCvs->copy();
    for(auto& line : m_savedLines)
    {
        m_drawLine(line, m_cvs, false);
    }
    update();
}

void cCanvas::m_drawLine(const LineObj &line, QImage *cvs, bool isPropertyBufferization)
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

    if(isPropertyBufferization)
    {
        m_previuosPoint = saved_m_bufPoint;
        m_brushSize = saved_m_brushSize;;
        m_brushColor = saved_m_brushColor;
        m_isSymmetry = saved_m_isSymmetry;
        m_nAxes = saved_m_nAxes;
    }
}

void cCanvas::startNewLine()
{
    m_undoLines.clear();
    if(m_savedLines.length() > m_maxNumSavedLines)
    {
        m_drawLine(m_savedLines[0], m_savedCvs, true);
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
            QPointF old_pos = m_getPolarCoords(m_previuosPoint);
            QPointF new_pos = m_getPolarCoords(point);
            for(int axis = 0; axis < m_nAxes; ++axis)
            {
                QPoint start(width()/2 + cos(old_pos.y() + (angle * axis)) * old_pos.x(),
                             height()/2 + sin(old_pos.y() + (angle * axis)) * old_pos.x());
                QPoint end(width()/2 + cos(new_pos.y() + (angle * axis)) * new_pos.x(),
                           height()/2 + sin(new_pos.y() + (angle * axis)) * new_pos.x());
                painter.drawLine(start, end);
                if(m_isSymmetry)
                {
                    QPoint start(width()/2 + cos((M_PI - old_pos.y() + (angle * axis))) * old_pos.x(),
                                 height()/2 + sin((M_PI - old_pos.y() + (angle * axis))) * old_pos.x());
                    QPoint end(width()/2 + cos((M_PI - new_pos.y() + (angle * axis))) * new_pos.x(),
                               height()/2 + sin((M_PI - new_pos.y() + (angle * axis))) * new_pos.x());
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
    m_undoLines.clear();
    m_savedLines.clear();
    m_cvs->fill(Qt::transparent);
    update();
}

void cCanvas::paint(QPainter *ppainter)
{
    ppainter->drawImage(QPoint(0, 0), *m_cvs);
}


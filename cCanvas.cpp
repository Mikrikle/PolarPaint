#include "cCanvas.h"

cCanvas::cCanvas(QQuickItem *pqi) : QQuickPaintedItem(pqi)
    , m_brushSize(1)
    , m_brushColor("#FF00FF00")
    , m_isSymmetry(false)
    , m_nAxes(1)
    , m_bgColor("#202020")
    , m_scale(1.0)
    , m_isMoveMod(false)
    , m_PixelRatio(1)
    , m_isSaveBg(true)
    , m_isDrawCenterPoint(true)
    , m_cvsSize(2000)
    , m_offset(0, 0)
    , m_maxNumSavedLines(25)
{
    this->setSmooth(false);
    m_cvs = new QImage(m_cvsSize, m_cvsSize, QImage::Format_ARGB32_Premultiplied);
    m_savedCvs = new QImage(m_cvsSize, m_cvsSize, QImage::Format_ARGB32_Premultiplied);
    clear();
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
    QVector2D pos(coords.x() - m_cvsSize / 2, coords.y() - m_cvsSize / 2);
    float radius = pos.length();
    if(radius <= 0)
        return QPointF(0, 0);
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
                QPoint start(m_cvsSize/2 + cos(posFrom.y() + (angle * axis)) * posFrom.x(),
                             m_cvsSize/2 + sin(posFrom.y() + (angle * axis)) * posFrom.x());
                QPoint end(m_cvsSize/2 + cos(posTo.y() + (angle * axis)) * posTo.x(),
                           m_cvsSize/2 + sin(posTo.y() + (angle * axis)) * posTo.x());
                painter.drawLine(start, end);
                if(m_isSymmetry)
                {
                    QPoint start(m_cvsSize/2 + cos((M_PI - posFrom.y() + (angle * axis))) * posFrom.x(),
                                 m_cvsSize/2 + sin((M_PI - posFrom.y() + (angle * axis))) * posFrom.x());
                    QPoint end(m_cvsSize/2 + cos((M_PI - posTo.y() + (angle * axis))) * posTo.x(),
                               m_cvsSize/2 + sin((M_PI - posTo.y() + (angle * axis))) * posTo.x());
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


Q_INVOKABLE bool cCanvas::save()
{

    QString filename = "PolarPaint-" + QDateTime::currentDateTime().toString("dd-MM-yy-hh-mm-ss-zzz") + ".png";
    QString path = QStandardPaths::writableLocation(QStandardPaths::PicturesLocation)
                   + "/" + filename;

    if(m_isSaveBg)
    {
        QImage tmp(m_cvs->size(), m_cvs->format());
        tmp.fill(QColor(m_bgColor));

        QPainter painter(&tmp);
        painter.drawImage(QPoint(0, 0), *m_cvs);
        return tmp.save(path);
    }
    else
    {
        return m_cvs->save(path);
    }
}


void cCanvas::clear()
{
    m_deletedLines.clear();
    m_savedLines.clear();
    m_cvs->fill(Qt::transparent);
    m_savedCvs->fill(Qt::transparent);
    update();
}

void cCanvas::move(const QPoint &path)
{
    m_offset += path;
}

void cCanvas::moveCenter()
{
    m_offset.setX(0);
    m_offset.setY(0);
}

void cCanvas::setCvsSize(const int size)
{
    m_cvsSize = (size > 1?size:2);
    *m_cvs = m_cvs->scaled(m_cvsSize, m_cvsSize);
    *m_savedCvs = m_savedCvs->scaled(m_cvsSize, m_cvsSize);
    update();
}

void cCanvas::paint(QPainter *ppainter)
{
    QRect imgRect(
        width() / 2 - (m_cvsSize / 2 * (m_scale / m_PixelRatio)) + m_offset.x(),
        height() / 2 - (m_cvsSize / 2 * (m_scale / m_PixelRatio)) + m_offset.y(),
        m_cvsSize * (m_scale / m_PixelRatio),
        m_cvsSize * (m_scale / m_PixelRatio)
        );
    ppainter->setPen(QPen(Qt::black, 2));
    ppainter->drawRect(imgRect);
    ppainter->setPen(QPen(Qt::white, 1));
    ppainter->drawRect(imgRect);
    ppainter->drawImage(imgRect,*m_cvs);

    if(m_isDrawCenterPoint)
    {
        ppainter->setPen(QPen(Qt::white, 1));
        ppainter->drawPoint(width() / 2, height() / 2);
    }
}

QPoint cCanvas::getCorrectPos(const QPoint& pos)
{
    return QPoint(
        ((pos.x() - m_offset.x() - (width() / 2 - (m_cvsSize / 2 * (m_scale / m_PixelRatio)))) / (m_scale / m_PixelRatio)),
        ((pos.y() - m_offset.y() - (height() / 2 - (m_cvsSize / 2 * (m_scale / m_PixelRatio)))) / (m_scale / m_PixelRatio))
        );
}


void cCanvas::changeScaleWithCentering(double scaleChange)
{
    QPoint corret_center(getCorrectPos(QPoint(width() / 2, height() / 2)));
    m_scale += scaleChange;
    emit scaleChanged(m_scale);
    move(QPoint((m_cvsSize / 2 - corret_center.x()) / (1 / scaleChange),
                (m_cvsSize / 2 - corret_center.y()) / (1 / scaleChange))
         );
}

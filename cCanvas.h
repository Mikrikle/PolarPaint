#ifndef CCANVAS_H
#define CCANVAS_H

#include <QObject>
#include <QtQuick>

#include <QFile>
#include <QJsonObject>
#include <QJsonDocument>


class QPainter;

class jsonEditor
{
private:
    QJsonObject json;
    QString filename;

public:
    jsonEditor();

    int getInt(const QString &key) const;
    QString getString(const QString &key) const;
    bool getBool(const QString &key) const;

    void setData(int brushSize, const QString &brushColor, bool symmetry, int nAxes);
};

class cCanvas : public QQuickPaintedItem
{
    Q_OBJECT
    Q_PROPERTY(int brushSize MEMBER m_brushSize NOTIFY brushSizeChanged)
    Q_PROPERTY(QString brushColor MEMBER m_brushColor NOTIFY brushColorChanged)
    Q_PROPERTY(bool symmetry MEMBER m_symmetry NOTIFY symmetryChanged)
    Q_PROPERTY(int axes MEMBER m_nAxes NOTIFY axesNumChanged)
    Q_PROPERTY(QPoint bufPoint WRITE setBufPoint READ getBufPoint)

private:
    jsonEditor jsSettings;

    int m_brushSize;
    QString m_brushColor;
    bool m_symmetry;
    int m_nAxes;
    QPoint m_bufPoint;

    QImage *cvs;
    QImage prev_cvs;
    QImage canceled_cvs;
    bool isMayUndo;
    bool isMayRedo;

public:
    cCanvas(QQuickItem *pqi = nullptr);
    virtual ~cCanvas();

    Q_INVOKABLE void draw(const QList<QPoint> &points);
    Q_INVOKABLE void clear();
    Q_INVOKABLE void redo();
    Q_INVOKABLE void undo();

    Q_INVOKABLE void memorizeCanvas();


    void paint(QPainter *ppainter) override;
    QPointF getPolarCoords(QPoint coords);

    QPoint getBufPoint() const {return m_bufPoint;}
    void setBufPoint(const QPoint& point) {m_bufPoint = point;}

signals:
    void brushSizeChanged(const int brushSize);
    void symmetryChanged(const bool symmetry);
    void axesNumChanged(const int nAxes);
    void brushColorChanged(const QString &color);
};

#endif // CCANVAS_H


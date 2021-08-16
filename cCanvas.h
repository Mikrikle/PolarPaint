#ifndef CCANVAS_H
#define CCANVAS_H

#include <QObject>
#include <QtQuick>

#include <QFile>
#include <QJsonObject>
#include <QJsonDocument>


class QPainter;


class cCanvas : public QQuickPaintedItem
{
    Q_OBJECT
    Q_PROPERTY(int brushSize MEMBER m_brushSize NOTIFY brushSizeChanged)
    Q_PROPERTY(QString brushColor MEMBER m_brushColor NOTIFY brushColorChanged)
    Q_PROPERTY(bool symmetry MEMBER m_isSymmetry NOTIFY symmetryChanged)
    Q_PROPERTY(int axes MEMBER m_nAxes NOTIFY axesNumChanged)
    Q_PROPERTY(QPoint previousPoint MEMBER m_previuosPoint NOTIFY PreviousPointChanged)

private:
    int m_brushSize;
    QString m_brushColor;
    bool m_isSymmetry;
    int m_nAxes;
    QPoint m_previuosPoint;

    QImage *m_cvs;


    QImage *m_savedCvs;
    int m_maxNumSavedLines;
    struct LineObj
    {
        QList<QList<QPoint>> path;
        int size;
        QString color;
        int nAxes{0};
        bool symmetry{false};
    };
    QList <LineObj> m_savedLines;
    QStack <LineObj> m_undoLines;
    void m_restoreCvs();
    void m_drawLine(const LineObj &line, QImage *cvs, bool isPropertyBufferization);
    void m_drawPoints(const QList<QPoint> &points, QImage *cvs);

    QPointF m_getPolarCoords(QPoint coords);
public:
    cCanvas(QQuickItem *pqi = nullptr);
    virtual ~cCanvas();

    Q_INVOKABLE void clear();
    Q_INVOKABLE void redo();
    Q_INVOKABLE void undo();

    Q_INVOKABLE void startNewLine();
    Q_INVOKABLE void continueLine(const QList<QPoint> &points);

    void paint(QPainter *ppainter) override;

signals:
    void brushSizeChanged(const int brushSize);
    void symmetryChanged(const bool symmetry);
    void axesNumChanged(const int nAxes);
    void brushColorChanged(const QString &color);
    void PreviousPointChanged(const QPoint& point);
};

#endif // CCANVAS_H


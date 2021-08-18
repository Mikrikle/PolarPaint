#ifndef JSONLOADER_H
#define JSONLOADER_H

#include <QObject>
#include <QStandardPaths>

#include <QFile>
#include <QJsonObject>
#include <QJsonDocument>

class JsonLoader : public QObject
{
    Q_OBJECT

private:
    QString m_path;
    QString m_state;

public:
    explicit JsonLoader(QObject *parent = 0);

    Q_INVOKABLE QString load(const QString &filename);
    Q_INVOKABLE bool save(const QString &data);
    Q_INVOKABLE QString getState();
signals:
    void filenameChanged();
};

#endif // JSONLOADER_H

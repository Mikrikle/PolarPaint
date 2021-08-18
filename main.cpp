#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtSvg>

#include "cCanvas.h"
#include "jsonloader.h"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QGuiApplication app(argc, argv);

    qmlRegisterType<cCanvas>("com.cpp.MirroredCanvas", 1, 0, "MirroredCanvas");
    qmlRegisterType<JsonLoader>("com.cpp.JsonSettings", 1, 0, "JsonSettings");

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}

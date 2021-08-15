#include "cCanvas.h"


jsonEditor::jsonEditor()
{
    filename = QCoreApplication::applicationDirPath() + "/settings.json";

    QFile file;
    file.setFileName(filename);
    if(!file.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        setData(2, "#FF55FF00", false, 3);
        file.open(QIODevice::ReadOnly | QIODevice::Text);
    }

    QString val;
    val = file.readAll();
    QJsonDocument doc = QJsonDocument::fromJson(val.toUtf8());
    json = doc.object();
}


int jsonEditor::getInt(const QString &key) const
{
    return json[key].toInt();
}


QString jsonEditor::getString(const QString &key) const
{
    return json[key].toString();
}

bool jsonEditor::getBool(const QString &key) const
{
    return json[key].toBool();
}

void jsonEditor::setData(int brushSize, const QString &brushColor, bool symmetry, int nAxes)
{
    QFile file;
    file.setFileName(filename);
    file.open(QIODevice::WriteOnly | QIODevice::Text);

    QJsonObject recordObject;
    recordObject.insert("brushSize", QJsonValue::fromVariant(brushSize));
    recordObject.insert("brushColor", QJsonValue::fromVariant(brushColor));
    recordObject.insert("symmetry", QJsonValue::fromVariant(symmetry));
    recordObject.insert("nAxes", QJsonValue::fromVariant(nAxes));
    QJsonDocument doc(recordObject);
    QString jsonString = doc.toJson(QJsonDocument::Indented);

    QTextStream stream( &file );
    stream << jsonString;
    file.close();
}

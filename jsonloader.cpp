#include "jsonloader.h"

JsonLoader::JsonLoader(QObject *parent): QObject(parent)
{
}

QString JsonLoader::getState()
{
    return "State: " + m_state;
}


bool JsonLoader::save(const QString &data)
{
    m_state.clear();
    if(!m_path.isEmpty())
    {
        m_state = "the path exists";
        QFile file;
        file.setFileName(m_path);
        if(file.open(QIODevice::WriteOnly | QIODevice::Text))
        {
            m_state = "successfully saved";
            QTextStream stream(&file);
            stream << data;
            file.close();
            return true;
        }
        m_state = "file not saved\n" + m_path;
    }
    return false;
}


QString JsonLoader::load(const QString &filename)
{
    m_state.clear();
    m_path = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
    if(!m_path.isEmpty())
    {
        m_path += filename;
        QFile file;
        file.setFileName(m_path);
        if(!file.open(QIODevice::ReadOnly | QIODevice::Text))
        {
            m_state = "file not open:" + m_path;
            QJsonObject recordObject;
            recordObject.insert("slider_brushSize", QJsonValue::fromVariant(1));
            recordObject.insert("slider_nAxes", QJsonValue::fromVariant(3));
            recordObject.insert("property_isSymmetry", QJsonValue::fromVariant(false));
            recordObject.insert("slider_aColor", QJsonValue::fromVariant(255));
            recordObject.insert("slider_hColor", QJsonValue::fromVariant(100));
            recordObject.insert("slider_sColor", QJsonValue::fromVariant(100));
            recordObject.insert("slider_lColor", QJsonValue::fromVariant(50));
            recordObject.insert("slider_BgAColor", QJsonValue::fromVariant(255));
            recordObject.insert("slider_BgHColor", QJsonValue::fromVariant(0));
            recordObject.insert("slider_BgSColor", QJsonValue::fromVariant(0));
            recordObject.insert("slider_BgLColor", QJsonValue::fromVariant(10));
            recordObject.insert("property_isDrawAxes", QJsonValue::fromVariant(true));
            recordObject.insert("property_axesOpacity", QJsonValue::fromVariant(64));
            QJsonDocument doc(recordObject);
            save(doc.toJson(QJsonDocument::Compact));

            file.open(QIODevice::ReadOnly | QIODevice::Text);
        }
        if(file.isOpen())
        {
            m_state = "file open:" + m_path;
            QString data = file.readAll();
            file.close();
            return data;
        }
    }
    return QString{};
}

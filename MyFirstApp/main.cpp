#include <QGuiApplication>
#include <QQuickView>

#include "sailfishapplication.h"
#include <QJsonDocument>
#include <QQmlEngine>
#include <QQmlContext>


Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(Sailfish::createApplication(argc, argv));
    QScopedPointer<QQuickView> view(Sailfish::createView("main.qml"));

    Sailfish::showView(view.data());

    /*QQuickView viewer;
    QJsonDocument doc;

    viewer.rootContext()->setContextProperty("doc", &doc);
    viewer.setSource(QUrl::fromLocalFile("FirstPage.qml"));
    viewer.show();*/
    
    return app->exec();
}



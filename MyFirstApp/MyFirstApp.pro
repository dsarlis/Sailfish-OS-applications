# The name of your app
TARGET = MyFirstApp

# C++ sources
SOURCES += main.cpp

# C++ headers
HEADERS +=

# QML files and folders
qml.files = *.qml pages cover main.qml

# The .desktop file
desktop.files = MyFirstApp.desktop

# Please do not modify the following line.
include(sailfishapplication/sailfishapplication.pri)

OTHER_FILES = \
    rpm/MyFirstApp.yaml \
    rpm/MyFirstApp.spec \
    pages/DeleteMultiple.qml


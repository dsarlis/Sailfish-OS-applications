import QtQuick 2.0
import Sailfish.Silica 1.0


Rectangle {
    id: cover
    anchors.fill: parent
    color: "blue"

    Label {
        id: label
        anchors.centerIn: parent
        text: "Notebook"
    }
    
    CoverActionList {
        id: coverAction
        
        CoverAction {
            iconSource: "image://theme/icon-l-copy"
            onTriggered: {
                pageStack.push(Qt.resolvedUrl("../pages/Note.qml"), {dataContainer: cover.initialPage})
            }
        }
        
    }
}



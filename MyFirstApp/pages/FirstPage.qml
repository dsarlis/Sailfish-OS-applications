import QtQuick.LocalStorage 2.0
import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    id: root
    property Item contextMenu
    property bool keepSearchFieldFocus: true
    property string searchString: ""


    function getDatabase() {
        return LocalStorage.openDatabaseSync("Notebook", "1.0", "StorageDatabase", 100000);
    }

    function initialize() {
        var db = getDatabase();

        db.transaction(
                    function (tx) {
                        tx.executeSql('CREATE TABLE IF NOT EXISTS notebook(title TEXT UNIQUE, note TEXT)');
                    });
    }


    function getNotes() {
        var db = getDatabase();

        notebookModel.clear();
        db.transaction(function(tx) {
            var rs = tx.executeSql('SELECT * FROM notebook;');
            for (var i = 0; i < rs.rows.length; i++)
                if (rs.rows.item(i).title.toLowerCase().indexOf(searchString) !== -1)
                    root.addNote(rs.rows.item(i).title, rs.rows.item(i).note);
        });
    }

    function remove(title) {
        var db = getDatabase();
        var res="";

        db.transaction(function(tx) {
            //console.log('DELETE FROM notebook WHERE title = "' + title + '";');
            var rs = tx.executeSql('DELETE FROM notebook WHERE title = "' + title + '";');

            if (rs.rowsAffected > 0) {
                res = "OK";
                console.log("Removed from Database");
            }
            else {
                res = "ERROR";
                console.log("Error removing from database");
            }
        });

        return res;
    }

    function addNote(title, note) {
        notebookModel.append({"title": title, "note": note});
    }

    function editNote(index, note) {
        notebookModel.setProperty(index, "note", note);
    }


    Component.onCompleted: {
        console.log("Loaded First Page");
        initialize();
        console.log("Getting notes...");
        getNotes();
    }

    onSearchStringChanged: {
        getNotes()
    }

    ListModel {
        id: notebookModel

    }

    SilicaListView {
        id: notebookList

        width: parent.width; height: parent.height
        anchors.top: parent.top
        model: notebookModel
        currentIndex: -1
        header:  SearchField {
            id: search
            width: parent.width - 170
            anchors.topMargin: 60
            anchors.left: parent.left
            anchors.leftMargin: 200
            placeholderText: "search"

            Binding {
                target: root
                property: "searchString"
                value: search.text.toLowerCase().trim()
            }
        }
        ViewPlaceholder {
                enabled: notebookList.count == 0
                text: qsTr("Please enter your notes");
        }

        PullDownMenu {
            MenuItem {
                text: "Add note"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("Note.qml"), {dataContainer: root, newNote: true})
                    keepSearchFieldFocus = activeFocus
                }
            }
        }


        PushUpMenu {
            spacing: Theme.paddingLarge
            MenuItem {
                text: qsTr("Return to Top")
                onClicked: notebookList.scrollToTop()
            }
        }

        
        delegate: ListItem {
            id: myListItem
            property bool menuOpen: contextMenu != null && contextMenu.parent === myListItem
            property int myIndex: index

            width: ListView.view.width
            height: menuOpen ? contextMenu.height + contentItem.height : contentItem.height

            function remove() {
                var removal = removalComponent.createObject(myListItem);
                ListView.remove.connect(removal.deleteAnimation.start);
                removal.execute(contentItem, "Deleting", function() { root.remove(title); root.getNotes() });
            }

            BackgroundItem {
                id: contentItem

                width: parent.width
                onPressAndHold: {
                    if (!contextMenu)
                        contextMenu = contextMenuComponent.createObject(notebookList)
                    contextMenu.show(myListItem)
                }

                onClicked: {
                    console.log("Clicked " + title)
                    pageStack.push(Qt.resolvedUrl("Note.qml"), {dataContainer: root, noteTitleText: title, noteText: notebookModel.get(index).note, newNote: false, index: myIndex})
                }

                Label {
                    x: Theme.paddingLarge
                    text: Theme.highlightText(title, searchString, Theme.highlightColor)
                    anchors.verticalCenter: parent.verticalCenter
                    color: contentItem.down || menuOpen ? Theme.highlightColor : Theme.primaryColor
                }
            }


            Component {
                id: removalComponent
                RemorseItem {
                    property QtObject deleteAnimation: SequentialAnimation {
                        PropertyAction { target: myListItem; property: "ListView.delayRemove"; value: true }
                        NumberAnimation {
                            target: myListItem;
                            properties: "height,opacity";
                            to: 0; duration: 300;
                            easing.type: Easing.InOutQuad
                        }
                        PropertyAction { target: myListItem; property: "ListView.delayRemove"; value: false }
                    }
                    onCanceled: destroy()
                }
            }

            Component {
                id: contextMenuComponent
                ContextMenu {
                    id: menu
                    MenuItem {
                        text: "Delete"
                        onClicked: myListItem.remove()
                    }
                }
            }
        }

        Component.onCompleted: {
            if (keepSearchFieldFocus) {
                forceActiveFocus()
            }
                keepSearchFieldFocus = false
        }
    }

}



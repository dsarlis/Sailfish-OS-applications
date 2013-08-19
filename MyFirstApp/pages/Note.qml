import QtQuick.LocalStorage 2.0
import QtQuick 2.0
import Sailfish.Silica 1.0


Page {

    id: page
    property QtObject dataContainer
    property bool newNote
    property int index
    property string noteTitleText: ""
    property string noteText: ""


    function getDatabase() {
        return LocalStorage.openDatabaseSync("Notebook", "1.0", "StorageDatabase", 100000);
    }

    function setNote(title, note) {
        var db = getDatabase();
        var res = "";

        db.transaction(function(tx) {
            var rs;
            if (newNote) {
                rs = tx.executeSql('INSERT INTO notebook VALUES(?,?);', [title, note]);
                dataContainer.addNote(title, note);
            }
            else {
                rs = tx.executeSql('UPDATE notebook SET note="' + note + '" WHERE title = "' + title + '";');
                dataContainer.editNote(index, note);
            }

            if (rs.rowsAffected > 0) {
                res = "OK";
                console.log("Saved to Database");
            }
            else {
                res = "ERROR";
                console.log("Error saving to database");
            }

       });
       return res;
    }


    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: "Save"
                onClicked: {
                    setNote(noteTitle.text, note.text);
                    console.log("Saved note " + noteTitle.text + " with text " + note.text)
                }
            }
            MenuItem {
                text: "Save and Exit"
                onClicked: {
                    setNote(noteTitle.text, note.text);
                    console.log("Saved note " + noteTitle.text + " with text " + note.text);
                    pageStack.pop();
                }
            }
        }

        contentHeight: childrenRect.height

        Component.onCompleted: {
            if (noteTitleText != "") noteTitle.text = noteTitleText
            if (noteText != "") note.text = noteText
        }

        Rectangle {
            width: parent.width
            TextField {
                id: noteTitle
                focus: true
                anchors.top: parent.top
                width: parent.width - 120
                anchors.topMargin: 20
                anchors.left: parent.left
                anchors.leftMargin: 80
                placeholderText: "Title of Note"

                KeyNavigation.tab: note
            }

            TextEdit {
                id: note
                text: focus ? "" : "Insert your note here"
                width: parent.width
                height: parent.height - 120
                anchors.top: noteTitle.bottom
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingLarge
                color: Theme.primaryColor
                wrapMode: TextEdit.WordWrap
                KeyNavigation.tab: noteTitle
            }
        }
    }

}

import QtQuick.LocalStorage 2.0
import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    id: deleteMultiple
    property QtObject dataContainer
    property QtObject notebookModel

    function getNotes() {
        var db = dataContainer.getDatabase();

        notebookModel.clear();
        db.transaction(function(tx) {
            var rs = tx.executeSql('SELECT * FROM notebook;');
            for (var i = 0; i < rs.rows.length; i++)
                deleteMultiple.addNote(rs.rows.item(i).title, rs.rows.item(i).note);
        });
    }

    function remove() {
        var db = dataContainer.getDatabase();
        var res="";
        var title="";
        var rs;

        db.transaction(function(tx) {
            for (var i=0; i<helper.count; i++) {
                title = helper.get(i).title;
                rs = tx.executeSql('DELETE FROM notebook WHERE title = "' + title + '";');
            }

        });
        return res;
    }

    function addNote(title, note) {
        notebookModel.append({"title": title, "note": note});
    }

    function findIndex(title, helper) {
        for (var i = 0; i<helper.count; i++)
            if (title === helper.get(i).title)
                return i;
    }

    Component.onCompleted: {
        getNotes()
    }

    ListModel {
        id: notebookModel
    }

    ListModel {
        id: helper
    }

    SilicaListView {
        id: notebookList

        width: parent.width; height: parent.height
        anchors.top: parent.top
        header: PageHeader {
                }
        model: notebookModel

        PullDownMenu {
            MenuItem {
                text: "Delete Selected"
                onClicked: {
                    remove();
                    dataContainer.getNotes();
                    pageStack.pop();
                }
            }
        }

        delegate: ListItem {
            id: myListItem
            property int myIndex: index

            width: ListView.view.width
            height: contentItem.height

            BackgroundItem {
                id: contentItem

                width: parent.width

                Label {
                    id: label
                    x: Theme.paddingLarge
                    text: title
                    anchors.verticalCenter: parent.verticalCenter
                }

                Switch {
                    id: selected
                    property bool flag: false

                    anchors.right: parent.right
                    anchors.rightMargin: Theme.paddingLarge
                    anchors.verticalCenter: parent.verticalCenter
                    onCheckedChanged: {
                        if (!flag) {
                            flag = true
                            helper.append({"title": title, "note": notebookModel.get(index).note});
                            console.log("Checked " + title);
                        }
                        else {
                            flag = false
                            var curr = findIndex(title, helper);
                            helper.remove(curr);
                            console.log("Unchecked " + title);
                        }
                    }
                }
            }
         }
    }
}

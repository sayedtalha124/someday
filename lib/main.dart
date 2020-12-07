import 'package:flutter/material.dart';

import 'db_provider.dart';
import 'notes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        darkTheme: ThemeData.dark(),
        theme: ThemeData(
            primarySwatch: Colors.blue,
            buttonTheme: ButtonThemeData(
              buttonColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(13)),
              ),
              textTheme: ButtonTextTheme.normal,
            )),
        home: TodoList());
  }
}

class TodoList extends StatefulWidget {
  @override
  createState() => TodoListState();
}

class TodoListState extends State<TodoList> {
  void _promptRemoveTodoItem(Notes note) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('Mark "${note.title}" as done?'),
              actions: <Widget>[
                FlatButton(
                    child: Text('CANCEL'),
                    onPressed: () => Navigator.of(context).pop()),
                FlatButton(
                    child: Text('MARK AS DONE'),
                    onPressed: () {
                      //   _removeTodoItem(index);
                      DBProvider.da.deleteNote(note.id);
                      Navigator.of(context).pop();
                      setState(() {});
                    })
              ]);
        });
  }

  Widget buildList(snapshot) {
    return ListView.builder(
      itemCount: snapshot.data.length,
      itemBuilder: (BuildContext context, int index) {
        Notes item = snapshot.data[index];
        return ListTile(
          title: Text(item.title),
          subtitle: Text(item.desc),
          onTap: () => _editNote(item),
        );
      },
    );
  }

  Widget _buildTodoList2() {
    return FutureBuilder<List<Notes>>(
        future: DBProvider.da.getAllNotes(),
        builder: (BuildContext context, AsyncSnapshot<List<Notes>> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length == 0) {
              return Center(
                  child: Text(
                "No task added!!",
                style: TextStyle(color: Colors.blue, fontSize: 29),
              ));
            } else {
              return buildList(snapshot);
            }
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
              "No task added!!",
              style: TextStyle(color: Colors.blue, fontSize: 29),
            ));
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tasks')),
      body: _buildTodoList2(),
      floatingActionButton: FloatingActionButton(
          onPressed: _pushAddTodoScreen,
          tooltip: 'Add task',
          child: Icon(Icons.add)),
    );
  }

  void _pushAddTodoScreen() {
    var title = new TextEditingController();
    var desc = new TextEditingController();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return Scaffold(
          appBar: AppBar(title: Text('Add a task')),
          body: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    autofocus: true,
                    /*  onChanged: (val) {
                      title = val;
                    },*/
                    controller: title,
                    decoration: InputDecoration(
                        hintText: 'Title',
                        contentPadding: const EdgeInsets.all(16.0)),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter title';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    /*onChanged: (val) {
                      desc = val;
                    },*/
                    controller: desc,
                    autofocus: false,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter note';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        hintText: 'Take a note',
                        contentPadding: const EdgeInsets.all(16.0)),
                  ),
                  Padding(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: RaisedButton(
                        textColor: Colors.white,
                        child: Text(
                          "Done",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            if (desc.text.toString() != null &&
                                title.text.toString() != null) {
                              var notes = Notes(1, title.text.toString(),
                                  desc.text.toString());
                              await DBProvider.da.newTask(notes).then((value) {
                                Navigator.pop(context);
                                setState(() {});
                              });
                            } else {
                              print("not null");
                            }
                          } else {
                            print("not validate");
                          }
                        },
                      ),
                    ),
                    padding: EdgeInsets.all(20),
                  ),
                ],
              )));
    }));
  }

  _editNote(Notes item) {
    List<bool> _list = [true, false, true, false];
    var title = new TextEditingController();
    var desc = new TextEditingController();
    title.text = item.title;
    desc.text = item.desc;
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return Scaffold(
          appBar: AppBar(title: Text('Edit task')),
          body: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    autofocus: true,
                    controller: title,
                    decoration: InputDecoration(
                        hintText: 'Title',
                        contentPadding: const EdgeInsets.all(16.0)),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter title';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    /*onChanged: (val) {
                      desc = val;
                    },*/
                    controller: desc,
                    autofocus: false,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter note';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        hintText: 'Take a note',
                        contentPadding: const EdgeInsets.all(16.0)),
                  ),
                  Row(
                    children: [
                      Padding(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: RaisedButton(
                            textColor: Colors.white,
                            child: Text(
                              "Done",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                if (desc.text.toString() != null &&
                                    title.text.toString() != null) {
                                  var notes = Notes(
                                      item.id,
                                      title.text.toString(),
                                      desc.text.toString());
                                  await DBProvider.da
                                      .update(notes)
                                      .then((value) {
                                    print(value);
                                    Navigator.pop(context);
                                    setState(() {});
                                  });
                                } else {
                                  print("not null");
                                }
                              } else {
                                print("not validate");
                              }
                            },
                          ),
                        ),
                        padding: EdgeInsets.all(20),
                      ),
                      Padding(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: RaisedButton.icon(
                            color: Colors.red,
                            textColor: Colors.white,
                            icon: Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                            ),
                            label: Text(
                              "Delete",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              DBProvider.da.deleteNote(item.id);
                              Navigator.of(context).pop();
                              setState(() {});
                            },
                          ),
                        ),
                        padding: EdgeInsets.all(20),
                      ),
                    ],
                  )
                ],
              )));
    }));
  }
}

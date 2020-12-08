import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'db_provider.dart';
import 'new_task_screen.dart';
import 'notes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        darkTheme: ThemeData(
          brightness: Brightness.dark,
        ),
        theme: ThemeData(
            primarySwatch: Colors.blue,
            brightness: Brightness.light,
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

  Widget buildList2(snapshot) {
    List<Notes> list = snapshot.data.reversed.toList();
    return Container(
        margin: const EdgeInsets.fromLTRB(5.0, 10, 5.0, 0),
        child: StaggeredGridView.countBuilder(
          crossAxisCount: 4,
          addRepaintBoundaries: true,
          itemCount: list.length,
          itemBuilder: (BuildContext context, int index) {
            Notes item = list[index];

            return Container(
              padding: const EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(6)),
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: ListTile(
                  tileColor: Colors.transparent,
                  title: Text(item.title),
                  subtitle: Text(item.desc),
                  onTap: () => _pushAddTodoScreen(item),
                ),
              ),
            );
          },
          staggeredTileBuilder: (int index) => StaggeredTile.fit(2),
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
        ),
        color: Colors.transparent);
  }

  Widget _buildTodoList2(context) {
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
              return buildList2(snapshot);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
      ),
      body: _buildTodoList2(context),
      floatingActionButton: FloatingActionButton(
          onPressed: _pushAddTodoScreen,
          tooltip: 'Add task',
          child: Icon(Icons.add)),
    );
  }

  void _pushAddTodoScreen([Notes notes]) async {
    var title;
    var isNew;
    if (notes == null) {
      title = 'Add a task';
      isNew = true;
    } else {
      isNew = false;
      title = 'Edit task';
    }
    final result =
        await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return NewTodo(title, isNew, notes);
    }));
    if (result != null) {
      setState(() {});
    }
  }

  _editNote(Notes item) {
    final _formKey = GlobalKey<FormState>();

    List<bool> _list = [true, false, true, false];
    var title = new TextEditingController();
    var desc = new TextEditingController();
    title.text = item.title;
    desc.text = item.desc;
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return Scaffold(
          appBar: AppBar(title: Text('Edit task')),
          body: SingleChildScrollView(
            child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      maxLength: 50,
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
                      keyboardType: TextInputType.multiline,
                      maxLength: null,
                      maxLines: null,
                      textInputAction: TextInputAction.newline,
                      textCapitalization: TextCapitalization.sentences,
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
                )),
          ));
    }));
  }
}

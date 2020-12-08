import 'package:flutter/material.dart';

import 'db_provider.dart';
import 'notes.dart';

class NewTodo extends StatefulWidget {
  final String title;
  final bool isNew;
  final Notes notes;

  NewTodo(this.title, this.isNew, [this.notes]);

  @override
  _NewTodoState createState() => _NewTodoState();
}

class _NewTodoState extends State<NewTodo> {
  @override
  void initState() {
    super.initState();
    if (!widget.isNew) {
      notes = widget.notes;

      title.text = notes.title;
      desc.text = notes.desc;
    }
  }

  final _formKey = GlobalKey<FormState>();

  var title = new TextEditingController();
  var desc = new TextEditingController();
  Notes notes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: SingleChildScrollView(
          child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  TextFormField(
                    autofocus: true,
                    textCapitalization: TextCapitalization.sentences,
                    controller: title,
                    maxLength: 50,
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
                  widget.isNew == true
                      ? Padding(
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
                                    await DBProvider.da
                                        .newTask(notes)
                                        .then((value) {
                                      Navigator.pop(context, 'catch');
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
                        )
                      : Padding(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Align(
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
                                        var note = Notes(
                                            notes.id,
                                            title.text.toString(),
                                            desc.text.toString());
                                        await DBProvider.da
                                            .update(note)
                                            .then((value) {
                                          Navigator.pop(context, "console");
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
                              Align(
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
                                    DBProvider.da.deleteNote(notes.id);
                                    Navigator.pop(context, "console");
                                  },
                                ),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(20),
                        ),
                ],
              )),
        ));
  }
}

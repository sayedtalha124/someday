import 'dart:convert';

import 'package:someday/sql_helper.dart';

Notes clientFromJson(String str) {
  final jsonData = json.decode(str);
  return Notes.fromMap(jsonData);
}

String clientToJson(Notes data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class Notes {
  String title;
  String desc;
  int id;

  Notes(this.id, this.title, this.desc);

  Map<String, dynamic> toMap() => {
        "id": id,
        "title": title,
        "desc": desc,
      };

  Notes.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    title = map[columnTitle];
    desc = map[columnDesc];
  }
}

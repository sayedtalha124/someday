import 'package:path/path.dart';
import 'package:someday/sql_helper.dart';
import 'package:sqflite/sqflite.dart';

import 'notes.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider da = DBProvider._();
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await initDB();
    return _database;
  }

  initDB() async {
    return await openDatabase(join(await getDatabasesPath(), 'someday.db'),
        version: 1,
        onOpen: (db) {}, onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE $tableTodo ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
          "title TEXT,"
          "desc TEXT"
          ")");
    });
  }

  Future<List<Notes>> getAllNotes() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query(tableTodo);

    return List.generate(maps.length, (i) {
      return Notes(
        maps[i]['id'],
        maps[i]['title'],
        maps[i]['desc'],
      );
    });
  }

  Future<int> newTask(Notes notes) async {
    final db = await database;
    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM $tableTodo");
    int id = table.first["id"];
    var raw = db.rawInsert(
        "INSERT Into $tableTodo (id,title,desc)"
        " VALUES (?,?,?)",
        [id, notes.title, notes.desc]);

    return raw;
  }

  deleteNote(int id) async {
    final db = await database;
    db.delete("$tableTodo", where: "id = ?", whereArgs: [id]);
  }

  Future<int> update(Notes notes) async {
    final db = await database;

    return await db.update(
      tableTodo,
      notes.toMap(),
      where: "id = ?",
      whereArgs: [notes.id],
    );
  }
}

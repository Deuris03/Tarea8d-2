// ignore_for_file: file_names, depend_on_referenced_packages
/*
Nombre: Deuris Andres Estevez Bueno
Matricula: 2022-0233
*/

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'registro.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  late Database _db;

  DatabaseHelper._();

  factory DatabaseHelper() => _instance;

  Future<void> initDB() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'registro.db');
    _db = await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE registro (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        date TEXT,
        audioPath TEXT, 
        photoPath TEXT
      )
    ''');
  }

  Future<int> insertRegistro(Registro registro) async {
    return await _db.insert('registro', registro.toMapExceptId());
  }

  Future<List<Registro>> retrieveRegistros() async {
    final List<Map<String, dynamic>> registroMaps =
        await _db.query('registro', orderBy: 'date');
    return registroMaps.map((registroMap) => Registro.fromMap(registroMap)).toList();
  }

  Future<void> updateRegistro(Registro registro) async {
    await _db.update(
      'registro',
      registro.toMapExceptId(),
      where: 'id = ?',
      whereArgs: [registro.id],
    );
  }

  Future<void> deleteRegistro(int id) async {
    await _db.delete('registro', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllRegistros() async {
    await _db.delete('registro');
  }
}

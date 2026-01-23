import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/medicamento.dart';
import 'medication_seeds.dart';

class DatabaseHelper {
  static DatabaseHelper _instance = DatabaseHelper._internal();
  static DatabaseHelper get instance => _instance;
  static set instance(DatabaseHelper value) => _instance = value;

  static Database? _database;
  static String? testDatabasePath;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      // Opcional: Verificar si necesitamos re-sembrar (ej. si el usuario pide 500 y hay 2)
      await _checkAndSeed(_database!);
      return _database!;
    }
    _database = await _initDatabase();
    await _checkAndSeed(_database!);
    return _database!;
  }

  Future<void> _checkAndSeed(Database db) async {
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM medicamentos'));
    if (count != null && count < 500) {
      print('DEBUG: Database count is $count, seeding mass data...');
      await _seedDatabase(db);
    }
  }

  Future<Database> _initDatabase() async {
    final dbPath = testDatabasePath ?? await getDatabasesPath();
    final path = join(dbPath, 'medicamentos.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE medicamentos(
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        para_que_sirve TEXT NOT NULL,
        como_tomar TEXT NOT NULL,
        advertencias TEXT NOT NULL
      )
    ''');

    await _seedDatabase(db);
  }

  Future<void> _seedDatabase(Database db) async {
    // Importación dinámica o desde lista estática
    final batch = db.batch();
    for (var m in medicationSeeds) {
      batch.insert('medicamentos', m.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit();
  }

  Future<Medicamento?> getMedicamentoById(String id) async {
    final db = await database;
    final result = await db.query(
      'medicamentos',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      final m = result.first;
      return Medicamento(
        id: m['id'] as String,
        nombre: m['nombre'] as String,
        paraQueSirve: m['para_que_sirve'] as String,
        comoTomar: m['como_tomar'] as String,
        advertencias: m['advertencias'] as String,
      );
    }
    return null;
  }

  Future<Medicamento?> getMedicamentoByNombre(String nombre) async {
    final db = await database;
    final result = await db.query(
      'medicamentos',
      where: 'LOWER(nombre) = ?',
      whereArgs: [nombre.toLowerCase().trim()],
    );

    if (result.isNotEmpty) {
      final m = result.first;
      return Medicamento(
        id: m['id'] as String,
        nombre: m['nombre'] as String,
        paraQueSirve: m['para_que_sirve'] as String,
        comoTomar: m['como_tomar'] as String,
        advertencias: m['advertencias'] as String,
      );
    }
    return null;
  }

  Future<List<Medicamento>> getAllMedicamentos() async {
    final db = await database;
    final result = await db.query('medicamentos');

    return result
        .map(
          (m) => Medicamento(
            id: m['id'] as String,
            nombre: m['nombre'] as String,
            paraQueSirve: m['para_que_sirve'] as String,
            comoTomar: m['como_tomar'] as String,
            advertencias: m['advertencias'] as String,
          ),
        )
        .toList();
  }

  Future<void> insertMedicamento(Medicamento medicamento) async {
    final db = await database;
    await db.insert(
      'medicamentos',
      medicamento.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateMedicamento(Medicamento medicamento) async {
    final db = await database;
    await db.update(
      'medicamentos',
      medicamento.toMap(),
      where: 'id = ?',
      whereArgs: [medicamento.id],
    );
  }

  Future<void> deleteMedicamento(String id) async {
    final db = await database;
    await db.delete('medicamentos', where: 'id = ?', whereArgs: [id]);
  }
}

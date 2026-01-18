import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/medicamento.dart';

class DatabaseHelper {
  static DatabaseHelper _instance = DatabaseHelper._internal();
  static DatabaseHelper get instance => _instance;
  static set instance(DatabaseHelper value) => _instance = value;

  static Database? _database;
  static String? testDatabasePath;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    print('DEBUG: Calling getDatabasesPath');
    final dbPath = testDatabasePath ?? await getDatabasesPath();
    print('DEBUG: getDatabasesPath returned: $dbPath');
    final path = join(dbPath, 'medicamentos.db');

    print('DEBUG: Opening database at $path');
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

    // 🔹 Datos iniciales (simulan la BD real)
    await db.insert(
      'medicamentos',
      Medicamento(
        id: 'paracetamol',
        nombre: 'Paracetamol',
        paraQueSirve: 'Sirve para aliviar el dolor y la fiebre.',
        comoTomar: 'Tomar una pastilla cada 8 horas.',
        advertencias: 'No tomar más de 4 pastillas al día.',
      ).toMap(),
    );

    await db.insert(
      'medicamentos',
      Medicamento(
        id: 'ibuprofeno',
        nombre: 'Ibuprofeno',
        paraQueSirve: 'Sirve para reducir el dolor y la inflamación.',
        comoTomar: 'Tomar una pastilla después de comer.',
        advertencias: 'No tomar con el estómago vacío.',
      ).toMap(),
    );
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

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('donnation.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE requests(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        age TEXT NOT NULL,
        gender TEXT NOT NULL,
        needType TEXT NOT NULL,
        bloodGroup TEXT NOT NULL,
        phone TEXT NOT NULL,
        location TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE communes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    // Insérer quelques communes par défaut
    final communesList = [
      "Bab El Oued",
      "Belouizdad",
      "El Harrach",
      "El Madania",
      "Kouba",
      "Hydra",
      "Birkhadem",
      "Bir Mourad Raïs",
      "Mohamed Belouizdad"
    ];
    for (var commune in communesList) {
      await db.insert('communes', {'name': commune});
    }
  }

  // Méthode pour insérer une requête
  Future<int> insertRequest(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('requests', row);
  }

  // Méthode pour récupérer les communes
  Future<List<String>> getCommunes() async {
    final db = await instance.database;
    final result = await db.query('communes', orderBy: 'name');
    return result.map((row) => row['name'] as String).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

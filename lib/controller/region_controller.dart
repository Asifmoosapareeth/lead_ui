import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocationDatabaseHelper {
  static Future<Database> _getDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'location.db'),
      onCreate: (db, version) async {
        // Create tables for states, districts, and cities
        await db.execute(
            '''
          CREATE TABLE state(
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL
          )
          '''
        );

        await db.execute(
            '''
          CREATE TABLE district(
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            state_id INTEGER NOT NULL,
            FOREIGN KEY(state_id) REFERENCES state(id) ON DELETE CASCADE
          )
          '''
        );

        await db.execute(
            '''
          CREATE TABLE city(
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            district_id INTEGER NOT NULL,
            FOREIGN KEY(district_id) REFERENCES district(id) ON DELETE CASCADE
          )
          '''
        );
      },
      version: 1,
    );
  }

  // Insert state
  static Future<void> insertState(int id, String name) async {
    final db = await _getDatabase();
    await db.insert(
      'state',
      {'id': id, 'name': name},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Insert district
  static Future<void> insertDistrict(int id, String name, int stateId) async {
    final db = await _getDatabase();
    await db.insert(
      'district',
      {'id': id, 'name': name, 'state_id': stateId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Insert city
  static Future<void> insertCity(int id, String name, int districtId) async {
    final db = await _getDatabase();
    await db.insert(
      'city',
      {'id': id, 'name': name, 'district_id': districtId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch all states
  static Future<List<Map<String, dynamic>>> fetchStates() async {
    final db = await _getDatabase();
    return await db.query('state');
  }

  // Fetch all districts for a specific state
  static Future<List<Map<String, dynamic>>> fetchDistricts(int stateId) async {
    final db = await _getDatabase();
    return await db.query('district', where: 'state_id = ?', whereArgs: [stateId]);
  }

  // Fetch all cities for a specific district
  static Future<List<Map<String, dynamic>>> fetchCities(int districtId) async {
    final db = await _getDatabase();
    return await db.query('city', where: 'district_id = ?', whereArgs: [districtId]);
  }

  // Clear all data
  static Future<void> clearData() async {
    final db = await _getDatabase();
    await db.delete('city');
    await db.delete('district');
    await db.delete('state');
  }
}

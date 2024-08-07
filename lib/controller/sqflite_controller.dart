import 'package:latlong2/latlong.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../Model/leaddata_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE leads (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        contact_number TEXT,
        is_whatsapp INTEGER,
        email TEXT,
        address TEXT,
        state TEXT,
        district TEXT,
        city TEXT,
        location_coordinates TEXT,
        latitude TEXT,
        longitude TEXT,
        follow_up TEXT,
        follow_up_date TEXT,
        lead_priority TEXT,
        remarks TEXT,
        image_path TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE locations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        latitude REAL,
        longitude REAL,
        timestamp TEXT
      )
    ''');
  }

  // Leads Table Operations
  Future<void> insertLead(Map<String, dynamic> lead) async {
    if (lead.containsKey('follow_up_date') && lead['follow_up_date'] is DateTime) {
      lead['follow_up_date'] = (lead['follow_up_date'] as DateTime).toIso8601String();
    }

    final db = await database;
    await db.insert(
      'leads',
      lead,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getLeads() async {
    final db = await database;
    return await db.query('leads');
  }

  Future<void> deleteLead(int id) async {
    final db = await database;
    await db.delete(
      'leads',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateLead(Lead lead) async {
    final db = await database;
    try {
      await db.update(
        'leads',
        {
          'name': lead.name,
          'contact_number': lead.contactNumber,
          'is_whatsapp': lead.isWhatsapp ? 1 : 0,
          'email': lead.email,
          'address': lead.address,
          'state': lead.state,
          'district': lead.district,
          'city': lead.city,
          'location_coordinates': lead.locationCoordinates,
          'latitude': lead.latitude,
          'longitude': lead.longitude,
          'follow_up': lead.followUp,
          'follow_up_date': lead.followup_date,
          'lead_priority': lead.leadPriority,
          'remarks': lead.remarks,
          'image_path': lead.image_path,
        },
        where: 'id = ?',
        whereArgs: [lead.id],
      );
    } catch (e) {
      print('Error updating lead: $e');
    }
  }

  Future<Lead?> getLeadById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'leads',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Lead.fromJson(maps.first);
    }
    return null;
  }

  Future<void> printAllLeads() async {
    final db = await database;
    final List<Map<String, dynamic>> leads = await db.query('leads');

    for (var lead in leads) {
      print('Lead ID: ${lead['id']}');
      print('Name: ${lead['name']}');
      print('Contact Number: ${lead['contact_number']}');
      print('Is WhatsApp: ${lead['is_whatsapp']}');
      print('Email: ${lead['email']}');
      print('Address: ${lead['address']}');
      print('State: ${lead['state']}');
      print('District: ${lead['district']}');
      print('City: ${lead['city']}');
      print('Location Coordinates: ${lead['location_coordinates']}');
      print('Latitude: ${lead['latitude']}');
      print('Longitude: ${lead['longitude']}');
      print('Follow Up: ${lead['follow_up']}');
      print('Lead Priority: ${lead['lead_priority']}');
      print('Remarks: ${lead['remarks']}');
      print('Image Path: ${lead['image_path']}');
      print('--------------------------------------');
    }
  }

  // Locations Table Operations
  Future<void> insertLocation(double latitude, double longitude, String timestamp) async {
    final db = await database;
    await db.insert(
      'locations',
      {
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getLocations() async {
    final db = await database;
    return await db.query('locations');
  }

  Future<void> deleteLocation(int id) async {
    final db = await database;
    await db.delete(
      'locations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<LatLng?> getLatestCoordinates() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'locations',
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      final latitude = maps.first['latitude'] as double;
      final longitude = maps.first['longitude'] as double;
      return LatLng(latitude, longitude);
    }
    return null;
  }
}
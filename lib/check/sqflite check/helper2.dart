// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
//
// import '../../Model/leaddata_model.dart';
//
//
// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   factory DatabaseHelper() => _instance;
//   DatabaseHelper._internal();
//
//   static Database? _database;
//
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }
//
//   Future<Database> _initDatabase() async {
//     final path = join(
//         await getDatabasesPath(), 'leads.db');
//     print('Opening database at $path');
//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: (db, version) {
//         return db.execute(
//           'CREATE TABLE leads(id INTEGER PRIMARY KEY AUTOINCREMENT, '
//               'name TEXT, '
//               'contact_number TEXT,'
//               ' is_whatsapp TEXT,'
//               ' email TEXT, '
//               'address TEXT,'
//               ' state TEXT, '
//               'district TEXT, '
//               'city TEXT, '
//               'location_coordinates TEXT, '
//               'latitude TEXT,'
//               ' longitude TEXT,'
//               ' follow_up TEXT,'
//           'follow_up_date TEXT,'
//               'lead_priority TEXT,'
//               ' remarks TEXT,'
//               ' image_path TEXT )',
//         );
//       },
//     );
//   }
//   //
//   // Future<void> insertLead(Map<String, dynamic> lead) async {
//   //   // if (lead['is_whatsapp'] is bool) {
//   //   //   lead['is_whatsapp'] = lead['is_whatsapp'] ? 1 : 0;
//   //   // }
//   //   //
//   //   // // Convert DateTime to String
//   //   // if (lead['follow_up_date'] is DateTime) {
//   //   //   lead['follow_up_date'] = (lead['follow_up_date'] as DateTime).toIso8601String();
//   //   // }
//   //   final db = await database;
//   //   // if (lead['follow_up_date'] is DateTime) {
//   //   //   lead['follow_up_date'] = (lead['follow_up_date'] as DateTime).toIso8601String();
//   //   // }
//   //   await db.insert(
//   //     'leads',
//   //     lead,
//   //     conflictAlgorithm: ConflictAlgorithm.replace,
//   //   );
//   // }
//   Future<void> insertLead(Map<String, dynamic> lead) async {
//     if (lead.containsKey('follow_up_date') &&
//         lead['follow_up_date'] is DateTime) {
//       lead['follow_up_date'] =
//           (lead['follow_up_date'] as DateTime).toIso8601String();
//     }
//     // lead['follow_up_date'] = ;
//
//     final db = await database;
//     await db.insert(
//       'leads',
//       lead,
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }
//
//
//   Future<List<Map<String, dynamic>>> getLeads() async {
//     final db = await database;
//     final List<Map<String, dynamic>> leads = await db.query('leads');
//
//     // Convert int to bool
//     // for (var lead in leads) {
//     //   lead['is_whatsapp'] = (lead['is_whatsapp'] == 1);
//     // }
//
//     // // Convert String to DateTime
//     // for (var lead in leads) {
//     //   if (lead['follow_up_date'] != null) {
//     //     lead['follow_up_date'] = DateTime.tryParse(lead['follow_up_date']);
//     //   }
//     // }
//
//     return leads;
//   }
//
//   // Future<void> updateLead(int id, Map<String, dynamic> lead) async {
//   //   final db = await database;
//   //   await db.update(
//   //     'leads',
//   //     lead,
//   //     where: 'id = ?',
//   //     whereArgs: [id],
//   //   );
//   // }
//
//   Future<List<Map<String, dynamic>>> getAllLeads() async {
//     final db = await database;
//     return await db.query('leads');
//
//   }
//
//   Future<void> deleteLead(int id) async {
//     final db = await database;
//     await db.delete(
//       'leads',
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }
//   // Future<void> updateLead(int id, Map<String, dynamic> lead) async {
//   //   final db = await database;
//   //   await db.update(
//   //     'leads',
//   //     lead,
//   //     where: 'id = ?',
//   //     whereArgs: [id],
//   //   );
//   // }
//
//   Future<void> printAllLeads() async {
//     final db = await database;
//     final List<Map<String, dynamic>> leads = await db.query('leads');
//
//     for (var lead in leads) {
//
//       print('Lead ID: ${lead['id']}');
//       print('Name: ${lead['name']}');
//       print('Contact Number: ${lead['contact_number']}');
//       print('Is WhatsApp: ${lead['is_whatsapp']}');
//       print('Email: ${lead['email']}');
//       print('Address: ${lead['address']}');
//       print('State: ${lead['state']}');
//       print('District: ${lead['district']}');
//       print('City: ${lead['city']}');
//       print('Location Coordinates: ${lead['location_coordinates']}');
//       print('Latitude: ${lead['latitude']}');
//       print('Longitude: ${lead['longitude']}');
//       print('Follow Up: ${lead['follow_up']}');
//       print('Lead Priority: ${lead['lead_priority']}');
//       print('Remarks: ${lead['remarks']}');
//       print('Image Path: ${lead['image_path']}');
//       print('--------------------------------------');
//     }
//   }
//
//   Future<void> updateLead(Lead lead) async {
//     final db = await database;
//
//     try {
//       await db.update(
//         'leads',
//         {
//           'name': lead.name,
//           'contact_number': lead.contactNumber,
//           'is_whatsapp': lead.isWhatsapp ? 1 : 0,
//           'email': lead.email,
//           'address': lead.address,
//           'state': lead.state,
//           'district': lead.district,
//           'city': lead.city,
//           'location_coordinates': lead.locationCoordinates,
//           'latitude': lead.latitude,
//           'longitude': lead.longitude,
//           'follow_up': lead.followUp,
//           'follow_up_date': lead.followup_date,
//           'lead_priority': lead.leadPriority,
//           'remarks': lead.remarks,
//           'image_path': lead.image_path,
//         },
//         where: 'id = ?',
//         whereArgs: [lead.id],
//       );
//     } catch (e) {
//       print('Error updating lead: $e');
//     }
//   }
//
//
//   Future<Lead?> getLeadById(int id) async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query(
//       'leads',
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//
//     if (maps.isNotEmpty) {
//       return Lead.fromJson(maps.first);
//     }
//     return null;
//   }
//
//
// }
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
//
// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   factory DatabaseHelper() => _instance;
//   DatabaseHelper._internal();
//
//   static Database? _database;
//
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }
//
//   Future<Database> _initDatabase() async {
//     final path = join(await getDatabasesPath(), 'leads.db');
//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: (db, version) {
//         return db.execute(
//           'CREATE TABLE leads('
//               'id INTEGER PRIMARY KEY AUTOINCREMENT,'
//               'name TEXT, '
//               'contact_number TEXT, '
//               'is_whatsapp INTEGER, '
//               'email TEXT, '
//               'address TEXT, '
//               'state TEXT, '
//               'district TEXT, '
//               'city TEXT, '
//               'location_coordinates TEXT, '
//               'latitude TEXT, '
//               'longitude TEXT, '
//               'follow_up TEXT, '
//               'lead_priority TEXT, '
//               'remarks TEXT, '
//               'image_path TEXT)',
//         );
//       },
//     );
//   }
//
//   Future<void> insertLead(Map<String, dynamic> lead) async {
//     final db = await database;
//     // Ensure correct type conversion
//     if (lead['is_whatsapp'] is bool) {
//       lead['is_whatsapp'] = lead['is_whatsapp'] ? 1 : 0;
//     }
//     // Insert the lead into the database
//     await db.insert(
//       'leads',
//       lead,
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }
//
//   Future<List<Map<String, dynamic>>> getLeads() async {
//     final db = await database;
//     try {
//       final List<Map<String, dynamic>> leads = await db.query('leads');
//       // Convert int to bool
//       for (var lead in leads) {
//         lead['is_whatsapp'] = (lead['is_whatsapp'] == 1);
//       }
//       return leads;
//     } catch (e) {
//       print('Error fetching leads: $e');
//       return [];
//     }
//   }
//
//   Future<List<Map<String, dynamic>>> getAllLeads() async {
//     final db = await database;
//     try {
//       return await db.query('leads');
//     } catch (e) {
//       print('Error fetching all leads: $e');
//       return [];
//     }
//   }
//
//   Future<void> deleteLead(int id) async {
//     final db = await database;
//     try {
//       await db.delete(
//         'leads',
//         where: 'id = ?',
//         whereArgs: [id],
//       );
//     } catch (e) {
//       print('Error deleting lead: $e');
//     }
//   }
//
//   Future<void> printAllLeads() async {
//     final db = await database;
//     try {
//       final List<Map<String, dynamic>> leads = await db.query('leads');
//       for (var lead in leads) {
//         print('Lead ID: ${lead['id']}');
//         print('Name: ${lead['name']}');
//         print('Contact Number: ${lead['contact_number']}');
//         print('Is WhatsApp: ${lead['is_whatsapp']}');
//         print('Email: ${lead['email']}');
//         print('Address: ${lead['address']}');
//         print('State: ${lead['state']}');
//         print('District: ${lead['district']}');
//         print('City: ${lead['city']}');
//         print('Location Coordinates: ${lead['location_coordinates']}');
//         print('Latitude: ${lead['latitude']}');
//         print('Longitude: ${lead['longitude']}');
//         print('Follow Up: ${lead['follow_up']}');
//         print('Lead Priority: ${lead['lead_priority']}');
//         print('Remarks: ${lead['remarks']}');
//         print('Image Path: ${lead['image_path']}');
//         print('--------------------------------------');
//       }
//     } catch (e) {
//       print('Error printing leads: $e');
//     }
//   }
// }

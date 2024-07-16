// import 'package:riverpod/riverpod.dart';
// import 'package:dio/dio.dart';
// import '../Model/leaddata_model.dart';
// final leadDataProvider = FutureProvider<List<Lead>>((ref) async {
//   final dio = Dio();
//   final response = await dio.get("http://127.0.0.1:8000/api/leads");
//   return List<Lead>.from(
//     response.data.map((lead) => Lead.fromJson(lead)),
//   );
// });
// api_services.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/leaddata_model.dart';

class ApiServices {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  Future<List<Lead>> fetchLeads() async {
    final response = await http.get(Uri.parse('$baseUrl/leads'));
    if (response.statusCode == 200) {
      List<dynamic> leadsJson = jsonDecode(response.body);
      return leadsJson.map((json) => Lead.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch leads: ${response.statusCode}');
    }
  }

  Future<void> deleteLead(int leadId) async {
    final response = await http.delete(Uri.parse('$baseUrl/leads/$leadId'));
    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    } else {
      throw Exception('Failed to delete lead: ${response.statusCode}');
    }
  }
}

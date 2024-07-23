
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/leaddata_model.dart';
import '../constants/globals.dart';

class ApiServices {


  Future<List<Lead>> fetchLeads() async {
    final response = await http.get(Uri.parse('$baseURL/leads'));
    if (response.statusCode == 200) {
      List<dynamic> leadsJson = jsonDecode(response.body);
      return leadsJson.map((json) => Lead.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch leads: ${response.statusCode}');
    }
  }

  Future<void> deleteLead(int leadId) async {
    final response = await http.delete(Uri.parse('$baseURL/leads/$leadId'));
    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    } else {
      throw Exception('Failed to delete lead: ${response.statusCode}');
    }
  }
}

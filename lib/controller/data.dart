
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/follow_up_date.dart';
import '../Model/leaddata_model.dart';
import '../constants/globals.dart';

class ApiServices {

  //
  // Future<List<Lead>> fetchLeads() async {
  //   final response = await http.get(Uri.parse('$baseURL/leads'));
  //   if (response.statusCode == 200) {
  //     List<dynamic> leadsJson = jsonDecode(response.body);
  //     return leadsJson.map((json) => Lead.fromJson(json)).toList();
  //   } else {
  //     throw Exception('Failed to fetch leads: ${response.statusCode}');
  //   }
  // }
  //
  // Future<void> deleteLead(int leadId) async {
  //   final response = await http.delete(Uri.parse('$baseURL/leads/$leadId'));
  //   if (response.statusCode == 200 || response.statusCode == 204) {
  //     return;
  //   } else {
  //     throw Exception('Failed to delete lead: ${response.statusCode}');
  //   }
  // }
  // Future<List<FollowUpDate>> fetchFollowUpDates(Lead lead) async {
  //   final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/follow-up-dates/${lead.id}'));
  //
  //   if (response.statusCode == 200) {
  //     List jsonResponse = json.decode(response.body);
  //     return jsonResponse.map((data) => FollowUpDate.fromJson(data)).toList();
  //   } else {
  //     throw Exception('Failed to load follow-up dates');
  //   }
  // }

}

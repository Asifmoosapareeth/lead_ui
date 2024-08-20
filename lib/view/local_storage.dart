import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Model/leaddata_model.dart';
import '../../view/add_data.dart';
import '../controller/sqflite_controller.dart';
import 'package:http/http.dart' as http;


class LeadsListPage extends StatefulWidget {
  @override
  _LeadsListPageState createState() => _LeadsListPageState();
}

class _LeadsListPageState extends State<LeadsListPage> {
  late Future<List<Map<String, dynamic>>> _leads;



  @override
  void initState() {
    super.initState();
    _fetchLeads();
  }

  void _showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  Future<void> _fetchLeads() async {
    setState(() {
      _leads = DatabaseHelper().getLeads();
    });
  }
  // void _updateLead(int leadId, Map<String, dynamic> updatedLead) async {
  //   await DatabaseHelper().updateLead(leadId, updatedLead);
  //   _fetchLeads(); // Refresh the leads list after updating
  // }


  void _deleteLead(int leadId) async {
    await DatabaseHelper().deleteLead(leadId);

    setState(() {
      _fetchLeads();
    });

  }
  // Future<void> syncLeads() async {
  //   final db = await DatabaseHelper().database;
  //   final List<Map<String, dynamic>> leads = await db.query(
  //     'leads',
  //     where: 'synced = ?',
  //     whereArgs: [0], // Fetch only unsynced leads
  //   );
  //
  //   for (var lead in leads) {
  //     final response = await http.post(
  //       Uri.parse('http://yourserver/api/leads'),
  //       body: lead,
  //     );
  //
  //     if (response.statusCode == 201) {
  //       // Mark lead as synced
  //       await db.update(
  //         'leads',
  //         {'synced': 1},
  //         where: 'id = ?',
  //         whereArgs: [lead['id']],
  //       );
  //     } else {
  //       // Handle failed sync
  //       print('Failed to sync lead with id ${lead['id']}');
  //     }
  //   }
  // }
  // void _syncLeads() async {
  //   await syncLeads();
  //   _fetchLeads(); // Refresh the leads list after syncing
  // }

  Future<void> _submitForm(Map<String, dynamic> lead) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      print("Token not found");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Authentication token not found')));
      return;
    }

    var request = http.MultipartRequest(
        'POST', Uri.parse('http://127.0.0.1:8000/api/leads'));

    request.headers['Authorization'] = 'Bearer $token';

    // Add form fields
    request.fields['name'] = lead['name'] ?? "";
    request.fields['contact_number'] = lead['contact_number'] ?? "";
    request.fields['is_whatsapp'] = lead['is_whatsapp']?.toString() ?? "0";
    request.fields['email'] = lead['email'] ?? "";
    request.fields['address'] = lead['address'] ?? "";
    request.fields['state'] = lead['state'] ?? "";
    request.fields['district'] = lead['district'] ?? "";
    request.fields['city'] = lead['city'] ?? "";
    request.fields['location_coordinates'] = lead['location_coordinates'] ?? "";
    request.fields['latitude'] = lead['latitude']?.toString() ?? "";
    request.fields['longitude'] = lead['longitude']?.toString() ?? "";
    request.fields['follow_up'] = lead['follow_up'] ?? "";
    request.fields['follow_up_date'] = lead['follow_up_date'] ?? "";
    request.fields['lead_priority'] = lead['lead_priority'] ?? "";

    // Check if image_path is not null or empty before adding it to the request
    if (lead['image_path'] != null && lead['image_path'].isNotEmpty) {
      var file = await http.MultipartFile.fromPath('image_path', lead['image_path']);
      request.files.add(file);
    }

    try {
      var response = await request.send();

      if (response.statusCode == 201 || response.statusCode == 200) {

        DatabaseHelper().deleteLead(lead['id']);
        _fetchLeads();
        print("Request successful");
        _showAlertDialog(context, 'Success', 'Form submitted successfully');


      } else {
        var responseBody = await response.stream.bytesToString();
        print("Request failed with status: ${response.statusCode}");
        print("Response body: $responseBody");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Form submission failed')));
        _showAlertDialog(context, 'Error', 'Form submission failed');
      }
    } catch (e) {
      print("Request failed with error: $e");
      _showAlertDialog(context, 'No Internet', 'Turn on your Internet Connection');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leads List'),
        actions: [
          IconButton(
              icon: Icon(Icons.sync),
              onPressed:(){
                _fetchLeads();
              }
            //_syncLeads,
          ),
        ],

      ),
      body: RefreshIndicator(
        onRefresh: ()=>_fetchLeads(),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _leads,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No leads found'));
            } else {
              final leads = snapshot.data!;
              return ListView.builder(
                itemCount: leads.length,
                itemBuilder: (context, index) {
                  final lead = leads[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(lead['id'].toString()),
                          Text(lead['name'] ?? 'No name',style: TextStyle(fontWeight: FontWeight.bold),),
                          Text('Contact: ${lead['is_whatsapp'] ?? 'No contact'}'),
                          Text(lead['contact_number']),
                          Text(lead['email'] ?? 'No email'),
                          Text(lead['address'] ?? 'No address'),
                          Text(lead['state'] ?? 'No state'),
                          Text(lead['district'] ?? 'No district'),
                          Text(lead['city'] ?? 'No city'),
                          Text(lead['location_coordinates'] ?? 'No location_coordinates'),
                          Text(lead['latitude'] ?? 'No latitude '),
                          Text(lead['longitude'] ?? 'No longitude '),
                          Text(lead['follow_up'] ?? 'No follow_up'),
                          Text(lead['lead_priority'] ?? 'No lead_priority'),
                          Text(lead['remarks'] ?? 'No remarks'),
                          Text(lead['image_path'] ?? 'No image_path'),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  // Fetch all leads
                                  // List<Map<String, dynamic>> leadMaps = await DatabaseHelper().getLeads();
                                  // List<Lead> leads = leadMaps.map((map) => Lead.fromJson(map)).toList();
                                  //
                                  // // Access the specific lead by index
                                  // Lead leadToUpdate = leads[index];
                                  //
                                  // // Update the data
                                  // await DatabaseHelper().updateLead(leadToUpdate);
                                  //
                                  // // Fetch the updated data
                                  // Lead? updatedLead = await DatabaseHelper().getLeadById(leadToUpdate.id);
                                  //
                                  // if (updatedLead != null) {
                                  //   // Navigate to DataCollection with updated lead
                                  //   Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //       builder: (context) => Editpage(lead: updatedLead),
                                  //     ),
                                  //   );
                                  // }
                                  _submitForm(lead);

                                },
                                icon: Icon(Icons.send),
                              ),
                              IconButton(

                                onPressed: () {
                                  int leadId = lead['id'];
                                  _deleteLead(leadId);
                                },
                                icon: Icon(Icons.delete),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

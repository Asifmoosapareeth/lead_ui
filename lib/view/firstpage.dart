import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Model/leaddata_model.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  List<Lead> _leads = [];
  Map<String, String> _stateMap = {};

  @override
  void initState() {
    super.initState();
    _fetchLeads();
  }

  Future<void> _fetchLeads() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/leads'));
    if (response.statusCode == 200) {
      setState(() {
        List<dynamic> leadsJson = jsonDecode(response.body);
        _leads = leadsJson.map((json) => Lead.fromJson(json)).toList();
      });
    } else {
      print('Failed to fetch leads: ${response.statusCode}');
    }
  }

  Future<void> _deleteLead(int leadId) async {
    final response = await http.delete(Uri.parse('http://127.0.0.1:8000/api/leads/$leadId'));
    if (response.statusCode == 200 || response.statusCode == 204) {
      setState(() {
        _leads.removeWhere((lead) => lead.id == leadId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lead deleted successfully')),
      );
    } else {
      print('Failed to delete lead: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete lead')),
      );
    }
  }

  // Future<void>_refresh () async{
  //   await _fetchLeads();
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leads List'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchLeads,
        child: _leads.isEmpty
            ? Center(child: Text('No Leads Added'))
            : ListView.builder(
          itemCount: _leads.length,
          itemBuilder: (context, index) {
            final lead = _leads[index];
        
            return Card(
              margin: EdgeInsets.all(8.0),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lead.name,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text('Email: ${lead.email}'),
                        Text('Phone: ${lead.contactNumber}'),
                        Text('Address: ${lead.address}'),
                        Text('State: ${lead.stateName}'),
                        Text('District: ${lead.districtName}'),
                        Text('City: ${lead.cityName}')
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          onPressed: () {
        
                          },
                          icon: Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () {
                            _deleteLead(lead.id);
                          },
                          icon: Icon(Icons.delete),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

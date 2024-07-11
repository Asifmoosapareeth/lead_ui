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
    // _fetchStates();
  }

  Future<void> _fetchLeads() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/leads'));
    if (response.statusCode == 200) {
      setState(() {
        List<dynamic> leadsJson = jsonDecode(response.body);
        _leads = leadsJson.map((json) => Lead.fromJson(json)).toList();
      });
    } else {
      // Handle error scenario
      print('Failed to fetch leads: ${response.statusCode}');
    }
  }

  // Future<void> _fetchStates() async {
  //   final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/states'));
  //   if (response.statusCode == 200) {
  //     List<dynamic> states = jsonDecode(response.body);
  //     setState(() {
  //       _stateMap = Map.fromIterable(states,
  //           key: (state) => state['id'].toString(),
  //           value: (state) => state['name'].toString());
  //     });
  //   } else {
  //     // Handle error scenario
  //     print('Failed to fetch states: ${response.statusCode}');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leads List'),
      ),
      body: _leads.isEmpty
          ? Center(child: Text('No Leads Added'))
          : ListView.builder(
        itemCount: _leads.length,
        itemBuilder: (context, index) {
          final lead = _leads[index];
       //   final stateName = _stateMap[lead.stateId] ?? '';

          return Card(
            margin: EdgeInsets.all(8.0),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
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
                  // Text('State: $stateName'),
                  Text('State: ${lead.stateName}'),
                  Text('District: ${lead.districtName}'),
                  Text('city: ${lead.cityName}')

                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
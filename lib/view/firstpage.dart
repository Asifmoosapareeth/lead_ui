import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lead_enquiry/constants/texticon.dart';
import '../Model/leaddata_model.dart';
import 'package:url_launcher/url_launcher.dart';

import 'add_data.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  List<Lead> _leads = [];

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
  void _openWhatsApp(String phoneNumber) async {
    final Uri whatsappUri = Uri(
      scheme: 'https',
      host: 'wa.me',
      path: phoneNumber,
      queryParameters: {'text': 'Hello'},
    );

    if (await canLaunch(whatsappUri.toString())) {
      await launch(whatsappUri.toString());
    } else {
      throw 'Could not launch $whatsappUri';
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launch(launchUri.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leads List'),
        backgroundColor: Colors.teal,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchLeads,
        child: _leads.isEmpty
            ? Center(child: Text('No Leads Added'))
            : ListView.builder(
          itemCount: _leads.length,
          itemBuilder: (context, index) {
            final lead = _leads[index];

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                shadowColor: Colors.green,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.teal.shade100,
                elevation: 8,
                margin: EdgeInsets.all(8.0),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(lead.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,)),
                            ),
                            SizedBox(height: 10),


                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconText(icon: Icons.phone, text: '${lead.contactNumber}'),
                              IconButton(
                                onPressed: () {
                                  _makePhoneCall(lead.contactNumber.toString());
                                },
                                icon: Icon(Icons.call, color: Colors.green),
                              ),
                                if (lead.isWhatsapp==false)
                              GestureDetector(
                                  onTap: (){
                                    _openWhatsApp(lead.contactNumber.toString());
                                  },
                                  child: Image.asset('asset/logo/whatsp_icon.png',scale: 15,)

                              )
                            ],),

                            IconText(icon: Icons.email, text: '${lead.email}'),
                            IconText(icon: Icons.home, text: lead.address),
                            IconText(icon: Icons.flag, text: 'State: ${lead.stateName}'),
                            IconText(icon: Icons.flag_outlined, text: 'District: ${lead.districtName}'),
                            IconText(icon: Icons.location_city, text: 'City: ${lead.cityName}'),
                            IconText(icon: Icons.map, text: ' ${lead.locationCoordinates}'),
                            IconText(icon: Icons.date_range, text: 'Follow-up date: ${lead.followup_date}'),
                            Divider(color: Colors.grey,height: 25,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                              GestureDetector(
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Editpage(lead: lead), // Pass the lead data
                                      ),
                                    );
                                    _fetchLeads();
                                  },
                                  child: Image.asset('asset/logo/edit_icon.png',scale: 10,)),

                                GestureDetector(
                                    onTap: (){
                                    },
                                    child: Image.asset('asset/logo/delete_icon.png',scale: 10,)),
                            ],)
                          ],
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

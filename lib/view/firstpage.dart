import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lead_enquiry/constants/texticon.dart';
import 'package:lead_enquiry/view/details.dart';
import 'package:lead_enquiry/view/triall2.dart';
import '../Model/follow_up_date.dart';
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


  void _makeEmailCall(String emailAddress) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: emailAddress,
    );

    if (await canLaunch(emailUri.toString())) {
      await launch(emailUri.toString());
    } else {
      throw 'Could not launch $emailUri';
    }
  }

  Future<List<FollowUpDate>> _fetchFollowUpDates(int leadId) async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/follow-up-dates/$leadId'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((json) => FollowUpDate.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load follow-up dates');
    }
  }
  void _showFollowUpDates(BuildContext context, int leadId) async {
    try {
      List<FollowUpDate> followUpDates = await _fetchFollowUpDates(leadId);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Follow Up Dates'),
            content: Container(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: followUpDates.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(followUpDates[index].followUpDates),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to load follow-up dates'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leads List'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchLeads,
        child: _leads.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: _leads.length,
          itemBuilder: (context, index) {
            final lead = _leads[index];

            return GestureDetector(
              onLongPress:
               () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailsPage(lead: lead,),
                  ),
                );
              },
              child: Card(
                color: Colors.teal.shade100,
                margin: EdgeInsets.all(16.0),
                elevation: 15,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [

                          CircleAvatar(
                            backgroundImage: lead.image_path != null
                                ? NetworkImage('http://127.0.0.1:8000/storage/${lead.image_path}')
                                : null,
                            radius: 30,
                            child: lead.image_path == null
                                ? Icon(Icons.person, size: 30) // Replace with any default icon or image
                                : null,
                          )
                          ,
                          SizedBox(width: 20),
                          Text(lead.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () {
                              _makePhoneCall(lead.contactNumber.toString());
                            },
                            icon: Icon(Icons.call,size: 30, color: Colors.green),
                          ),

                          SizedBox(width: 15,),
                          Text(  '${lead.contactNumber}',style: TextStyle(fontSize: 16),),
                          SizedBox(width: 100,),

                          lead.isWhatsapp==true
                              ? GestureDetector(
                            onTap: () {
                              _openWhatsApp(lead.contactNumber.toString());
                            },
                            child: Image.asset('asset/logo/whatsp_icon.png', scale: 15),
                          )
                              : Text(''),
                        ],),
                      ListTile(
                        leading: Icon(Icons.email, color: Colors.blue),
                        title: Text(lead.email ?? 'No email provided'),
                        subtitle: Text('Email'),
                        onTap: () {
                          if (lead.email != null) _makeEmailCall(lead.email!);
                        },
                      ),
                      Card(
                        color: Colors.teal.shade100,


                        shape: RoundedRectangleBorder(

                          borderRadius: BorderRadius.circular(10),

                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.home, color: Colors.grey),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      lead.address,
                                      style: TextStyle(fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.flag, color: Colors.grey),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      lead.stateName,
                                      style: TextStyle(fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.map, color: Colors.grey),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      lead.locationCoordinates,
                                      style: TextStyle(fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Divider(color: Colors.grey, height: 20),
                   SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Editpage(lead: lead),
                                ),
                              );
                            },
                            child: Image.asset('asset/logo/edit_icon.png', scale: 10),
                          ),
                          SizedBox(width: 10),

                          IconButton(
                            onPressed: () => _showFollowUpDates(context, lead.id),
                            icon: Icon(Icons.info, color: Colors.blue),
                          ),

                          SizedBox(width: 10,),
                          GestureDetector(
                            onTap: () {
                              _deleteLead(lead.id);
                            },
                            child: Image.asset('asset/logo/delete_icon.png', scale: 10),
                          ),
                        ],
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
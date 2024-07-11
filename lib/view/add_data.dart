import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class Editpage extends StatefulWidget {
  const Editpage({Key? key}) : super(key: key);

  @override
  State<Editpage> createState() => _EditpageState();
}

class _EditpageState extends State<Editpage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool followUp = false;
  String _location = '';

  List<dynamic> _states = [];
  List<dynamic> _districts = [];
  List<dynamic> _cities = [];

  String? _selectedState;
  String? _selectedDistrict;

  @override
  void initState() {
    super.initState();
    _fetchStates();
  }

  Future<void> _fetchStates() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/states'));
    if (response.statusCode == 200) {
      setState(() {
        _states = jsonDecode(response.body);
        print(response.body);
      });
    }
  }

  Future<void> _fetchDistricts(String stateId) async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/districts/$stateId'));
    if (response.statusCode == 200) {
      setState(() {
        _districts = jsonDecode(response.body);
      });
    }
  }

  Future<void> _fetchCities(String districtId) async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/cities/$districtId'));
    if (response.statusCode == 200) {
      setState(() {
        _cities = jsonDecode(response.body);
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _location = 'Location services are disabled.';
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _location = 'Location permissions are denied';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _location = 'Location permissions are permanently denied';
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _location = 'Lat: ${position.latitude}, Long: ${position.longitude}';
    });

    _formKey.currentState?.fields['location_coordinates']?.didChange(_location);
  }


  Future<void> _submitForm(Map<String, dynamic> formData) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/leads'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(formData),
    );

    if (response.statusCode == 201) {
      // Handle success response
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lead created successfully')),
      );
      setState(() {
        reset();
      });


    } else {
      // Handle error response
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create lead')),
      );
    }
  }
  void reset() {
    _formKey.currentState?.reset();
    setState(() {
      followUp=false;
      _location="";
      _formKey.currentState?.fields['follow_up']?.didChange(null);
      _formKey.currentState?.fields['location_coordinates']?.didChange('');
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lead data'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FormBuilder(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 10,),
                  FormBuilderTextField(
                    name: 'name',
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      labelText: 'Name',
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                  ),
                  SizedBox(height: 13),
                  FormBuilderTextField(
                    name: 'contact_number',
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.phone, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      labelText: 'Contact Number',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.contacts),
                        onPressed: (){},
                      ),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.numeric(),
                      FormBuilderValidators.minLength(10),
                      FormBuilderValidators.maxLength(10),
                    ]),
                  ),
                  SizedBox(height: 5),
                  FormBuilderCheckbox(
                    name: 'is_whatsapp',
                    title: Text('Is this a WhatsApp number?', style: TextStyle(fontSize: 12)),
                    initialValue: false,
                  ),
                  SizedBox(height: 5),
                  FormBuilderTextField(
                    name: 'email',
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      labelText: 'Email (optional)',
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.email(),
                    ]),
                  ),
                  SizedBox(height: 13),
                  FormBuilderTextField(
                    name: 'address',
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.home, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      labelText: 'Address',
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                    maxLines: 4,
                  ),
                  SizedBox(height: 13),
                  FormBuilderDropdown(
                    name: 'state',
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.location_city, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      labelText: 'State',
                    ),
                    items: _states.map((state) => DropdownMenuItem(
                      value: state['id'].toString(),
                      child: Text(state['name']),
                    )).toList(),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                    onChanged: (val) {
                      setState(() {
                        _selectedState = val.toString();
                        _fetchDistricts(_selectedState!);
                        _districts = [];
                        _cities = [];
                      });
                    },
                  ),
                  SizedBox(height: 13),
                  FormBuilderDropdown(
                    name: 'district',
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.location_city, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      labelText: 'District',
                    ),
                    items: _districts.map((district) => DropdownMenuItem(
                      value: district['id'].toString(),
                      child: Text(district['name']),
                    )).toList(),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                    onChanged: (val) {
                      setState(() {
                        _selectedDistrict = val.toString();
                        _fetchCities(_selectedDistrict!);
                        _cities = [];
                      });
                    },
                  ),
                  SizedBox(height: 13),
                  FormBuilderDropdown(
                    name: 'city',
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.location_city, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      labelText: 'City',
                    ),
                    items: _cities.map((city) => DropdownMenuItem(
                      value: city['id'].toString(),
                      child: Text(city['name']),
                    )).toList(),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                  ),
                  SizedBox(height: 13),
                  FormBuilderTextField(
                    name: 'location_coordinates',
                    initialValue: _location,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      labelText: 'Location Coordinates',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.my_location, color: Colors.blue),
                        onPressed: () {
                          setState(() {
                            _getCurrentLocation();
                          });
                          print(_location);
                        },
                      ),
                    ),
                    readOnly: true,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                  ),
                  SizedBox(height: 13),
                  FormBuilderDropdown(
                    name: 'follow_up',
                    initialValue: followUp ? 'Yes' : 'No',
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      labelText: 'Follow-up',
                    ),
                    items: ['Yes', 'No'].map((followUp) => DropdownMenuItem(
                      value: followUp,
                      child: Text(followUp),
                    )).toList(),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                    onChanged: (val) {
                      setState(() {
                        followUp = val == 'Yes';
                      });
                    },
                  ),
                  SizedBox(height: 13),
                  FormBuilderRadioGroup(
                    name: 'lead_priority',
                    decoration: const InputDecoration(
                      labelText: 'Lead Priority',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                    options: ['Hot', 'Warm', 'Cold'].map((priority) => FormBuilderFieldOption(
                      value: priority,
                      child: Text(priority),
                    )).toList(),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.saveAndValidate()) {
                        final formData = _formKey.currentState!.value;
                        _submitForm(formData);
                      }
                    },
                    child: Text('Submit'),
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

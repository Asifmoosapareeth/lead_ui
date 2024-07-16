import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:developer';
import 'package:contacts_service/contacts_service.dart';
import 'package:intl/intl.dart';
import 'package:lead_enquiry/Model/leaddata_model.dart';
import 'package:permission_handler/permission_handler.dart';

class Editpage extends StatefulWidget {
  final Lead? lead;
  const Editpage({Key? key, this.lead}) : super(key: key);

  @override
  State<Editpage> createState() => _EditpageState();
}

class _EditpageState extends State<Editpage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool followUp = false;

  List<dynamic> _states = [];
  List<dynamic> _districts = [];
  List<dynamic> _cities = [];

  String? _selectedState;
  String? _selectedDistrict;
  String? _selectedCity;

  String currentAddress = 'My Address';
  Position? currentPosition;


  @override
  void initState() {
    super.initState();
    _fetchStates();
    if (widget.lead != null) {
      _selectedState = widget.lead!.state;
      _fetchDistricts(widget.lead!.state);
      _fetchCities(widget.lead!.district);

    }
  }

  Future<void> pickContact() async {
    PermissionStatus permissionStatus = await Permission.contacts.request();

    if (permissionStatus.isGranted) {
      Contact? contact = await ContactsService.openDeviceContactPicker();
      if (contact != null && contact.phones!.isNotEmpty) {
        setState(() {
          _formKey.currentState?.fields['contact_number']?.didChange(contact.phones!.first.value);
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contacts permission is required to pick a contact')),
      );
    }
  }

  static Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: 'Please enable Your Location Service');
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location permissions are denied');
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg:
          'Location permissions are permanently denied, we cannot request permissions.');
      return Future.error('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          currentAddress =
          "${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.administrativeArea}";
        });

        _formKey.currentState?.fields['location_coordinates']?.didChange(currentAddress);
      } else {
        log("No address found for the provided coordinates.");
        setState(() {
          currentAddress = "No address available";
        });
      }
    } catch (e) {
      log("Error retrieving address: $e");
      setState(() {
        currentAddress = "Error retrieving address";
      });
    }
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
        _selectedDistrict = widget.lead?.district;
      });
    }
  }

  Future<void> _fetchCities(String districtId) async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/cities/$districtId'));
    if (response.statusCode == 200) {
      setState(() {
        _cities = jsonDecode(response.body);
        _selectedCity=widget.lead?.city;
      });
    }
  }

  Future<void> _submitForm(Map<String, dynamic> formDetails) async {
    Map<String, dynamic> encodableFormDetails = formDetails.map((key, value) {
      if (value is DateTime) {
        return MapEntry(key, value.toIso8601String());
      }
      return MapEntry(key, value);
    });

    if (widget.lead != null) {

      final response = await http.put(
        Uri.parse('http://127.0.0.1:8000/api/leads/${widget.lead!.id}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(encodableFormDetails),
      );

      if (response.statusCode == 200) {
        // Handle success response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lead updated successfully')),
        );
        Navigator.pop(context); // Go back after saving
      } else {
        // Handle error response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update lead')),
        );
      }
    } else {

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/leads'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(encodableFormDetails),
      );

      if (response.statusCode == 201) {
        // Handle success response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lead created successfully')),
        );
        Navigator.pop(context); // Go back after saving
      } else {
        // Handle error response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create lead')),
        );
      }
    }
  }



  void reset() {
    _formKey.currentState?.reset();
    setState(() {
      followUp = false;
      _formKey.currentState?.fields['follow_up']?.didChange(null);
      _formKey.currentState?.fields['location_coordinates']?.didChange('');
      _formKey.currentState?.fields['state']?.didChange('');
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
                  SizedBox(height: 10),
                  FormBuilderTextField(
                    name: 'name',
                    // controller: _nameController,
                    initialValue: widget.lead?.name,
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
                    // controller: _phoneController,
                    initialValue: widget.lead?.contactNumber,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.phone, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      labelText: 'Contact Number',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.contacts),
                        onPressed: () {
                          pickContact();
                        },
                      ),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.minLength(10),
                    ]),
                  ),
                  SizedBox(height: 5),


                  FormBuilderCheckbox(
                    name: 'is_whatsapp',
                    title: Text('Is this a WhatsApp number?',
                        style: TextStyle(fontSize: 12)),
                    initialValue: widget.lead?.isWhatsapp??false,
                  ),
                  SizedBox(height: 5),
                  FormBuilderTextField(
                    name: 'email',
                    // controller: _emailController,
                    initialValue: widget.lead?.email,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      labelText: 'Email (optional)',
                    ),
                    // validator: FormBuilderValidators.compose([
                    //   FormBuilderValidators.email(),
                    // ]),
                  ),
                  SizedBox(height: 13),
                  FormBuilderTextField(
                    name: 'address',
                    // controller: _addressController,
                    initialValue: widget.lead?.address,
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
                    initialValue:  widget.lead?.state,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.location_city, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      labelText: 'State',
                    ),
                    items: _states
                        .map((state) => DropdownMenuItem(
                      value: state['id'].toString(),
                      child: Text(state['name']),
                    ))
                        .toList(),
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
                  initialValue: _selectedDistrict,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.location_city, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      labelText: 'District',
                    ),
                    items: _districts
                        .map((district) => DropdownMenuItem(
                      value: district['id'].toString(),
                      child: Text(district['name']),
                    ))
                        .toList(),
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
                    initialValue: _selectedCity,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.location_city, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      labelText: 'City',
                    ),
                    items: _cities
                        .map((city) => DropdownMenuItem(
                      value: city['id'].toString(),
                      child: Text(city['name']),
                    ))
                        .toList(),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                  ),
                  SizedBox(height: 13),
                  FormBuilderTextField(
                    name: 'location_coordinates',

                   initialValue:   widget.lead?.locationCoordinates,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.location_on, color: Colors.blue),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.my_location, color: Colors.blue),
                        onPressed: () async {
                          Position position = await _determinePosition();
                          setState(() {
                            currentPosition = position;
                            _getAddressFromLatLng(currentPosition!);
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      labelText: 'Location Coordinates',
                    ),
                  ),
                  SizedBox(height: 13),
                  FormBuilderRadioGroup(
                     // initialValue:  widget.lead?.followUp,
                    name: 'follow_up',
                     initialValue: widget.lead?.followUp,
                    options: [
                      FormBuilderFieldOption(value: 'Yes'),
                      FormBuilderFieldOption(value: 'No'),
                    ],
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.assignment_turned_in,
                          color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      labelText: 'Follow-up Required?',
                    ),
                    onChanged: (value) {
                      setState(() {
                        followUp = value == 'Yes';
                      });
                    },
                  ),
                  if (followUp) ...[
                    SizedBox(height: 13),
                    FormBuilderDateTimePicker(
                      name: 'follow_up_date',
                      decoration: const InputDecoration(
                        prefixIcon:
                        Icon(Icons.calendar_today, color: Colors.blue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        labelText: 'Follow-up Date',
                      ),
                      inputType: InputType.date,
                      format: DateFormat('dd-MM-yyyy') ,

                    ),
                  ],
                  SizedBox(height: 13),
                  FormBuilderRadioGroup(
                  initialValue: widget.lead?.leadPriority,
                    name: 'lead_priority',
                    options: [
                      FormBuilderFieldOption(value: 'Low'),
                      FormBuilderFieldOption(value: 'Medium'),
                      FormBuilderFieldOption(value: 'High'),
                    ],
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.priority_high, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      labelText: 'Priority',
                    ),
                  ),
                  SizedBox(height: 13),
                  FormBuilderTextField(
                    name: 'remarks',
                    initialValue: widget.lead?.remarks,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.notes, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      labelText: 'Remarks',
                    ),
                    maxLines: 4,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.saveAndValidate()) {
                        _submitForm(_formKey.currentState!.value);
                      }
                    },

                    child:
                    Text(widget.lead==null?'Submit': 'update'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

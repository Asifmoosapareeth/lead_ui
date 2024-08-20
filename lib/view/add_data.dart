import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
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
import 'package:image_picker/image_picker.dart';
import '../check/helper_sqflite.dart';
import '../check/sqflite check/helper2.dart';
import '../constants/globals.dart';
import '../controller/sqflite_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firstpage.dart';
import 'homepage.dart';

class Editpage extends StatefulWidget {
  final Lead? lead;
  const Editpage({Key? key, this.lead}) : super(key: key);

  @override
  State<Editpage> createState() => _EditpageState();
}

class _EditpageState extends State<Editpage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final followUpDateController = TextEditingController();


  File? _image;
  final picker = ImagePicker();

  bool followUp = false;

  List<dynamic> _states = [];
  List<dynamic> _districts = [];
  List<dynamic> _cities = [];

  String? _selectedState;
  String? _selectedDistrict;
  String? _selectedCity;

  String currentAddress = 'My Address';
  Position? currentPosition;

  // String? latitude;
  // String? longitude;

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
          String phoneNumber = contact.phones!.first.value!;
          String sanitizedPhoneNumber =
          phoneNumber.replaceAll(RegExp(r'\D'), '');
          if (sanitizedPhoneNumber.startsWith('91') &&
              sanitizedPhoneNumber.length > 10) {
            sanitizedPhoneNumber = sanitizedPhoneNumber.substring(2);
          }

          _formKey.currentState!.fields['contact_number']
              ?.didChange(sanitizedPhoneNumber);
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: const Text('Contacts permission is required to pick a contact')),
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
    final response = await http.get(Uri.parse('${baseURL}states'));
    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          _states = jsonDecode(response.body);
        });
      }
    }

  }

  Future<void> _fetchDistricts(String stateId) async {
    final response = await http.get(Uri.parse('${baseURL}districts/$stateId'));
    if (response.statusCode == 200) {
      setState(() {
        _districts = jsonDecode(response.body);
        _selectedDistrict = widget.lead?.district;
      });
    }
  }

  Future<void> _fetchCities(String districtId) async {
    final response = await http.get(Uri.parse('${baseURL}cities/$districtId'));
    if (response.statusCode == 200) {
      setState(() {
        _cities = jsonDecode(response.body);
        // _selectedCity=widget.lead?.city;
      });
    }
  }

  // Future<void> updateForm(Map<String, dynamic> formData) async {
  //
  //   Map<String, dynamic> encodableFormData = formData.map((key, value) {
  //     if (value is DateTime) {
  //       return MapEntry(key, value.toIso8601String());
  //     }
  //     return MapEntry(key, value);
  //
  //   });
  //
  //
  //   final response = await http.put(
  //     Uri.parse('http://127.0.0.1:8000/api/leads/${widget.lead!.id}'),
  //     headers: {
  //       'Accept': 'application/json',
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: jsonEncode(encodableFormData),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Lead Updated successfully'),
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //     setState(() {
  //
  //     });
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Failed to Update lead'),
  //         duration: Durations.short1,),
  //     );
  //   }
  // }


  Future<void> updateForm(Map<String, dynamic> formData, String latLong) async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      print("Token not found");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Authentication token not found')));
      return;
    }

    // Create a copy of formData and add the lat_long
    Map<String, dynamic> encodableFormData = Map<String, dynamic>.from(formData);
    encodableFormData?['latitude'] = currentPosition?.latitude.toString()==null?widget.lead?.latitude:currentPosition?.latitude.toString();
    encodableFormData?['longitude'] = currentPosition?.longitude.toString()==null?widget.lead?.longitude:currentPosition?.longitude.toString();

    // Convert DateTime fields to ISO 8601 strings
    encodableFormData = encodableFormData.map((key, value) {
      if (value is DateTime) {
        return MapEntry(key, value.toIso8601String());
      }
      return MapEntry(key, value);
    });


    final response = await http.put(
      Uri.parse('http://127.0.0.1:8000/api/leads/${widget.lead!.id}'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(encodableFormData),
    );

    // Handle the response
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lead updated successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
      setState(() {

      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update lead: ${response.body}'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  // Future<void> _submitForm(formKey) async {
  //   var connectivityResult = await (Connectivity().checkConnectivity());
  //   bool hasInternet = connectivityResult != ConnectivityResult.none;
  //
  //   var leadData = {
  //     'name': formKey['name'],
  //     'contact_number': formKey['contact_number'],
  //     'is_whatsapp': formKey['is_whatsapp'] ? '1' : '0',
  //     'email': formKey['email'],
  //     'address': formKey['address'],
  //     'state': formKey['state'],
  //     'district': formKey['district'],
  //     'city': formKey['city'],
  //     'location_coordinates': formKey['location_coordinates'],
  //     'latitude': currentPosition!.latitude.toString(),
  //     'longitude': currentPosition!.longitude.toString(),
  //     'follow_up': formKey['follow_up'],
  //     'follow_up_date': formKey['follow_up_date']?.toIso8601String(),
  //     'lead_priority': formKey['lead_priority'],
  //     'remarks': formKey['remarks'],
  //     'image_path': _image?.path,
  //     'synced': hasInternet ? 1 : 0, // Mark as synced if there's internet
  //   };
  //
  //   if (hasInternet) {
  //     // Send the request to the backend
  //     var request = http.MultipartRequest('POST', Uri.parse('http://127.0.0.1:8000/api/leads'));
  //     leadData.forEach((key, value) {
  //       if (value != null) {
  //         request.fields[key] = value.toString();
  //       }
  //     });
  //
  //     if (_image != null) {
  //       var file = await http.MultipartFile.fromPath('image_path', _image!.path);
  //       request.files.add(file);
  //     }
  //
  //     var response = await request.send();
  //
  //     if (response.statusCode == 201) {
  //       print("Request successful");
  //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Form submitted successfully'), backgroundColor: Colors.green,));
  //     } else {
  //       print("Request failed with status: ${response.statusCode}");
  //       var responseBody = await response.stream.bytesToString();
  //       print("Response body: $responseBody");
  //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Form submission failed')));
  //     }
  //   } else {
  //     // Save the data locally
  //     await DatabaseHelper().insertLead(leadData);
  //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved locally due to no internet')));
  //   }
  // }
///

  // Future<void> _handleSubmit() async {
  //   if (_formKey.currentState!.validate()) {
  //     _formKey.currentState!.save();
  //     final formKey = Map<String, dynamic>.from(_formKey.currentState!.value);
  //
  //
  //     formKey['latitude'] = currentPosition?.latitude.toString() ?? '';
  //     formKey['longitude'] = currentPosition?.longitude.toString() ?? '';
  //
  //
  //     formKey['image_path'] = _image?.path ?? '';
  //
  //     log('Form Data: $formKey');
  //
  //     var connectivityResult = await (Connectivity().checkConnectivity());
  //
  //     if (connectivityResult == ConnectivityResult.none) {
  //
  //       await DatabaseHelper().insertLead(formKey);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Form saved offline.'),
  //           backgroundColor: Colors.orange,
  //           duration: Duration(seconds: 1),
  //         ),
  //       );
  //     } else {
  //       String latLong = currentPosition.toString();
  //
  //       if (widget.lead != null) {
  //         await updateForm(formKey,latLong);
  //       } else {
  //         await _submitForm(formKey);
  //         // await DatabaseHelper().insertLead(formKey);
  //       }
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Form submitted successfully.'),
  //           backgroundColor: Colors.green,
  //         ),
  //       );
  //     }
  //
  //
  //     // reset();
  //     // Navigator.push(
  //     //   context,
  //     //   MaterialPageRoute(builder: (context) => BottomNavBarDemo()),
  //     // );
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Failed to submit form.'),
  //         backgroundColor: Colors.red,
  //         duration: Duration(seconds: 1),
  //       ),
  //     );
  //     print("Failed to validate form");
  //   }
  // }


  Future<bool> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> handleSubmit() async {
    // Validate the form
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      _formKey.currentState!.save();
      final formKey = Map<String, dynamic>.from(_formKey.currentState!.value);
      formKey['latitude'] = currentPosition?.latitude.toString() ?? '';
      formKey['longitude'] = currentPosition?.longitude.toString() ?? '';


      formKey['image_path'] = _image?.path ?? '';

      log('Form Data: $formKey');
      // Check connectivity
      bool isConnected = await checkInternetConnection();

      if (isConnected) {

        try {
          await _submitForm(formKey);
        } catch (e) {
          print("Failed to submit to backend, saving locally: $e");
          await DatabaseHelper().insertLead(formKey);
        }
      } else {

        await DatabaseHelper().insertLead(formKey);
      }
    } else {
      print('Form is not valid');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please correct the errors in the form.')));
    }
  }


  Future<void> _submitForm(formKey) async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      print("Token not found");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Authentication token not found')));
      return;
    }
    // if (formKey) {
    var request = http.MultipartRequest('POST', Uri.parse('http://127.0.0.1:8000/api/leads'));

    request.headers['Authorization'] = 'Bearer $token';
    // Add form fields
    request.fields['name'] =formKey['name'];
    request.fields['contact_number'] = formKey['contact_number'];
    request.fields['is_whatsapp'] = formKey['is_whatsapp'] ? '1' : '0';
    if (formKey['email'] != null && formKey['email'].isNotEmpty) {
      request.fields['email'] = formKey['email'];
    }
    request.fields['address'] = formKey['address'];
    request.fields['state'] = formKey['state'];
    request.fields['district'] = formKey['district'];
    request.fields['city'] = formKey['city'];
    request.fields['location_coordinates'] = formKey['location_coordinates'];
    request.fields['latitude'] = currentPosition!.latitude.toString();
    request.fields['longitude'] = currentPosition!.longitude.toString();
    request.fields['follow_up'] = formKey['follow_up'];

    if (formKey['follow_up_date'] != null) {
      request.fields['follow_up_date'] = formKey['follow_up_date'] ;
    }


    request.fields['lead_priority'] = formKey['lead_priority'];

    if (formKey['remarks'] != null && formKey['remarks'].isNotEmpty) {
      request.fields['remarks'] = formKey['remarks'];
    }


    if (_image != null) {
      var file = await http.MultipartFile.fromPath('image_path', _image!.path);
      request.files.add(file);
    }

    // Send the request
    var response = await request.send();

    // Handle the response
    if (response.statusCode == 201 ) {
      print("Request successful");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Form submitted successfully'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ));

    } else {
      print("Request failed with status: ${response.statusCode}");
      var responseBody = await response.stream.bytesToString();
      print("Response body: $responseBody");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Form submission failed')));
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

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile!.path);
    });
  }
  Future<void> _pickImagecamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = File(pickedFile!.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.shade100,
        elevation: 0,
        title: Center(
          child: const Text('Lead data',style: TextStyle(fontWeight: FontWeight.bold,),
          ),
        ),

      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0,right: 16.0,top: 0,bottom: 16),
          child: FormBuilder(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 10,),
                  Stack(
                    children: [

                      CircleAvatar(
                        backgroundColor: Colors.teal.shade100,
                        radius: 50,
                        backgroundImage: _image != null ? FileImage(_image!) : null,
                        child: _image == null ? const Icon(Icons.person, size: 50,color: Colors.teal,) : null,
                      ),

                      // CircleAvatar(
                      //   backgroundColor: Colors.teal.shade100,
                      //   radius: 50,
                      //   backgroundImage: widget.lead!.image_path != null
                      //       ? NetworkImage('http://127.0.0.1:8000/storage/${widget.lead!.image_path}')
                      //       : null,
                      //   child: widget.lead!.image_path == null
                      //       ? const Icon(Icons.person, size: 50, color: Colors.teal)
                      //       : null,
                      // ),


                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton.filled(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text("Add Profile"),
                                      actions: [
                                        IconButton(
                                            onPressed: () {
                                              _pickImagecamera();
                                              Navigator.of(context).pop();
                                            },
                                            icon: const Column(
                                              children: [
                                                Icon(Icons.camera),
                                                Text("Camera")
                                              ],
                                            )),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        IconButton(
                                            onPressed: () {
                                              _pickImage();
                                              Navigator.of(context).pop();
                                            },
                                            icon: const Column(
                                              children: [
                                                Icon(Icons.image),
                                                Text("Image")
                                              ],
                                            )),
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: const Icon(Icons.add))
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  FormBuilderTextField(
                    name: 'name',
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
                  const SizedBox(height: 13),
                  FormBuilderTextField(
                    name: 'contact_number',
                    keyboardType: TextInputType.phone,
                    initialValue: widget.lead?.contactNumber,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.phone, color: Colors.blue),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      labelText: 'Contact Number',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.contacts),
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
                  const SizedBox(height: 5),


                  FormBuilderCheckbox(
                    name: 'is_whatsapp',
                    title: const Text('Is this a WhatsApp number?',
                        style: TextStyle(fontSize: 12)),

                    initialValue: widget.lead?.isWhatsapp??false,
                  ),
                  const SizedBox(height: 5),
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
                  const SizedBox(height: 13),
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
                  const SizedBox(height: 13),
                  FormBuilderDropdown(
                    name: 'state',
                    // initialValue:  widget.lead?.state,
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
                  const SizedBox(height: 13),
                  FormBuilderDropdown(
                    name: 'district',
                    // initialValue: _selectedDistrict,
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
                  const SizedBox(height: 13),
                  FormBuilderDropdown(
                    name: 'city',
                    // initialValue: _selectedCity,
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
                  const SizedBox(height: 13),
                  FormBuilderTextField(
                    name: 'location_coordinates',

                    initialValue:   widget.lead?.locationCoordinates,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.location_on, color: Colors.blue),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.my_location, color: Colors.blue),
                        onPressed: () async {
                          Position position = await _determinePosition();
                          setState(() {
                            currentPosition = position;
                            _getAddressFromLatLng(currentPosition!);
                          });
                        },
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      labelText: 'Location Coordinates',
                    ),
                  ),
                  const SizedBox(height: 13),
                  FormBuilderRadioGroup(
                    // initialValue:  widget.lead?.followUp,
                    name: 'follow_up',
                    initialValue: widget.lead?.followUp,
                    options: [
                      const FormBuilderFieldOption(value: 'Yes'),
                      const FormBuilderFieldOption(value: 'No'),
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
                        //           ? await _submitForm(formKey)
                        followUp = value == 'Yes';
                      });
                    },
                  ),
                  if (followUp) ...[
                    const SizedBox(height: 13),
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
                  const SizedBox(height: 13),
                  FormBuilderRadioGroup(
                    initialValue: widget.lead?.leadPriority,
                    name: 'lead_priority',
                    options: [
                      const FormBuilderFieldOption(value: 'Low'),
                      const FormBuilderFieldOption(value: 'Medium'),
                      const FormBuilderFieldOption(value: 'High'),
                    ],
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.priority_high, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      labelText: 'Priority',
                    ),
                  ),
                  const SizedBox(height: 13),
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
                  const SizedBox(height: 20),
                  // ElevatedButton(
                  //   onPressed: () async {
                  //     if (_formKey.currentState!.saveAndValidate()) {
                  //
                  //       var formKey = _formKey.currentState!.value;
                  //       (formKey['follow_up_date'] as DateTime?)
                  //           ?.toIso8601String() ??
                  //           '';
                  //       await DatabaseHelper().insertLead(formKey);
                  //       String latLong = currentPosition.toString();
                  //       widget.lead == null
                  //           : await updateForm(formKey,latLong);
                  //
                  //       setState(() {});
                  //     }
                  //     // reset();
                  //   },
                  //   child: Text(widget.lead == null ? 'Submit' : 'Update'),
                  // )

//                   ElevatedButton(
//                     // style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade100),
//                     onPressed: () async {
//                       if (_formKey.currentState!.saveAndValidate()) {
//                         // Create a modifiable copy of the form data
//                         var formKey = Map<String, dynamic>.from(_formKey.currentState!.value);
//
//                         formKey['latitude'] = currentPosition?.latitude.toString() ?? '';
//                         formKey['longitude'] = currentPosition?.longitude.toString() ?? '';
//
//                         if (_image != null) {
//                           formKey['image_path'] = _image!.path;
//                         } else {
//                           formKey['image_path'] = '';
//                         }
//                         if (widget.lead == null) {
//                           await DatabaseHelper().insertLead(formKey);
//                         }
// //                        _handleSubmit();
//
//                         if (formKey.containsKey('follow_up_date') && formKey['follow_up_date'] is DateTime) {
//                           formKey['follow_up_date'] = (formKey['follow_up_date'] as DateTime).toIso8601String();
//                         }
//
//                         String latLong = currentPosition.toString();
//                         widget.lead == null
//                             ? await _submitForm(formKey)
//                             :  await updateForm(formKey, latLong);
//
//                         setState(() {});
//                         reset();
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) =>  BottomNavBarDemo()),
//                         );
//                       }
//                     },
//                     child: Text(widget.lead == null ? 'Submit' : 'Update'),
//                   )
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade100),
                    onPressed: () async {
                      await handleSubmit();
                    },
                    child: Text(widget.lead == null ? 'Submit' : 'Update'),
                  )



                ],

              ),
            ),
          ),
        ),
      ),
    );
  }
}

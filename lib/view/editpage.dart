import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:geolocator/geolocator.dart';

class Editpage extends StatefulWidget {
  const Editpage({Key? key}) : super(key: key);

  @override
  State<Editpage> createState() => _EditpageState();
}

class _EditpageState extends State<Editpage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool followUp = false;
  String _location = ''; // Initialize location as 'Unknown'

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
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

    // Get current position
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _location = 'Lat: ${position.latitude}, Long: ${position.longitude}';
    });

    // Update the form field value
    _formKey.currentState?.fields['location_coordinates']?.didChange(_location);
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
                  FormBuilderTextField(
                    name: 'name',
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person),
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
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      labelText: 'Contact Number',
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
                      prefixIcon: Icon(Icons.email),
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
                      prefixIcon: Icon(Icons.home),
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
                      prefixIcon: Icon(Icons.location_city),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      labelText: 'State',
                    ),
                    items: ['Kerala', 'Tamilnadu']
                        .map((state) => DropdownMenuItem(
                      value: state,
                      child: Text(state),
                    ))
                        .toList(),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                  ),
                  SizedBox(height: 13),
                  FormBuilderDropdown(
                    name: 'district',
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.location_city),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      labelText: 'District',
                    ),
                    items: [
                      'Thiruvananthapuram',
                      'Kollam',
                      'Pathanamthitta',
                      'Alappuzha',
                      'Kottayam',
                      'Idukki',
                      'Ernakulam',
                      'Thrissur',
                      'Palakkad',
                      'Malappuram',
                      'Kozhikode',
                      'Wayanad',
                      'Kannur',
                      'Kasaragod'
                    ]
                        .map((district) => DropdownMenuItem(
                      value: district,
                      child: Text(district),
                    ))
                        .toList(),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                  ),
                  SizedBox(height: 13),
                  FormBuilderDropdown(
                    name: 'city',
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.location_city),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      labelText: 'City',
                    ),
                    items: ['City1', 'City2', 'City3']
                        .map((city) => DropdownMenuItem(
                      value: city,
                      child: Text(city),
                    ))
                        .toList(),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                  ),
                  SizedBox(height: 13),
                  FormBuilderTextField(
                    name: 'location_coordinates',
                    initialValue:_location,

                    // Use _location as initial value
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      labelText: 'Location Coordinates',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.my_location),
                        onPressed: ()  {
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
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      labelText: 'Follow-up',
                    ),
                    items: ['Yes', 'No']
                        .map((followUp) => DropdownMenuItem(
                      value: followUp,
                      child: Text(followUp),
                    ))
                        .toList(),
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
                    options: ['Hot', 'Warm', 'Cold']
                        .map((priority) => FormBuilderFieldOption(
                      value: priority,
                      child: Text(priority),
                    ))
                        .toList(),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.saveAndValidate()) {
                        final formData = _formKey.currentState!.value;
                        print(formData);
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

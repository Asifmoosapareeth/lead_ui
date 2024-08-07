// import 'package:flutter/material.dart';
// import 'package:flutter_form_builder/flutter_form_builder.dart';
// import 'package:form_builder_validators/form_builder_validators.dart';
//
// import 'helper2.dart';
// import 'lead_check.dart'; // Import your DatabaseHelper
//
// class LeadFormPage extends StatefulWidget {
//   @override
//   _LeadFormPageState createState() => _LeadFormPageState();
// }
//
// class _LeadFormPageState extends State<LeadFormPage> {
//   final _formKey = GlobalKey<FormBuilderState>();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Add Lead'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: FormBuilder(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               children: <Widget>[
//                 FormBuilderTextField(
//                   name: 'name',
//                   decoration: InputDecoration(labelText: 'Name'),
//                   validator: FormBuilderValidators.compose([
//
//                   ]),
//                 ),
//                 FormBuilderTextField(
//                   name: 'contact_number',
//                   decoration: InputDecoration(labelText: 'Contact Number'),
//                   validator: FormBuilderValidators.compose([
//
//                   ]),
//                 ),
//                 FormBuilderSwitch(
//                   name: 'is_whatsapp',
//                   title: Text('WhatsApp'),
//                 ),
//                 FormBuilderTextField(
//                   name: 'email',
//                   decoration: InputDecoration(labelText: 'Email'),
//                 ),
//                 FormBuilderTextField(
//                   name: 'address',
//                   decoration: InputDecoration(labelText: 'Address'),
//                 ),
//                 FormBuilderTextField(
//                   name: 'state',
//                   decoration: InputDecoration(labelText: 'State'),
//                 ),
//                 FormBuilderTextField(
//                   name: 'district',
//                   decoration: InputDecoration(labelText: 'District'),
//                 ),
//                 FormBuilderTextField(
//                   name: 'city',
//                   decoration: InputDecoration(labelText: 'City'),
//                 ),
//                 FormBuilderTextField(
//                   name: 'location_coordinates',
//                   decoration: InputDecoration(labelText: 'Location Coordinates'),
//                 ),
//                 FormBuilderTextField(
//                   name: 'latitude',
//                   decoration: InputDecoration(labelText: 'Latitude'),
//                 ),
//                 FormBuilderTextField(
//                   name: 'longitude',
//                   decoration: InputDecoration(labelText: 'Longitude'),
//                 ),
//                 FormBuilderTextField(
//                   name: 'lead_priority',
//                   decoration: InputDecoration(labelText: 'Lead Priority'),
//                 ),
//                 FormBuilderDateTimePicker(
//                   name: 'follow_up_date',
//                   decoration: InputDecoration(labelText: 'Follow-up Date'),
//                   inputType: InputType.date,
//                 ),
//                 FormBuilderTextField(
//                   name: 'remarks',
//                   decoration: InputDecoration(labelText: 'Remarks'),
//                 ),
//                 SizedBox(height: 20),
//                 Row(
//                   children: [
//                     ElevatedButton(
//                       onPressed: () async {
//                         if (_formKey.currentState?.saveAndValidate() ?? false) {
//                           final formData = _formKey.currentState?.value;
//
//                           await DatabaseHelper().insertLead(formData!);
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('Lead saved successfully')),
//                           );
//                           await DatabaseHelper()..printAllLeads();
//                           // Navigator.push(
//                           //   context,
//                           //   MaterialPageRoute(builder: (context) => LeadsListPage()),
//                           // );
//                         } else {
//                           print("Validation failed");
//                         }
//                       },
//                       child: Text('Save Lead'),
//                     ),
//                     ElevatedButton(onPressed: (){
//                     Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => LeadsListPage()),
//                     );
//                     }, child: Text('lead'))
//                   ],
//                 ),
//                 SizedBox(height: 20,)
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

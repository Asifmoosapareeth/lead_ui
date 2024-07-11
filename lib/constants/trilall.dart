// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../Model/leaddata_model.dart';
// import '../controller/data.dart';
//
// class FirstPage extends ConsumerWidget {
//   const FirstPage({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     AsyncValue<List<Lead>> leadsAsyncValue = ref.watch(leadDataProvider);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Leads List'),
//       ),
//       body: leadsAsyncValue.when(
//         data: (leads) {
//           return leads.isEmpty
//               ? Center(child: Text('No Leads Added'))
//               : ListView.builder(
//             itemCount: leads.length,
//             itemBuilder: (context, index) {
//               final lead = leads[index];
//               return LeadCard(lead: lead);
//             },
//           );
//         },
//         loading: () => Center(child: CircularProgressIndicator()),
//         error: (error, stack) => Center(child: Text('Error: $error')),
//       ),
//     );
//   }
// }
//
// class LeadCard extends StatelessWidget {
//   final Lead lead;
//
//   const LeadCard({required this.lead});
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: EdgeInsets.all(8.0),
//       child: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               lead.name,
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 5),
//             Text('Email: ${lead.email ?? 'N/A'}'),
//             Text('Address: ${lead.address ?? 'N/A'}'),
//             Text('State: ${lead.stateId}'),
//
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // final leadDataProvider = FutureProvider<List<Lead>>((ref) async {
// //   final dio = Dio();
// //   final response = await dio.get("http://127.0.0.1:8000/api/leads");
// //   return List<Lead>.from(
// //     response.data.map((lead) => Lead.fromJson(lead)),
// //   );
// // });
// //
// // class FirstPage extends StatelessWidget {
// //   const FirstPage({Key? key}) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Leads List'),
// //       ),
// //       body: Consumer(builder: (context, watch, child) {
// //         final leadsAsyncValue = watch(leadDataProvider);
// //
// //         return leadsAsyncValue.when(
// //           data: (leads) {
// //             return leads.isEmpty
// //                 ? Center(child: Text('No Leads Added'))
// //                 : ListView.builder(
// //               itemCount: leads.length,
// //               itemBuilder: (context, index) {
// //                 final lead = leads[index];
// //                 return LeadCard(lead: lead);
// //               },
// //             );
// //           },
// //           loading: () => Center(child: CircularProgressIndicator()),
// //           error: (error, stackTrace) => Center(child: Text('Error: $error')),
// //         );
// //       }),
// //     );
// //   }
// // }
// //
// // class LeadCard extends StatelessWidget {
// //   final Lead lead;
// //
// //   const LeadCard({Key? key, required this.lead}) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final stateName = context.read(stateMapProvider).state[lead.stateId] ?? '';
// //
// //     return Card(
// //       margin: EdgeInsets.all(8.0),
// //       child: Padding(
// //         padding: EdgeInsets.all(16.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text(
// //               lead.name,
// //               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// //             ),
// //             SizedBox(height: 5),
// //             Text('Email: ${lead.email}'),
// //             Text('Address: ${lead.address}'),
// //             Text('State: $stateName'),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

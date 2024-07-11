import 'package:riverpod/riverpod.dart';
import 'package:dio/dio.dart';
import '../Model/leaddata_model.dart';
final leadDataProvider = FutureProvider<List<Lead>>((ref) async {
  final dio = Dio();
  final response = await dio.get("http://127.0.0.1:8000/api/leads");
  return List<Lead>.from(
    response.data.map((lead) => Lead.fromJson(lead)),
  );
});

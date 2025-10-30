import 'package:dio/dio.dart';
import 'package:videomeet/core/errors/exception.dart';

class ApiService {
  final Dio dio;
  final String _baseUrl = 'https://reqres.in/api';

  ApiService(this.dio);

  Future<List<dynamic>> getUsers() async {
    try {
      List<dynamic> allUsers = [];
      
      // Fetch page 1 (6 users)
      final response1 = await dio.get(
        '$_baseUrl/users?page=1',
        options: Options(
          headers: {'Authorization': null}, // Remove auth header
        ),
      );
      if (response1.statusCode == 200) {
        allUsers.addAll(response1.data['data'] as List<dynamic>);
      }
      
      // Fetch page 2 (6 more users = 12 total)
      final response2 = await dio.get(
        '$_baseUrl/users?page=2',
        options: Options(
          headers: {'Authorization': null}, // Remove auth header
        ),
      );
      if (response2.statusCode == 200) {
        allUsers.addAll(response2.data['data'] as List<dynamic>);
      }
      
      return allUsers;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ServerException('Unauthorized. Token may be invalid or expired.');
      }
      throw ServerException('Failed to load users: ${e.message}');
    }
  }
}
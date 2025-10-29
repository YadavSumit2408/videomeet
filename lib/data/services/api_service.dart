import 'package:dio/dio.dart';
import 'package:videomeet/core/errors/exception.dart';
 // Make sure this path is correct

class ApiService {
  // 1. DO NOT initialize Dio here.
  final Dio dio;
  final String _baseUrl = 'https://reqres.in/api';

  // 2. Get the Dio instance from the constructor.
  // This is the Dio that has our token interceptor.
  ApiService(this.dio);

  Future<List<dynamic>> getUsers() async {
    try {
      // 3. Use the 'dio' field (which came from the constructor).
      final response = await dio.get('$_baseUrl/users?page=1');
      
      if (response.statusCode == 200) {
        // The list of users is inside the 'data' key
        return response.data['data'] as List<dynamic>;
      } else {
        throw ServerException('Failed to load users: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Handle 401 error specifically for better debugging
      if (e.response?.statusCode == 401) {
        throw ServerException('Unauthorized. Token may be invalid or expired.');
      }
      throw ServerException('Failed to load users: ${e.message}');
    }
  }
}
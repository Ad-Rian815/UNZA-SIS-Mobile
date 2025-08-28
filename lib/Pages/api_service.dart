import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class ApiService {
  // ✅ Change to your backend when deployed
  static const String _localUrl = "http://10.0.2.2:5000"; // Android Emulator localhost
  static const String _prodUrl = "http://localhost:5000"; // Desktop/Web testing
  static final String baseUrl = _localUrl;

  static final Logger _logger = Logger();

  // ✅ Helper: Get headers (with token if available)
  static Future<Map<String, String>> _getHeaders({bool withAuth = false}) async {
    final headers = {"Content-Type": "application/json"};
    if (withAuth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }
    }
    return headers;
  }

  // ✅ Signup
  static Future<Map<String, dynamic>> signup(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/signup"),
        headers: await _getHeaders(),
        body: jsonEncode({"username": username, "password": password}),
      );

      _logger.i("Signup Response Code: ${response.statusCode}");
      _logger.i("Signup Response Body: ${response.body}");

      if (response.statusCode == 201) {
        return {'success': true, 'message': 'Signup successful'};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Signup failed'};
      }
    } catch (e) {
      _logger.e("Signup Error: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ✅ Login + save user info + courses
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: await _getHeaders(),
        body: jsonEncode({"username": username, "password": password}),
      );

      _logger.i("Login Response Code: ${response.statusCode}");
      _logger.i("Login Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['token'] != null && responseData['user'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('token', responseData['token']);
          await prefs.setString('username', responseData['user']['username'] ?? '');

          // ✅ Save student info
          await prefs.setString('studentName', responseData['user']['studentName'] ?? '');
          await prefs.setString('studentNRC', responseData['user']['studentNRC'] ?? '');
          await prefs.setString('yearOfStudy', responseData['user']['yearOfStudy'] ?? '');
          await prefs.setString('program', responseData['user']['program'] ?? '');
          await prefs.setString('school', responseData['user']['school'] ?? '');
          await prefs.setString('campus', responseData['user']['campus'] ?? '');
          await prefs.setString('major', responseData['user']['major'] ?? '');
          await prefs.setString('intake', responseData['user']['intake'] ?? '');

          // ✅ Save courses (as JSON string)
          if (responseData['user']['courses'] != null) {
            await prefs.setString('courses', jsonEncode(responseData['user']['courses']));
          }

          return {'success': true, 'message': 'Login successful'};
        }
        return {'success': false, 'message': 'Invalid login response'};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      _logger.e("Login Error: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ✅ Get stored student data
  static Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    List<dynamic> courses = [];
    final coursesString = prefs.getString('courses');
    if (coursesString != null) {
      courses = jsonDecode(coursesString);
    }

    return {
      'username': prefs.getString('username'),
      'token': prefs.getString('token'),
      'studentName': prefs.getString('studentName'),
      'studentNRC': prefs.getString('studentNRC'),
      'yearOfStudy': prefs.getString('yearOfStudy'),
      'program': prefs.getString('program'),
      'school': prefs.getString('school'),
      'campus': prefs.getString('campus'),
      'major': prefs.getString('major'),
      'intake': prefs.getString('intake'),
      'courses': courses,
    };
  }

  // ✅ Change Password
  static Future<Map<String, dynamic>> changePassword(
      String username, String oldPassword, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/change-password"),
        headers: await _getHeaders(),
        body: jsonEncode({
          "username": username,
          "oldPassword": oldPassword,
          "newPassword": newPassword
        }),
      );

      _logger.i("Change Password Response Code: ${response.statusCode}");
      _logger.i("Change Password Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Password updated successfully'};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Password update failed'
        };
      }
    } catch (e) {
      _logger.e("Change Password Error: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ✅ Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    _logger.i("Before logout: ${prefs.getString('username')}");
    await prefs.clear();
    _logger.i("After logout: ${prefs.getString('username')}");
  }

  // ✅ Check login state
  static Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}

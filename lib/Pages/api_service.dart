import 'dart:async'; // ← required for TimeoutException
import 'dart:convert';
import 'dart:io' show Platform; // ✅ Needed for platform checks
import 'package:flutter/foundation.dart'; // ✅ For kIsWeb
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class ApiService {
  // ✅ URLs for different environments
  static const String _emulatorUrl = "http://10.0.2.2:5000"; // Android Emulator
  static const String _localhostUrl = "http://localhost:5000"; // Web/Desktop
  static const String _deviceUrl = "http://192.168.0.100:5000";

  // Optional override when you want to force a specific base URL (helpful for testing)
  static String? overrideBaseUrl;

  // ✅ Automatically choose correct baseUrl
  static String get baseUrl {
    if (overrideBaseUrl != null && overrideBaseUrl!.isNotEmpty) {
      return overrideBaseUrl!;
    }
    if (kIsWeb) {
      return _localhostUrl; // Browser → localhost
    } else if (Platform.isAndroid) {
      return _emulatorUrl; // Android Emulator → 10.0.2.2
    } else {
      return _localhostUrl; // iOS/macOS/Windows
    }
  }

  static final Logger _logger = Logger();

  // ✅ Helper: Get headers (with token if available)
  static Future<Map<String, String>> _getHeaders(
      {bool withAuth = false}) async {
    final headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };
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
  static Future<Map<String, dynamic>> signup(
      String username, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/signup"),
            headers: await _getHeaders(),
            body: jsonEncode({"username": username, "password": password}),
          )
          .timeout(const Duration(seconds: 10));

      _logger.i("Signup Response Code: ${response.statusCode}");
      _logger.i("Signup Response Body: ${response.body}");

      Map<String, dynamic>? data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        data = null;
      }

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data != null
              ? (data['message'] ?? 'Signup successful')
              : 'Signup successful'
        };
      } else {
        return {
          'success': false,
          'message': data != null
              ? (data['message'] ?? 'Signup failed')
              : 'Unexpected server response: ${response.body}'
        };
      }
    } catch (e) {
      _logger.e("Signup Error: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ✅ Login + save user info + courses
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/login"),
            headers: await _getHeaders(),
            body: jsonEncode({"username": username, "password": password}),
          )
          .timeout(const Duration(seconds: 10));

      _logger.i("Login Response Code: ${response.statusCode}");
      _logger.i("Login Response Body: ${response.body}");

      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        _logger.w("Login: response is not valid JSON: ${response.body}");
        return {
          'success': false,
          'message': 'Invalid login response (non-JSON): ${response.body}'
        };
      }

      // Case A: expected shape { token: "...", user: { ... } }
      if (responseData.containsKey('token') &&
          responseData.containsKey('user')) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('token', responseData['token']);
        await prefs.setString(
            'username', responseData['user']['username'] ?? '');

        await prefs.setString(
            'studentName', responseData['user']['studentName'] ?? '');
        await prefs.setString(
            'studentNRC', responseData['user']['studentNRC'] ?? '');
        await prefs.setString(
            'yearOfStudy', responseData['user']['yearOfStudy'] ?? '');
        await prefs.setString('program', responseData['user']['program'] ?? '');
        await prefs.setString('school', responseData['user']['school'] ?? '');
        await prefs.setString('campus', responseData['user']['campus'] ?? '');
        await prefs.setString('major', responseData['user']['major'] ?? '');
        await prefs.setString('intake', responseData['user']['intake'] ?? '');

        if (responseData['user']['courses'] != null) {
          await prefs.setString(
              'courses', jsonEncode(responseData['user']['courses']));
        } else {
          await prefs.remove('courses');
        }

        return {'success': true, 'message': 'Login successful'};
      }

      // Case B: server uses envelope { response: { status, message, data } }
      if (responseData.containsKey('response') &&
          responseData['response'] is Map) {
        final envelope = responseData['response'] as Map<String, dynamic>;
        final status = envelope['status'];
        final message =
            envelope['message'] ?? envelope['msg'] ?? 'Unauthorized';

        // treat 2xx as success if token/user exist inside data
        if (status is int && status >= 200 && status < 300) {
          // try to extract token/user from envelope.data if present
          final data = envelope['data'];
          if (data is Map &&
              data.containsKey('token') &&
              data.containsKey('user')) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isLoggedIn', true);
            await prefs.setString('token', data['token']);
            await prefs.setString('username', data['user']['username'] ?? '');

            await prefs.setString(
                'studentName', data['user']['studentName'] ?? '');
            await prefs.setString(
                'studentNRC', data['user']['studentNRC'] ?? '');
            await prefs.setString(
                'yearOfStudy', data['user']['yearOfStudy'] ?? '');
            await prefs.setString('program', data['user']['program'] ?? '');
            await prefs.setString('school', data['user']['school'] ?? '');
            await prefs.setString('campus', data['user']['campus'] ?? '');
            await prefs.setString('major', data['user']['major'] ?? '');
            await prefs.setString('intake', data['user']['intake'] ?? '');

            if (data['user']['courses'] != null) {
              await prefs.setString(
                  'courses', jsonEncode(data['user']['courses']));
            } else {
              await prefs.remove('courses');
            }

            return {'success': true, 'message': 'Login successful'};
          }
        }

        // non-200 status: show server message when available
        return {'success': false, 'message': message};
      }

      // unexpected response shape
      _logger.w("Invalid login response structure: ${response.body}");
      return {
        'success': false,
        'message': 'Invalid login response: ${response.body}'
      };
    } on http.ClientException catch (e) {
      _logger.e("Login ClientException: $e");
      return {'success': false, 'message': 'Client error: $e'};
    } on TimeoutException catch (e) {
      _logger.e("Login Timeout: $e");
      return {'success': false, 'message': 'Request timed out'};
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
      try {
        courses = jsonDecode(coursesString);
      } catch (_) {
        courses = [];
      }
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
      final response = await http
          .post(
            Uri.parse("$baseUrl/change-password"),
            headers: await _getHeaders(),
            body: jsonEncode({
              "username": username,
              "oldPassword": oldPassword,
              "newPassword": newPassword
            }),
          )
          .timeout(const Duration(seconds: 10));

      _logger.i("Change Password Response Code: ${response.statusCode}");
      _logger.i("Change Password Response Body: ${response.body}");

      Map<String, dynamic>? data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        data = null;
      }

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data != null
              ? (data['message'] ?? 'Password updated successfully')
              : 'Password updated successfully'
        };
      } else {
        return {
          'success': false,
          'message': data != null
              ? (data['message'] ?? 'Password update failed')
              : 'Unexpected server response: ${response.body}'
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

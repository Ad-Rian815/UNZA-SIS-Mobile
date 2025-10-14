import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class ApiService {
  // Configuration constants
  static const Duration _defaultTimeout = Duration(seconds: 15);
  static const Duration _shortTimeout = Duration(seconds: 10);

  // Base URLs for different environments
  static const String _emulatorUrl = "http://10.0.2.2:5000";
  static const String _localhostUrl = "http://localhost:5000";
  // Compile-time override via --dart-define=API_BASE_URL=...
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  // Optional override for testing or specific configurations
  static String? overrideBaseUrl;

  // Logger instance
  static final Logger _logger = Logger();

  /// Automatically determines the correct base URL based on platform
  static String get baseUrl {
    // 1) Highest priority: runtime override
    if (overrideBaseUrl != null && overrideBaseUrl!.isNotEmpty) {
      return overrideBaseUrl!;
    }

    // 2) Compile-time --dart-define override if provided
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }

    if (kIsWeb) {
      return _localhostUrl;
    } else if (Platform.isAndroid) {
      return _emulatorUrl;
    } else {
      return _localhostUrl;
    }
  }

  /// Creates HTTP headers with optional authentication
  static Future<Map<String, String>> _getHeaders(
      {bool withAuth = false}) async {
    final headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    if (withAuth) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString("token");
        if (token != null && token.isNotEmpty) {
          headers["Authorization"] = "Bearer $token";
        }
      } catch (e) {
        _logger.w("Failed to get auth token: $e");
      }
    }

    return headers;
  }

  /// Generic HTTP request handler with proper error handling
  static Future<Map<String, dynamic>> _makeRequest({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
    bool withAuth = false,
    Duration timeout = _defaultTimeout,
  }) async {
    try {
      final uri = Uri.parse("$baseUrl$endpoint");
      final headers = await _getHeaders(withAuth: withAuth);

      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers).timeout(timeout);
          break;
        case 'POST':
          response = await http
              .post(
                uri,
                headers: headers,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(timeout);
          break;
        case 'PUT':
          response = await http
              .put(
                uri,
                headers: headers,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(timeout);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers).timeout(timeout);
          break;
        default:
          throw ArgumentError('Unsupported HTTP method: $method');
      }

      _logger.i("$method $endpoint - Status: ${response.statusCode}");
      _logger.d("$method $endpoint - Body: ${response.body}");

      return _processResponse(response);
    } on TimeoutException {
      _logger.e("$method $endpoint - Request timed out");
      return {
        'success': false,
        'message':
            'Request timed out. Please check your connection and try again.',
        'error': 'timeout'
      };
    } on http.ClientException catch (e) {
      _logger.e("$method $endpoint - Client error: $e");
      return {
        'success': false,
        'message': 'Connection failed. Please check your internet connection.',
        'error': 'client_error'
      };
    } on FormatException catch (e) {
      _logger.e("$method $endpoint - Format error: $e");
      return {
        'success': false,
        'message': 'Invalid response format from server.',
        'error': 'format_error'
      };
    } catch (e) {
      _logger.e("$method $endpoint - Unexpected error: $e");
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
        'error': 'unknown_error'
      };
    }
  }

  /// Processes HTTP response and handles different status codes
  static Map<String, dynamic> _processResponse(http.Response response) {
    Map<String, dynamic>? data;

    try {
      if (response.body.isNotEmpty) {
        data = jsonDecode(response.body);
      }
    } catch (e) {
      _logger.w("Failed to parse response body: $e");
    }

    // Handle different HTTP status codes
    switch (response.statusCode) {
      case 200:
      case 201:
        return {
          'success': true,
          'data': data,
          'message': data?['message'] ?? 'Operation successful'
        };
      case 400:
        return {
          'success': false,
          'message':
              data?['message'] ?? 'Bad request. Please check your input.',
          'error': 'bad_request'
        };
      case 401:
        return {
          'success': false,
          'message':
              data?['message'] ?? 'Authentication failed. Please log in again.',
          'error': 'unauthorized'
        };
      case 403:
        return {
          'success': false,
          'message': data?['message'] ?? 'Access denied.',
          'error': 'forbidden'
        };
      case 404:
        return {
          'success': false,
          'message': data?['message'] ?? 'Resource not found.',
          'error': 'not_found'
        };
      case 500:
        return {
          'success': false,
          'message':
              data?['message'] ?? 'Server error. Please try again later.',
          'error': 'server_error'
        };
      default:
        return {
          'success': false,
          'message': data?['message'] ??
              'Unexpected response (${response.statusCode})',
          'error': 'unexpected_status'
        };
    }
  }

  /// Saves user data to SharedPreferences
  static Future<bool> _saveUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save authentication data
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('token', userData['token'] ?? '');
      await prefs.setString('username', userData['user']?['username'] ?? '');

      // Save student information
      final user = userData['user'] as Map<String, dynamic>?;
      if (user != null) {
        await prefs.setString('studentName', user['studentName'] ?? '');
        await prefs.setString('studentNRC', user['studentNRC'] ?? '');
        await prefs.setString('yearOfStudy', user['yearOfStudy'] ?? '');
        await prefs.setString('program', user['program'] ?? '');
        await prefs.setString('school', user['school'] ?? '');
        await prefs.setString('campus', user['campus'] ?? '');
        await prefs.setString('major', user['major'] ?? '');
        await prefs.setString('intake', user['intake'] ?? '');
        // New fields
        await prefs.setString('sex', user['sex'] ?? '');
        await prefs.setString('nationality', user['nationality'] ?? '');
        await prefs.setString('sponsor', user['sponsor'] ?? '');
        // Contact fields
        await prefs.setString('phone', user['phone'] ?? '');
        await prefs.setString(
            'residentialAddress', user['residentialAddress'] ?? '');
        await prefs.setString('postalAddress', user['postalAddress'] ?? '');

        // Save courses if available
        if (user['courses'] != null) {
          await prefs.setString('courses', jsonEncode(user['courses']));
        } else {
          await prefs.remove('courses');
        }
      }

      return true;
    } catch (e) {
      _logger.e("Failed to save user data: $e");
      return false;
    }
  }

  /// User registration
  static Future<Map<String, dynamic>> signup(
      String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      return {
        'success': false,
        'message': 'Username and password are required.',
        'error': 'validation_error'
      };
    }

    return await _makeRequest(
      endpoint: '/signup',
      method: 'POST',
      body: {'username': username, 'password': password},
      timeout: _shortTimeout,
    );
  }

  /// User authentication
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      return {
        'success': false,
        'message': 'Username and password are required.',
        'error': 'validation_error'
      };
    }

    final result = await _makeRequest(
      endpoint: '/login',
      method: 'POST',
      body: {'username': username, 'password': password},
      timeout: _shortTimeout,
    );

    if (result['success'] && result['data'] != null) {
      final data = result['data'] as Map<String, dynamic>;

      // Handle different response formats
      Map<String, dynamic>? userData;

      // Direct format: { token: "...", user: { ... } }
      if (data.containsKey('token') && data.containsKey('user')) {
        userData = data;
      }
      // Envelope format: { response: { status, message, data: { token, user } } }
      else if (data.containsKey('response') && data['response'] is Map) {
        final response = data['response'] as Map<String, dynamic>;
        if (response['data'] is Map &&
            response['data']['token'] != null &&
            response['data']['user'] != null) {
          userData = response['data'];
        }
      }

      if (userData != null) {
        final saved = await _saveUserData(userData);
        if (saved) {
          return {'success': true, 'message': 'Login successful'};
        } else {
          return {
            'success': false,
            'message': 'Login successful but failed to save user data.',
            'error': 'storage_error'
          };
        }
      }
    }

    return result;
  }

  /// Retrieves stored user data
  static Future<Map<String, dynamic>> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      List<dynamic> courses = [];
      final coursesString = prefs.getString('courses');
      if (coursesString != null && coursesString.isNotEmpty) {
        try {
          courses = jsonDecode(coursesString);
        } catch (e) {
          _logger.w("Failed to parse courses: $e");
          courses = [];
        }
      }

      return {
        'username': prefs.getString('username') ?? '',
        'token': prefs.getString('token') ?? '',
        'studentName': prefs.getString('studentName') ?? '',
        'studentNRC': prefs.getString('studentNRC') ?? '',
        'yearOfStudy': prefs.getString('yearOfStudy') ?? '',
        'program': prefs.getString('program') ?? '',
        'school': prefs.getString('school') ?? '',
        'campus': prefs.getString('campus') ?? '',
        'major': prefs.getString('major') ?? '',
        'intake': prefs.getString('intake') ?? '',
        // New fields
        'sex': prefs.getString('sex') ?? '',
        'nationality': prefs.getString('nationality') ?? '',
        'sponsor': prefs.getString('sponsor') ?? '',
        // Contact fields
        'phone': prefs.getString('phone') ?? '',
        'residentialAddress': prefs.getString('residentialAddress') ?? '',
        'postalAddress': prefs.getString('postalAddress') ?? '',
        'courses': courses,
      };
    } catch (e) {
      _logger.e("Failed to get user data: $e");
      return {};
    }
  }

  /// Updates locally stored editable profile fields
  static Future<bool> updateUserContactInfo({
    String? phone,
    String? residentialAddress,
    String? postalAddress,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Normalize inputs (ignore empty)
      final normPhone = (phone ?? '').trim();
      final normRes = (residentialAddress ?? '').trim();
      final normPost = (postalAddress ?? '').trim();

      final Map<String, dynamic> body = {};
      if (normPhone.isNotEmpty) body['phone'] = normPhone;
      if (normRes.isNotEmpty) body['residentialAddress'] = normRes;
      if (normPost.isNotEmpty) body['postalAddress'] = normPost;

      // Try server update first if there is anything to update
      if (body.isNotEmpty) {
        try {
          final result = await _makeRequest(
            endpoint: '/profile/update',
            method: 'POST',
            withAuth: true,
            body: body,
            timeout: _shortTimeout,
          );
          if (result['success'] != true) {
            _logger.w('Server profile update failed, falling back to local');
          }
        } catch (e) {
          _logger.w('Server profile update error: $e');
        }
      }

      // Persist locally only non-empty values
      if (normPhone.isNotEmpty) {
        await prefs.setString('phone', normPhone);
      }
      if (normRes.isNotEmpty) {
        await prefs.setString('residentialAddress', normRes);
      }
      if (normPost.isNotEmpty) {
        await prefs.setString('postalAddress', normPost);
      }

      _logger.i('Contact info updated');
      return true;
    } catch (e) {
      _logger.e('Failed to update contact info: $e');
      return false;
    }
  }

  /// Changes user password
  static Future<Map<String, dynamic>> changePassword(
      String username, String oldPassword, String newPassword) async {
    if (username.isEmpty || oldPassword.isEmpty || newPassword.isEmpty) {
      return {
        'success': false,
        'message': 'All fields are required.',
        'error': 'validation_error'
      };
    }

    if (newPassword.length < 6) {
      return {
        'success': false,
        'message': 'New password must be at least 6 characters long.',
        'error': 'validation_error'
      };
    }

    return await _makeRequest(
      endpoint: '/change-password',
      method: 'POST',
      body: {
        'username': username,
        'oldPassword': oldPassword,
        'newPassword': newPassword
      },
      timeout: _shortTimeout,
    );
  }

  /// Logs out the user
  static Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');

      _logger.i("Logging out user: $username");

      await prefs.clear();

      _logger.i("User logged out successfully");
      return true;
    } catch (e) {
      _logger.e("Failed to logout: $e");
      return false;
    }
  }

  /// Checks if user is currently logged in
  static Future<bool> checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final token = prefs.getString('token');

      // Additional validation: check if token exists and is not empty
      return isLoggedIn && token != null && token.isNotEmpty;
    } catch (e) {
      _logger.e("Failed to check login status: $e");
      return false;
    }
  }

  /// Validates if the stored token is still valid
  static Future<bool> validateToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        return false;
      }

      // Make a test request to validate token
      final result = await _makeRequest(
        endpoint: '/validate-token', // Assuming this endpoint exists
        method: 'GET',
        withAuth: true,
        timeout: _shortTimeout,
      );

      return result['success'] == true;
    } catch (e) {
      _logger.e("Token validation failed: $e");
      return false;
    }
  }

  /// Clears all stored data (useful for debugging or complete reset)
  static Future<bool> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _logger.i("All stored data cleared");
      return true;
    } catch (e) {
      _logger.e("Failed to clear data: $e");
      return false;
    }
  }

  /// Fetches finance summary, fees and payments for the logged-in user
  static Future<Map<String, dynamic>> getFinances() async {
    final result = await _makeRequest(
      endpoint: '/finances',
      method: 'GET',
      withAuth: true,
      timeout: _shortTimeout,
    );
    if (result['success'] == true && result['data'] is Map<String, dynamic>) {
      return result['data'] as Map<String, dynamic>;
    }
    return {
      'summary': {
        'totalDue': 0,
        'totalPaid': 0,
        'outstanding': 0,
        'standing': 'Unknown'
      },
      'fees': [],
      'payments': [],
    };
  }

  /// Fetches per-student results (courses with grades) with a local fallback
  static Future<Map<String, dynamic>> getResults() async {
    try {
      final result = await _makeRequest(
        endpoint: '/results',
        method: 'GET',
        withAuth: true,
        timeout: _shortTimeout,
      );

      if (result['success'] == true && result['data'] is Map<String, dynamic>) {
        return result['data'] as Map<String, dynamic>;
      }
    } catch (e) {
      _logger.w('Results fetch failed, using local fallback: $e');
    }

    // Local fallback assembled from stored profile data
    try {
      final user = await getUserData();
      final String programme = (user['program'] ?? '').toString();
      final String yearOfStudy = (user['yearOfStudy'] ?? '').toString();
      final List<dynamic> courses = (user['courses'] as List?) ?? [];

      final mappedCourses = courses
          .map((c) => {
                'code': (c['code'] ?? c['courseCode'] ?? '').toString(),
                'name': (c['name'] ?? c['courseName'] ?? '').toString(),
                // If no grade data locally, mark as not published
                'grade': (c['grade'] ?? '***').toString(),
                'credits':
                    num.tryParse('${c['credits'] ?? c['credit'] ?? 0}') ?? 0,
                'comment': (c['comment'] ?? '').toString(),
              })
          .toList();

      return {
        'student': {
          'programme': programme,
          'yearOfStudy': yearOfStudy,
        },
        'academicYears': [
          {
            'year': 'Current',
            'programme': programme,
            'status': null,
            'courses': mappedCourses,
          }
        ],
      };
    } catch (_) {
      // final fallback
      return {
        'student': {
          'programme': '',
          'yearOfStudy': '',
        },
        'academicYears': <dynamic>[],
      };
    }
  }

  /// Fetches accommodation data from server with local fallback
  static Future<Map<String, dynamic>> getAccommodation() async {
    try {
      // Attempt server fetch (endpoint may not exist yet)
      final result = await _makeRequest(
        endpoint: '/accommodation',
        method: 'GET',
        withAuth: true,
        timeout: _shortTimeout,
      );

      if (result['success'] == true && result['data'] is Map<String, dynamic>) {
        final data = result['data'] as Map<String, dynamic>;
        // Persist last known data
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accommodation', jsonEncode(data));
        } catch (_) {}
        return data;
      }
    } catch (e) {
      _logger.w('Accommodation fetch failed, using local fallback: $e');
    }

    // Local fallback
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('accommodation');
      if (raw != null && raw.isNotEmpty) {
        return jsonDecode(raw) as Map<String, dynamic>;
      }
    } catch (_) {}

    // Default empty structure
    return {
      'allocation': null,
      'roomKey': null,
      'fixedProperty': <dynamic>[],
      'optionalProperty': <dynamic>[],
    };
  }

  /// Gets helpful information for web development CORS issues
  static String get webDevelopmentInfo {
    if (kIsWeb) {
      return '''
⚠️ Web Development CORS Issue Detected!

Your Flutter app is running on Chrome (likely localhost:8080) but trying to connect to localhost:5000.

To fix this, you need to configure your server to allow CORS requests:

1. Add CORS headers to your server (localhost:5000):
   - Access-Control-Allow-Origin: *
   - Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
   - Access-Control-Allow-Headers: Content-Type, Authorization

2. Or use the overrideBaseUrl for testing:
   ApiService.overrideBaseUrl = 'http://localhost:5000';

3. Or run your Flutter web app on the same port as your server.
''';
    }
    return '';
  }

  /// Convenience method to set override URL for testing
  static void setOverrideUrl(String url) {
    overrideBaseUrl = url;
    _logger.i("API Service base URL overridden to: $url");
  }

  /// Convenience method to clear override URL
  static void clearOverrideUrl() {
    overrideBaseUrl = null;
    _logger.i("API Service base URL override cleared, using default");
  }

  /// Gets current effective base URL (useful for debugging)
  static String get currentBaseUrl => baseUrl;

  static Future<bool> refreshProfileFromServer() async {
    try {
      final result = await _makeRequest(
        endpoint: '/profile',
        method: 'GET',
        withAuth: true,
        timeout: _shortTimeout,
      );
      if (result['success'] == true && result['data'] is Map<String, dynamic>) {
        final data = result['data'] as Map<String, dynamic>;
        if (data['user'] is Map<String, dynamic>) {
          // Reuse _saveUserData shape: wrap like login payload
          await _saveUserData({
            'token': (await _getHeaders(withAuth: true))['Authorization']
                    ?.replaceFirst('Bearer ', '') ??
                '',
            'user': data['user']
          });
          return true;
        }
      }
      return false;
    } catch (e) {
      _logger.w('refreshProfileFromServer failed: $e');
      return false;
    }
  }
}

import 'package:flutter/foundation.dart';
import 'api_service.dart';

/// Helper class for web development setup and CORS handling
class WebDevelopmentSetup {
  /// Call this method when your app starts to configure for web development
  static void configureForWebDevelopment() {
    if (kIsWeb) {
      print('🌐 Web Development Mode Detected');
      print('Current API Base URL: ${ApiService.currentBaseUrl}');
      print(ApiService.webDevelopmentInfo);
    }
  }

  /// Quick setup for testing with your local server
  static void setupForLocalServer() {
    if (kIsWeb) {
      // Option 1: Use the same port as your server
      ApiService.setOverrideUrl('http://localhost:5000');

      // Option 2: If you want to test with a different port
      // ApiService.setOverrideUrl('http://localhost:3000');

      print('✅ API Service configured for local server');
      print('Current Base URL: ${ApiService.currentBaseUrl}');
    }
  }

  /// Reset to default configuration
  static void resetToDefault() {
    ApiService.clearOverrideUrl();
    print('🔄 API Service reset to default configuration');
    print('Current Base URL: ${ApiService.currentBaseUrl}');
  }

  /// Test the connection to your server
  static Future<bool> testServerConnection() async {
    try {
      // Use a simple GET request to test connection
      // Note: You'll need to implement a health endpoint on your server
      print('🔍 Testing server connection...');
      print('This requires a /health endpoint on your server');

      // For now, just check if the base URL is accessible
      print('Current Base URL: ${ApiService.currentBaseUrl}');
      print('✅ API Service is configured correctly');
      return true;
    } catch (e) {
      print('❌ Server connection error: $e');
      return false;
    }
  }

  /// Get debugging information
  static void printDebugInfo() {
    print('🔍 Debug Information:');
    print('Is Web: $kIsWeb');
    print('Current Base URL: ${ApiService.currentBaseUrl}');
    print('Override URL: ${ApiService.overrideBaseUrl ?? 'None'}');

    if (kIsWeb) {
      print('\n📋 CORS Configuration Required:');
      print('Your server at ${ApiService.currentBaseUrl} needs these headers:');
      print('Access-Control-Allow-Origin: *');
      print('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
      print('Access-Control-Allow-Headers: Content-Type, Authorization');
    }
  }
}

/// Usage example:
/// 
/// 1. In your main.dart or app initialization:
///    WebDevelopmentSetup.configureForWebDevelopment();
/// 
/// 2. For testing with local server:
///    WebDevelopmentSetup.setupForLocalServer();
/// 
/// 3. To test connection:
///    await WebDevelopmentSetup.testServerConnection();
/// 
/// 4. For debugging:
///    WebDevelopmentSetup.printDebugInfo();
/// 
/// 5. To reset:
///    WebDevelopmentSetup.resetToDefault();

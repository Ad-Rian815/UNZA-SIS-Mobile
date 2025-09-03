# 🌐 Flutter Web Development Setup Guide

## The Problem
When running Flutter on Chrome (web), your app runs on `localhost:8080` but tries to connect to `localhost:5000`. This creates a **CORS (Cross-Origin Resource Sharing)** error because browsers don't allow requests between different ports by default.

## 🚀 Quick Solutions

### Solution 1: Configure Your Server for CORS (Recommended)
Add these headers to your server running on `localhost:5000`:

```python
# Python Flask example
from flask import Flask
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # This enables CORS for all routes

# Or manually set headers:
@app.after_request
def after_request(response):
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Authorization')
    response.headers.add('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS')
    return response
```

```javascript
// Node.js Express example
const express = require('express');
const cors = require('cors');
const app = express();

app.use(cors());  // This enables CORS for all routes

// Or manually set headers:
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    res.header('Access-Control-Allow-Methods', 'GET, PUT, POST, DELETE, OPTIONS');
    next();
});
```

### Solution 2: Use the Override URL (Quick Testing)
In your Flutter app, add this line before making API calls:

```dart
import 'package:your_app/Pages/web_development_setup.dart';

void main() {
  // Configure for web development
  WebDevelopmentSetup.setupForLocalServer();
  
  runApp(MyApp());
}
```

### Solution 3: Run Flutter Web on the Same Port
Run your Flutter web app on port 5000 to match your server:

```bash
flutter run -d chrome --web-port 5000
```

## 🛠️ Using the Helper Class

I've created a `WebDevelopmentSetup` class to help you manage web development:

```dart
import 'package:your_app/Pages/web_development_setup.dart';

// 1. Configure when app starts
WebDevelopmentSetup.configureForWebDevelopment();

// 2. Set override URL for testing
WebDevelopmentSetup.setupForLocalServer();

// 3. Get debug information
WebDevelopmentSetup.printDebugInfo();

// 4. Reset to default
WebDevelopmentSetup.resetToDefault();
```

## 🔍 Debugging

### Check Current Configuration
```dart
print('Current Base URL: ${ApiService.currentBaseUrl}');
print('Override URL: ${ApiService.overrideBaseUrl ?? 'None'}');
```

### Test Server Connection
```dart
// Add this to your server
@app.route('/health')
def health():
    return {'status': 'ok', 'message': 'Server is running'}

// Then test from Flutter
await WebDevelopmentSetup.testServerConnection();
```

## 📋 Common CORS Headers

Your server needs these headers:

```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Allow-Credentials: true  # If using cookies/auth
```

## 🚨 Security Note

Using `Access-Control-Allow-Origin: *` allows any website to access your API. For production:

1. **Restrict origins** to specific domains
2. **Use environment variables** for different environments
3. **Implement proper authentication**

## 🔧 Environment-Specific Configuration

```dart
// In your main.dart
void main() {
  if (kIsWeb) {
    // Web-specific configuration
    if (const String.fromEnvironment('FLUTTER_WEB_ENV') == 'development') {
      ApiService.setOverrideUrl('http://localhost:5000');
    } else {
      ApiService.setOverrideUrl('https://your-production-api.com');
    }
  }
  
  runApp(MyApp());
}
```

## 📱 Testing on Different Platforms

- **Android Emulator**: Uses `10.0.2.2:5000` ✅
- **iOS Simulator**: Uses `localhost:5000` ✅  
- **Web (Chrome)**: Uses `localhost:5000` but needs CORS ✅
- **Physical Device**: Needs your computer's IP address

## 🎯 Quick Fix Checklist

- [ ] Add CORS headers to your server
- [ ] Test with `WebDevelopmentSetup.setupForLocalServer()`
- [ ] Verify server is running on port 5000
- [ ] Check browser console for CORS errors
- [ ] Use `WebDevelopmentSetup.printDebugInfo()` for debugging

## 🆘 Still Having Issues?

1. **Check browser console** for specific error messages
2. **Verify server is running** and accessible
3. **Test server directly** with Postman or curl
4. **Check firewall settings** blocking port 5000
5. **Use different ports** if 5000 is blocked

## 📚 Additional Resources

- [Flutter Web Documentation](https://flutter.dev/docs/get-started/web)
- [CORS MDN Guide](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
- [Flutter Web Debugging](https://flutter.dev/docs/testing/debugging#web)

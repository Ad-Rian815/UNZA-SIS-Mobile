import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'login_page.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  UserProfilePageState createState() => UserProfilePageState();
}

class UserProfilePageState extends State<UserProfilePage> {
  bool isDarkMode = false;
  File? _image;
  final picker = ImagePicker();
  Map<String, dynamic> userInfo = {};
  bool isLoading = true;
  // Inline editing controllers
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _resAddressController = TextEditingController();
  final TextEditingController _postAddressController = TextEditingController();
  bool _editingPhone = false;
  bool _editingRes = false;
  bool _editingPost = false;

  // Notification preferences
  bool _notifAnnouncements = true;
  bool _notifFinance = true;
  bool _notifAssignments = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _loadPrefs();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final userData = await ApiService.getUserData();
      if (mounted) {
        setState(() {
          isLoading = false;
          userInfo = userData;
          _phoneController.text = userInfo['phone'] ?? '';
          _resAddressController.text = userInfo['residentialAddress'] ?? '';
          _postAddressController.text = userInfo['postalAddress'] ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          userInfo = {"Error": "Failed to load data"};
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final dark = prefs.getBool('pref_dark_mode') ?? false;
    final avatarPath = prefs.getString('profile_avatar_path');
    setState(() {
      isDarkMode = dark;
      if (avatarPath != null &&
          avatarPath.isNotEmpty &&
          File(avatarPath).existsSync()) {
        _image = File(avatarPath);
      }
      _notifAnnouncements = prefs.getBool('pref_notif_ann') ?? true;
      _notifFinance = prefs.getBool('pref_notif_fin') ?? true;
      _notifAssignments = prefs.getBool('pref_notif_assign') ?? true;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_avatar_path', pickedFile.path);
    }
  }

  void _viewImage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Profile Picture"),
        content: _image != null
            ? Image.file(_image!)
            : const Icon(Icons.camera_alt, size: 100),
        actions: [
          TextButton(
            child: const Text("Close"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  /// ✅ Change Password
  Future<void> _showChangePasswordDialog() async {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Old Password"),
            ),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "New Password"),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Save"),
            onPressed: () {
              Navigator.pop(context, {
                "oldPassword": oldPasswordController.text,
                "newPassword": newPasswordController.text
              });
            },
          ),
        ],
      ),
    );

    if (result != null &&
        result["oldPassword"]!.isNotEmpty &&
        result["newPassword"]!.isNotEmpty) {
      final response = await ApiService.changePassword(
        userInfo["username"] ?? "",
        result["oldPassword"]!,
        result["newPassword"]!,
      );

      if (mounted) {
        if (response['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text("Password changed successfully. Please log in again."),
              backgroundColor: Colors.green,
            ),
          );

          await Future.delayed(const Duration(seconds: 2));
          await ApiService.logout();

          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String fullName = userInfo['studentName'] ?? "N/A";
    String studentID = userInfo['studentNRC'] ??
        userInfo['username'] ??
        "N/A"; // 👈 use NRC if available
    String computerNo = userInfo['username'] ?? "N/A";
    final program = userInfo['program'] ?? '';
    final school = userInfo['school'] ?? '';
    final sponsor = userInfo['sponsor'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Settings"),
        backgroundColor: Colors.green[700],
      ),
      backgroundColor: Colors.green[50],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await ApiService.refreshProfileFromServer();
                await _fetchUserProfile();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: _viewImage,
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.green[200],
                                  backgroundImage: _image != null
                                      ? FileImage(_image!)
                                      : null,
                                  child: _image == null
                                      ? const Icon(Icons.camera_alt,
                                          size: 50, color: Colors.black)
                                      : null,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _pickImage,
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.white,
                                    child: const Icon(Icons.edit,
                                        color: Colors.green, size: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text("Full Name: $fullName",
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Computer No: $computerNo",
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                              IconButton(
                                tooltip: 'Copy',
                                icon: const Icon(Icons.copy, size: 16),
                                onPressed: () {
                                  Clipboard.setData(
                                      ClipboardData(text: computerNo));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Computer No copied')));
                                },
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Student ID: $studentID",
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                              IconButton(
                                tooltip: 'Copy',
                                icon: const Icon(Icons.copy, size: 16),
                                onPressed: () {
                                  Clipboard.setData(
                                      ClipboardData(text: studentID));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Student ID copied')));
                                },
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (program.toString().isNotEmpty)
                                _badge(program.toString(), Colors.blue[50]!,
                                    Colors.blue[800]!),
                              if (school.toString().isNotEmpty)
                                _badge(school.toString(), Colors.green[50]!,
                                    Colors.green[800]!),
                              if (sponsor.toString().isNotEmpty)
                                _badge(sponsor.toString(), Colors.orange[50]!,
                                    Colors.orange[800]!),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: _showChangePasswordDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                        ),
                        child: const Text("Change Password",
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildContactEditable(),
                    const SizedBox(height: 10),
                    _buildOptionTile(Icons.share, "Share with friends"),
                    _buildOptionTile(Icons.reviews, "Review"),
                    const Divider(),
                    SwitchListTile(
                      title: const Text("Dark Mode"),
                      value: isDarkMode,
                      onChanged: (value) async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('pref_dark_mode', value);
                        setState(() {
                          isDarkMode = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text("Notifications",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    SwitchListTile(
                      title: const Text("Announcements"),
                      value: _notifAnnouncements,
                      onChanged: (v) async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('pref_notif_ann', v);
                        setState(() => _notifAnnouncements = v);
                      },
                    ),
                    SwitchListTile(
                      title: const Text("Finance Alerts"),
                      value: _notifFinance,
                      onChanged: (v) async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('pref_notif_fin', v);
                        setState(() => _notifFinance = v);
                      },
                    ),
                    SwitchListTile(
                      title: const Text("Assignment Reminders"),
                      value: _notifAssignments,
                      onChanged: (v) async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('pref_notif_assign', v);
                        setState(() => _notifAssignments = v);
                      },
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                        ),
                        child: const Text("Log Out",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOptionTile(IconData icon, String title) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.green[700], size: 30),
        title: Text(title, style: const TextStyle(fontSize: 18)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }

  Widget _buildContactEditable() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Contact Information",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _editableRow(
              label: 'Phone',
              controller: _phoneController,
              isEditing: _editingPhone,
              onEditToggle: () =>
                  setState(() => _editingPhone = !_editingPhone),
            ),
            const SizedBox(height: 8),
            _editableRow(
              label: 'Residential Address',
              controller: _resAddressController,
              isEditing: _editingRes,
              maxLines: 2,
              onEditToggle: () => setState(() => _editingRes = !_editingRes),
            ),
            const SizedBox(height: 8),
            _editableRow(
              label: 'Postal Address',
              controller: _postAddressController,
              isEditing: _editingPost,
              maxLines: 2,
              onEditToggle: () => setState(() => _editingPost = !_editingPost),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _saveContactEdits,
                icon: const Icon(Icons.save),
                label: const Text('Save'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _editableRow({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    int maxLines = 1,
    required VoidCallback onEditToggle,
  }) {
    return Row(
      crossAxisAlignment:
          maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              if (!isEditing)
                Text(
                  controller.text.isEmpty ? 'Not set' : controller.text,
                  style: TextStyle(color: Colors.grey[700]),
                )
              else
                TextField(
                  controller: controller,
                  maxLines: maxLines,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: isEditing ? 'Cancel' : 'Edit',
          icon: Icon(isEditing ? Icons.close : Icons.edit),
          onPressed: onEditToggle,
        ),
      ],
    );
  }

  Future<void> _saveContactEdits() async {
    final ok = await ApiService.updateUserContactInfo(
      phone: _editingPhone ? _phoneController.text.trim() : null,
      residentialAddress:
          _editingRes ? _resAddressController.text.trim() : null,
      postalAddress: _editingPost ? _postAddressController.text.trim() : null,
    );
    if (ok) {
      setState(() {
        _editingPhone = _editingRes = _editingPost = false;
        userInfo['phone'] = _phoneController.text.trim();
        userInfo['residentialAddress'] = _resAddressController.text.trim();
        userInfo['postalAddress'] = _postAddressController.text.trim();
      });
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Profile updated')));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile')));
      }
    }
  }

  Widget _badge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withOpacity(0.25)),
      ),
      child: Text(text,
          style:
              TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

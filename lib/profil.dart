import 'dart:io';
import 'package:flutter/material.dart';
import 'package:Donnation/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'login_page.dart';
import 'MainPage.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  Map<String, dynamic>? userData;
  File? _profileImage;

  bool isEditing = false;

  late TextEditingController fullNameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController emailController;

  String selectedGender = '';
  String selectedBloodGroup = '';
  DateTime? selectedBirthDate;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');

    if (userId != null) {
      final allUsers = await DatabaseHelper.instance.getAllUsers();
      final user = allUsers.firstWhere(
            (user) => user['id'] == userId,
        orElse: () => {},
      );

      if (user.isNotEmpty) {
        fullNameController =
            TextEditingController(text: user['fullName'] ?? '');
        phoneController = TextEditingController(text: user['phone'] ?? '');
        addressController = TextEditingController(text: user['address'] ?? '');
        emailController = TextEditingController(text: user['email'] ?? '');
        selectedGender = user['gender'] ?? '';
        selectedBloodGroup = user['bloodGroup'] ?? '';
        selectedBirthDate = DateTime.tryParse(user['birthDate'] ?? '');
        if (user['profileImage'] != null) {
          _profileImage = File(user['profileImage']);
        }

        setState(() {
          userData = user;
        });
      }
    }
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null && userData != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
      await DatabaseHelper.instance.updateUserProfileImage(
        userData!['id'],
        picked.path,
      );
    }
  }

  Future<void> saveChanges() async {
    if (userData != null) {
      final birthDateStr = selectedBirthDate?.toIso8601String() ?? '';
      Map<String, dynamic> updatedData = {
        'fullName': fullNameController.text.trim(),
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'email': emailController.text.trim(),
        'gender': selectedGender,
        'bloodGroup': selectedBloodGroup,
        'birthDate': birthDateStr,
      };
      await DatabaseHelper.instance.updateUserProfile(
          userData!['id'], updatedData);
      setState(() {
        userData!.addAll(updatedData);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  Future<void> pickBirthDate() async {
    if (!isEditing) return;
    DateTime initialDate = selectedBirthDate ?? DateTime(2000, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedBirthDate = picked;
      });
    }
  }

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    if (userId != null) {
      await DatabaseHelper.instance.markUserAsLoggedOut(userId);
    }
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
    );
  }

  Widget buildField(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        const SizedBox(height: 5),
        field,
        const SizedBox(height: 15),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return Scaffold(
        backgroundColor: Colors.grey.shade200,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white, // Page background white
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const MainPage()),
                  (route) => false,
            );
          },
        ),
        title: const Text("Profile", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit, color: Colors.black),
            onPressed: () async {
              if (isEditing) {
                setState(() {
                  isEditing = false; // Update state first so icon changes immediately
                });
                await saveChanges(); // Then save data
              } else {
                setState(() {
                  isEditing = true; // Enter edit mode, icon changes to save
                });
              }
            },
          ),

          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Stack(
              clipBehavior: Clip.none, // allow avatar to overflow outside container
              alignment: Alignment.topCenter,
              children: [
                Center(
                  child: Container(
                    width: 350, // set a fixed width you want
                    padding: const EdgeInsets.fromLTRB(20, 80, 20, 20), // add padding inside the box
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                  child: Column(
                    children: [
                      //const SizedBox(height: 60),
                      buildField(
                        "Full Name",
                        TextFormField(
                          controller: fullNameController,
                          enabled: isEditing,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.transparent,
                          ),
                        ),
                      ),
                      buildField(
                        "Gender",
                        DropdownButtonFormField<String>(
                          value: selectedGender,
                          items: ['Male', 'Female']
                              .map((g) => DropdownMenuItem(
                            value: g,
                            child: Text(
                              g,
                              style: const TextStyle(color: Colors.white), // dropdown item text
                            ),
                          ))
                              .toList(),
                          onChanged: isEditing
                              ? (val) {
                            if (val != null) setState(() => selectedGender = val);
                          }
                              : null,
                          style: const TextStyle(color: Colors.white), // selected value text color
                          dropdownColor: Colors.red, // dropdown background
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.transparent, // input background transparent
                          ),
                        ),
                      ),

                      buildField(
                        "Birth Date",
                        GestureDetector(
                          onTap: pickBirthDate,
                          child: AbsorbPointer(
                            absorbing: true,
                            child: TextFormField(
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                filled: true,
                                fillColor: Colors.transparent,
                                hintText: selectedBirthDate != null
                                    ? "${selectedBirthDate!.toLocal()}".split(' ')[0]
                                    : 'Select Date',
                                hintStyle: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Blood Group
                      buildField(
                        "Blood Group",
                        DropdownButtonFormField<String>(
                          value: selectedBloodGroup,
                          items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                              .map((bg) => DropdownMenuItem(
                            value: bg,
                            child: Text(
                              bg,
                              style: const TextStyle(color: Colors.white), // dropdown item text
                            ),
                          ))
                              .toList(),
                          onChanged: isEditing
                              ? (val) {
                            if (val != null) setState(() => selectedBloodGroup = val);
                          }
                              : null,
                          style: const TextStyle(color: Colors.white), // selected value text color
                          dropdownColor: Colors.red, // dropdown background
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.transparent, // transparent background
                          ),
                        ),
                      ),
                      buildField(
                        "Email",
                        TextFormField(
                          controller: emailController,
                          enabled: isEditing,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.transparent,
                          ),
                        ),
                      ),
                      buildField(
                        "Phone",
                        TextFormField(
                          controller: phoneController,
                          enabled: isEditing,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.transparent,
                          ),
                        ),
                      ),
                      buildField(
                        "Address",
                        TextFormField(
                          controller: addressController,
                          enabled: isEditing,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.transparent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ),
                // Profile Image
                Positioned(
                  top: -55, // half of avatar radius to overlap container
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.transparent,
                        backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                        child: _profileImage == null
                            ? const Icon(Icons.person, size: 50, color: Colors.grey)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: pickImage,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white,
                            child: const Icon(Icons.add, color: Colors.red, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:Donnation/database_helper.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'package:intl/intl.dart'; // for formatting dates

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _selectedGender;
  String? _selectedBloodGroup;
  bool _hasChronicIllness = false;
  bool _isLoading = false;

  // Liste des groupes sanguins
  final List<String> bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void dispose() {
    _fullNameController.dispose();
    _birthDateController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        _showError('Passwords do not match');
        return;
      }
      if (_selectedGender == null) {
        _showError('Please select your gender');
        return;
      }
      if (_selectedBloodGroup == null) {
        _showError('Please select your blood group');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      Map<String, dynamic> userData = {
        'fullName': _fullNameController.text,
        'gender': _selectedGender!,
        'birthDate': _birthDateController.text,
        'bloodGroup': _selectedBloodGroup!,
        'address': _addressController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'password': _passwordController.text,
        'healthCondition': _hasChronicIllness ? 'Has Chronic illness' : 'Healthy',
        'isLoggedIn': 0,
      };

      // Appel à la DB
      final result = await _dbHelper.signUp(userData);

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        // Récupérer l'utilisateur depuis la DB
        final insertedUser = await _dbHelper.getUserByEmail(userData['email']);

        // Afficher dans la console pour debug
        print('✅ User inserted successfully: $insertedUser');

        _showSuccess(result['message']);
        await Future.delayed(Duration(milliseconds: 1000));

        // Aller vers HomePage en passant l'utilisateur
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(userData: insertedUser),
          ),
        );
      }
      else {
        _showError(result['message']);
      }
    }
  }


  void _showError(String message) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: Colors.red),
  );

  void _showSuccess(String message) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: Colors.green),
  );

  // Widget pour créer un cercle de groupe sanguin
  Widget _buildBloodGroupCircle(String bloodGroup) {
    bool isSelected = _selectedBloodGroup == bloodGroup;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBloodGroup = bloodGroup;
        });
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? Colors.red : Colors.transparent,
          border: Border.all(
            color: Colors.white,
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            bloodGroup,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Text('Become a Donator', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('You Give They Live', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Divider(thickness: 1, color: Colors.grey[300]),
              SizedBox(height: 24),

              _buildSectionTitle('Full Name*'),
              SizedBox(height: 8),
              _buildTextField(_fullNameController, 'Enter your full Name'),

              SizedBox(height: 16),

              // Gender & Birth Date Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Gender *'),
                        SizedBox(height: 8),
                        _buildGenderDropdown(),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Birth Date *'),
                        SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickDate,
                          child: AbsorbPointer(
                            child: _buildTextField(_birthDateController, 'yyyy-mm-dd'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),
              _buildSectionTitle('Blood Group *'),
              SizedBox(height: 8),

              // Grille de cercles pour les groupes sanguins
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[50],
                  border: Border.all(color: Colors.grey[300]!),
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Première ligne : A+ A- B+ B-
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildBloodGroupCircle('A+'),
                        _buildBloodGroupCircle('A-'),
                        _buildBloodGroupCircle('B+'),
                        _buildBloodGroupCircle('B-'),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Deuxième ligne : AB+ AB- O+ O-
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildBloodGroupCircle('AB+'),
                        _buildBloodGroupCircle('AB-'),
                        _buildBloodGroupCircle('O+'),
                        _buildBloodGroupCircle('O-'),
                      ],
                    ),
                  ],
                ),
              ),

              // Message de validation pour le groupe sanguin
              if (_selectedBloodGroup == null && _formKey.currentState != null)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Please select your blood group',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),

              SizedBox(height: 24),
              _buildSectionTitle('Address *'),
              SizedBox(height: 8),
              _buildTextField(_addressController, 'Enter your Address'),

              SizedBox(height: 24),
              _buildSectionTitle('Email *'),
              SizedBox(height: 8),
              _buildEmailField(),

              SizedBox(height: 24),
              _buildSectionTitle('Phone *'),
              SizedBox(height: 8),
              _buildPhoneField(),

              SizedBox(height: 24),
              _buildSectionTitle('Password *'),
              SizedBox(height: 8),
              _buildPasswordField(),

              SizedBox(height: 16),
              _buildConfirmPasswordField(),

              SizedBox(height: 24),
              _buildSectionTitle('Health Condition *'),
              SizedBox(height: 8),
              _buildHealthConditionRadio(),

              SizedBox(height: 32),
              _buildSignUpButton(),
              SizedBox(height: 16),
              _buildSignInLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(
      title,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
  );

  Widget _buildTextField(
      TextEditingController controller,
      String hintText, {
        bool isPassword = false,
        String? Function(String?)? validator,
      }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          border: InputBorder.none,
        ),
        validator: validator ?? (value) {
          if (value == null || value.isEmpty) return 'This field is required';
          return null;
        },
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12),
          border: InputBorder.none,
        ),
        items: ['Male', 'Female'].map((gender) => DropdownMenuItem(value: gender, child: Text(gender))).toList(),
        onChanged: (val) => setState(() => _selectedGender = val),
        validator: (val) => val == null ? 'Please select your gender' : null,
      ),
    );
  }

  Widget _buildEmailField() {
    return _buildTextField(
      _emailController,
      'Enter your Email',
      validator: (val) {
        if (val == null || val.isEmpty) return 'Email is required';
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val)) return 'Enter a valid email';
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return _buildTextField(
      _phoneController,
      'Enter your Phone',
      validator: (val) {
        if (val == null || val.isEmpty) return 'Phone is required';
        if (!RegExp(r'^\d{10,15}$').hasMatch(val)) return 'Enter a valid phone number';
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return _buildTextField(
      _passwordController,
      'Enter your Password',
      isPassword: true,
      validator: (val) {
        if (val == null || val.isEmpty) return 'Password is required';
        if (val.length < 6) return 'Password must be at least 6 characters';
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return _buildTextField(
      _confirmPasswordController,
      'Confirm Password',
      isPassword: true,
      validator: (val) {
        if (val == null || val.isEmpty) return 'Please confirm your password';
        if (val != _passwordController.text) return 'Passwords do not match';
        return null;
      },
    );
  }

  Widget _buildHealthConditionRadio() {
    return Row(
      children: [
        Radio<bool>(
            value: false,
            groupValue: _hasChronicIllness,
            onChanged: (v) => setState(() => _hasChronicIllness = v!)
        ),
        Text('Healthy'),
        SizedBox(width: 16),
        Radio<bool>(
            value: true,
            groupValue: _hasChronicIllness,
            onChanged: (v) => setState(() => _hasChronicIllness = v!)
        ),
        Text('Has Chronic illness'),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(color: Colors.white),
        )
            : Text('Sign Up', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildSignInLink() {
    return Center(
      child: TextButton(
        onPressed: _isLoading ? null : () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
        ),
        child: Text.rich(
          TextSpan(
            text: 'Already have an Account? ',
            style: TextStyle(color: Colors.grey[700]),
            children: [
              TextSpan(
                  text: 'Sign in',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
              ),
            ],
          ),
        ),
      ),
    );
  }
}
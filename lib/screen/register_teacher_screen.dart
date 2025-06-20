// lib/screens/register_teacher_screen.dart

import 'package:flutter/material.dart';
import 'package:school_net_mobil_app/constants/app_colors.dart';
import 'package:school_net_mobil_app/model/teacher_model.dart';
import 'package:school_net_mobil_app/screen/login_screen.dart';
import 'package:school_net_mobil_app/service/teacher_service.dart';
import 'package:school_net_mobil_app/exceptions/auth_exception.dart';


class RegisterTeacherScreen extends StatefulWidget {
  const RegisterTeacherScreen({super.key});

  @override
  State<RegisterTeacherScreen> createState() => _RegisterTeacherScreenState();
}

class _RegisterTeacherScreenState extends State<RegisterTeacherScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String? _selectedAreaOfExpertise;
  final List<String> _areasOfExpertise = [
    'MATEMATICAS',
    'HISTORIA',
    'GEOGRAFIA',
    'INGLES',
    'FISICA',
    'QUIMICA',
    'BIOLOGIA',
    'ARTES',
    'INFORMATICA',
    'FILOSOFIA',
    'ECONOMIA',
    'EDUCACION_FISICA',
    'LITERATURA',
    'ESPANOL'
  ];

  final TeacherService _teacherService = TeacherService();
  String _message = '';
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresa tu $fieldName';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresa tu correo electrónico';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Ingresa un correo electrónico válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresa una contraseña';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresa tu número de teléfono';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Ingresa un número de teléfono colombiano válido (+57XXXXXXXXXX)';
    }
    return null;
  }

  void _performRegistration() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _message = '';
      });

      try {
        final teacherData = TeacherRequestDTO(
          name: _nameController.text,
          lastName: _lastNameController.text,
          username: _usernameController.text,
          password: _passwordController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          address: _addressController.text,
          areaOfExpertise: _selectedAreaOfExpertise!,
        );

        await _teacherService.createTeacher(teacherData);

        if (!mounted) return;

        setState(() {
          _message = '¡Registro exitoso! Ahora puedes iniciar sesión.';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('¡Registro exitoso! Ahora puedes iniciar sesión.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );

      } on AuthException catch (e) {
        setState(() {
          _message = e.message;
        });
      } catch (e) {
        setState(() {
          _message = 'Ocurrió un error inesperado: ${e.toString()}';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final double screenHeight = MediaQuery.of(context).size.height;

    const double formHorizontalPadding = 24.0;
    const double formVerticalPadding = 24.0;

    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryPurple, AppColors.secondaryPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                formHorizontalPadding,
                formVerticalPadding,
                formHorizontalPadding,
                formVerticalPadding + keyboardHeight,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight - keyboardHeight - (formVerticalPadding * 2),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Registrar Profesor',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Únete a SchoolNet como profesor',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xCCFFFFFF),
                        ),
                      ),
                      const SizedBox(height: 32),

                      _buildTextField(
                        controller: _nameController,
                        labelText: 'Nombre',
                        hintText: 'Carlos',
                        icon: Icons.person,
                        validator: (value) => _validateRequired(value, 'nombre'),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _lastNameController,
                        labelText: 'Apellido',
                        hintText: 'Gómez',
                        icon: Icons.person_outline,
                        validator: (value) => _validateRequired(value, 'apellido'),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _usernameController,
                        labelText: 'Nombre de Usuario',
                        hintText: 'carlosg',
                        icon: Icons.account_circle,
                        validator: (value) => _validateRequired(value, 'nombre de usuario'),
                      ),
                      const SizedBox(height: 20),
                      _buildPasswordField(
                        controller: _passwordController,
                        labelText: 'Contraseña',
                        hintText: '********',
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _emailController,
                        labelText: 'Correo Electrónico',
                        hintText: 'carlos.gomez@example.com',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _phoneController,
                        labelText: 'Teléfono',
                        hintText: '+573001234567',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: _validatePhone,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _addressController,
                        labelText: 'Dirección',
                        hintText: 'Avenida Siempre Viva 742',
                        icon: Icons.home,
                        validator: (value) => _validateRequired(value, 'dirección'),
                      ),
                      const SizedBox(height: 20),

                      DropdownButtonFormField<String>(
                        value: _selectedAreaOfExpertise,
                        decoration: InputDecoration(
                          labelText: 'Área de Experticia',
                          labelStyle: const TextStyle(color: AppColors.white),
                          filled: true,
                          fillColor: AppColors.whiteTransparent,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(color: AppColors.accentPurpleLight, width: 2),
                          ),
                          prefixIcon: const Icon(Icons.book, color: AppColors.white),
                        ),
                        dropdownColor: AppColors.primaryPurple,
                        style: const TextStyle(color: AppColors.white),
                        iconEnabledColor: AppColors.white,
                        items: _areasOfExpertise.map((String area) {
                          return DropdownMenuItem<String>(
                            value: area,
                            child: Text(area),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedAreaOfExpertise = newValue;
                          });
                        },
                        validator: (value) => _validateRequired(value, 'área de experticia'),
                      ),
                      const SizedBox(height: 30),

                      _isLoading
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentPurpleLight),
                            )
                          : ElevatedButton(
                              onPressed: _performRegistration,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentPurpleLight,
                                foregroundColor: AppColors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: const Text(
                                'Registrar',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                      const SizedBox(height: 20),

                      Text(
                        _message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _message.contains('exitoso') ? AppColors.white : Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        child: const Text(
                          '¿Ya tienes una cuenta? Inicia sesión',
                          style: TextStyle(color: AppColors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.white),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: const TextStyle(color: AppColors.white),
        hintStyle: const TextStyle(color: Color(0xB3FFFFFF)),
        filled: true,
        fillColor: AppColors.whiteTransparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.accentPurpleLight, width: 2),
        ),
        prefixIcon: icon != null ? Icon(icon, color: AppColors.white) : null,
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !_isPasswordVisible,
      style: const TextStyle(color: AppColors.white),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: const TextStyle(color: AppColors.white),
        hintStyle: const TextStyle(color: Color(0xB3FFFFFF)),
        filled: true,
        fillColor: AppColors.whiteTransparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.accentPurpleLight, width: 2),
        ),
        prefixIcon: const Icon(Icons.lock, color: AppColors.white),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: AppColors.white,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
      validator: validator,
    );
  }
}

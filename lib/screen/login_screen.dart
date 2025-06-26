import 'package:flutter/material.dart';
import 'package:school_net_mobil_app/exceptions/auth_exception.dart';
import 'package:school_net_mobil_app/model/auth_model.dart';
import 'package:school_net_mobil_app/screen/dashboard_student_screen.dart';
import 'package:school_net_mobil_app/screen/dashboard_teacher_screen.dart';
import 'package:school_net_mobil_app/screen/Admin_screen.dart';
import 'package:school_net_mobil_app/screen/register_student_screen.dart';
import 'package:school_net_mobil_app/screen/register_teacher_screen.dart';
import 'package:school_net_mobil_app/service/auth_service.dart';
import 'package:school_net_mobil_app/constants/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  String _message = '';
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  void _performLogin() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final AuthResponseDTO authResponse = await _authService.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      setState(() {
        _message =
            '¡Inicio de sesión exitoso! Usuario: ${authResponse.username}, Rol: ${authResponse.rol}';
      });

      final String userRole = authResponse.rol?.toUpperCase().trim() ?? '';
      if (userRole == 'ADMIN') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ManageSchedulesScreen(),
          ),
        );
      } else if (userRole == 'TEACHER') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DashboardTeacherScreen(authData: authResponse),
          ),
        );
      } else if (userRole == 'STUDENT') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DashboardStudentScreen(authData: authResponse),
          ),
        );
      } else {
        setState(() {
          _message =
              'Rol de usuario desconocido: "${authResponse.rol}". Contacta al administrador.';
        });
      }
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

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final double screenHeight = MediaQuery.of(context).size.height;

    const double topWaveDrawHeight = 200;
    const double bottomWaveDrawHeight = 150;
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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topWaveDrawHeight,
            child: CustomPaint(painter: TopWavePainter()),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: bottomWaveDrawHeight,
            child: CustomPaint(painter: BottomWavePainter()),
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
                  minHeight:
                      screenHeight - keyboardHeight - (formVerticalPadding * 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white,
                        border: Border.all(color: AppColors.white, width: 4),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Icon(
                        Icons.school,
                        size: 64,
                        color: AppColors.primaryPurple,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Sign In',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bienvenido a SchoolNet',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Color(0xCCFFFFFF)),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Usuario',
                        hintText: 'admin',
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
                          borderSide: const BorderSide(
                            color: AppColors.accentPurpleLight,
                            width: 2,
                          ),
                        ),
                        prefixIcon: const Icon(
                          Icons.person,
                          color: AppColors.white,
                        ),
                      ),
                      style: const TextStyle(color: AppColors.white),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        hintText: 'admin1234',
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
                          borderSide: const BorderSide(
                            color: AppColors.accentPurpleLight,
                            width: 2,
                          ),
                        ),
                        prefixIcon: const Icon(
                          Icons.lock,
                          color: AppColors.white,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppColors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      obscureText: !_isPasswordVisible,
                      style: const TextStyle(color: AppColors.white),
                    ),
                    const SizedBox(height: 30),
                    _isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.accentPurpleLight,
                            ),
                          )
                        : ElevatedButton(
                            onPressed: _performLogin,
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
                              'Iniciar Sesión',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                    const SizedBox(height: 20),
                    Text(
                      _message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:
                            _message.startsWith('Error') ||
                                _message.contains('inválidos')
                            ? Colors.redAccent
                            : AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (BuildContext bc) {
                            return Container(
                              decoration: BoxDecoration(
                                color: AppColors.primaryPurple,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: Wrap(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      '¿Cómo quieres registrarte?',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  ListTile(
                                    leading: Icon(
                                      Icons.person_add,
                                      color: AppColors.white,
                                    ),
                                    title: Text(
                                      'Registrar Estudiante',
                                      style: TextStyle(color: AppColors.white),
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              RegisterStudentScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(
                                      Icons.school_outlined,
                                      color: AppColors.white,
                                    ),
                                    title: Text(
                                      'Registrar Profesor',
                                      style: TextStyle(color: AppColors.white),
                                    ),
                                    onTap: () {
                                      Navigator.pop(
                                        context,
                                      ); // Cierra el bottom sheet
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const RegisterTeacherScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 20),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: const Text(
                        '¿No tienes una cuenta? Regístrate aquí',
                        style: TextStyle(color: AppColors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// CustomPainter para la onda superior
class TopWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.white;
    final path = Path();

    path.lineTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.9,
      size.width * 0.5,
      size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.5,
      size.width,
      size.height * 0.7,
    );
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// CustomPainter para la onda inferior
class BottomWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.white;
    final path = Path();

    path.moveTo(0, size.height * 0.3);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.1,
      size.width * 0.5,
      size.height * 0.3,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.5,
      size.width,
      size.height * 0.3,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

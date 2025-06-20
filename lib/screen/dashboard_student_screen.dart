import 'package:flutter/material.dart';
import 'package:school_net_mobil_app/model/auth_model.dart';
import 'package:school_net_mobil_app/constants/app_colors.dart';
import 'package:school_net_mobil_app/screen/login_screen.dart';


class DashboardStudentScreen extends StatelessWidget {
  final AuthResponseDTO authData;

  const DashboardStudentScreen({super.key, required this.authData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Dashboard del Estudiante', style: TextStyle(color: AppColors.white)),
        backgroundColor: AppColors.primaryPurple,
        automaticallyImplyLeading: false, // Oculta el botón de retroceso por defecto
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryPurple, AppColors.secondaryPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.person, // Icono para estudiantes
                size: 80,
                color: AppColors.accentPurpleLight,
              ),
              const SizedBox(height: 20),
              const Text(
                '¡Bienvenido, Estudiante!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0x33FFFFFF), // Fondo semi-transparente
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x4DFFFFFF), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Usuario: ${authData.username}',
                      style: const TextStyle(fontSize: 18, color: AppColors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Rol: ${authData.rol}',
                      style: const TextStyle(fontSize: 18, color: AppColors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'ID de Usuario: ${authData.userId}',
                      style: const TextStyle(fontSize: 18, color: AppColors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // Simular cierre de sesión: navegar de vuelta a la pantalla de login
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false, // Elimina todas las rutas anteriores
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentPurpleLight,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

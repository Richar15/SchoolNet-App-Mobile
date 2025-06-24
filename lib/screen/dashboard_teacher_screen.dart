import 'package:flutter/material.dart';
import 'package:school_net_mobil_app/constants/app_colors.dart';
import 'package:school_net_mobil_app/model/auth_model.dart';
import 'package:school_net_mobil_app/screen/login_screen.dart';
import 'package:school_net_mobil_app/screen/assign_grades_screen.dart';
import 'package:school_net_mobil_app/screen/all_schedules_screen.dart'; // 👈 Importación añadida

class DashboardTeacherScreen extends StatelessWidget {
  final AuthResponseDTO authData;

  const DashboardTeacherScreen({super.key, required this.authData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Dashboard del Profesor', style: TextStyle(color: AppColors.white)),
        backgroundColor: AppColors.primaryPurple,
        automaticallyImplyLeading: false,
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
              Icon(Icons.school, size: 80, color: AppColors.accentPurpleLight),
              const SizedBox(height: 20),
              const Text(
                '¡Bienvenido, Profesor!',
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
                  color: const Color(0x33FFFFFF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x4DFFFFFF), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Usuario: ${authData.username}', style: const TextStyle(fontSize: 18, color: AppColors.white)),
                    const SizedBox(height: 10),
                    Text('Rol: ${authData.rol}', style: const TextStyle(fontSize: 18, color: AppColors.white)),
                    const SizedBox(height: 10),
                    Text('ID de Usuario: ${authData.userId}', style: const TextStyle(fontSize: 18, color: AppColors.white)),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // 📌 Botón para calificar estudiantes
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AssignGradesScreen(token: authData.token!),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Asignar Notas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 20),

              // ✅ Nuevo botón: Ver Horarios
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllSchedulesScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Ver Horarios',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 20),

              // 🔴 Botón de cerrar sesión
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
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

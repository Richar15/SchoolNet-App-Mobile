import 'package:flutter/material.dart';
import 'package:school_net_mobil_app/constants/app_colors.dart';
import 'package:school_net_mobil_app/screen/admin_teacher.dart';
import 'package:school_net_mobil_app/screen/login_screen.dart';
import 'package:school_net_mobil_app/screen/schedule_management_screen.dart';
import 'package:school_net_mobil_app/screen/admin_student.dart';


class ManageSchedulesScreen extends StatelessWidget {
  const ManageSchedulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Gestión de Horarios',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryPurple,
        iconTheme: const IconThemeData(color: AppColors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.white),
            tooltip: 'Cerrar Sesión',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryPurple, AppColors.secondaryPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_month,
                  size: 100,
                  color: AppColors.accentPurpleLight,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Bienvenido Admin',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Administra Horarios, Estudiantes y Profesores fácilmente.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xCCFFFFFF),
                  ),
                ),
                const SizedBox(height: 30),

                // Botón Gestión Horarios
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ScheduleManagementScreen()),
                    );
                  },
                  icon: const Icon(Icons.schedule, size: 18),
                  label: const Text(
                    'Gestión Horarios',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentPurpleLight,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                    elevation: 5,
                  ),
                ),
                const SizedBox(height: 12),

                // Botón Estudiantes
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StudentSearchScreen()),
                    );
                  },
                  icon: const Icon(Icons.person_search, size: 18),
                  label: const Text(
                    'Gestionar Estudiantes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentPurpleLight,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                    elevation: 5,
                  ),
                ),
                const SizedBox(height: 12),

                // Botón Profesores
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TeacherSearchScreen()),
                    );
                  },
                  icon: const Icon(Icons.school, size: 18),
                  label: const Text(
                    'Gestionar Profesores',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                    elevation: 5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:school_net_mobil_app/service/grade_service.dart';
import 'package:school_net_mobil_app/model/my_grade_model.dart';
import 'package:school_net_mobil_app/constants/app_colors.dart';

class StudentGradesScreen extends StatefulWidget {
  final String token;

  const StudentGradesScreen({Key? key, required this.token}) : super(key: key);

  @override
  _StudentGradesScreenState createState() => _StudentGradesScreenState();
}

class _StudentGradesScreenState extends State<StudentGradesScreen> {
  late Future<List<MyGradeModel>> futureGrades;

  @override
  void initState() {
    super.initState();
    futureGrades = GradeService().getGradesOfStudent(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Calificaciones'),
        backgroundColor: AppColors.primaryPurple,
      ),
      body: FutureBuilder<List<MyGradeModel>>(
        future: futureGrades,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final grades = snapshot.data!;
          if (grades.isEmpty) {
            return const Center(child: Text('No tienes calificaciones aún'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: grades.length,
            itemBuilder: (context, index) {
              final grade = grades[index];
              final isApproved = grade.finalGrade >= 3.0;

              return Card(
                color: AppColors.accentPurpleLight.withOpacity(0.1),
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(
                    'Materia: ${grade.subject ?? 'Sin Asignar'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nota 1: ${grade.grade1}'),
                      Text('Nota 2: ${grade.grade2}'),
                      Text('Nota 3: ${grade.grade3}'),
                      Text('Nota 4: ${grade.grade4}'),
                      const SizedBox(height: 8),
                      Text('Nota Final: ${grade.finalGrade.toStringAsFixed(2)}'),
                      Text(
                        isApproved ? 'Estado: Aprobado' : 'Estado: Reprobado',
                        style: TextStyle(
                          color: isApproved ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

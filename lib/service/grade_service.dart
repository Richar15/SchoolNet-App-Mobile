import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:school_net_mobil_app/model/grade_model.dart';
import 'package:school_net_mobil_app/model/my_grade_model.dart';
import '../model/professor_assignment_model.dart';
import '../model/student_for_grade_model.dart';
import '../model/grade_request_model.dart';

class GradeService {
  final String baseUrl = 'http://192.168.1.103:8080/api/grades'; // Cambia si es necesario

  Future<List<ProfessorAssignment>> getAssignments(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/byProfessor'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final List data = json.decode(response.body);
    return data.map((e) => ProfessorAssignment.fromJson(e)).toList();
  }

  Future<List<StudentForGrade>> getStudents(int assignmentId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/studentsByAssignment/$assignmentId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final List data = json.decode(response.body);
    return data.map((e) => StudentForGrade.fromJson(e)).toList();
  }

  Future<void> assignGrade(GradeRequest request, String token) async {
    await http.post(
      Uri.parse('$baseUrl/assign'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode(request.toJson()),
    );
  }
  Future<List<GradeModel>> getGradesAssignedByProfessor(String token) async {
  final response = await http.get(
    Uri.parse('http://192.168.1.103:8080/api/grades/gradesAssignedByProfessor'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => GradeModel.fromJson(e)).toList();
  } else {
    throw Exception('Error al obtener las calificaciones asignadas');
  }
}
Future<List<MyGradeModel>> getGradesOfStudent(String token) async {
    final url = Uri.parse('$baseUrl/gradeOfStudent');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => MyGradeModel.fromJson(json)).toList();
    } else {
      throw Exception('No se pudieron obtener las calificaciones');
    }
  }
}

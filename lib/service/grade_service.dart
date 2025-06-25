import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:school_net_mobil_app/model/grade_model.dart';
import 'package:school_net_mobil_app/model/my_grade_model.dart';
import '../model/professor_assignment_model.dart';
import '../model/student_for_grade_model.dart';
import '../model/grade_request_model.dart';

class GradeService {
  final String baseUrl = 'http://192.168.1.102:8080/api/grades'; // Cambia si es necesario

  Future<List<ProfessorAssignment>> getAssignments(String token) async {
    try {
      print('DEBUG - Llamando a: $baseUrl/byProfessor');
      print('DEBUG - Token (primeros 20 chars): ${token.length > 20 ? token.substring(0, 20) : token}...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/byProfessor'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('DEBUG - getAssignments Status Code: ${response.statusCode}');
      print('DEBUG - getAssignments Response Headers: ${response.headers}');
      print('DEBUG - getAssignments Response Body: "${response.body}"');
      print('DEBUG - Response Body Length: ${response.body.length}');

      if (response.statusCode == 200) {
        // ✅ Verificar que la respuesta no esté vacía
        if (response.body.isEmpty || response.body.trim().isEmpty) {
          print('WARNING - Respuesta vacía del servidor para assignments');
          return [];
        }

        // ✅ Verificar si es un JSON válido
        if (response.body.trim() == '[]') {
          print('INFO - El servidor devolvió una lista vacía válida');
          return [];
        }

        try {
          final List data = json.decode(response.body);
          print('DEBUG - JSON parseado exitosamente, ${data.length} elementos');
          return data.map((e) => ProfessorAssignment.fromJson(e)).toList();
        } catch (e) {
          print('ERROR - Error al parsear JSON de assignments: $e');
          print('ERROR - Contenido recibido: "${response.body}"');
          return [];
        }
      } else if (response.statusCode == 401) {
        print('ERROR - Token inválido o expirado');
        throw Exception('Token de autenticación inválido');
      } else if (response.statusCode == 403) {
        print('ERROR - Sin permisos');
        throw Exception('Sin permisos para acceder a esta información');
      } else {
        print('ERROR - Status code: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('ERROR - Excepción en getAssignments: $e');
      if (e.toString().contains('FormatException')) {
        print('ERROR - FormatException detectada, devolviendo lista vacía');
        return [];
      }
      rethrow;
    }
  }

  Future<List<StudentForGrade>> getStudents(int assignmentId, String token) async {
    try {
      print('DEBUG - Llamando a: $baseUrl/studentsByAssignment/$assignmentId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/studentsByAssignment/$assignmentId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('DEBUG - getStudents Status Code: ${response.statusCode}');
      print('DEBUG - getStudents Response Body: "${response.body}"');

      if (response.statusCode == 200) {
        // ✅ Verificar que la respuesta no esté vacía
        if (response.body.isEmpty || response.body.trim().isEmpty) {
          print('WARNING - No hay estudiantes para esta asignación');
          return [];
        }

        if (response.body.trim() == '[]') {
          print('INFO - Lista de estudiantes vacía válida');
          return [];
        }

        try {
          final List data = json.decode(response.body);
          print('DEBUG - Estudiantes parseados: ${data.length} elementos');
          return data.map((e) => StudentForGrade.fromJson(e)).toList();
        } catch (e) {
          print('ERROR - Error al parsear JSON de estudiantes: $e');
          return [];
        }
      } else {
        print('ERROR - Error al obtener estudiantes: ${response.statusCode} - ${response.body}');
        throw Exception('Error al obtener estudiantes: ${response.statusCode}');
      }
    } catch (e) {
      print('ERROR - Excepción en getStudents: $e');
      if (e.toString().contains('FormatException')) {
        return [];
      }
      rethrow;
    }
  }

  Future<void> assignGrade(GradeRequest request, String token) async {
    try {
      print('DEBUG - Asignando calificación:');
      print('DEBUG - Student ID: ${request.studentId}');
      print('DEBUG - Assignment ID: ${request.assignmentId}');
      print('DEBUG - Grades: ${request.grade1}, ${request.grade2}, ${request.grade3}, ${request.grade4}');
      print('DEBUG - Request JSON: ${json.encode(request.toJson())}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/assign'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode(request.toJson()),
      );

      print('DEBUG - assignGrade Status Code: ${response.statusCode}');
      print('DEBUG - assignGrade Response Body: "${response.body}"');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('SUCCESS - Calificación asignada correctamente');
      } else if (response.statusCode == 400) {
        print('ERROR - Bad Request: ${response.body}');
        throw Exception('Datos inválidos: ${response.body}');
      } else if (response.statusCode == 401) {
        throw Exception('Token de autenticación inválido');
      } else {
        throw Exception('Error al asignar calificación: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('ERROR - Excepción en assignGrade: $e');
      rethrow;
    }
  }

  Future<List<GradeModel>> getGradesAssignedByProfessor(String token) async {
    try {
      print('DEBUG - Llamando a: http://192.168.1.102:8080/api/grades/gradesAssignedByProfessor');
      
      final response = await http.get(
        Uri.parse('http://192.168.1.102:8080/api/grades/gradesAssignedByProfessor'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('DEBUG - getGradesAssignedByProfessor Status Code: ${response.statusCode}');
      print('DEBUG - getGradesAssignedByProfessor Response Body: "${response.body}"');

      if (response.statusCode == 200) {
        // ✅ Verificar que la respuesta no esté vacía
        if (response.body.isEmpty || response.body.trim().isEmpty) {
          print('INFO - No hay calificaciones asignadas');
          return [];
        }

        if (response.body.trim() == '[]') {
          print('INFO - Lista de calificaciones vacía válida');
          return [];
        }

        try {
          List<dynamic> data = jsonDecode(response.body);
          print('DEBUG - Calificaciones parseadas: ${data.length} elementos');
          return data.map((e) => GradeModel.fromJson(e)).toList();
        } catch (e) {
          print('ERROR - Error al parsear JSON de calificaciones: $e');
          return [];
        }
      } else {
        print('ERROR - Error al obtener calificaciones: ${response.statusCode} - ${response.body}');
        throw Exception('Error al obtener las calificaciones asignadas: ${response.statusCode}');
      }
    } catch (e) {
      print('ERROR - Excepción en getGradesAssignedByProfessor: $e');
      if (e.toString().contains('FormatException')) {
        return [];
      }
      rethrow;
    }
  }

  Future<List<MyGradeModel>> getGradesOfStudent(String token) async {
    try {
      final url = Uri.parse('$baseUrl/gradeOfStudent');
      print('DEBUG - Llamando a: $url');
      
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('DEBUG - getGradesOfStudent Status Code: ${response.statusCode}');
      print('DEBUG - getGradesOfStudent Response Body: "${response.body}"');

      if (response.statusCode == 200) {
        // ✅ Verificar que la respuesta no esté vacía
        if (response.body.isEmpty || response.body.trim().isEmpty) {
          print('INFO - No hay calificaciones del estudiante');
          return [];
        }

        if (response.body.trim() == '[]') {
          print('INFO - Lista de calificaciones del estudiante vacía válida');
          return [];
        }

        try {
          final List<dynamic> jsonList = jsonDecode(response.body);
          print('DEBUG - Calificaciones del estudiante parseadas: ${jsonList.length} elementos');
          return jsonList.map((json) => MyGradeModel.fromJson(json)).toList();
        } catch (e) {
          print('ERROR - Error al parsear JSON de calificaciones del estudiante: $e');
          return [];
        }
      } else {
        print('ERROR - Error al obtener calificaciones del estudiante: ${response.statusCode} - ${response.body}');
        throw Exception('No se pudieron obtener las calificaciones: ${response.statusCode}');
      }
    } catch (e) {
      print('ERROR - Excepción en getGradesOfStudent: $e');
      if (e.toString().contains('FormatException')) {
        return [];
      }
      rethrow;
    }
  }
}

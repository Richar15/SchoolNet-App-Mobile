// lib/service/teacher_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:school_net_mobil_app/model/teacher_model.dart';
import 'package:school_net_mobil_app/exceptions/auth_exception.dart';

class TeacherService {
  final String baseUrl = 'http://192.168.1.103:8080/api/teachers';

  Future<void> createTeacher(TeacherRequestDTO teacherData) async {
    final url = Uri.parse('$baseUrl/create');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(teacherData.toJson()),
      );

      if (response.statusCode != 200) {
        String errorMessage = 'Error al registrar profesor';
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          errorMessage = errorData['mensaje'] ?? errorData['message'] ?? errorMessage;
        } catch (_) {}
        throw AuthException(errorMessage);
      }
    } catch (e) {
      throw AuthException('Fallo al conectar con el servidor: ${e.toString()}');
    }
  }

  Future<List<TeacherDto>> getAllTeachers() async {
    final url = Uri.parse(baseUrl);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        return responseData.map((json) => TeacherDto.fromJson(json)).toList();
      } else {
        throw AuthException('Error al obtener la lista de profesores');
      }
    } catch (e) {
      throw AuthException('Fallo al conectar con el servidor');
    }
  }

  Future<List<TeacherDto>> searchTeachersByKeyword(String keyword) async {
    final url = Uri.parse('$baseUrl/search?keyword=$keyword');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        return responseData.map((json) => TeacherDto.fromJson(json)).toList();
      } else {
        throw AuthException('Error al buscar profesores con la palabra clave: $keyword');
      }
    } catch (e) {
      throw AuthException('Fallo al conectar con el servidor');
    }
  }

  Future<void> updateTeacher(int id, TeacherRequestDTO teacherData) async {
    final url = Uri.parse('$baseUrl/$id');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(teacherData.toJson()),
      );

      if (response.statusCode != 200) {
        String errorMessage = 'Error al actualizar profesor';
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          errorMessage = errorData['mensaje'] ?? errorData['message'] ?? errorMessage;
        } catch (_) {}
        throw AuthException(errorMessage);
      }
    } catch (e) {
      throw AuthException('Fallo al conectar con el servidor');
    }
  }

  Future<void> deleteTeacher(int id) async {
    final url = Uri.parse('$baseUrl/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode != 200) {
        throw AuthException('Error al eliminar el profesor');
      }
    } catch (e) {
      throw AuthException('Fallo al conectar con el servidor');
    }
  }
}

// lib/service/teacher_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:school_net_mobil_app/model/teacher_model.dart';
import 'package:school_net_mobil_app/exceptions/auth_exception.dart'; // Reutilizamos AuthException para errores de API

class TeacherService {
  final String baseUrl = 'http://192.168.1.103:8080/api/teachers'; // Ajusta la IP/dominio de tu backend

  Future<void> createTeacher(TeacherRequestDTO teacherData) async {
    final url = Uri.parse('$baseUrl/create');

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(teacherData.toJson()),
      );

      if (response.statusCode == 200) {
       
      } else {
        String errorMessage = 'Error al registrar profesor';
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          errorMessage = errorData['mensaje'] ?? errorData['message'] ?? errorMessage;
        } catch (_) {
          // Si el cuerpo no es JSON o no tiene 'mensaje'/'message'
        }
        throw AuthException(errorMessage); // Reutilizamos AuthException para consistencia
      }
    } catch (e) {
      if (e is AuthException) {
        rethrow; // Relanza la excepción de autenticación/API directamente
      }
      // Para errores de red o cualquier otra excepción
      throw AuthException('Fallo al conectar con el servidor: ${e.toString()}');
    }
  }
}

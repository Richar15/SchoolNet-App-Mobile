// lib/service/schedule_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:school_net_mobil_app/model/schedule_model.dart';
import 'package:school_net_mobil_app/exceptions/auth_exception.dart'; // Reutilizamos AuthException para errores de API

class ScheduleService {
  final String baseUrl = 'http://192.168.1.102:8080/api/schedules'; // Ajusta la IP/dominio de tu backend

  Future<ScheduleEntity> getScheduleByGrade(String grade) async {
    final url = Uri.parse('$baseUrl/$grade');
    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
     
        final List<dynamic> responseDataList = jsonDecode(response.body);
        
        if (responseDataList.isNotEmpty) {
          // Tomamos el primer elemento de la lista y lo parseamos como ScheduleEntity
          return ScheduleEntity.fromJson(responseDataList.first);
        } else {
          throw AuthException('No se encontró horario para el grado $grade.');
        }
      } else {
        String errorMessage = 'Error al obtener horario para el grado $grade';
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          errorMessage = errorData['mensaje'] ?? errorData['message'] ?? errorMessage;
        } catch (_) {
          // Si el cuerpo no es JSON o no tiene 'mensaje'/'message'
        }
        throw AuthException(errorMessage);
      }
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Fallo al conectar con el servidor: ${e.toString()}');
    }
  }

  Future<List<ScheduleEntity>> getAllSchedules() async {
    final url = Uri.parse(baseUrl);
    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        return responseData.map((json) => ScheduleEntity.fromJson(json)).toList();
      } else {
        String errorMessage = 'Error al obtener todos los horarios';
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          errorMessage = errorData['mensaje'] ?? errorData['message'] ?? errorMessage;
        } catch (_) {
          // Si el cuerpo no es JSON o no tiene 'mensaje'/'message'
        }
        throw AuthException(errorMessage);
      }
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Fallo al conectar con el servidor: ${e.toString()}');
    }
  }

  Future<ScheduleEntity> createSchedule(String grade) async {
    final url = Uri.parse('$baseUrl/$grade');
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return ScheduleEntity.fromJson(responseData);
      } else {
        String errorMessage = 'Error al crear horario para el grado $grade';
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          errorMessage = errorData['mensaje'] ?? errorData['message'] ?? errorMessage;
        } catch (_) {
          // Si el cuerpo no es JSON o no tiene 'mensaje'/'message'
        }
        throw AuthException(errorMessage);
      }
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Fallo al conectar con el servidor: ${e.toString()}');
    }
  }

  Future<void> deleteSchedulesByGrade(String grade) async {
    final url = Uri.parse('$baseUrl/$grade');
    try {
      final response = await http.delete(url);

      if (response.statusCode != 204) { // 204 No Content para eliminación exitosa
        String errorMessage = 'Error al eliminar horarios para el grado $grade';
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          errorMessage = errorData['mensaje'] ?? errorData['message'] ?? errorMessage;
        } catch (_) {
          // Si el cuerpo no es JSON o no tiene 'mensaje'/'message'
        }
        throw AuthException(errorMessage);
      }
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Fallo al conectar con el servidor: ${e.toString()}');
    }
  }

  Future<void> deleteAllSchedules() async {
    final url = Uri.parse(baseUrl);
    try {
      final response = await http.delete(url);

      if (response.statusCode != 204) {
        String errorMessage = 'Error al eliminar todos los horarios';
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          errorMessage = errorData['mensaje'] ?? errorData['message'] ?? errorMessage;
        } catch (_) {
          // Si el cuerpo no es JSON o no tiene 'mensaje'/'message'
        }
        throw AuthException(errorMessage);
      }
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Fallo al conectar con el servidor: ${e.toString()}');
    }
  }
}

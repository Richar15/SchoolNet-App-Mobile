import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:school_net_mobil_app/model/student_model.dart';
import 'package:school_net_mobil_app/exceptions/auth_exception.dart'; 

class StudentService {
  final String baseUrl = 'http://192.168.1.102:8080/api/students'; 

  Future<void> createStudent(StudentRequestDTO studentData) async {
    final url = Uri.parse('$baseUrl/create');

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(studentData.toJson()),
      );

      if (response.statusCode == 200) {
      
       
      } else {
       
        String errorMessage = 'Error al registrar estudiante';
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          errorMessage = errorData['mensaje'] ?? errorData['message'] ?? errorMessage;
        } catch (_) {
         
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


 Future<List<StudentDto>> searchStudentsByKeyword(String keyword) async {
    final url = Uri.parse('$baseUrl/search?keyword=$keyword');
    print('StudentService: Intentando buscar estudiantes en URL: $url'); // DEBUG
    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      print('StudentService: Respuesta recibida. Status Code: ${response.statusCode}'); 
      print('StudentService: Cuerpo de la respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        print('StudentService: Decodificación JSON exitosa. Cantidad de elementos: ${responseData.length}'); 
        return responseData.map((json) => StudentDto.fromJson(json)).toList();
      } else {
        String errorMessage = 'Error al buscar estudiantes por palabra clave: $keyword';
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          errorMessage = errorData['mensaje'] ?? errorData['message'] ?? errorMessage;
        } catch (_) {
          // Si el cuerpo no es JSON o no tiene 'mensaje'/'message'
        }
        print('StudentService: Error HTTP ${response.statusCode}: $errorMessage'); // DEBUG
        throw AuthException(errorMessage);
      }
    } catch (e) {
      if (e is AuthException) {
        print('StudentService: AuthException capturada: ${e.message}'); // DEBUG
        rethrow;
      }
      print('StudentService: Error inesperado al conectar: ${e.toString()}'); // DEBUG
      throw AuthException('Fallo al conectar con el servidor para buscar estudiantes');
    }
  }

  Future<StudentDto> updateStudent(int id, StudentRequestDTO updatedStudent) async {
  final url = Uri.parse('$baseUrl/$id');

  try {
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(updatedStudent.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return StudentDto.fromJson(data);
    } else {
      String errorMessage = 'Error al actualizar estudiante';
      try {
        final errorData = jsonDecode(response.body);
        errorMessage = errorData['mensaje'] ?? errorData['message'] ?? errorMessage;
      } catch (_) {}
      throw AuthException(errorMessage);
    }
  } catch (e) {
    if (e is AuthException) rethrow;
    throw AuthException('Fallo al conectar con el servidor al actualizar: ${e.toString()}');
  }
}
Future<List<StudentDto>> getAllStudents() async {
  final url = Uri.parse(baseUrl); 

  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => StudentDto.fromJson(json)).toList();
    } else {
      String errorMessage = 'Error al obtener estudiantes';
      try {
        final errorData = jsonDecode(response.body);
        errorMessage = errorData['mensaje'] ?? errorData['message'] ?? errorMessage;
      } catch (_) {}
      throw AuthException(errorMessage);
    }
  } catch (e) {
    if (e is AuthException) rethrow;
    throw AuthException('Fallo al conectar con el servidor al obtener estudiantes');
  }
}
Future<void> deleteStudent(int id) async {
  final url = Uri.parse('$baseUrl/$id');

  try {
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      String errorMessage = 'Error al eliminar estudiante';
      try {
        final errorData = jsonDecode(response.body);
        errorMessage = errorData['mensaje'] ?? errorData['message'] ?? errorMessage;
      } catch (_) {}
      throw AuthException(errorMessage);
    }
  } catch (e) {
    if (e is AuthException) rethrow;
    throw AuthException('Fallo al conectar con el servidor al eliminar estudiante');
  }
}

}

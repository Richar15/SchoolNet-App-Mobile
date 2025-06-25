import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:school_net_mobil_app/model/auth_model.dart';
import 'package:school_net_mobil_app/exceptions/auth_exception.dart';


class AuthService {
  final String baseUrl = 'http://192.168.1.102:8080/api/auth'; 

  Future<AuthResponseDTO> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final loginRequest = LoginRequestDTO(username: username, password: password);

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(loginRequest.toJson()),
      );

      // Siempre intenta decodificar la respuesta como AuthResponseDTO
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final AuthResponseDTO authResponse = AuthResponseDTO.fromJson(responseData);

      // Si el backend indica un error en el DTO
      if (authResponse.error == true) {
        throw AuthException(authResponse.mensaje ?? 'Error desconocido del servidor');
      }

      // Si el backend no indica error en el DTO, pero el status code no es 200
      // Esto es una capa de seguridad si el backend no siempre setea 'error: true'
      if (response.statusCode != 200) {
        throw AuthException(authResponse.mensaje ?? 'Error inesperado del servidor con código: ${response.statusCode}');
      }

      // Si todo es exitoso
      return authResponse;

    } catch (e) {
      if (e is AuthException) {
        rethrow; // Relanza la excepción de autenticación directamente
      }
      // Para errores de red o cualquier otra excepción no AuthException
      throw AuthException('Fallo al conectar con el servidor revise su conexión a internet');
    }
  }
}

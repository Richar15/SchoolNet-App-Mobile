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

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final AuthResponseDTO authResponse = AuthResponseDTO.fromJson(responseData);

      if (authResponse.error == true) {
        throw AuthException(authResponse.mensaje ?? 'Error desconocido del servidor');
      }

      if (response.statusCode != 200) {
        throw AuthException(authResponse.mensaje ?? 'Error inesperado del servidor con código: ${response.statusCode}');
      }

      return authResponse;

    } catch (e) {
      if (e is AuthException) {
        rethrow; 
      }
      throw AuthException('Fallo al conectar con el servidor revise su conexión a internet');
    }
  }
}

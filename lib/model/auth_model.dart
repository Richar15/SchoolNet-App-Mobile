
// Define la clase para la solicitud de login
class LoginRequestDTO {
  final String username;
  final String password;

  LoginRequestDTO({required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}

// Define la clase para la respuesta de autenticación (ahora incluye campos de error)
class AuthResponseDTO {
  final String? token; // Nullable para casos de error
  final String? username; // Nullable para casos de error
  final String? rol; // Nullable para casos de error
  final int? userId; // Nullable para casos de error
  
  final bool? error; // Nuevo campo para indicar si hubo un error
  final String? mensaje; // Nuevo campo para el mensaje de error
  final int? status; // Nuevo campo para el código de estado del error
  final DateTime? timestamp; // Nuevo campo para la marca de tiempo del error

  AuthResponseDTO({
    this.token,
    this.username,
    this.rol,
    this.userId,
    this.error,
    this.mensaje,
    this.status,
    this.timestamp,
  });

  factory AuthResponseDTO.fromJson(Map<String, dynamic> json) {
    return AuthResponseDTO(
      token: json['token'],
      username: json['username'],
      rol: json['rol'],
      userId: json['userId'],
      error: json['error'],
      mensaje: json['mensaje'],
      status: json['status'],
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : null,
    );
  }
}

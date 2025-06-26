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


class AuthResponseDTO {
  final String? token; 
  final String? username; 
  final String? rol; 
  final int? userId; 
  
  final bool? error; 
  final String? mensaje; 
  final int? status;
  final DateTime? timestamp; 

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

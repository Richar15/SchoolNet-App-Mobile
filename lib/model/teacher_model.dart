// lib/model/teacher_model.dart

class TeacherRequestDTO {
  final String name;
  final String lastName;
  final String username;
  final String password;
  final String email;
  final String phone;
  final String address;
  final String areaOfExpertise;

  TeacherRequestDTO({
    required this.name,
    required this.lastName,
    required this.username,
    required this.password,
    required this.email,
    required this.phone,
    required this.address,
    required this.areaOfExpertise,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lastName': lastName,
      'username': username,
      'password': password,
      'email': email,
      'phone': phone,
      'address': address,
      'areaOfExpertise': areaOfExpertise,
    };
  }
}

class TeacherDto {
  final int? id; // ✅ necesario para actualizar
  final String name;
  final String lastName;
  final String username;
  final String password;
  final String email;
  final String phone;
  final String address;
  final String areaOfExpertise;

  TeacherDto({
    this.id, // ✅ debe ser opcional
    required this.name,
    required this.lastName,
    required this.username,
    required this.password,
    required this.email,
    required this.phone,
    required this.address,
    required this.areaOfExpertise,
  });

  factory TeacherDto.fromJson(Map<String, dynamic> json) {
    return TeacherDto(
      id: json['id'] as int?, // ✅ importante: puede ser null
      name: json['name'],
      lastName: json['lastName'],
      username: json['username'],
      password: json['password'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      areaOfExpertise: json['areaOfExpertise'],
    );
  }
}

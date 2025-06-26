class StudentRequestDTO {
  final String name;
  final String lastName;
  final String username;
  final String password;
  final String email;
  final String phone;
  final String address;
  final String grade;

  StudentRequestDTO({
    required this.name,
    required this.lastName,
    required this.username,
    required this.password,
    required this.email,
    required this.phone,
    required this.address,
    required this.grade,
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
      'grade': grade,
    };
  }
}


class StudentDto {
  final int? id; 
  final String name;
  final String lastName;
  final String username;
  final String password;
  final String email;
  final String phone;
  final String address;
  final String grade;

  StudentDto({
    this.id, 
    required this.name,
    required this.lastName,
    required this.username,
    required this.password,
    required this.email,
    required this.phone,
    required this.address,
    required this.grade,
  });

  factory StudentDto.fromJson(Map<String, dynamic> json) {
    return StudentDto(
      id: json['id'] as int?, 
      name: json['name'],
      lastName: json['lastName'],
      username: json['username'],
      password: json['password'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      grade: json['grade'],
    );
  }
}

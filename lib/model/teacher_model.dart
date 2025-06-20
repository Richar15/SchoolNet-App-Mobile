
class TeacherRequestDTO {
  final String name;
  final String lastName;
  final String username;
  final String password;
  final String email;
  final String phone;
  final String address;
  final String areaOfExpertise; // Usamos String para el área de experticia

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

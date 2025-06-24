class StudentForGrade {
  final int id;
  final String name;

  StudentForGrade({required this.id, required this.name});

  factory StudentForGrade.fromJson(Map<String, dynamic> json) {
    return StudentForGrade(
      id: json['id'],
      name: json['name'],
    );
  }
}

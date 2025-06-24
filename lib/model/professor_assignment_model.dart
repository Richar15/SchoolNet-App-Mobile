class ProfessorAssignment {
  final int id;
  final String subject;
  final String grade;

  ProfessorAssignment({required this.id, required this.subject, required this.grade});

  factory ProfessorAssignment.fromJson(Map<String, dynamic> json) {
    return ProfessorAssignment(
      id: json['id'],
      subject: json['subject'],
      grade: json['grade'],
    );
  }
}

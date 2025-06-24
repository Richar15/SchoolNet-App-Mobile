class GradeModel {
  final int id;
  final int studentId;
  final int assignmentId;
  final double grade1;
  final double grade2;
  final double grade3;
  final double grade4;
  final double finalGrade;

  GradeModel({
    required this.id,
    required this.studentId,
    required this.assignmentId,
    required this.grade1,
    required this.grade2,
    required this.grade3,
    required this.grade4,
    required this.finalGrade,
  });

  factory GradeModel.fromJson(Map<String, dynamic> json) {
    return GradeModel(
      id: json['id'],
      studentId: json['studentId'],
      assignmentId: json['assignmentId'],
      grade1: (json['grade1'] as num).toDouble(),
      grade2: (json['grade2'] as num).toDouble(),
      grade3: (json['grade3'] as num).toDouble(),
      grade4: (json['grade4'] as num).toDouble(),
      finalGrade: (json['finalGrade'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'assignmentId': assignmentId,
      'grade1': grade1,
      'grade2': grade2,
      'grade3': grade3,
      'grade4': grade4,
      'finalGrade': finalGrade,
    };
  }
}

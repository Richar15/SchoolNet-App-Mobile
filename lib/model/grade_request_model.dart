class GradeRequest {
  final int studentId;
  final int assignmentId;
  final double grade1;
  final double grade2;
  final double grade3;
  final double grade4;

  GradeRequest({
    required this.studentId,
    required this.assignmentId,
    required this.grade1,
    required this.grade2,
    required this.grade3,
    required this.grade4,
  });

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'assignmentId': assignmentId,
      'grade1': grade1,
      'grade2': grade2,
      'grade3': grade3,
      'grade4': grade4,
    };
  }
}

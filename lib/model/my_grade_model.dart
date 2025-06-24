class MyGradeModel {
  final double grade1;
  final double grade2;
  final double grade3;
  final double grade4;
  final double finalGrade;
  final String? subject; // ✅ importante

  MyGradeModel({
    required this.grade1,
    required this.grade2,
    required this.grade3,
    required this.grade4,
    required this.finalGrade,
    this.subject,
  });

  factory MyGradeModel.fromJson(Map<String, dynamic> json) {
    return MyGradeModel(
      grade1: (json['grade1'] as num).toDouble(),
      grade2: (json['grade2'] as num).toDouble(),
      grade3: (json['grade3'] as num).toDouble(),
      grade4: (json['grade4'] as num).toDouble(),
      finalGrade: (json['finalGrade'] as num).toDouble(),
      subject: json['subject'], // ✅
    );
  }
}

class Session {
  final int id;
  final String day;
  final String start;
  final String end;
  final String? subject; 
  final String teacher;
  final String classroom;

  Session({
    required this.id,
    required this.day,
    required this.start,
    required this.end,
    this.subject,
    required this.teacher,
    required this.classroom,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'],
      day: json['day'],
      start: json['start'],
      end: json['end'],
      subject: json['subject'],
      teacher: json['teacher'],
      classroom: json['classroom'],
    );
  }
}

class ScheduleEntity {
  final int id;
  final String grade;
  final List<Session> sessions;

  ScheduleEntity({
    required this.id,
    required this.grade,
    required this.sessions,
  });

  factory ScheduleEntity.fromJson(Map<String, dynamic> json) {
    var sessionsList = json['sessions'] as List;
    List<Session> sessions = sessionsList.map((i) => Session.fromJson(i)).toList();

    return ScheduleEntity(
      id: json['id'],
      grade: json['grade'],
      sessions: sessions,
    );
  }
}

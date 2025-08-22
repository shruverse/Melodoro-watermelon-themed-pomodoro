class StudySession {
  final int duration; // in minutes
  final DateTime completedAt;
  final String? taskName;

  StudySession({
    required this.duration,
    required this.completedAt,
    this.taskName,
  });

  Map<String, dynamic> toJson() {
    return {
      'duration': duration,
      'completedAt': completedAt.toIso8601String(),
      'taskName': taskName,
    };
  }

  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      duration: json['duration'],
      completedAt: DateTime.parse(json['completedAt']),
      taskName: json['taskName'],
    );
  }
}

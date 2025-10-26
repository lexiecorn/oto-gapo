class Announcement {
  Announcement({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.type,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      date: json['date'] as String,
      type: json['type'] as String,
    );
  }
  final String title;
  final String subtitle;
  final String date;
  final String type;
}

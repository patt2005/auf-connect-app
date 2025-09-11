class PreviewEvent {
  final String id;
  final String title;
  final String date;
  final String city;
  final String link;

  PreviewEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.city,
    required this.link,
  });

  factory PreviewEvent.fromJson(Map<String, dynamic> json) {
    return PreviewEvent(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      city: json['city'] ?? '',
      link: json['link'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'city': city,
      'link': link,
    };
  }

  PreviewEvent copyWith({
    String? id,
    String? title,
    String? date,
    String? city,
    String? link,
  }) {
    return PreviewEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      city: city ?? this.city,
      link: link ?? this.link,
    );
  }
}
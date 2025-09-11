class EventModel {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? videoUrl;
  final String date;
  final String city;
  final String eventType;
  final String theme;
  final String hashtags;
  final List<EventSection> sections;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.videoUrl,
    required this.date,
    required this.city,
    required this.eventType,
    required this.theme,
    required this.hashtags,
    required this.sections,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
      date: json['date'] ?? '',
      city: json['city'] ?? '',
      eventType: json['eventType'] ?? '',
      theme: json['theme'] ?? '',
      hashtags: json['hashtags'] ?? '',
      sections: json['sections'] != null
          ? (json['sections'] as List<dynamic>)
              .map((item) => EventSection.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'date': date,
      'city': city,
      'eventType': eventType,
      'theme': theme,
      'hashtags': hashtags,
      'sections': sections.map((section) => section.toJson()).toList(),
    };
  }

  // Create a copy with updated values
  EventModel copyWith({
    String? title,
    String? description,
    String? imageUrl,
    String? videoUrl,
    String? date,
    String? city,
    String? eventType,
    String? theme,
    String? hashtags,
    List<EventSection>? sections,
  }) {
    return EventModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      date: date ?? this.date,
      city: city ?? this.city,
      eventType: eventType ?? this.eventType,
      theme: theme ?? this.theme,
      hashtags: hashtags ?? this.hashtags,
      sections: sections ?? this.sections,
    );
  }
}

class EventSection {
  final String id;
  final String eventId;
  final String title;
  final String description;
  final String linkUrl;
  final String linkText;

  EventSection({
    required this.id,
    required this.eventId,
    required this.title,
    required this.description,
    required this.linkUrl,
    required this.linkText,
  });

  factory EventSection.fromJson(Map<String, dynamic> json) {
    return EventSection(
      id: json['id']?.toString() ?? '',
      eventId: json['eventId']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      linkUrl: json['linkUrl'] ?? '',
      linkText: json['linkText'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'title': title,
      'description': description,
      'linkUrl': linkUrl,
      'linkText': linkText,
    };
  }

  EventSection copyWith({
    String? title,
    String? description,
    String? linkUrl,
    String? linkText,
  }) {
    return EventSection(
      id: id,
      eventId: eventId,
      title: title ?? this.title,
      description: description ?? this.description,
      linkUrl: linkUrl ?? this.linkUrl,
      linkText: linkText ?? this.linkText,
    );
  }
}
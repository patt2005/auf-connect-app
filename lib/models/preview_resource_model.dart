class PreviewResource {
  final String id;
  final String title;
  final String description;
  final String? link;
  final String? imageUrl;

  PreviewResource({
    required this.id,
    required this.title,
    required this.description,
    this.link,
    this.imageUrl,
  });

  // Create PreviewResource from API JSON response
  factory PreviewResource.fromJson(Map<String, dynamic> json) {
    return PreviewResource(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      link: json['link']?.toString(),
      imageUrl: json['imageUrl'],
    );
  }

  // Convert PreviewResource to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      if (link != null) 'link': link,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }

  // Create a copy with updated values
  PreviewResource copyWith({
    String? title,
    String? description,
    String? link,
    String? imageUrl,
  }) {
    return PreviewResource(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      link: link ?? this.link,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  String toString() {
    return 'PreviewResource(id: $id, title: $title, description: $description, link: $link, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PreviewResource && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
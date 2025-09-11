
enum ResourceType {
  formation('Formation'),
  resources('Resources'),
  expertise('Expertise'),
  innovation('Innovation'),
  prospective('Prospective'),
  allocation('Allocation');

  const ResourceType(this.value);
  final String value;

  static ResourceType fromString(String value) {
    return ResourceType.values.firstWhere(
      (type) => type.value.toLowerCase() == value.toLowerCase(),
      orElse: () => ResourceType.resources,
    );
  }

  @override
  String toString() => value;
}

class ResourceSection {
  final String title;
  final String description;
  final String? imageUrl;
  final String url;

  ResourceSection({
    required this.title,
    required this.description,
    this.imageUrl,
    required this.url,
  });

  factory ResourceSection.fromMap(Map<String, dynamic> data) {
    return ResourceSection(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
      url: data['url'] ?? '',
    );
  }

  factory ResourceSection.fromJson(Map<String, dynamic> json) {
    return ResourceSection(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'url': url,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'url': url,
    };
  }

  ResourceSection copyWith({
    String? title,
    String? description,
    String? imageUrl,
    String? url,
  }) {
    return ResourceSection(
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      url: url ?? this.url,
    );
  }
}

class ResourceModel {
  final String id;
  final ResourceType type;
  final String? link;
  final List<ResourceSection> sections;

  ResourceModel({
    required this.id,
    required this.type,
    this.link,
    required this.sections,
  });

  // Create ResourceModel from API JSON response
  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    return ResourceModel(
      id: json['id']?.toString() ?? '',
      type: ResourceType.fromString(json['type']?.toString() ?? ''),
      link: json['link']?.toString(),
      sections: (json['sections'] as List<dynamic>? ?? [])
          .map((section) => ResourceSection.fromJson(section as Map<String, dynamic>))
          .toList(),
    );
  }

  // Convert ResourceModel to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      if (link != null) 'link': link,
      'sections': sections.map((section) => section.toJson()).toList(),
    };
  }

  // Create a copy with updated values
  ResourceModel copyWith({
    String? id,
    ResourceType? type,
    String? link,
    List<ResourceSection>? sections,
  }) {
    return ResourceModel(
      id: id ?? this.id,
      type: type ?? this.type,
      link: link ?? this.link,
      sections: sections ?? this.sections,
    );
  }
}
class ServiceModel {
  final String id;
  final String imageUrl;
  final String title;
  final String dateString;

  ServiceModel({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.dateString,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id']?.toString() ?? '',
      imageUrl: json['imageUrl'] ?? '',
      title: json['title'] ?? '',
      dateString: json['dateString'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'title': title,
      'dateString': dateString,
    };
  }

  ServiceModel copyWith({
    String? id,
    String? imageUrl,
    String? title,
    String? dateString,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      dateString: dateString ?? this.dateString,
    );
  }
}
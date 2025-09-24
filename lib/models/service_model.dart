class ServiceModel {
  final String id;
  final String imageUrl;
  final String title;
  final String dateString;
  final bool isClosed;

  ServiceModel({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.dateString,
    this.isClosed = false,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id']?.toString() ?? '',
      imageUrl: json['imageUrl'] ?? '',
      title: json['title'] ?? '',
      dateString: json['dateString'] ?? '',
      isClosed: json['isClosed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'title': title,
      'dateString': dateString,
      'isClosed': isClosed,
    };
  }

  ServiceModel copyWith({
    String? id,
    String? imageUrl,
    String? title,
    String? dateString,
    bool? isClosed,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      dateString: dateString ?? this.dateString,
      isClosed: isClosed ?? this.isClosed,
    );
  }
}
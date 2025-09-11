class PartnerModel {
  final String id;
  final String name;
  final String? logoUrl;
  final String partnerUrl;

  PartnerModel({
    required this.id,
    required this.name,
    this.logoUrl,
    required this.partnerUrl,
  });

  // Create PartnerModel from API JSON response
  factory PartnerModel.fromJson(Map<String, dynamic> json) {
    return PartnerModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      logoUrl: json['imageUrl'],
      partnerUrl: json['link'] ?? '',
    );
  }

  // Convert PartnerModel to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl,
      'partnerUrl': partnerUrl,
    };
  }

  // Create a copy with updated values
  PartnerModel copyWith({String? name, String? logoUrl, String? partnerUrl}) {
    return PartnerModel(
      id: id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      partnerUrl: partnerUrl ?? this.partnerUrl,
    );
  }
}

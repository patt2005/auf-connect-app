class MemberModel {
  final String id;
  final String name;
  final String description;
  final String? background;
  final String? contactName;
  final String? contactTitle;
  final String? statutoryType;
  final String? universityType;
  final String? address;
  final String? phone;
  final String? website;
  final String? region;
  final String? foundedYear;

  MemberModel({
    required this.id,
    required this.name,
    required this.description,
    this.background,
    this.contactName,
    this.contactTitle,
    this.statutoryType,
    this.universityType,
    this.address,
    this.phone,
    this.website,
    this.region,
    this.foundedYear,
  });

  // Create MemberModel from API JSON response
  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      background: json['background']?.toString(),
      contactName: json['contactName']?.toString(),
      contactTitle: json['contactTitle']?.toString(),
      statutoryType: json['statutoryType']?.toString(),
      universityType: json['universityType']?.toString(),
      address: json['address']?.toString(),
      phone: json['phone']?.toString(),
      website: json['website']?.toString(),
      region: json['region']?.toString(),
      foundedYear: json['foundedYear']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      if (background != null) 'background': background,
      if (contactName != null) 'contactName': contactName,
      if (contactTitle != null) 'contactTitle': contactTitle,
      if (statutoryType != null) 'statutoryType': statutoryType,
      if (universityType != null) 'universityType': universityType,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (website != null) 'website': website,
      if (region != null) 'region': region,
      if (foundedYear != null) 'foundedYear': foundedYear,
    };
  }

  // Create a copy with updated values
  MemberModel copyWith({
    String? name,
    String? description,
    String? background,
    String? contactName,
    String? contactTitle,
    String? statutoryType,
    String? universityType,
    String? address,
    String? phone,
    String? website,
    String? region,
    String? foundedYear,
  }) {
    return MemberModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      background: background ?? this.background,
      contactName: contactName ?? this.contactName,
      contactTitle: contactTitle ?? this.contactTitle,
      statutoryType: statutoryType ?? this.statutoryType,
      universityType: universityType ?? this.universityType,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      region: region ?? this.region,
      foundedYear: foundedYear ?? this.foundedYear,
    );
  }
}

class PreviewMember {
  final String id;
  final String name;
  final String region;
  final String? address;
  final String? link;

  PreviewMember({
    required this.id,
    required this.name,
    required this.region,
    this.address,
    this.link,
  });

  // Create PreviewMember from API JSON response
  factory PreviewMember.fromJson(Map<String, dynamic> json) {
    return PreviewMember(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      region: json['region'] ?? '',
      address: json['address']?.toString(),
      link: json['link']?.toString(),
    );
  }

  // Convert PreviewMember to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'region': region,
      if (address != null) 'address': address,
      if (link != null) 'link': link,
    };
  }

  // Create a copy with updated values
  PreviewMember copyWith({
    String? name,
    String? address,
    String? region,
    String? link,
  }) {
    return PreviewMember(
      id: id,
      name: name ?? this.name,
      address: address ?? this.address,
      region: region ?? this.region,
      link: link ?? this.link,
    );
  }
}
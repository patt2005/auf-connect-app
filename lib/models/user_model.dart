class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? fcmToken;
  // Address fields
  final String? country;
  final String? city;
  final String? addressLine1;
  final String? addressLine2;
  final String? stateOrRegion;
  final String? postalCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final NotificationPreferences notificationPreferences;
  final List<String> favoriteProjectIds;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.fcmToken,
    this.country,
    this.city,
    this.addressLine1,
    this.addressLine2,
    this.stateOrRegion,
    this.postalCode,
    required this.createdAt,
    required this.updatedAt,
    required this.notificationPreferences,
    this.favoriteProjectIds = const [],
  });

  // Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'],
      fcmToken: json['fcmToken'],
      country: json['country'],
      city: json['city'],
      addressLine1: json['addressLine1'],
      addressLine2: json['addressLine2'],
      stateOrRegion: json['stateOrRegion'],
      postalCode: json['postalCode'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      notificationPreferences: NotificationPreferences.fromMap(
        json['notificationPreferences'] ?? {},
      ),
      favoriteProjectIds: json['favoriteProjectIds'] != null
          ? List<String>.from(json['favoriteProjectIds'])
          : [],
    );
  }

  // Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'fcmToken': fcmToken,
      'country': country,
      'city': city,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'stateOrRegion': stateOrRegion,
      'postalCode': postalCode,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'notificationPreferences': notificationPreferences.toMap(),
      'favoriteProjectIds': favoriteProjectIds,
    };
  }

  // Create a copy with updated values
  UserModel copyWith({
    String? email,
    String? fullName,
    String? phoneNumber,
    String? fcmToken,
    String? country,
    String? city,
    String? addressLine1,
    String? addressLine2,
    String? stateOrRegion,
    String? postalCode,
    DateTime? updatedAt,
    NotificationPreferences? notificationPreferences,
    List<String>? favoriteProjectIds,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fcmToken: fcmToken ?? this.fcmToken,
      country: country ?? this.country,
      city: city ?? this.city,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      stateOrRegion: stateOrRegion ?? this.stateOrRegion,
      postalCode: postalCode ?? this.postalCode,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      notificationPreferences: notificationPreferences ?? this.notificationPreferences,
      favoriteProjectIds: favoriteProjectIds ?? this.favoriteProjectIds,
    );
  }
}

class NotificationPreferences {
  final bool callNotifications;
  final bool savedProjectsNotifications;
  final bool resourceListNotifications;
  final bool passwordChangeNotifications;
  final bool eventsNotifications;
  final bool newsletterNotifications;

  NotificationPreferences({
    this.callNotifications = true,
    this.savedProjectsNotifications = true,
    this.resourceListNotifications = true,
    this.passwordChangeNotifications = true,
    this.eventsNotifications = true,
    this.newsletterNotifications = true,
  });

  factory NotificationPreferences.fromMap(Map<String, dynamic> map) {
    return NotificationPreferences(
      callNotifications: map['callNotifications'] ?? true,
      savedProjectsNotifications: map['savedProjectsNotifications'] ?? true,
      resourceListNotifications: map['resourceListNotifications'] ?? true,
      passwordChangeNotifications: map['passwordChangeNotifications'] ?? true,
      eventsNotifications: map['eventsNotifications'] ?? true,
      newsletterNotifications: map['newsletterNotifications'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'callNotifications': callNotifications,
      'savedProjectsNotifications': savedProjectsNotifications,
      'resourceListNotifications': resourceListNotifications,
      'passwordChangeNotifications': passwordChangeNotifications,
      'eventsNotifications': eventsNotifications,
      'newsletterNotifications': newsletterNotifications,
    };
  }

  NotificationPreferences copyWith({
    bool? callNotifications,
    bool? savedProjectsNotifications,
    bool? resourceListNotifications,
    bool? passwordChangeNotifications,
    bool? eventsNotifications,
    bool? newsletterNotifications,
  }) {
    return NotificationPreferences(
      callNotifications: callNotifications ?? this.callNotifications,
      savedProjectsNotifications: savedProjectsNotifications ?? this.savedProjectsNotifications,
      resourceListNotifications: resourceListNotifications ?? this.resourceListNotifications,
      passwordChangeNotifications: passwordChangeNotifications ?? this.passwordChangeNotifications,
      eventsNotifications: eventsNotifications ?? this.eventsNotifications,
      newsletterNotifications: newsletterNotifications ?? this.newsletterNotifications,
    );
  }
}

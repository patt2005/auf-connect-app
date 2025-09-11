import '../models/user_model.dart';

class RegisterRequest {
  final String email;
  final String password;
  final String fullName;
  final String? phoneNumber;
  final String? fcmToken;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.fullName,
    this.phoneNumber,
    this.fcmToken,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'fullName': fullName,
    if (phoneNumber != null) 'phoneNumber': phoneNumber,
    if (fcmToken != null) 'fcmToken': fcmToken,
  };
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class AuthResponse {
  final String token;
  final UserResponse user;

  AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      user: UserResponse.fromJson(json['user']),
    );
  }
}

class UserResponse {
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

  UserResponse({
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

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'],
      email: json['email'],
      fullName: json['fullName'],
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

  // Convert to UserModel for compatibility with existing code
  UserModel toUserModel() {
    return UserModel(
      id: id,
      email: email,
      fullName: fullName,
      phoneNumber: phoneNumber,
      fcmToken: fcmToken,
      country: country,
      city: city,
      addressLine1: addressLine1,
      addressLine2: addressLine2,
      stateOrRegion: stateOrRegion,
      postalCode: postalCode,
      createdAt: createdAt,
      updatedAt: updatedAt,
      notificationPreferences: notificationPreferences,
      favoriteProjectIds: favoriteProjectIds,
    );
  }
}

class EditUserRequest {
  final String fullName;
  final String? phoneNumber;
  final String? fcmToken;
  // Address fields (optional for now)
  final String? country;
  final String? city;
  final String? addressLine1;
  final String? addressLine2;
  final String? stateOrRegion;
  final String? postalCode;
  final NotificationPreferences notificationPreferences;

  EditUserRequest({
    required this.fullName,
    this.phoneNumber,
    this.fcmToken,
    this.country,
    this.city,
    this.addressLine1,
    this.addressLine2,
    this.stateOrRegion,
    this.postalCode,
    required this.notificationPreferences,
  });

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    if (phoneNumber != null) 'phoneNumber': phoneNumber,
    if (fcmToken != null) 'fcmToken': fcmToken,
    if (country != null) 'country': country,
    if (city != null) 'city': city,
    if (addressLine1 != null) 'addressLine1': addressLine1,
    if (addressLine2 != null) 'addressLine2': addressLine2,
    if (stateOrRegion != null) 'stateOrRegion': stateOrRegion,
    if (postalCode != null) 'postalCode': postalCode,
    'notificationPreferences': notificationPreferences.toMap(),
  };
}

class EditUserResponse {
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

  EditUserResponse({
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

  factory EditUserResponse.fromJson(Map<String, dynamic> json) {
    return EditUserResponse(
      id: json['id'],
      email: json['email'],
      fullName: json['fullName'],
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

  // Convert to UserModel for compatibility with existing code
  UserModel toUserModel() {
    return UserModel(
      id: id,
      email: email,
      fullName: fullName,
      phoneNumber: phoneNumber,
      fcmToken: fcmToken,
      country: country,
      city: city,
      addressLine1: addressLine1,
      addressLine2: addressLine2,
      stateOrRegion: stateOrRegion,
      postalCode: postalCode,
      createdAt: createdAt,
      updatedAt: updatedAt,
      notificationPreferences: notificationPreferences,
      favoriteProjectIds: favoriteProjectIds,
    );
  }
}

class FavoriteProjectRequest {
  final String projectId;

  FavoriteProjectRequest({required this.projectId});

  Map<String, dynamic> toJson() => {
    'ProjectId': projectId,
  };
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

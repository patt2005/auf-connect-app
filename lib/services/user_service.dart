import 'dart:async';
import 'dart:convert';
import '../models/user_model.dart';
import '../models/project_model.dart';
import '../models/auth_models.dart';
import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final ApiService _apiService = ApiService();

  UserModel? _userModel;
  bool _isLoggedIn = false;
  String? _authToken;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  UserModel? get userModel => _userModel;
  String? get userId => _userModel?.id;
  String? get userEmail => _userModel?.email;
  String? get displayName => _userModel?.fullName;
  String? get phoneNumber => _userModel?.phoneNumber;
  String? get fcmToken => _userModel?.fcmToken;
  String? get authToken => _authToken;
  NotificationPreferences? get notificationPreferences =>
      _userModel?.notificationPreferences;

  // Stream controllers for reactive UI updates
  final StreamController<bool> _authStateController =
      StreamController<bool>.broadcast();
  Stream<bool> get authStateStream => _authStateController.stream;

  Future<void> initialize() async {
    try {
      // Try to get stored token and user data
      final storedToken = await _apiService.getStoredToken();
      if (storedToken != null) {
        _authToken = storedToken;

        // Load stored user data
        await _loadStoredUserData();

        if (_userModel != null) {
          _isLoggedIn = true;
          _authStateController.add(_isLoggedIn);
        }
      }
    } catch (e) {
      print('Error initializing user service: $e');
    }
  }

  // Save user data to local storage
  Future<void> _saveUserData(UserModel userModel) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = json.encode(userModel.toJson());
      await prefs.setString('user_data', userJson);
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  // Load user data from local storage
  Future<void> _loadStoredUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_data');
      if (userJson != null) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        _userModel = UserModel.fromJson(userMap);
      }
    } catch (e) {
      print('Error loading stored user data: $e');
      _userModel = null;
    }
  }

  // Clear stored user data
  Future<void> _clearStoredUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
    } catch (e) {
      print('Error clearing stored user data: $e');
    }
  }

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
    String? phoneNumber,
    String? fcmToken,
  }) async {
    try {
      final registerRequest = RegisterRequest(
        email: email,
        password: password,
        fullName: displayName ?? '',
        phoneNumber: phoneNumber,
        fcmToken: fcmToken,
      );

      final authResponse = await _apiService.register(registerRequest);

      _userModel = authResponse.user.toUserModel();
      _authToken = authResponse.token;
      _isLoggedIn = true;

      // Save user data to local storage
      await _saveUserData(_userModel!);

      // Notify listeners about auth state change
      _authStateController.add(_isLoggedIn);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    try {
      final loginRequest = LoginRequest(email: email, password: password);

      final authResponse = await _apiService.login(
        loginRequest,
        rememberMe: rememberMe,
      );

      _userModel = authResponse.user.toUserModel();
      _authToken = authResponse.token;
      _isLoggedIn = true;

      // Save user data to local storage only if rememberMe is true
      if (rememberMe) {
        await _saveUserData(_userModel!);
      }

      // Notify listeners about auth state change
      _authStateController.add(_isLoggedIn);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _apiService.logout();

      _userModel = null;
      _authToken = null;
      _isLoggedIn = false;

      // Clear stored user data
      await _clearStoredUserData();

      // Notify listeners about auth state change
      _authStateController.add(_isLoggedIn);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    // Note: This would need to be implemented in your API
    throw UnimplementedError('Password reset not yet implemented in API');
  }

  Future<void> updateDisplayName(String displayName) async {
    // Note: This would need to be implemented in your API
    throw UnimplementedError('Update display name not yet implemented in API');
  }

  Future<void> updateEmail(String email) async {
    // Note: This would need to be implemented in your API
    throw UnimplementedError('Update email not yet implemented in API');
  }

  Future<void> updatePassword(String password) async {
    // Note: This would need to be implemented in your API
    throw UnimplementedError('Update password not yet implemented in API');
  }

  Future<void> resetPassword({
    String? email,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _apiService.resetPassword(
        userId: _userModel?.id,
        email: email,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUser() async {
    // Note: This would need to be implemented in your API
    throw UnimplementedError('Delete user not yet implemented in API');
  }

  // Update FCM token
  Future<void> updateFcmToken(String fcmToken) async {
    try {
      await updateUserProfile(fcmToken: fcmToken);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateNotificationPreferences(
    NotificationPreferences preferences,
  ) async {
    try {
      await updateUserProfile(notificationPreferences: preferences);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSingleNotificationPreference({
    bool? callNotifications,
    bool? savedProjectsNotifications,
    bool? resourceListNotifications,
    bool? passwordChangeNotifications,
    bool? eventsNotifications,
    bool? newsletterNotifications,
  }) async {
    try {
      if (_userModel?.notificationPreferences != null) {
        final updatedPreferences = _userModel!.notificationPreferences.copyWith(
          callNotifications: callNotifications,
          savedProjectsNotifications: savedProjectsNotifications,
          resourceListNotifications: resourceListNotifications,
          passwordChangeNotifications: passwordChangeNotifications,
          eventsNotifications: eventsNotifications,
          newsletterNotifications: newsletterNotifications,
        );

        await updateNotificationPreferences(updatedPreferences);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserProfile({
    String? fullName,
    String? phoneNumber,
    String? fcmToken,
    String? country,
    String? city,
    String? addressLine1,
    String? addressLine2,
    String? stateOrRegion,
    String? postalCode,
    NotificationPreferences? notificationPreferences,
  }) async {
    try {
      if (_userModel?.id == null) {
        throw Exception('User not logged in');
      }

      final editRequest = EditUserRequest(
        fullName: fullName ?? _userModel!.fullName,
        phoneNumber: phoneNumber ?? _userModel!.phoneNumber,
        fcmToken: fcmToken ?? _userModel!.fcmToken,
        country: country ?? _userModel!.country,
        city: city ?? _userModel!.city,
        addressLine1: addressLine1 ?? _userModel!.addressLine1,
        addressLine2: addressLine2 ?? _userModel!.addressLine2,
        stateOrRegion: stateOrRegion ?? _userModel!.stateOrRegion,
        postalCode: postalCode ?? _userModel!.postalCode,
        notificationPreferences:
            notificationPreferences ?? _userModel!.notificationPreferences,
      );

      final editUserResponse = await _apiService.editUser(
        _userModel!.id,
        editRequest,
      );

      _userModel = editUserResponse.toUserModel();

      await _saveUserData(_userModel!);

      _authStateController.add(_isLoggedIn);
    } catch (e) {
      rethrow;
    }
  }

  // Favorite Projects methods
  Future<void> addFavoriteProject(String projectId) async {
    try {
      if (_userModel?.id == null) {
        throw Exception('User not logged in');
      }

      await _apiService.addFavoriteProject(_userModel!.id, projectId);

      // Update local user model with new favorite
      final updatedFavorites = List<String>.from(
        _userModel!.favoriteProjectIds,
      )..add(projectId);

      _userModel = _userModel!.copyWith(favoriteProjectIds: updatedFavorites);
      await _saveUserData(_userModel!);

      // Notify listeners
      _authStateController.add(_isLoggedIn);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeFavoriteProject(String projectId) async {
    try {
      if (_userModel?.id == null) {
        throw Exception('User not logged in');
      }

      await _apiService.removeFavoriteProject(_userModel!.id, projectId);

      // Update local user model by removing favorite
      final updatedFavorites = List<String>.from(
        _userModel!.favoriteProjectIds,
      )..remove(projectId);

      _userModel = _userModel!.copyWith(favoriteProjectIds: updatedFavorites);
      await _saveUserData(_userModel!);

      // Notify listeners
      _authStateController.add(_isLoggedIn);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> getFavoriteProjects() async {
    try {
      if (_userModel?.id == null) {
        throw Exception('User not logged in');
      }

      final favorites = await _apiService.getFavoriteProjects(_userModel!.id);

      // Update local user model with fresh favorites from server
      _userModel = _userModel!.copyWith(favoriteProjectIds: favorites);
      await _saveUserData(_userModel!);

      return favorites;
    } catch (e) {
      rethrow;
    }
  }

  // Fetch full favorite projects (detailed) for future use
  Future<List<ProjectModel>> getFavoriteProjectsDetailed() async {
    try {
      if (_userModel?.id == null) {
        throw Exception('User not logged in');
      }

      final projects = await _apiService.getFavoriteProjectsDetailed(
        _userModel!.id,
      );
      return projects;
    } catch (e) {
      rethrow;
    }
  }

  // Helper methods for favorites
  bool isProjectFavorite(String projectId) {
    return _userModel?.favoriteProjectIds.contains(projectId) ?? false;
  }

  List<String> get favoriteProjectIds =>
      _userModel?.favoriteProjectIds ?? [];

  int get favoriteProjectsCount => _userModel?.favoriteProjectIds.length ?? 0;

  void dispose() {
    _authStateController.close();
  }
}

# Edit User Functionality - Usage Guide

## Overview

The edit user functionality allows you to update user profile information and notification preferences through your API endpoint `PUT /api/user/edit/{userId}`.

## New Components Added

### 1. Models (`lib/models/auth_models.dart`)
- `EditUserRequest` - Request model for the edit user API call
- Updated to include all authentication-related models

### 2. API Service (`lib/services/api_service.dart`)
- `editUser(String userId, EditUserRequest request)` - Makes the PUT request to update user info

### 3. User Service (`lib/services/user_service.dart`)
Updated methods that now work with the API:
- `updateUserProfile()` - Updates full name, phone, FCM token, and notification preferences
- `updateFcmToken()` - Updates only FCM token
- `updateNotificationPreferences()` - Updates all notification preferences
- `updateSingleNotificationPreference()` - Updates individual notification settings

### 4. Profile Screen (`lib/screens/profile_screen.dart`)
- `_saveChanges()` - Now actually saves user profile changes via API
- Full integration with the edit user endpoint

## Usage Examples

### Example 1: Update User Profile from Profile Screen
The profile screen now automatically uses the API when the user clicks "Save Changes":
```dart
// This happens automatically in the profile screen
await _userService.updateUserProfile(
  fullName: "John Doe Updated",
  phoneNumber: "+1234567890",
  notificationPreferences: updatedPreferences,
);
```

### Example 2: Update Only FCM Token
```dart
await UserService().updateFcmToken("new-fcm-token-here");
```

### Example 3: Update Notification Preferences
```dart
final newPrefs = NotificationPreferences(
  callNotifications: true,
  savedProjectsNotifications: false,
  resourceListNotifications: true,
  passwordChangeNotifications: true,
  eventsNotifications: false,
  newsletterNotifications: true,
);

await UserService().updateNotificationPreferences(newPrefs);
```

### Example 4: Update Single Notification Setting
```dart
await UserService().updateSingleNotificationPreference(
  eventsNotifications: false,
);
```

### Example 5: Direct API Call
```dart
final editRequest = EditUserRequest(
  fullName: "Updated Name",
  phoneNumber: "+1234567890",
  fcmToken: "firebase-token",
  notificationPreferences: NotificationPreferences(
    callNotifications: true,
    savedProjectsNotifications: false,
    resourceListNotifications: true,
    passwordChangeNotifications: true,
    eventsNotifications: false,
    newsletterNotifications: true,
  ),
);

final authResponse = await ApiService().editUser(userId, editRequest);
```

## API Request Format

The API call sends a PUT request to `/api/user/edit/{userId}` with:

**Headers:**
- `Content-Type: application/json`
- `Authorization: Bearer {JWT_TOKEN}` (automatically added)

**Body:**
```json
{
  "fullName": "Updated Name",
  "phoneNumber": "+1234567890",
  "fcmToken": "firebase-token",
  "notificationPreferences": {
    "callNotifications": true,
    "savedProjectsNotifications": false,
    "resourceListNotifications": true,
    "passwordChangeNotifications": true,
    "eventsNotifications": false,
    "newsletterNotifications": true
  }
}
```

## Error Handling

The API service handles various error scenarios:
- **404**: User not found
- **400/401**: Validation or authentication errors
- **Network errors**: Connection issues

All errors are properly propagated with localized messages in the UI.

## Features

✅ **Complete Profile Editing**: Update name, phone, and all notification preferences
✅ **Individual Updates**: Update specific fields without affecting others
✅ **Token Management**: JWT authentication automatically handled
✅ **Error Handling**: Proper error messages and user feedback
✅ **Local State Updates**: User model is updated locally after successful API calls
✅ **UI Integration**: Profile screen fully functional with real API calls

## Notes

- Image upload functionality is noted as requiring a separate file upload endpoint
- All changes are immediately synced with your backend API
- User authentication state is maintained throughout profile updates
- The profile screen provides visual feedback during save operations

The edit user functionality is now fully integrated and ready to use with your .NET API!
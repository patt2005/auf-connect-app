import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event_model.dart';
import '../models/preview_event_model.dart';
import '../models/project_model.dart';
import '../models/member_model.dart';
import '../models/partner_model.dart';
import '../models/preview_resource_model.dart';
import '../models/resource_model.dart';
import '../models/paginated_response.dart';
import '../models/paged_result.dart';
import '../models/auth_models.dart';
import '../models/service_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl =
      'https://auf-connect-api-164860087792.europe-west1.run.app';

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();
  String? _authToken;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  // Set auth token
  void setAuthToken(String token) {
    _authToken = token;
  }

  // Clear auth token
  void clearAuthToken() {
    _authToken = null;
  }

  // Get current auth token
  String? get authToken => _authToken;

  Future<PagedResult<PreviewEvent>> getEvents({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/Events').replace(
        queryParameters: {
          'pageNumber': pageNumber.toString(),
          'pageSize': pageSize.toString(),
        },
      );

      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;

        return PagedResult<PreviewEvent>(
          data:
              (jsonResponse['data'] as List<dynamic>)
                  .map(
                    (item) =>
                        PreviewEvent.fromJson(item as Map<String, dynamic>),
                  )
                  .toList(),
          pageNumber: jsonResponse['pageNumber'] ?? pageNumber,
          pageSize: jsonResponse['pageSize'] ?? pageSize,
          totalCount: jsonResponse['totalCount'] ?? 0,
        );
      } else {
        throw Exception(
          'Failed to load events: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching events: $e');
    }
  }

  Future<EventModel?> getEventById(String eventId) async {
    try {
      final uri = Uri.parse('$baseUrl/api/Events/$eventId');
      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return EventModel.fromJson(jsonResponse);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(
          'Failed to load event: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching event: $e');
    }
  }

  Future<EventModel?> getEventByLink(String link) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/api/Events/details',
      ).replace(queryParameters: {'link': link});
      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return EventModel.fromJson(jsonResponse);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(
          'Failed to load event: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching event by link: $e');
    }
  }

  Future<EventModel> createEvent(EventModel event) async {
    try {
      final uri = Uri.parse('$baseUrl/api/Events');
      final response = await _client.post(
        uri,
        headers: _headers,
        body: json.encode(event.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return EventModel.fromJson(jsonResponse);
      } else {
        throw Exception(
          'Failed to create event: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error creating event: $e');
    }
  }

  Future<EventModel> updateEvent(EventModel event) async {
    try {
      final uri = Uri.parse('$baseUrl/api/Events/${event.id}');
      final response = await _client.put(
        uri,
        headers: _headers,
        body: json.encode(event.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return EventModel.fromJson(jsonResponse);
      } else {
        throw Exception(
          'Failed to update event: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error updating event: $e');
    }
  }

  Future<bool> deleteEvent(String eventId) async {
    try {
      final uri = Uri.parse('$baseUrl/api/Events/$eventId');
      final response = await _client.delete(uri, headers: _headers);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception(
          'Failed to delete event: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error deleting event: $e');
    }
  }

  Future<PaginatedResponse<PreviewProject>> getProjectsPaginated({
    int pageNumber = 1,
    int pageSize = 10,
    List<String>? regions,
    List<String>? axes,
    List<int>? status,
  }) async {
    try {
      final params = <String, String>{
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
      };
      final List<String> pairs = [
        for (final e in params.entries)
          '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}',
      ];
      if (regions != null) {
        for (final r in regions) {
          pairs.add('regions=${Uri.encodeQueryComponent(r)}');
        }
      }
      if (axes != null) {
        for (final a in axes) {
          pairs.add('axes=${Uri.encodeQueryComponent(a)}');
        }
      }
      if (status != null) {
        for (final s in status) {
          pairs.add('status=${Uri.encodeQueryComponent(s.toString())}');
        }
      }
      final query = pairs.join('&');
      final uri = Uri.parse(
        '$baseUrl/api/Projects${query.isEmpty ? '' : '?$query'}',
      );

      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;

        // Handle PagedResult<PreviewProject> format from your API
        final totalCount = jsonResponse['totalCount'] ?? 0;
        final totalPages = (totalCount / pageSize).ceil();

        return PaginatedResponse<PreviewProject>(
          data:
              (jsonResponse['data'] as List<dynamic>)
                  .map(
                    (item) =>
                        PreviewProject.fromJson(item as Map<String, dynamic>),
                  )
                  .toList(),
          currentPage: jsonResponse['pageNumber'] ?? pageNumber,
          totalPages: totalPages,
          pageSize: jsonResponse['pageSize'] ?? pageSize,
          totalCount: totalCount,
          hasNextPage: pageNumber < totalPages,
          hasPreviousPage: pageNumber > 1,
        );
      } else {
        throw Exception(
          'Failed to load projects: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching projects: $e');
    }
  }

  Future<ProjectModel?> getProjectById(String projectId) async {
    try {
      final uri = Uri.parse('$baseUrl/api/Projects/$projectId');
      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return ProjectModel.fromJson(jsonResponse);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(
          'Failed to load project: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching project: $e');
    }
  }

  Future<ProjectModel?> getProjectByLink(String link) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/api/Projects/details',
      ).replace(queryParameters: {'link': link});
      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return ProjectModel.fromJson(jsonResponse);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(
          'Failed to load project: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching project by link: $e');
    }
  }

  Future<ProjectModel?> getProjectByIdOrName({String? id, String? name}) async {
    if (id == null && name == null) {
      throw ArgumentError('Either id or name must be provided');
    }

    try {
      final queryParameters = <String, String>{};
      if (id != null) queryParameters['id'] = id;
      if (name != null) queryParameters['name'] = name;

      final uri = Uri.parse(
        '$baseUrl/api/Projects/details',
      ).replace(queryParameters: queryParameters);

      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return ProjectModel.fromJson(jsonResponse);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(
          'Failed to load project: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching project: $e');
    }
  }

  Future<PaginatedResponse<PreviewProject>> searchProjects({
    required String query,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      if (query.trim().isEmpty) {
        throw Exception('Search query is required');
      }

      final uri = Uri.parse('$baseUrl/api/Projects/search').replace(
        queryParameters: {
          'query': query,
          'pageNumber': pageNumber.toString(),
          'pageSize': pageSize.toString(),
        },
      );

      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;

        final totalCount = jsonResponse['totalCount'] ?? 0;
        final totalPages = (totalCount / pageSize).ceil();

        return PaginatedResponse<PreviewProject>(
          data:
              (jsonResponse['data'] as List<dynamic>)
                  .map(
                    (item) =>
                        PreviewProject.fromJson(item as Map<String, dynamic>),
                  )
                  .toList(),
          currentPage: jsonResponse['pageNumber'] ?? pageNumber,
          totalPages: totalPages,
          pageSize: jsonResponse['pageSize'] ?? pageSize,
          totalCount: totalCount,
          hasNextPage: pageNumber < totalPages,
          hasPreviousPage: pageNumber > 1,
        );
      } else if (response.statusCode == 400) {
        throw Exception('Search query is required');
      } else {
        throw Exception(
          'Failed to search projects: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error searching projects: $e');
    }
  }

  // Members API methods
  Future<PaginatedResponse<PreviewMember>> getMembersPaginated({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/Members').replace(
        queryParameters: {
          'pageNumber': pageNumber.toString(),
          'pageSize': pageSize.toString(),
        },
      );

      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;

        // Handle PagedResult<PreviewMember> format from your API
        final totalCount = jsonResponse['totalCount'] ?? 0;
        final totalPages = (totalCount / pageSize).ceil();

        return PaginatedResponse<PreviewMember>(
          data:
              (jsonResponse['data'] as List<dynamic>)
                  .map(
                    (item) =>
                        PreviewMember.fromJson(item as Map<String, dynamic>),
                  )
                  .toList(),
          currentPage: jsonResponse['pageNumber'] ?? pageNumber,
          totalPages: totalPages,
          pageSize: jsonResponse['pageSize'] ?? pageSize,
          totalCount: totalCount,
          hasNextPage: pageNumber < totalPages,
          hasPreviousPage: pageNumber > 1,
        );
      } else {
        throw Exception(
          'Failed to load members: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching members: $e');
    }
  }

  Future<MemberModel?> getMemberById(String memberId) async {
    try {
      final uri = Uri.parse('$baseUrl/api/Members/$memberId');
      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return MemberModel.fromJson(jsonResponse);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(
          'Failed to load member: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching member: $e');
    }
  }

  Future<MemberModel?> getMemberByName(String memberName) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/api/Members/details/${Uri.encodeComponent(memberName)}',
      );
      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return MemberModel.fromJson(jsonResponse);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(
          'Failed to load member: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching member by name: $e');
    }
  }

  Future<MemberModel?> getMemberByLink(String link) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/api/Members/details',
      ).replace(queryParameters: {'link': link});
      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return MemberModel.fromJson(jsonResponse);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(
          'Failed to load member: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching member by link: $e');
    }
  }

  Future<MemberModel?> getMemberByIdOrName({String? id, String? name}) async {
    if (id == null && name == null) {
      throw ArgumentError('Either id or name must be provided');
    }

    try {
      final queryParameters = <String, String>{};
      if (id != null) queryParameters['id'] = id;
      if (name != null) queryParameters['name'] = name;

      final uri = Uri.parse(
        '$baseUrl/api/Members/details',
      ).replace(queryParameters: queryParameters);

      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return MemberModel.fromJson(jsonResponse);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(
          'Failed to load member: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching member: $e');
    }
  }

  // Partners API methods
  Future<PaginatedResponse<PartnerModel>> getPartnersPaginated({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/Partners').replace(
        queryParameters: {
          'pageNumber': pageNumber.toString(),
          'pageSize': pageSize.toString(),
        },
      );

      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;

        // Handle PagedResult<Partner> format from your API
        final totalCount = jsonResponse['totalCount'] ?? 0;
        final totalPages = (totalCount / pageSize).ceil();

        return PaginatedResponse<PartnerModel>(
          data:
              (jsonResponse['data'] as List<dynamic>)
                  .map(
                    (item) =>
                        PartnerModel.fromJson(item as Map<String, dynamic>),
                  )
                  .toList(),
          currentPage: jsonResponse['pageNumber'] ?? pageNumber,
          totalPages: totalPages,
          pageSize: jsonResponse['pageSize'] ?? pageSize,
          totalCount: totalCount,
          hasNextPage: pageNumber < totalPages,
          hasPreviousPage: pageNumber > 1,
        );
      } else {
        throw Exception(
          'Failed to load partners: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching partners: $e');
    }
  }

  Future<PagedResult<PreviewResource>> getResourcesByType({
    required ResourceType type,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/Resources').replace(
        queryParameters: {
          'type': type.value,
          'pageNumber': pageNumber.toString(),
          'pageSize': pageSize.toString(),
        },
      );

      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;

        return PagedResult<PreviewResource>(
          data:
              (jsonResponse['data'] as List<dynamic>)
                  .map(
                    (item) =>
                        PreviewResource.fromJson(item as Map<String, dynamic>),
                  )
                  .toList(),
          pageNumber: jsonResponse['pageNumber'] ?? pageNumber,
          pageSize: jsonResponse['pageSize'] ?? pageSize,
          totalCount: jsonResponse['totalCount'] ?? 0,
        );
      } else {
        throw Exception(
          'Failed to load resources: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching resources: $e');
    }
  }

  Future<PreviewResource?> getResourceById(String resourceId) async {
    try {
      final uri = Uri.parse('$baseUrl/api/Resources/$resourceId');
      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return PreviewResource.fromJson(jsonResponse);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(
          'Failed to load resource: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching resource: $e');
    }
  }

  Future<ResourceSection?> getResourceByIdOrName({
    String? id,
    String? name,
  }) async {
    if (id == null && name == null) {
      throw ArgumentError('Either id or name must be provided');
    }

    try {
      final queryParameters = <String, String>{};
      if (id != null) queryParameters['id'] = id;
      if (name != null) queryParameters['name'] = name;

      final uri = Uri.parse(
        '$baseUrl/api/Resources/details',
      ).replace(queryParameters: queryParameters);

      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return ResourceSection.fromJson(jsonResponse);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(
          'Failed to load resource: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching resource: $e');
    }
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final uri = Uri.parse('$baseUrl/api/User/register');
      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;

        print("================================");
        print(jsonResponse);
        final authResponse = AuthResponse.fromJson(jsonResponse);

        setAuthToken(authResponse.token);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', authResponse.token);

        return authResponse;
      } else {
        final errorBody = json.decode(response.body);
        throw ApiException(
          statusCode: response.statusCode,
          message: errorBody['message'] ?? errorBody.toString(),
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(statusCode: 0, message: 'Network error: $e');
    }
  }

  Future<AuthResponse> login(
    LoginRequest request, {
    bool rememberMe = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/User/login');
      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;

        final authResponse = AuthResponse.fromJson(jsonResponse);

        setAuthToken(authResponse.token);

        if (rememberMe) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', authResponse.token);
        }

        return authResponse;
      } else {
        final errorBody = json.decode(response.body);
        print(errorBody);
        throw ApiException(
          statusCode: response.statusCode,
          message: errorBody['message'] ?? errorBody.toString(),
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(statusCode: 0, message: 'Network error: $e');
    }
  }

  Future<void> logout() async {
    try {
      clearAuthToken();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
    } catch (e) {
      throw Exception('Error during logout: $e');
    }
  }

  Future<EditUserResponse> editUser(
    String userId,
    EditUserRequest request,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/api/User/edit/$userId');

      final body = json.encode(request.toJson());

      final response = await _client.put(uri, headers: _headers, body: body);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        final editUserResponse = EditUserResponse.fromJson(jsonResponse);

        return editUserResponse;
      } else if (response.statusCode == 404) {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'User not found',
        );
      } else {
        final errorBody = json.decode(response.body);
        throw ApiException(
          statusCode: response.statusCode,
          message: errorBody['message'] ?? errorBody.toString(),
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(statusCode: 0, message: 'Network error: $e');
    }
  }

  // Favorite Projects API methods
  Future<void> addFavoriteProject(String userId, String projectId) async {
    try {
      final uri = Uri.parse('$baseUrl/api/User/$userId/favorites');
      final request = FavoriteProjectRequest(projectId: projectId);

      final response = await _client.post(
        uri,
        headers: _headers,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 400) {
        final errorBody = json.decode(response.body);
        throw ApiException(
          statusCode: response.statusCode,
          message: errorBody['message'] ?? 'Project already in favorites',
        );
      } else {
        final errorBody = json.decode(response.body);
        throw ApiException(
          statusCode: response.statusCode,
          message: errorBody['message'] ?? errorBody.toString(),
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(statusCode: 0, message: 'Network error: $e');
    }
  }

  Future<void> removeFavoriteProject(String userId, String projectId) async {
    try {
      final uri = Uri.parse('$baseUrl/api/User/$userId/favorites');
      final request = FavoriteProjectRequest(projectId: projectId);

      final response = await _client.delete(
        uri,
        headers: _headers,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 404) {
        final errorBody = json.decode(response.body);
        throw ApiException(
          statusCode: response.statusCode,
          message: errorBody['message'] ?? 'Project not found in favorites',
        );
      } else {
        final errorBody = json.decode(response.body);
        throw ApiException(
          statusCode: response.statusCode,
          message: errorBody['message'] ?? errorBody.toString(),
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(statusCode: 0, message: 'Network error: $e');
    }
  }

  Future<List<String>> getFavoriteProjects(String userId) async {
    try {
      final uri = Uri.parse('$baseUrl/api/User/$userId/favorites');
      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as List<dynamic>;
        // Backend returns List<Guid>, convert to List<String> project IDs
        return jsonResponse.map((projectId) => projectId.toString()).toList();
      } else {
        throw Exception(
          'Failed to load favorite projects: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw Exception('Error fetching favorite projects: $e');
    }
  }

  // Get full favorite projects details for a user
  Future<List<ProjectModel>> getFavoriteProjectsDetailed(String userId) async {
    try {
      final uri = Uri.parse('$baseUrl/api/User/$userId/favorite-projects');
      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as List<dynamic>;
        return jsonResponse
            .map((item) => ProjectModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 404) {
        // User or resource not found; return empty list for convenience
        return <ProjectModel>[];
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message:
              'Failed to load favorite projects details: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(statusCode: 0, message: 'Network error: $e');
    }
  }

  Future<String?> getStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        setAuthToken(token);
      }
      return token;
    } catch (e) {
      return null;
    }
  }

  // Services API methods
  Future<List<ServiceModel>> getServices() async {
    try {
      final uri = Uri.parse('$baseUrl/api/Services');
      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as List<dynamic>;
        return jsonResponse
            .map((item) => ServiceModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Failed to load services: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching services: $e');
    }
  }

  Future<void> resetPassword({
    String? userId,
    String? email,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      if ((userId == null || userId.isEmpty) &&
          (email == null || email.isEmpty)) {
        throw ApiException(
          statusCode: 400,
          message: 'Either User ID or Email is required',
        );
      }

      final uri = Uri.parse('$baseUrl/api/user/reset-password');

      final requestBody = <String, dynamic>{
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      };

      if (userId != null && userId.isNotEmpty) {
        requestBody['userId'] = userId;
      }
      if (email != null && email.isNotEmpty) {
        requestBody['email'] = email;
      }

      final response = await _client.put(
        uri,
        headers: _headers,
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        return;
      } else {
        final errorBody = json.decode(response.body);
        throw ApiException(
          statusCode: response.statusCode,
          message: errorBody['message'] ?? errorBody.toString(),
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(statusCode: 0, message: 'Network error: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}

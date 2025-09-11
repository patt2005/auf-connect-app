import 'dart:async';
import '../models/resource_model.dart';
import '../models/preview_resource_model.dart';
import '../models/paged_result.dart';
import 'api_service.dart';

class ResourcesService {
  static final ResourcesService _instance = ResourcesService._internal();
  factory ResourcesService() => _instance;
  ResourcesService._internal();

  final ApiService _apiService = ApiService();
  final Map<ResourceType, List<PreviewResource>> _cachedResources = {};
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetchTime;

  static const Duration _cacheDuration = Duration(minutes: 5);

  final StreamController<Map<ResourceType, List<PreviewResource>>>
  _resourcesController =
      StreamController<Map<ResourceType, List<PreviewResource>>>.broadcast();
  final StreamController<bool> _loadingController =
      StreamController<bool>.broadcast();
  final StreamController<String?> _errorController =
      StreamController<String?>.broadcast();

  // Getters
  Map<ResourceType, List<PreviewResource>> get cachedResources =>
      _cachedResources;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _cachedResources.isNotEmpty;

  // Streams
  Stream<Map<ResourceType, List<PreviewResource>>> get resourcesStream =>
      _resourcesController.stream;
  Stream<bool> get loadingStream => _loadingController.stream;
  Stream<String?> get errorStream => _errorController.stream;

  // Check if cache is still valid
  bool get _isCacheValid {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheDuration;
  }

  // Fetch resources by type from API or return cached data
  Future<List<PreviewResource>> getResourcesByType(
    ResourceType type, {
    bool forceRefresh = false,
    int pageSize = 10,
  }) async {
    // Return cached data if valid and not forcing refresh
    if (!forceRefresh && _isCacheValid && _cachedResources.containsKey(type)) {
      return _cachedResources[type]!;
    }

    return _fetchResourcesByType(type, pageSize: pageSize);
  }

  // Private method to fetch resources from API
  Future<List<PreviewResource>> _fetchResourcesByType(
    ResourceType type, {
    int pageSize = 10,
  }) async {
    if (_isLoading) {
      return _cachedResources[type] ?? [];
    }

    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.getResourcesByType(
        type: type,
        pageNumber: 1,
        pageSize: pageSize,
      );

      _cachedResources[type] = response.data;
      _lastFetchTime = DateTime.now();

      _resourcesController.add(_cachedResources);
      return response.data;
    } catch (e) {
      final errorMessage = 'Failed to fetch resources: ${e.toString()}';
      _setError(errorMessage);

      if (_cachedResources.containsKey(type)) {
        return _cachedResources[type]!;
      }

      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Get paginated resources by type from API
  Future<PagedResult<PreviewResource>> getResourcesByTypePaginated({
    required ResourceType type,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await _apiService.getResourcesByType(
        type: type,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );

      return response;
    } catch (e) {
      final errorMessage = 'Failed to fetch resources: ${e.toString()}';
      _setError(errorMessage);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Get recent resources for a specific type (limit to 3 for home screen)
  List<PreviewResource> getRecentResourcesByType(
    ResourceType type, {
    int limit = 3,
  }) {
    if (!_cachedResources.containsKey(type) ||
        _cachedResources[type]!.isEmpty) {
      return [];
    }

    return _cachedResources[type]!.take(limit).toList();
  }

  // Refresh resources data for a specific type
  Future<void> refreshResourcesByType(ResourceType type) async {
    await _fetchResourcesByType(type);
  }

  // Initialize data for all resource types
  Future<void> initializeData() async {
    for (ResourceType type in ResourceType.values) {
      try {
        await _fetchResourcesByType(type, pageSize: 5);
      } catch (e) {
        // Continue with other types even if one fails
        continue;
      }
    }
  }

  // Clear cache
  void clearCache() {
    _cachedResources.clear();
    _lastFetchTime = null;
    _resourcesController.add(_cachedResources);
  }

  // Clear cache for specific type
  void clearCacheForType(ResourceType type) {
    _cachedResources.remove(type);
    _resourcesController.add(_cachedResources);
  }

  // Get full resource details by ID
  Future<ResourceSection?> getResourceDetailsById(String resourceId) async {
    try {
      return await _apiService.getResourceByIdOrName(id: resourceId);
    } catch (e) {
      _setError('Failed to fetch resource details: ${e.toString()}');
      rethrow;
    }
  }

  // Get full resource details by name
  Future<ResourceSection?> getResourceDetailsByName(String resourceName) async {
    try {
      return await _apiService.getResourceByIdOrName(name: resourceName);
    } catch (e) {
      _setError('Failed to fetch resource details: ${e.toString()}');
      rethrow;
    }
  }

  // Get full resource details by ID or name (flexible method)
  Future<ResourceSection?> getResourceDetails({
    String? id,
    String? name,
  }) async {
    try {
      return await _apiService.getResourceByIdOrName(id: id, name: name);
    } catch (e) {
      _setError('Failed to fetch resource details: ${e.toString()}');
      rethrow;
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    _loadingController.add(_isLoading);
  }

  void _setError(String? error) {
    _error = error;
    _errorController.add(_error);
  }

  // Format resource name for API URL (lowercase with dashes instead of spaces)
  String formatResourceNameForApi(String resourceName) {
    return resourceName
        .toLowerCase()                    // Convert to lowercase
        .trim()                          // Remove leading/trailing spaces
        .replaceAll(RegExp(r'[^\w\s-]'), '') // Remove special characters except word chars, spaces, and dashes
        .replaceAll(RegExp(r'\s+'), '-')     // Replace one or more spaces with single dash
        .replaceAll(RegExp(r'-+'), '-')      // Replace multiple consecutive dashes with single dash
        .replaceAll(RegExp(r'^-+|-+$'), ''); // Remove leading/trailing dashes
  }

  // Dispose streams
  void dispose() {
    _resourcesController.close();
    _loadingController.close();
    _errorController.close();
  }
}

import 'dart:async';
import '../models/project_model.dart';
import '../models/paginated_response.dart';
import 'api_service.dart';

class ProjectsService {
  static final ProjectsService _instance = ProjectsService._internal();
  factory ProjectsService() => _instance;
  ProjectsService._internal();

  final ApiService _apiService = ApiService();
  List<PreviewProject> _cachedProjects = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetchTime;
  
  // Cache duration - 5 minutes
  static const Duration _cacheDuration = Duration(minutes: 5);

  // Stream controllers for reactive updates
  final StreamController<List<PreviewProject>> _projectsController = 
      StreamController<List<PreviewProject>>.broadcast();
  final StreamController<bool> _loadingController = 
      StreamController<bool>.broadcast();
  final StreamController<String?> _errorController = 
      StreamController<String?>.broadcast();

  // Getters
  List<PreviewProject> get cachedProjects => _cachedProjects;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _cachedProjects.isNotEmpty;
  
  // Streams
  Stream<List<PreviewProject>> get projectsStream => _projectsController.stream;
  Stream<bool> get loadingStream => _loadingController.stream;
  Stream<String?> get errorStream => _errorController.stream;

  // Check if cache is still valid
  bool get _isCacheValid {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheDuration;
  }

  Future<List<PreviewProject>> getProjects({
    bool forceRefresh = false,
    int pageSize = 10,
  }) async {
    if (!forceRefresh && _isCacheValid && _cachedProjects.isNotEmpty) {
      return _cachedProjects;
    }

    return _fetchProjects(pageSize: pageSize);
  }

  Future<List<PreviewProject>> _fetchProjects({int pageSize = 10}) async {
    if (_isLoading) return _cachedProjects;

    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.getProjectsPaginated(
        pageNumber: 1,
        pageSize: pageSize,
      );

      _cachedProjects = response.data;
      _lastFetchTime = DateTime.now();
      
      _projectsController.add(_cachedProjects);
      return _cachedProjects;
    } catch (e) {
      final errorMessage = 'Failed to fetch projects: ${e.toString()}';
      _setError(errorMessage);
      
      // Return cached data if available, even if stale
      if (_cachedProjects.isNotEmpty) {
        return _cachedProjects;
      }
      
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Get paginated projects from API
  Future<PaginatedResponse<PreviewProject>> getProjectsPaginated({
    int pageNumber = 1,
    int pageSize = 10,
    List<String>? regions,
    List<String>? axes,
    List<int>? status,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final response = await _apiService.getProjectsPaginated(
        pageNumber: pageNumber,
        pageSize: pageSize,
        regions: regions,
        axes: axes,
        status: status,
      );
      
      return response;
    } catch (e) {
      final errorMessage = 'Failed to fetch projects: ${e.toString()}';
      _setError(errorMessage);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Refresh projects data
  Future<void> refreshProjects() async {
    await _fetchProjects();
  }

  // Get full project details by ID
  Future<ProjectModel?> getProjectDetailsById(String projectId) async {
    try {
      return await _apiService.getProjectByIdOrName(id: projectId);
    } catch (e) {
      _setError('Failed to fetch project details: ${e.toString()}');
      rethrow;
    }
  }

  // Get full project details by ID or name (flexible method)
  Future<ProjectModel?> getProjectDetails({
    String? id,
    String? name,
  }) async {
    try {
      return await _apiService.getProjectByIdOrName(id: id, name: name);
    } catch (e) {
      _setError('Failed to fetch project details: ${e.toString()}');
      rethrow;
    }
  }

  // Search projects
  Future<PaginatedResponse<PreviewProject>> searchProjects({
    required String query,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final response = await _apiService.searchProjects(
        query: query,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
      
      return response;
    } catch (e) {
      final errorMessage = 'Failed to search projects: ${e.toString()}';
      _setError(errorMessage);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Initialize data (call from splash screen)
  Future<void> initializeData() async {
    await _fetchProjects();
  }

  // Clear cache
  void clearCache() {
    _cachedProjects.clear();
    _lastFetchTime = null;
    _projectsController.add(_cachedProjects);
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

  // Dispose streams
  void dispose() {
    _projectsController.close();
    _loadingController.close();
    _errorController.close();
  }
}

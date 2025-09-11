import 'dart:async';
import '../models/member_model.dart';
import '../models/paginated_response.dart';
import 'api_service.dart';

class MembersService {
  static final MembersService _instance = MembersService._internal();
  factory MembersService() => _instance;
  MembersService._internal();

  final ApiService _apiService = ApiService();
  List<PreviewMember> _cachedMembers = [];
  bool _isLoading = false;
  String? _error;

  // Stream controllers for reactive updates
  final StreamController<List<PreviewMember>> _membersController = 
      StreamController<List<PreviewMember>>.broadcast();
  final StreamController<bool> _loadingController = 
      StreamController<bool>.broadcast();
  final StreamController<String?> _errorController = 
      StreamController<String?>.broadcast();

  // Getters
  List<PreviewMember> get cachedMembers => _cachedMembers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _cachedMembers.isNotEmpty;
  
  // Streams
  Stream<List<PreviewMember>> get membersStream => _membersController.stream;
  Stream<bool> get loadingStream => _loadingController.stream;
  Stream<String?> get errorStream => _errorController.stream;

  // Private method to fetch members from API
  Future<List<PreviewMember>> _fetchMembers({int pageSize = 10}) async {
    if (_isLoading) return _cachedMembers;

    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.getMembersPaginated(
        pageNumber: 1,
        pageSize: pageSize,
      );

      _cachedMembers = response.data;
      
      _membersController.add(_cachedMembers);
      return _cachedMembers;
    } catch (e) {
      final errorMessage = 'Failed to fetch members: ${e.toString()}';
      _setError(errorMessage);
      
      // Return cached data if available, even if stale
      if (_cachedMembers.isNotEmpty) {
        return _cachedMembers;
      }
      
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Get paginated members from API
  Future<PaginatedResponse<PreviewMember>> getMembersPaginated({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final response = await _apiService.getMembersPaginated(
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
      
      return response;
    } catch (e) {
      final errorMessage = 'Failed to fetch members: ${e.toString()}';
      _setError(errorMessage);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Refresh members data
  Future<void> refreshMembers() async {
    await _fetchMembers();
  }

  // Get full member details by ID
  Future<MemberModel?> getMemberDetailsById(String memberId) async {
    try {
      return await _apiService.getMemberByIdOrName(id: memberId);
    } catch (e) {
      _setError('Failed to fetch member details: ${e.toString()}');
      rethrow;
    }
  }

  // Initialize data (call from splash screen)
  Future<void> initializeData() async {
    await _fetchMembers();
  }

  // Clear cache
  void clearCache() {
    _cachedMembers.clear();
    _membersController.add(_cachedMembers);
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
    _membersController.close();
    _loadingController.close();
    _errorController.close();
  }
}
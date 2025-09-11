import 'dart:async';
import '../models/partner_model.dart';
import '../models/paginated_response.dart';
import 'api_service.dart';

class PartnersService {
  static final PartnersService _instance = PartnersService._internal();
  factory PartnersService() => _instance;
  PartnersService._internal();

  final ApiService _apiService = ApiService();
  List<PartnerModel> _cachedPartners = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetchTime;
  
  // Cache duration - 5 minutes
  static const Duration _cacheDuration = Duration(minutes: 5);

  // Stream controllers for reactive updates
  final StreamController<List<PartnerModel>> _partnersController = 
      StreamController<List<PartnerModel>>.broadcast();
  final StreamController<bool> _loadingController = 
      StreamController<bool>.broadcast();
  final StreamController<String?> _errorController = 
      StreamController<String?>.broadcast();

  // Getters
  List<PartnerModel> get cachedPartners => _cachedPartners;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _cachedPartners.isNotEmpty;
  
  // Streams
  Stream<List<PartnerModel>> get partnersStream => _partnersController.stream;
  Stream<bool> get loadingStream => _loadingController.stream;
  Stream<String?> get errorStream => _errorController.stream;

  // Check if cache is still valid
  bool get _isCacheValid {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheDuration;
  }

  // Fetch partners from API or return cached data
  Future<List<PartnerModel>> getPartners({
    bool forceRefresh = false,
    int pageSize = 10,
  }) async {
    // Return cached data if valid and not forcing refresh
    if (!forceRefresh && _isCacheValid && _cachedPartners.isNotEmpty) {
      return _cachedPartners;
    }

    return _fetchPartners(pageSize: pageSize);
  }

  // Private method to fetch partners from API
  Future<List<PartnerModel>> _fetchPartners({int pageSize = 10}) async {
    if (_isLoading) return _cachedPartners;

    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.getPartnersPaginated(
        pageNumber: 1,
        pageSize: pageSize,
      );

      _cachedPartners = response.data;
      _lastFetchTime = DateTime.now();
      
      _partnersController.add(_cachedPartners);
      return _cachedPartners;
    } catch (e) {
      final errorMessage = 'Failed to fetch partners: ${e.toString()}';
      _setError(errorMessage);
      
      // Return cached data if available, even if stale
      if (_cachedPartners.isNotEmpty) {
        return _cachedPartners;
      }
      
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Get paginated partners from API
  Future<PaginatedResponse<PartnerModel>> getPartnersPaginated({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final response = await _apiService.getPartnersPaginated(
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
      
      return response;
    } catch (e) {
      final errorMessage = 'Failed to fetch partners: ${e.toString()}';
      _setError(errorMessage);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Get recent partners (limit for home screen)
  List<PartnerModel> getRecentPartners({int limit = 3}) {
    if (_cachedPartners.isEmpty) return [];
    
    return _cachedPartners.take(limit).toList();
  }

  // Refresh partners data
  Future<void> refreshPartners() async {
    await _fetchPartners();
  }

  // Initialize data (call from splash screen)
  Future<void> initializeData() async {
    await _fetchPartners();
  }

  // Clear cache
  void clearCache() {
    _cachedPartners.clear();
    _lastFetchTime = null;
    _partnersController.add(_cachedPartners);
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
    _partnersController.close();
    _loadingController.close();
    _errorController.close();
  }
}
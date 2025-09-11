import 'dart:async';
import '../models/service_model.dart';
import 'api_service.dart';

class ServicesService {
  static final ServicesService _instance = ServicesService._internal();
  factory ServicesService() => _instance;
  ServicesService._internal();

  final ApiService _apiService = ApiService();
  List<ServiceModel> _cachedServices = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetchTime;
  
  // Cache duration - 5 minutes
  static const Duration _cacheDuration = Duration(minutes: 5);

  // Stream controllers for reactive updates
  final StreamController<List<ServiceModel>> _servicesController = 
      StreamController<List<ServiceModel>>.broadcast();
  final StreamController<bool> _loadingController = 
      StreamController<bool>.broadcast();
  final StreamController<String?> _errorController = 
      StreamController<String?>.broadcast();

  // Getters
  List<ServiceModel> get cachedServices => _cachedServices;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _cachedServices.isNotEmpty;
  
  // Streams
  Stream<List<ServiceModel>> get servicesStream => _servicesController.stream;
  Stream<bool> get loadingStream => _loadingController.stream;
  Stream<String?> get errorStream => _errorController.stream;

  // Check if cache is still valid
  bool get _isCacheValid {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheDuration;
  }

  // Fetch services from API or return cached data
  Future<List<ServiceModel>> getServices({
    bool forceRefresh = false,
  }) async {
    // Return cached data if valid and not forcing refresh
    if (!forceRefresh && _isCacheValid && _cachedServices.isNotEmpty) {
      return _cachedServices;
    }

    return _fetchServices();
  }

  // Private method to fetch services from API
  Future<List<ServiceModel>> _fetchServices() async {
    if (_isLoading) return _cachedServices;

    _setLoading(true);
    _setError(null);

    try {
      final services = await _apiService.getServices();

      _cachedServices = services;
      _lastFetchTime = DateTime.now();
      
      _servicesController.add(_cachedServices);
      return _cachedServices;
    } catch (e) {
      final errorMessage = 'Failed to fetch services: ${e.toString()}';
      _setError(errorMessage);
      
      // Return cached data if available, even if stale
      if (_cachedServices.isNotEmpty) {
        return _cachedServices;
      }
      
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Get recent services (limit to 3 for home screen)
  List<ServiceModel> getRecentServices({int limit = 3}) {
    if (_cachedServices.isEmpty) return [];
    
    // Sort by date (newest first) and take the limit
    final sortedServices = List<ServiceModel>.from(_cachedServices);
    sortedServices.sort((a, b) => b.dateString.compareTo(a.dateString));
    
    return sortedServices.take(limit).toList();
  }

  // Refresh services data
  Future<void> refreshServices() async {
    await _fetchServices();
  }

  // Initialize data (call from splash screen)
  Future<void> initializeData() async {
    await _fetchServices();
  }

  // Clear cache
  void clearCache() {
    _cachedServices.clear();
    _lastFetchTime = null;
    _servicesController.add(_cachedServices);
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
    _servicesController.close();
    _loadingController.close();
    _errorController.close();
  }
}
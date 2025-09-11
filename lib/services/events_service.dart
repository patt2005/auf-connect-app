import 'dart:async';
import '../models/preview_event_model.dart';
import '../models/event_model.dart';
import '../models/paged_result.dart';
import 'api_service.dart';

class EventsService {
  static final EventsService _instance = EventsService._internal();
  factory EventsService() => _instance;
  EventsService._internal();

  final ApiService _apiService = ApiService();
  List<PreviewEvent> _cachedEvents = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetchTime;
  
  // Cache duration - 5 minutes
  static const Duration _cacheDuration = Duration(minutes: 5);

  // Stream controllers for reactive updates
  final StreamController<List<PreviewEvent>> _eventsController = 
      StreamController<List<PreviewEvent>>.broadcast();
  final StreamController<bool> _loadingController = 
      StreamController<bool>.broadcast();
  final StreamController<String?> _errorController = 
      StreamController<String?>.broadcast();

  // Getters
  List<PreviewEvent> get cachedEvents => _cachedEvents;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _cachedEvents.isNotEmpty;
  
  // Streams
  Stream<List<PreviewEvent>> get eventsStream => _eventsController.stream;
  Stream<bool> get loadingStream => _loadingController.stream;
  Stream<String?> get errorStream => _errorController.stream;

  // Check if cache is still valid
  bool get _isCacheValid {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheDuration;
  }

  // Fetch events from API or return cached data
  Future<List<PreviewEvent>> getEvents({
    bool forceRefresh = false,
    int pageSize = 10,
  }) async {
    // Return cached data if valid and not forcing refresh
    if (!forceRefresh && _isCacheValid && _cachedEvents.isNotEmpty) {
      return _cachedEvents;
    }

    return _fetchEvents(pageSize: pageSize);
  }

  // Private method to fetch events from API
  Future<List<PreviewEvent>> _fetchEvents({int pageSize = 10}) async {
    if (_isLoading) return _cachedEvents;

    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.getEvents(
        pageNumber: 1,
        pageSize: pageSize,
      );

      _cachedEvents = response.data;
      _lastFetchTime = DateTime.now();
      
      _eventsController.add(_cachedEvents);
      return _cachedEvents;
    } catch (e) {
      final errorMessage = 'Failed to fetch events: ${e.toString()}';
      _setError(errorMessage);
      
      // Return cached data if available, even if stale
      if (_cachedEvents.isNotEmpty) {
        return _cachedEvents;
      }
      
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Get paginated events from API
  Future<PagedResult<PreviewEvent>> getEventsPaginated({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final response = await _apiService.getEvents(
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
      
      return response;
    } catch (e) {
      final errorMessage = 'Failed to fetch events: ${e.toString()}';
      _setError(errorMessage);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Get recent events (limit to 3 for home screen)
  List<PreviewEvent> getRecentEvents({int limit = 3}) {
    if (_cachedEvents.isEmpty) return [];
    
    // Sort by date (newest first) and take the limit
    final sortedEvents = List<PreviewEvent>.from(_cachedEvents);
    sortedEvents.sort((a, b) => b.date.compareTo(a.date));
    
    return sortedEvents.take(limit).toList();
  }

  // Refresh events data
  Future<void> refreshEvents() async {
    await _fetchEvents();
  }

  // Get full event details by ID
  Future<EventModel?> getEventDetailsById(String eventId) async {
    try {
      return await _apiService.getEventById(eventId);
    } catch (e) {
      _setError('Failed to fetch event details: ${e.toString()}');
      rethrow;
    }
  }

  // Get full event details by link
  Future<EventModel?> getEventDetailsByLink(String link) async {
    try {
      return await _apiService.getEventByLink(link);
    } catch (e) {
      _setError('Failed to fetch event details: ${e.toString()}');
      rethrow;
    }
  }

  // Initialize data (call from splash screen)
  Future<void> initializeData() async {
    await _fetchEvents();
  }

  // Clear cache
  void clearCache() {
    _cachedEvents.clear();
    _lastFetchTime = null;
    _eventsController.add(_cachedEvents);
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
    _eventsController.close();
    _loadingController.close();
    _errorController.close();
  }
}
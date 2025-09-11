import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/events_service.dart';
import '../services/projects_service.dart';
import '../services/members_service.dart';
import '../services/partners_service.dart';
import '../services/resources_service.dart';
import '../services/services_service.dart';
import '../models/preview_event_model.dart';
import '../models/project_model.dart';
import '../models/member_model.dart';
import '../models/partner_model.dart';
import '../models/resource_model.dart';
import '../models/preview_resource_model.dart';
import '../models/service_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'project_detail_screen.dart';
import 'member_detail_screen.dart';
import 'profile_screen.dart';
import 'resource_detail_screen.dart';
import 'event_detail_screen.dart';

enum SectionType { projects, members, partners, resources, services, events }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SectionType _selectedSection = SectionType.members;
  final EventsService _eventsService = EventsService();
  final ProjectsService _projectsService = ProjectsService();
  final MembersService _membersService = MembersService();
  final PartnersService _partnersService = PartnersService();
  final ResourcesService _resourcesService = ResourcesService();
  final ServicesService _servicesService = ServicesService();
  List<PreviewEvent> _events = [];
  List<PreviewProject> _projects = [];
  List<PreviewProject> _filteredProjects = [];
  final List<String> _regions = const [
    'Africa Australă și Oceanul Indian',
    'Africa Centrală și Marile Lacuri',
    'Africa de Vest',
    'Africa de Nord',
    'Americi',
    'Asia-Pacific',
    'Caraibe',
    'Europa Centrală și Orientală',
    'Europa Occidentală',
    'Orientul Mijlociu',
    'Internațional',
  ];
  final List<String> _axes = const [
    'Acreditare',
    'CLEF',
    'Dezvoltare',
    'Angajare',
    'Angajabilitate și inserție profesională',
    'Antreprenoriat',
    'Formare',
    'Francofonie',
    'Guvernare',
    'Inteligență artificială',
    'Calitate',
    'Cercetare',
  ];
  late final Map<String, String> _regionSlugMap = {
    'Africa Australă și Oceanul Indian': 'ocean-indien',
    'Africa Centrală și Marile Lacuri': 'afrique-centrale-grands-lacs',
    'Africa de Vest': 'afrique-ouest',
    'Africa de Nord': 'maghreb',
    'Americi': 'ameriques',
    'Asia-Pacific': 'asie-pacifique',
    'Caraibe': 'caraibe',
    'Europa Centrală și Orientală': 'europe-centrale-orientale',
    'Europa Occidentală': 'europe-ouest',
    'Orientul Mijlociu': 'moyen-orient',
    'Internațional': 'international',
  };
  late final Map<String, String> _axeSlugMap = {
    'Acreditare': 'accreditation',
    'CLEF': 'clef',
    'Dezvoltare': 'developpement',
    'Angajare': 'emploi',
    'Angajabilitate și inserție profesională':
        'employabilite-et-insertion-professionnelle',
    'Antreprenoriat': 'entrepreneuriat',
    'Formare': 'formation',
    'Francofonie': 'francophonie',
    'Guvernare': 'gouvernance',
    'Inteligență artificială': 'intelligence-artificielle',
    'Calitate': 'qualite',
    'Cercetare': 'recherche',
  };
  final Map<int, String> _statusOptions = const {1: 'În curs', 2: 'Terminat'};
  final Set<String> _selectedRegions = {};
  final Set<String> _selectedAxes = {};
  final Set<int> _selectedStatus = {};
  bool _regionsExpanded = false;
  bool _axesExpanded = false;
  bool _statusExpanded = false;
  List<PreviewMember> _members = [];
  List<PartnerModel> _partners = [];
  List<PreviewResource> _resources = [];
  List<ServiceModel> _services = [];
  ResourceType _selectedResourceType = ResourceType.formation;
  int _currentProjectPage = 1;
  int _currentMemberPage = 1;
  int _currentPartnerPage = 1;
  int _currentEventPage = 1;
  int _currentResourcePage = 1;

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  List<PreviewProject> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearchResults = false;
  Timer? _searchTimer;
  String _currentSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _loadProjects();
    _loadMembers();
    _loadPartners();
    _loadResources();
    _loadServices();
    _setupSearchListener();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  void _setupSearchListener() {
    _searchController.addListener(() {
      final query = _searchController.text.trim();

      // Cancel previous timer
      _searchTimer?.cancel();

      // If query is empty, clear search results
      if (query.isEmpty) {
        setState(() {
          _isSearching = false;
          _hasSearchResults = false;
          _searchResults.clear();
          _currentSearchQuery = '';
        });
        return;
      }

      // If query hasn't changed, don't search again
      if (query == _currentSearchQuery) {
        return;
      }

      // Set up debounced search
      _searchTimer = Timer(const Duration(milliseconds: 500), () {
        _performSearch(query);
      });
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
      _currentSearchQuery = query;
    });

    try {
      final searchResponse = await _projectsService.searchProjects(
        query: query,
        pageNumber: 1,
        pageSize: 20,
      );

      if (mounted) {
        setState(() {
          _searchResults = searchResponse.data;
          _hasSearchResults = true;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _hasSearchResults = false;
          _searchResults.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare la căutarea proiectelor: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _hasSearchResults = false;
      _searchResults.clear();
      _currentSearchQuery = '';
    });
  }

  void _loadEvents() {
    _fetchEvents(_currentEventPage);
  }

  Future<void> _fetchEvents(int pageNumber) async {
    setState(() {
      _currentEventPage = pageNumber;
    });

    try {
      final pagedResult = await _eventsService.getEventsPaginated(
        pageNumber: pageNumber,
        pageSize: 10, // Show more events per page
      );

      setState(() {
        _events = pagedResult.data;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare la încărcarea evenimentelor: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _loadProjects() async {
    await _fetchProjects(_currentProjectPage);
  }

  Future<void> _fetchProjects(int pageNumber) async {
    setState(() {
      _currentProjectPage = pageNumber;
    });

    try {
      // Map selected labels to API slugs
      final regionsSlugs =
          _selectedRegions
              .map((r) => _regionSlugMap[r])
              .whereType<String>()
              .toList();
      final axesSlugs =
          _selectedAxes.map((a) => _axeSlugMap[a]).whereType<String>().toList();
      final statusList = _selectedStatus.toList();

      final paginatedResponse = await _projectsService.getProjectsPaginated(
        pageNumber: pageNumber,
        pageSize: 10,
        regions: regionsSlugs.isEmpty ? null : regionsSlugs,
        axes: axesSlugs.isEmpty ? null : axesSlugs,
        status: statusList.isEmpty ? null : statusList,
      );

      setState(() {
        _projects = paginatedResponse.data;
        _filteredProjects = _projects; // API already returns filtered results
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare la încărcarea proiectelor: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _toggleRegion(String region) {
    setState(() {
      if (_selectedRegions.contains(region)) {
        _selectedRegions.remove(region);
      } else {
        _selectedRegions.add(region);
      }
    });
    _fetchProjects(1);
  }

  void _toggleAxe(String axe) {
    setState(() {
      if (_selectedAxes.contains(axe)) {
        _selectedAxes.remove(axe);
      } else {
        _selectedAxes.add(axe);
      }
    });
    _fetchProjects(1);
  }

  void _toggleStatus(int key) {
    setState(() {
      if (_selectedStatus.contains(key)) {
        _selectedStatus.remove(key);
      } else {
        _selectedStatus.add(key);
      }
    });
    _fetchProjects(1);
  }

  void _loadMembers() {
    _fetchMembers(_currentMemberPage);
  }

  Future<void> _fetchMembers(int pageNumber) async {
    setState(() {
      _currentMemberPage = pageNumber;
    });

    try {
      final paginatedResponse = await _membersService.getMembersPaginated(
        pageNumber: pageNumber,
        pageSize: 10,
      );

      setState(() {
        _members = paginatedResponse.data;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare la încărcarea membrilor: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _loadPartners() {
    _fetchPartners(_currentPartnerPage);
  }

  Future<void> _fetchPartners(int pageNumber) async {
    setState(() {
      _currentPartnerPage = pageNumber;
    });

    try {
      final paginatedResponse = await _partnersService.getPartnersPaginated(
        pageNumber: pageNumber,
        pageSize: 10,
      );

      setState(() {
        _partners = paginatedResponse.data;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare la încărcarea partenerilor: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _loadResources() {
    _fetchResources(_selectedResourceType, _currentResourcePage);
  }

  Future<void> _fetchResources(ResourceType type, int pageNumber) async {
    setState(() {
      _selectedResourceType = type;
      _currentResourcePage = pageNumber;
    });

    try {
      // Fetch resources from API with pagination
      final pagedResult = await _resourcesService.getResourcesByTypePaginated(
        type: type,
        pageNumber: pageNumber,
        pageSize: 10, // Show more resources per page
      );

      setState(() {
        _resources = pagedResult.data;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare la încărcarea resurselor: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _loadServices() async {
    try {
      final services = await _servicesService.getServices();
      if (mounted) {
        setState(() {
          _services = services;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare la încărcarea serviciilor: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _onResourceTypeChanged(ResourceType type) {
    // Reset to page 1 when changing resource type
    _fetchResources(type, 1);
  }

  void _onSectionTap(SectionType section) {
    setState(() {
      _selectedSection = section;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Francofonie text and menu row (above background)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Francofonie',
                      style: TextStyle(
                        fontFamily: 'Varela Round',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.menu,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },
                        tooltip: 'Profil',
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(12),
                          minimumSize: const Size(44, 44),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildTopSection(),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    _buildSectionButtons(context),
                    const SizedBox(height: 30),
                    _buildCategoryContent(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryContent() {
    switch (_selectedSection) {
      case SectionType.events:
        return _buildEventsContent();
      case SectionType.projects:
        return _buildProjectsContent();
      case SectionType.members:
        return _buildMembersContent();
      case SectionType.partners:
        return _buildPartnersContent();
      case SectionType.resources:
        return _buildResourcesContent();
      case SectionType.services:
        return _buildServicesContent();
    }
  }

  Widget _buildEventsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Evenimente Recente',
              style: TextStyle(
                fontFamily: 'Varela Round',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (_eventsService.isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Row(
                    children: [
                      // Previous page button
                      GestureDetector(
                        onTap:
                            _currentEventPage > 1
                                ? () => _fetchEvents(_currentEventPage - 1)
                                : null,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color:
                                _currentEventPage > 1
                                    ? AppColors.primary
                                    : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.chevron_left,
                            color:
                                _currentEventPage > 1
                                    ? Colors.white
                                    : Colors.grey[500],
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$_currentEventPage',
                          style: TextStyle(
                            fontFamily: 'Varela Round',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _fetchEvents(_currentEventPage + 1),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Show events list if available
        if (_events.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _events.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildEventCardFromPreview(_events[index]),
              );
            },
          )
        // Show empty state if no events and not loading
        else if (!_eventsService.isLoading)
          _buildEmptyEventsState()
        // Show loading placeholder if loading
        else
          _buildLoadingPlaceholder(),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildProjectsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchField(),
        const SizedBox(height: 16),
        if (!_hasSearchResults) ...[
          _buildProjectsFilterSection(),
          const SizedBox(height: 16),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _hasSearchResults ? 'Rezultate căutare' : 'Proiecte Recente',
              style: TextStyle(
                fontFamily: 'Varela Round',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Row(
              children: [
                if (_isSearching || _projectsService.isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (_hasSearchResults)
                  Text(
                    '${_searchResults.length} rezultate',
                    style: TextStyle(
                      fontFamily: 'Varela Round',
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  )
                else
                  Row(
                    children: [
                      // Previous page button
                      GestureDetector(
                        onTap:
                            _currentProjectPage > 1
                                ? () => _fetchProjects(_currentProjectPage - 1)
                                : null,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color:
                                _currentProjectPage > 1
                                    ? AppColors.primary
                                    : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.chevron_left,
                            color:
                                _currentProjectPage > 1
                                    ? Colors.white
                                    : Colors.grey[500],
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Page indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$_currentProjectPage',
                          style: TextStyle(
                            fontFamily: 'Varela Round',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Next page button
                      GestureDetector(
                        onTap: () => _fetchProjects(_currentProjectPage + 1),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Show search results or regular projects list
        if (_hasSearchResults) ...[
          if (_searchResults.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildProjectCard(_searchResults[index]),
                );
              },
            )
          else if (!_isSearching)
            _buildEmptySearchState()
          else
            _buildLoadingPlaceholder(),
        ] else ...[
          // Show regular projects list if available
          if (_filteredProjects.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredProjects.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildProjectCard(_filteredProjects[index]),
                );
              },
            )
          // Show empty state if no projects and not loading
          else if (!_projectsService.isLoading)
            _buildEmptyProjectsState()
          // Show loading placeholder if loading
          else
            _buildLoadingPlaceholder(),
        ],

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildProjectsFilterSection() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtrează proiectele',
            style: TextStyle(
              fontFamily: 'Varela Round',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),

          if (_selectedRegions.isNotEmpty ||
              _selectedAxes.isNotEmpty ||
              _selectedStatus.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.start,
              children: [
                for (final r in _selectedRegions)
                  _buildSelectedChip(r, onRemove: () => _toggleRegion(r)),
                for (final a in _selectedAxes)
                  _buildSelectedChip(a, onRemove: () => _toggleAxe(a)),
                for (final key in _selectedStatus)
                  _buildSelectedChip(
                    _statusOptions[key]!,
                    onRemove: () => _toggleStatus(key),
                  ),
              ],
            ),

          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterDropdown(
                'Regiuni',
                _regions,
                _selectedRegions,
                (v) => _toggleRegion(v),
                expanded: _regionsExpanded,
                onExpandToggle:
                    () => setState(() => _regionsExpanded = !_regionsExpanded),
              ),
              const SizedBox(height: 12),
              _buildFilterDropdown(
                'Axe',
                _axes,
                _selectedAxes,
                (v) => _toggleAxe(v),
                expanded: _axesExpanded,
                onExpandToggle:
                    () => setState(() => _axesExpanded = !_axesExpanded),
              ),
              const SizedBox(height: 12),
              _buildFilterDropdown(
                'Status',
                _statusOptions.values.toList(),
                _selectedStatus.map((e) => _statusOptions[e]!).toSet(),
                (label) {
                  final entry = _statusOptions.entries.firstWhere(
                    (e) => e.value == label,
                  );
                  _toggleStatus(entry.key);
                },
                expanded: _statusExpanded,
                onExpandToggle:
                    () => setState(() => _statusExpanded = !_statusExpanded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedChip(String label, {required VoidCallback onRemove}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 16, color: Colors.grey),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Varela Round',
                fontSize: 14,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String title,
    List<String> options,
    Set<String> selected,
    void Function(String) onToggle, {
    required bool expanded,
    required VoidCallback onExpandToggle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onExpandToggle,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Varela Round',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 18,
                  color: Colors.black87,
                ),
              ],
            ),
          ),
          if (expanded) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.start,
              children:
                  options.map((o) {
                    final isSelected = selected.contains(o);
                    return GestureDetector(
                      onTap: () => onToggle(o),
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 80,
                          maxWidth: 200,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : Colors.grey[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                isSelected
                                    ? AppColors.primary
                                    : Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          o,
                          style: TextStyle(
                            fontFamily: 'Varela Round',
                            fontSize: 13,
                            color:
                                isSelected ? AppColors.primary : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.start,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMembersContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Membri Recenti',
              style: TextStyle(
                fontFamily: 'Varela Round',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                if (_membersService.isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Row(
                    children: [
                      // Previous page button
                      GestureDetector(
                        onTap:
                            _currentMemberPage > 1
                                ? () => _fetchMembers(_currentMemberPage - 1)
                                : null,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color:
                                _currentMemberPage > 1
                                    ? AppColors.primary
                                    : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.chevron_left,
                            color:
                                _currentMemberPage > 1
                                    ? Colors.white
                                    : Colors.grey[500],
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Page indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$_currentMemberPage',
                          style: TextStyle(
                            fontFamily: 'Varela Round',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Next page button
                      GestureDetector(
                        onTap: () => _fetchMembers(_currentMemberPage + 1),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Show members list if available
        if (_members.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _members.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildMemberCard(_members[index]),
              );
            },
          )
        // Show empty state if no members and not loading
        else if (!_membersService.isLoading)
          _buildEmptyMembersState()
        // Show loading placeholder if loading
        else
          _buildLoadingPlaceholder(),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEmptyMembersState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.person_off_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'Nu sunt membri disponibili momentan',
            style: TextStyle(
              fontFamily: 'Varela Round',
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Verificați din nou mai târziu',
            style: TextStyle(
              fontFamily: 'Varela Round',
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(PreviewMember member) {
    return GestureDetector(
      onTap: () async {
        try {
          if (member.name.isEmpty) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Numele membrului nu este disponibil'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
            return;
          }

          final fullMember = await _membersService.getMemberDetailsById(
            member.id,
          );
          if (fullMember != null && context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MemberDetailScreen(member: fullMember),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Eroare la încărcarea membrului: $e'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 60),
                    child: Text(
                      member.name,
                      style: const TextStyle(
                        fontFamily: 'Varela Round',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(right: 60),
                    child: Text(
                      (member.address != null && member.address!.isNotEmpty)
                          ? member.address!
                          : 'Adresă nedisponibilă',
                      style: TextStyle(
                        fontFamily: 'Varela Round',
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (member.region.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        member.region,
                        style: TextStyle(
                          fontFamily: 'Varela Round',
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // AUF badge positioned absolutely
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'AUF',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Varela Round',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnersContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Parteneri Recenti',
              style: TextStyle(
                fontFamily: 'Varela Round',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Row(
              children: [
                if (_partnersService.isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Row(
                    children: [
                      // Previous page button
                      GestureDetector(
                        onTap:
                            _currentPartnerPage > 1
                                ? () => _fetchPartners(_currentPartnerPage - 1)
                                : null,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color:
                                _currentPartnerPage > 1
                                    ? AppColors.primary
                                    : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.chevron_left,
                            color:
                                _currentPartnerPage > 1
                                    ? Colors.white
                                    : Colors.grey[500],
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Page indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$_currentPartnerPage',
                          style: TextStyle(
                            fontFamily: 'Varela Round',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Next page button
                      GestureDetector(
                        onTap: () => _fetchPartners(_currentPartnerPage + 1),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Show partners list if available
        if (_partners.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _partners.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildPartnerCard(_partners[index]),
              );
            },
          )
        // Show empty state if no partners and not loading
        else if (!_partnersService.isLoading)
          _buildEmptyPartnersState()
        // Show loading placeholder if loading
        else
          _buildLoadingPlaceholder(),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEmptyPartnersState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.business_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'Nu sunt parteneri disponibili momentan',
            style: TextStyle(
              fontFamily: 'Varela Round',
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Verificați din nou mai târziu',
            style: TextStyle(
              fontFamily: 'Varela Round',
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerCard(PartnerModel partner) {
    return GestureDetector(
      onTap: () async {
        await _launchPartnerUrl(partner.partnerUrl);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Partner logo or placeholder
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child:
                  partner.logoUrl != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          partner.logoUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  _buildDefaultPartnerIcon(),
                        ),
                      )
                      : _buildDefaultPartnerIcon(),
            ),
            const SizedBox(width: 16),
            // Partner info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partner.name,
                    style: const TextStyle(
                      fontFamily: 'Varela Round',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.link, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          partner.partnerUrl,
                          style: TextStyle(
                            fontFamily: 'Varela Round',
                            fontSize: 12,
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Arrow indicator
            Icon(Icons.open_in_new, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultPartnerIcon() {
    return Icon(
      Icons.business,
      size: 30,
      color: AppColors.primary.withValues(alpha: 0.6),
    );
  }

  Future<void> _launchPartnerUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare la deschiderea URL-ului: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildEmptyProjectsState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.work_off, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'Nu sunt proiecte disponibile momentan',
            style: TextStyle(
              fontFamily: 'Varela Round',
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Verificați din nou mai târziu',
            style: TextStyle(
              fontFamily: 'Varela Round',
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(PreviewProject project) {
    return GestureDetector(
      onTap: () async {
        try {
          if (project.link == null) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Link-ul proiectului nu este disponibil'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
            return;
          }

          final fullProject = await _projectsService.getProjectDetailsById(
            project.id,
          );
          if (fullProject != null && context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ProjectDetailScreen(
                      project: fullProject,
                      projectLink: project.link!,
                    ),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Eroare la încărcarea proiectului: $e'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child:
                      project.imageUrl != null
                          ? Image.network(
                            project.imageUrl!,
                            width: double.infinity,
                            height: 160,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) =>
                                    _buildDefaultProjectImage(),
                          )
                          : _buildDefaultProjectImage(),
                ),
                // AUF badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'AUF',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Varela Round',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Content section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    style: const TextStyle(
                      fontFamily: 'Varela Round',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    project.description.length > 100
                        ? '${project.description.substring(0, 100)}...'
                        : project.description,
                    style: TextStyle(
                      fontFamily: 'Varela Round',
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultProjectImage() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Icon(
        Icons.work_outline,
        size: 64,
        color: AppColors.primary.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildEmptyEventsState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'Nu sunt evenimente disponibile momentan',
            style: TextStyle(
              fontFamily: 'Varela Round',
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Verificați din nou mai târziu',
            style: TextStyle(
              fontFamily: 'Varela Round',
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Column(
      children: List.generate(
        2,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 250,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget _buildEventCardFromPreview(PreviewEvent event) {
    return GestureDetector(
      onTap: () async {
        try {
          if (event.link.isEmpty) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Link-ul evenimentului nu este disponibil'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
            return;
          }

          final fullEvent = await _eventsService.getEventDetailsById(event.id);
          if (fullEvent != null && context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventDetailScreen(event: fullEvent),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Eroare la încărcarea evenimentului: $e'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event title with better overflow handling
              Text(
                event.title,
                style: const TextStyle(
                  fontFamily: 'Varela Round',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              ),
              const SizedBox(height: 12),

              // Event details row with better overflow handling
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Flexible(
                    flex: 1,
                    child: Text(
                      _formatPreviewDate(event.date),
                      style: TextStyle(
                        fontFamily: 'Varela Round',
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Flexible(
                    flex: 2,
                    child: Text(
                      event.city,
                      style: TextStyle(
                        fontFamily: 'Varela Round',
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Read more button row with proper spacing
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Eveniment',
                      style: TextStyle(
                        fontFamily: 'Varela Round',
                        fontSize: 12,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Citește mai mult',
                          style: TextStyle(
                            fontFamily: 'Varela Round',
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward,
                          size: 14,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPreviewDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Ian',
        'Feb',
        'Mar',
        'Apr',
        'Mai',
        'Iun',
        'Iul',
        'Aug',
        'Sep',
        'Oct',
        'Noi',
        'Dec',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildTopSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFFF8F4F0), const Color(0xFFF5F0EA)],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),

          // OIF Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'OIF',
                  style: TextStyle(
                    fontFamily: 'Varela Round',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                // Logo in top right corner (made bigger)
                Image.asset('images/logo.png', width: 120, height: 90),
              ],
            ),
          ),

          const SizedBox(height: 5),

          // Happy Image Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'images/happy.jpg',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionButtons(BuildContext context) {
    return Column(
      children: [
        // First row
        Row(
          children: [
            Expanded(
              child: _buildSectionButton(
                context: context,
                icon: Icons.description_outlined,
                title: 'Proiecte',
                isSelected: _selectedSection == SectionType.projects,
                onTap: () => _onSectionTap(SectionType.projects),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSectionButton(
                context: context,
                icon: Icons.people_outline,
                title: 'Membri',
                isSelected: _selectedSection == SectionType.members,
                onTap: () => _onSectionTap(SectionType.members),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSectionButton(
                context: context,
                icon: Icons.groups_outlined,
                title: 'Parteneri',
                isSelected: _selectedSection == SectionType.partners,
                onTap: () => _onSectionTap(SectionType.partners),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Second row
        Row(
          children: [
            Expanded(
              child: _buildSectionButton(
                context: context,
                icon: Icons.menu,
                title: 'Resurse',
                isSelected: _selectedSection == SectionType.resources,
                onTap: () => _onSectionTap(SectionType.resources),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSectionButton(
                context: context,
                icon: Icons.business_center_outlined,
                title: 'Servicii',
                isSelected: _selectedSection == SectionType.services,
                onTap: () => _onSectionTap(SectionType.services),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSectionButton(
                context: context,
                icon: Icons.celebration_outlined,
                title: 'Evenimente',
                isSelected: _selectedSection == SectionType.events,
                onTap: () => _onSectionTap(SectionType.events),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.grey[50],
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Varela Round',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourcesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Resurse',
              style: TextStyle(
                fontFamily: 'Varela Round',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (_resourcesService.isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 16),

        _buildResourceTypePicker(),
        const SizedBox(height: 30),

        if (_resources.isNotEmpty) ...[
          ..._resources.map(
            (resource) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildResourceCard(resource),
            ),
          ),
        ] else if (!_resourcesService.isLoading) ...[
          _buildEmptyResourcesState(),
        ] else ...[
          _buildLoadingPlaceholder(),
        ],

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildResourceTypePicker() {
    final resourceTypes = ResourceType.values;

    return Column(
      children: [
        // First row - 3 categories
        Row(
          children: [
            for (int i = 0; i < 3; i++) ...[
              Expanded(child: _buildResourceTypeCard(resourceTypes[i])),
              if (i < 2) const SizedBox(width: 12),
            ],
          ],
        ),
        const SizedBox(height: 12),
        // Second row - 3 categories
        Row(
          children: [
            for (int i = 3; i < 6; i++) ...[
              Expanded(child: _buildResourceTypeCard(resourceTypes[i])),
              if (i < 5) const SizedBox(width: 12),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildResourceTypeCard(ResourceType type) {
    final isSelected = type == _selectedResourceType;

    return GestureDetector(
      onTap: () => _onResourceTypeChanged(type),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color:
                      isSelected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.grey[100],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    _getResourceTypeImage(type),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Icon(
                          _getResourceTypeIcon(type),
                          size: 28,
                          color:
                              isSelected ? AppColors.primary : Colors.grey[600],
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getResourceTypeDisplayName(type),
                style: TextStyle(
                  fontFamily: 'Varela Round',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primary : Colors.grey[700],
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResourceCard(PreviewResource resource) {
    return GestureDetector(
      onTap: () {
        // Navigate to resource detail screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResourceDetailScreen(resource: resource),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with resource image
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.8),
                    AppColors.primary.withValues(alpha: 0.6),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Background image (use resource imageUrl if available, fallback to default)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child:
                        resource.imageUrl != null
                            ? Image.network(
                              resource.imageUrl!,
                              width: double.infinity,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      _buildDefaultResourceImage(),
                            )
                            : _buildDefaultResourceImage(),
                  ),

                  // Overlay
                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource.title,
                    style: const TextStyle(
                      fontFamily: 'Varela Round',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    resource.description,
                    style: TextStyle(
                      fontFamily: 'Varela Round',
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyResourcesState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(
            _getResourceTypeIcon(_selectedResourceType),
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'Nu sunt resurse disponibile pentru ${_getResourceTypeDisplayName(_selectedResourceType)}',
            style: TextStyle(
              fontFamily: 'Varela Round',
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Verificați din nou mai târziu',
            style: TextStyle(
              fontFamily: 'Varela Round',
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  String _getResourceTypeImage(ResourceType type) {
    switch (type) {
      case ResourceType.formation:
        return 'images/formations.jpg';
      case ResourceType.resources:
        return 'images/ressources.jpg';
      case ResourceType.expertise:
        return 'images/expertise.jpg';
      case ResourceType.innovation:
        return 'images/lightbulb.jpg';
      case ResourceType.prospective:
        return 'images/prospective.png';
      case ResourceType.allocation:
        return 'images/bourse.jpg';
    }
  }

  IconData _getResourceTypeIcon(ResourceType type) {
    switch (type) {
      case ResourceType.formation:
        return Icons.school_outlined;
      case ResourceType.resources:
        return Icons.library_books_outlined;
      case ResourceType.expertise:
        return Icons.psychology_outlined;
      case ResourceType.innovation:
        return Icons.lightbulb_outline;
      case ResourceType.prospective:
        return Icons.trending_up_outlined;
      case ResourceType.allocation:
        return Icons.account_balance_wallet_outlined;
    }
  }

  String _getResourceTypeDisplayName(ResourceType type) {
    switch (type) {
      case ResourceType.formation:
        return 'Instruire';
      case ResourceType.resources:
        return 'Resurse';
      case ResourceType.expertise:
        return 'Expertiză';
      case ResourceType.innovation:
        return 'Inovație';
      case ResourceType.prospective:
        return 'Prospectiv';
      case ResourceType.allocation:
        return 'Alocații';
    }
  }

  Widget _buildDefaultResourceImage() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Icon(
        Icons.library_books_outlined,
        size: 48,
        color: AppColors.primary.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(
          fontFamily: 'Varela Round',
          fontSize: 16,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: 'Căutați proiecte...',
          hintStyle: TextStyle(
            fontFamily: 'Varela Round',
            fontSize: 16,
            color: Colors.grey[500],
          ),
          prefixIcon: Icon(
            Icons.search,
            color: _hasSearchResults ? AppColors.primary : Colors.grey[400],
            size: 22,
          ),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? GestureDetector(
                    onTap: _clearSearch,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.close,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                    ),
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'Nu s-au găsit proiecte pentru căutarea "$_currentSearchQuery"',
            style: TextStyle(
              fontFamily: 'Varela Round',
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Încercați cu alți termeni de căutare',
            style: TextStyle(
              fontFamily: 'Varela Round',
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Servicii Disponibile',
              style: TextStyle(
                fontFamily: 'Varela Round',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (_servicesService.isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Show services list if available
        if (_services.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _services.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildServiceCard(_services[index]),
              );
            },
          )
        // Show empty state if no services and not loading
        else if (!_servicesService.isLoading)
          _buildEmptyServicesState()
        // Show loading placeholder if loading
        else
          _buildLoadingPlaceholder(),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildServiceCard(ServiceModel service) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child:
                    service.imageUrl.isNotEmpty
                        ? Image.network(
                          service.imageUrl,
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  _buildDefaultServiceImage(),
                        )
                        : _buildDefaultServiceImage(),
              ),
              // Service badge
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Apel închis',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Varela Round',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Content section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title,
                  style: const TextStyle(
                    fontFamily: 'Varela Round',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
                const SizedBox(height: 12),
                Text(
                  service.dateString,
                  style: TextStyle(
                    fontFamily: 'Varela Round',
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultServiceImage() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.2),
            AppColors.primary.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Icon(
        Icons.business_center_outlined,
        size: 64,
        color: AppColors.primary.withValues(alpha: 0.6),
      ),
    );
  }

  Widget _buildEmptyServicesState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.business_center_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'Nu sunt servicii disponibile momentan',
            style: TextStyle(
              fontFamily: 'Varela Round',
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Verificați din nou mai târziu',
            style: TextStyle(
              fontFamily: 'Varela Round',
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

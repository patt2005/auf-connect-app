import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../models/project_model.dart';
import '../screens/project_detail_screen.dart';
import 'login_screen.dart';
import 'reset_password_screen.dart';

enum ProfileSection { account, address, personalList, security }

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  // Address controllers
  late TextEditingController _countryController;
  late TextEditingController _cityController;
  late TextEditingController _address1Controller;
  late TextEditingController _address2Controller;
  late TextEditingController _regionController;
  late TextEditingController _postalCodeController;

  ProfileSection _selectedSection = ProfileSection.account;

  UserModel? currentUser;
  String? userImageUrl;
  bool isLoading = true;
  bool isUpdating = false;

  // Favorites state
  bool _loadingFavorites = false;
  List<ProjectModel> _favoriteProjects = [];
  List<String> _favoriteProjectIds = [];

  bool newCallsNotification = true;
  bool savedProjectsNotification = true;
  bool resourceListNotification = true;
  bool passwordChangeNotification = true;
  bool eventsNotification = true;
  bool newsletterNotification = true;

  @override
  void initState() {
    super.initState();
    currentUser = _userService.userModel;
    _initializeControllers();
    _loadUserData();
    _loadFavoriteProjects();
  }

  void _initializeControllers() {
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();

    // Address controllers
    _countryController = TextEditingController();
    _cityController = TextEditingController();
    _address1Controller = TextEditingController();
    _address2Controller = TextEditingController();
    _regionController = TextEditingController();
    _postalCodeController = TextEditingController();
  }

  Future<void> _loadFavoriteProjects() async {
    try {
      setState(() => _loadingFavorites = true);
      // Fetch project IDs and detailed projects
      final projectIds = await _userService.getFavoriteProjects();
      final projects = await _userService.getFavoriteProjectsDetailed();

      // Align projects with IDs by index (best-effort)
      final count =
          projectIds.length < projects.length
              ? projectIds.length
              : projects.length;
      setState(() {
        _favoriteProjectIds = projectIds.take(count).toList();
        _favoriteProjects = projects.take(count).toList();
      });
    } catch (e) {
      _showErrorSnackBar('Eroare la încărcarea proiectelor salvate: $e');
    } finally {
      if (mounted) setState(() => _loadingFavorites = false);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _regionController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    currentUser = _userService.userModel;
    if (currentUser != null) {
      try {
        final nameParts = currentUser!.fullName.split(' ');
        setState(() {
          _firstNameController.text =
              nameParts.isNotEmpty ? nameParts.first : '';
          _lastNameController.text =
              nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';
          _emailController.text = currentUser!.email;
          _phoneController.text = currentUser!.phoneNumber ?? '';
          // Address
          _countryController.text = currentUser!.country ?? '';
          _cityController.text = currentUser!.city ?? '';
          _address1Controller.text = currentUser!.addressLine1 ?? '';
          _address2Controller.text = currentUser!.addressLine2 ?? '';
          _regionController.text = currentUser!.stateOrRegion ?? '';
          _postalCodeController.text = currentUser!.postalCode ?? '';

          final prefs = currentUser!.notificationPreferences;
          newCallsNotification = prefs.callNotifications;
          savedProjectsNotification = prefs.savedProjectsNotifications;
          resourceListNotification = prefs.resourceListNotifications;
          passwordChangeNotification = prefs.passwordChangeNotifications;
          eventsNotification = prefs.eventsNotifications;
          newsletterNotification = prefs.newsletterNotifications;
        });
      } catch (e) {
        _showErrorSnackBar('Eroare la încărcarea datelor: $e');
      }
    }
    setState(() => isLoading = false);
  }

  Future<void> _saveAddress() async {
    // Basic validation
    if (_address1Controller.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty ||
        _countryController.text.trim().isEmpty) {
      _showErrorSnackBar(
        'Completează câmpurile obligatorii: țară, oraș, adresă',
      );
      return;
    }
    try {
      setState(() => isUpdating = true);
      await _userService.updateUserProfile(
        country: _countryController.text.trim(),
        city: _cityController.text.trim(),
        addressLine1: _address1Controller.text.trim(),
        addressLine2:
            _address2Controller.text.trim().isEmpty
                ? null
                : _address2Controller.text.trim(),
        stateOrRegion: _regionController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
      );
      setState(() => isUpdating = false);
      _showSuccessSnackBar('Adresa a fost actualizată');
      setState(() => currentUser = _userService.userModel);
    } catch (e) {
      setState(() => isUpdating = false);
      _showErrorSnackBar('Eroare la salvarea adresei: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<void> _saveChanges() async {
    if (currentUser != null) {
      try {
        setState(() => isUpdating = true);

        final fullName =
            '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
                .trim();

        final updatedPreferences = NotificationPreferences(
          callNotifications: newCallsNotification,
          savedProjectsNotifications: savedProjectsNotification,
          resourceListNotifications: resourceListNotification,
          passwordChangeNotifications: passwordChangeNotification,
          eventsNotifications: eventsNotification,
          newsletterNotifications: newsletterNotification,
        );

        // Update user profile
        await _userService.updateUserProfile(
          fullName: fullName,
          phoneNumber:
              _phoneController.text.trim().isEmpty
                  ? null
                  : _phoneController.text.trim(),
          notificationPreferences: updatedPreferences,
        );

        setState(() => isUpdating = false);
        _showSuccessSnackBar('Modificările au fost salvate!');
      } catch (e) {
        setState(() => isUpdating = false);
        _showErrorSnackBar('Eroare la salvarea modificărilor: $e');
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await _userService.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      _showErrorSnackBar('Eroare la deconectare: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.red, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Confirmare deconectare',
                style: TextStyle(
                  fontFamily: 'Varela Round',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'Sunteți sigur că doriți să vă deconectați din cont?',
            style: TextStyle(
              fontFamily: 'Varela Round',
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Anulează',
                style: TextStyle(
                  fontFamily: 'Varela Round',
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _signOut();
              },
              child: const Text(
                'Deconectează',
                style: TextStyle(
                  fontFamily: 'Varela Round',
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Cont',
            style: TextStyle(
              fontFamily: 'Varela Round',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cont',
          style: TextStyle(
            fontFamily: 'Varela Round',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionPicker(),
            const SizedBox(height: 24),
            _buildSelectedSectionContent(),
            const SizedBox(height: 35),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionPicker() {
    return Column(
      children: [
        _buildSectionButton(
          title: 'Cont',
          subtitle: 'Informații personale',
          icon: Icons.person,
          section: ProfileSection.account,
        ),
        const SizedBox(height: 12),
        _buildSectionButton(
          title: 'Adresă',
          subtitle: 'Adresa de contact',
          icon: Icons.location_on,
          section: ProfileSection.address,
        ),
        const SizedBox(height: 12),
        _buildSectionButton(
          title: 'Listă personală',
          subtitle: 'Proiecte salvate',
          icon: Icons.bookmark,
          section: ProfileSection.personalList,
        ),
        const SizedBox(height: 12),
        _buildSectionButton(
          title: 'Securitate',
          subtitle: 'Password, 2FA',
          icon: Icons.security,
          section: ProfileSection.security,
        ),
      ],
    );
  }

  Widget _buildSectionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required ProfileSection section,
  }) {
    final isSelected = _selectedSection == section;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSection = section;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isSelected ? Colors.white : Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Varela Round',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Varela Round',
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedSectionContent() {
    switch (_selectedSection) {
      case ProfileSection.account:
        return Column(
          children: [
            _buildPersonalInfoSection(),
            const SizedBox(height: 40),
            _buildNotificationSection(),
            const SizedBox(height: 40),
            _buildActionButtons(),
          ],
        );
      case ProfileSection.address:
        return _buildAddressSection();
      case ProfileSection.personalList:
        return _buildPersonalListSection();
      case ProfileSection.security:
        return _buildSecuritySection();
    }
  }

  Widget _buildPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informații personale',
          style: TextStyle(
            fontFamily: 'Varela Round',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 24),

        // Form fields
        _buildEditableInputField('Prenume', _firstNameController),
        const SizedBox(height: 16),
        _buildEditableInputField('Nume', _lastNameController),
        const SizedBox(height: 16),
        _buildInputField('Email', _emailController.text),
        const SizedBox(height: 16),
        _buildEditableInputField('Număr telefon', _phoneController),
      ],
    );
  }

  Widget _buildActionButton(
    String text,
    bool isPrimary, {
    bool isEnabled = true,
  }) {
    final opacity = isEnabled ? 1.0 : 0.5;
    return Opacity(
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : Colors.transparent,
          border: Border.all(
            color: isPrimary ? AppColors.primary : AppColors.textSecondary,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Varela Round',
            fontSize: 14,
            color: isPrimary ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Varela Round',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[100],
          ),
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Varela Round',
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableInputField(
    String label,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Varela Round',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: TextStyle(
            fontFamily: 'Varela Round',
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notificări e-mail',
          style: TextStyle(
            fontFamily: 'Varela Round',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 20),

        _buildNotificationItem('Apeluri noi', newCallsNotification, (value) {
          setState(() => newCallsNotification = value);
        }),
        _buildNotificationItem('Proiecte salvate', savedProjectsNotification, (
          value,
        ) {
          setState(() => savedProjectsNotification = value);
        }),
        _buildNotificationItem('Listă resurse', resourceListNotification, (
          value,
        ) {
          setState(() => resourceListNotification = value);
        }),
        _buildNotificationItem('Schimbare parolă', passwordChangeNotification, (
          value,
        ) {
          setState(() => passwordChangeNotification = value);
        }),
        _buildNotificationItem('Evenimente', eventsNotification, (value) {
          setState(() => eventsNotification = value);
        }),
        _buildNotificationItem('Newsletter', newsletterNotification, (value) {
          setState(() => newsletterNotification = value);
        }),
      ],
    );
  }

  Widget _buildNotificationItem(
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onChanged(!value),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: value ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: value ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child:
                  value
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Varela Round',
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Disconnect button
        GestureDetector(
          onTap: _showLogoutConfirmation,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Deconectați-vă',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Varela Round',
                fontSize: 16,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Action buttons row
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _loadUserData(),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: Text(
                    'Renunță',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Varela Round',
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: isUpdating ? null : _saveChanges,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color:
                        isUpdating
                            ? AppColors.primary.withValues(alpha: 0.6)
                            : AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      isUpdating
                          ? const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          )
                          : Text(
                            'Salvează',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Varela Round',
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, size: 24, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Adresa de contact',
                style: TextStyle(
                  fontFamily: 'Varela Round',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Country and City
          Row(
            children: [
              Expanded(
                child: _buildEditableInputField('Țară', _countryController),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEditableInputField('Oraș', _cityController),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Address lines
          _buildEditableInputField(
            'Adresă (stradă, număr)',
            _address1Controller,
          ),
          const SizedBox(height: 16),
          _buildEditableInputField(
            'Adresă linia 2 (opțional)',
            _address2Controller,
          ),
          const SizedBox(height: 16),

          // Region and Postal Code
          Row(
            children: [
              Expanded(
                child: _buildEditableInputField(
                  'Județ / Regiune',
                  _regionController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEditableInputField(
                  'Cod poștal',
                  _postalCodeController,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: _saveAddress,
              child: _buildActionButton('Salvează adresa', true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalListSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bookmark, size: 24, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Proiecte salvate',
                style: TextStyle(
                  fontFamily: 'Varela Round',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_loadingFavorites)
            const Center(child: CircularProgressIndicator())
          else if (_favoriteProjects.isEmpty)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bookmark, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'Nu aveți proiecte salvate încă',
                    style: TextStyle(
                      fontFamily: 'Varela Round',
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _favoriteProjects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final project = _favoriteProjects[index];
                final projectId =
                    index < _favoriteProjectIds.length
                        ? _favoriteProjectIds[index]
                        : null;
                return _buildFavoriteProjectCard(project, projectId);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFavoriteProjectCard(ProjectModel project, String? projectId) {
    return GestureDetector(
      onTap:
          projectId == null
              ? null
              : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ProjectDetailScreen(
                          project: project,
                          projectLink: projectId,
                        ),
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
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
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
                        height: 140,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                _buildDefaultFavoriteImage(),
                      )
                      : _buildDefaultFavoriteImage(),
            ),
            // Content
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
                    project.objectives.isNotEmpty
                        ? (project.objectives.length > 100
                            ? '${project.objectives.substring(0, 100)}...'
                            : project.objectives)
                        : project.targetAudience,
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

  Widget _buildDefaultFavoriteImage() {
    return Container(
      width: double.infinity,
      height: 140,
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
        size: 48,
        color: AppColors.primary.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, size: 24, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Securitate cont',
                style: TextStyle(
                  fontFamily: 'Varela Round',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Gestionați parola și securitatea contului',
            style: TextStyle(
              fontFamily: 'Varela Round',
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          _buildSecurityOption(
            icon: Icons.lock_reset,
            title: 'Resetează parola',
            subtitle: 'Schimbați parola contului',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ResetPasswordScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Varela Round',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Varela Round',
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

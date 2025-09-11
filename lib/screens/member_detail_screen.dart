import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/member_model.dart';
import '../constants/app_colors.dart';

class MemberDetailScreen extends StatelessWidget {
  final MemberModel member;

  const MemberDetailScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Custom app bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background gradient with multiple colors
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.9),
                          AppColors.primary.withValues(alpha: 0.7),
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),

                  // Decorative circles
                  Positioned(
                    top: -50,
                    right: -30,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 80,
                    left: -40,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),

                  // Profile section with enhanced design
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Profile avatar with better styling
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.15),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.person,
                            size: 55,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Member title/role indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'Membru AUF',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Varela Round',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Enhanced AUF badge
                  Positioned(
                    top: 60,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'AUF',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontFamily: 'Varela Round',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom decorative wave
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.background,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Member name
                    Text(
                      member.name,
                      style: const TextStyle(
                        fontFamily: 'Varela Round',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Description section
                    _buildSection(
                      title: 'Descriere',
                      content: member.description,
                      icon: Icons.description_outlined,
                    ),

                    // Background section (if available)
                    if (member.background != null &&
                        member.background!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildSection(
                        title: 'Background',
                        content: member.background!,
                        icon: Icons.school_outlined,
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Contact and Institution Information
                    _buildContactSection(context),

                    const SizedBox(height: 20),

                    // Location and Details
                    _buildLocationSection(),

                    const SizedBox(height: 20),

                    // Additional info section
                    _buildInfoSection(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 22, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Varela Round',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(
              fontFamily: 'Varela Round',
              fontSize: 16,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.05),
            AppColors.primary.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Despre acest membru',
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
          const Text(
            'Acest membru face parte din comunitatea AUF și contribuie la promovarea valorilor francofoniei și la dezvoltarea cooperării educaționale și culturale.',
            style: TextStyle(
              fontFamily: 'Varela Round',
              fontSize: 14,
              color: Colors.black54,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.contact_page_outlined,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Informații Contact',
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

          // Contact Name
          if (member.contactName != null && member.contactName!.isNotEmpty) ...[
            _buildInfoRow(
              icon: Icons.person_outline,
              label: 'Persoana de contact',
              value: member.contactName!,
            ),
            const SizedBox(height: 12),
          ],

          // Contact Title
          if (member.contactTitle != null && member.contactTitle!.isNotEmpty) ...[
            _buildInfoRow(
              icon: Icons.work_outline,
              label: 'Funcția',
              value: member.contactTitle!,
            ),
            const SizedBox(height: 12),
          ],

          // Phone
          if (member.phone != null && member.phone!.isNotEmpty) ...[
            _buildInfoRow(
              icon: Icons.phone_outlined,
              label: 'Telefon',
              value: member.phone!,
            ),
            const SizedBox(height: 12),
          ],

          // Website
          if (member.website != null && member.website!.isNotEmpty) ...[
            _buildClickableInfoRow(
              icon: Icons.language_outlined,
              label: 'Website',
              value: member.website!,
              onTap: () => _launchWebsite(member.website!, context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Detalii Instituție',
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

          // Address
          if (member.address != null && member.address!.isNotEmpty) ...[
            _buildInfoRow(
              icon: Icons.location_on_outlined,
              label: 'Adresa',
              value: member.address!,
            ),
            const SizedBox(height: 12),
          ],

          // Region
          if (member.region != null && member.region!.isNotEmpty) ...[
            _buildInfoRow(
              icon: Icons.map_outlined,
              label: 'Regiunea',
              value: member.region!,
            ),
            const SizedBox(height: 12),
          ],

          // Statutory Type
          if (member.statutoryType != null && member.statutoryType!.isNotEmpty) ...[
            _buildInfoRow(
              icon: Icons.account_balance_outlined,
              label: 'Tip statutar',
              value: member.statutoryType!,
            ),
            const SizedBox(height: 12),
          ],

          // University Type
          if (member.universityType != null && member.universityType!.isNotEmpty) ...[
            _buildInfoRow(
              icon: Icons.school_outlined,
              label: 'Tip universitate',
              value: member.universityType!,
            ),
            const SizedBox(height: 12),
          ],

          // Founded Year
          if (member.foundedYear != null && member.foundedYear!.isNotEmpty) ...[
            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Anul înființării',
              value: member.foundedYear!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isClickable = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary.withValues(alpha: 0.7)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Varela Round',
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Varela Round',
                  fontSize: 14,
                  color: isClickable ? AppColors.primary : Colors.black87,
                  fontWeight: FontWeight.w500,
                  decoration: isClickable ? TextDecoration.underline : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClickableInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary.withValues(alpha: 0.7)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Varela Round',
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Varela Round',
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.open_in_new,
            size: 16,
            color: AppColors.primary.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }

  Future<void> _launchWebsite(String url, BuildContext context) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Eroare la deschiderea website-ului: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

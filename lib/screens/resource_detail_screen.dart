import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../models/preview_resource_model.dart';

class ResourceDetailScreen extends StatelessWidget {
  final PreviewResource resource;

  const ResourceDetailScreen({
    super.key,
    required this.resource,
  });

  Future<void> _launchResourceUrl() async {
    try {
      final linkUrl = resource.link;
      if (linkUrl != null && linkUrl.isNotEmpty) {
        final uri = Uri.parse(linkUrl);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Error handled by the calling widget
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Detalii Resursă',
          style: TextStyle(
            fontFamily: 'Varela Round',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header image section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: resource.imageUrl != null
                      ? Image.network(
                          resource.imageUrl!,
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildDefaultResourceImage(),
                        )
                      : _buildDefaultResourceImage(),
                ),
              ),
            ),

            // Content section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resource title
                  Text(
                    resource.title,
                    style: TextStyle(
                      fontFamily: 'Varela Round',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Descriere',
                          style: TextStyle(
                            fontFamily: 'Varela Round',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          resource.description,
                          style: TextStyle(
                            fontFamily: 'Varela Round',
                            fontSize: 16,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Link section - only show if link is available
                  if (resource.link != null && resource.link!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.link, color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Link resursă',
                                style: TextStyle(
                                  fontFamily: 'Varela Round',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            resource.link!,
                            style: TextStyle(
                              fontFamily: 'Varela Round',
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Action button - only show if link is available
                  if (resource.link != null && resource.link!.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _launchResourceUrl,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Deschide Resursa',
                              style: TextStyle(
                                fontFamily: 'Varela Round',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.open_in_new, size: 18),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultResourceImage() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.2),
            AppColors.primary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books,
            size: 80,
            color: AppColors.primary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            'Resursă',
            style: TextStyle(
              fontFamily: 'Varela Round',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class ProjectModel {
  final String id;
  final String title;
  final String? imageUrl;
  final String objectives;
  final String targetAudience;
  final String? overallBudget;
  final String countryOfIntervention;
  final List<String> roleOfAufInAction;
  final String period;
  final String projectsFor2024_2025;
  final String projectsFor2023_2024;
  final String projectsFor2021_2022;
  final String? device;
  final List<String> operationalPartners;

  ProjectModel({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.objectives,
    required this.targetAudience,
    this.overallBudget,
    required this.countryOfIntervention,
    required this.roleOfAufInAction,
    required this.period,
    required this.projectsFor2024_2025,
    required this.projectsFor2023_2024,
    required this.projectsFor2021_2022,
    this.device,
    required this.operationalPartners,
  });

  // Create ProjectModel from API JSON response
  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'],
      objectives: json['objectives'] ?? '',
      targetAudience: json['targetAudience'] ?? '',
      overallBudget: json['overallBudget'],
      countryOfIntervention: json['countryOfIntervention'] ?? '',
      roleOfAufInAction: json['roleOfAufInAction'] != null 
          ? List<String>.from(json['roleOfAufInAction']) 
          : [],
      period: json['period'] ?? '',
      projectsFor2024_2025: json['projectsFor2024_2025'] ?? '',
      projectsFor2023_2024: json['projectsFor2023_2024'] ?? '',
      projectsFor2021_2022: json['projectsFor2021_2022'] ?? '',
      device: json['device'],
      operationalPartners: json['operationalPartners'] != null 
          ? List<String>.from(json['operationalPartners']) 
          : [],
    );
  }

  // Convert ProjectModel to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'objectives': objectives,
      'targetAudience': targetAudience,
      'overallBudget': overallBudget,
      'countryOfIntervention': countryOfIntervention,
      'roleOfAufInAction': roleOfAufInAction,
      'period': period,
      'projectsFor2024_2025': projectsFor2024_2025,
      'projectsFor2023_2024': projectsFor2023_2024,
      'projectsFor2021_2022': projectsFor2021_2022,
      'device': device,
      'operationalPartners': operationalPartners,
    };
  }

  // Create a copy with updated values
  ProjectModel copyWith({
    String? title,
    String? imageUrl,
    String? objectives,
    String? targetAudience,
    String? overallBudget,
    String? countryOfIntervention,
    List<String>? roleOfAufInAction,
    String? period,
    String? projectsFor2024_2025,
    String? projectsFor2023_2024,
    String? projectsFor2021_2022,
    String? device,
    List<String>? operationalPartners,
  }) {
    return ProjectModel(
      id: id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      objectives: objectives ?? this.objectives,
      targetAudience: targetAudience ?? this.targetAudience,
      overallBudget: overallBudget ?? this.overallBudget,
      countryOfIntervention: countryOfIntervention ?? this.countryOfIntervention,
      roleOfAufInAction: roleOfAufInAction ?? this.roleOfAufInAction,
      period: period ?? this.period,
      projectsFor2024_2025: projectsFor2024_2025 ?? this.projectsFor2024_2025,
      projectsFor2023_2024: projectsFor2023_2024 ?? this.projectsFor2023_2024,
      projectsFor2021_2022: projectsFor2021_2022 ?? this.projectsFor2021_2022,
      device: device ?? this.device,
      operationalPartners: operationalPartners ?? this.operationalPartners,
    );
  }
}

class PreviewProject {
  final String id;
  final String title;
  final String? imageUrl;
  final String description;
  final String? link;

  PreviewProject({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.description,
    this.link,
  });

  // Create PreviewProject from API JSON response
  factory PreviewProject.fromJson(Map<String, dynamic> json) {
    return PreviewProject(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'],
      description: json['description'] ?? '',
      link: json['link'],
    );
  }

  // Convert PreviewProject to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'description': description,
      'link': link,
    };
  }

  // Create a copy with updated values
  PreviewProject copyWith({
    String? title,
    String? imageUrl,
    String? description,
    String? link,
  }) {
    return PreviewProject(
      id: id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      link: link ?? this.link,
    );
  }
}
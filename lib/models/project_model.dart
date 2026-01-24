import 'package:portfolio_front/providers/language_provider.dart';

class Tool {
  final String name;
  final String iconName;

  Tool({required this.name, required this.iconName});

  factory Tool.fromJson(Map<String, dynamic> json) => Tool(
    name: json['name'] ?? '',
    iconName: json['icon_name'] ?? '',
  );
}

class ProjectLink {
  final String type;
  final String typeDisplay;
  final String url;
  final String label;

  ProjectLink({
    required this.type,
    required this.typeDisplay,
    required this.url,
    required this.label,
  });

  factory ProjectLink.fromJson(Map<String, dynamic> json) => ProjectLink(
    type: json['type'] ?? '',
    typeDisplay: json['type_display'] ?? '',
    url: json['url'] ?? '',
    label: json['label'] ?? '',
  );
}

class Project {
  final String id;
  final String titleFr;
  final String titleEn;
  final String shortDescriptionFr;
  final String shortDescriptionEn;
  final String descriptionFr;
  final String descriptionEn;

  final String? cardImage;
  final String? videoFile;
  final String? videoExternalUrl;
  final List<Tool> tools;
  final List<ProjectLink> links;
  final List<String> gallery;
  final String categorySlug;

  Project({
    required this.id,
    required this.titleFr,
    required this.titleEn,
    required this.shortDescriptionFr,
    required this.shortDescriptionEn,
    required this.descriptionFr,
    required this.descriptionEn,
    this.cardImage,
    this.videoFile,
    this.videoExternalUrl,
    required this.tools,
    required this.links,
    required this.gallery,
    required this.categorySlug,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'].toString(),
      titleFr: json['title_fr'] ?? '',
      titleEn: json['title_en'] ?? '',
      shortDescriptionFr: json['short_description_fr'] ?? '',
      shortDescriptionEn: json['short_description_en'] ?? '',
      descriptionFr: json['description_fr'] ?? '',
      descriptionEn: json['description_en'] ?? '',

      cardImage: json['card_image'],
      videoFile: json['video_file'],
      videoExternalUrl: json['video_external_url'],
      categorySlug: json['category'] != null ? json['category']['slug'] : '',
      tools: (json['tools'] as List? ?? [])
          .map((t) => Tool.fromJson(t))
          .toList(),
      links: (json['links'] as List? ?? [])
          .map((l) => ProjectLink.fromJson(l))
          .toList(),
      gallery: (json['gallery'] as List? ?? [])
          .map((g) => g['image'].toString())
          .toList(),
    );
  }

  // --- Helpers pour simplifier l'affichage ---

  String currentTitle(bool isFrench) => isFrench ? titleFr : titleEn;
  String currentShortDesc(bool isFrench) => isFrench ? shortDescriptionFr : shortDescriptionEn;
  String currentFullDesc(bool isFrench) => isFrench ? descriptionFr : descriptionEn;
}
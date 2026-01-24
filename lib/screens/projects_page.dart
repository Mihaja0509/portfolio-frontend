import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:portfolio_front/models/project_model.dart';
import 'package:portfolio_front/widgets/main_layout.dart';
import 'package:portfolio_front/providers/language_provider.dart';
import 'contact_page.dart';
import 'project_detail_page.dart';

class ApiService {
  static const String baseUrl = "https://portfolio-backend-6fvo.onrender.com/api";

  static Future<List<Project>> fetchProjects() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/projects/?category__slug=dev'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => Project.fromJson(json)).toList();
      }
      throw Exception('Erreur serveur: ${response.statusCode}');
    } catch (e) {
      debugPrint("Erreur API: $e");
      throw Exception("Impossible de charger les projets.");
    }
  }
}

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  late Future<List<Project>> _futureProjects;

  @override
  void initState() {
    super.initState();
    _futureProjects = ApiService.fetchProjects();
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Erreur lien : $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    final String cvUrl = lang.isFrench
        ? "https://drive.google.com/file/d/1njWGINUYr8vd305jfrYjQ2UzO4-2yLlB/view?usp=sharing"
        : "https://drive.google.com/file/d/19tEZfvNEywK3YyD6SZ7wlRroSQWSSNkT/view?usp=sharing";

    return LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 700;
          return Material(
            color: Colors.black,
            child: MainLayout(
              navActions: [
                _navButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icons.arrow_back_ios,
                    label: isMobile ? "" : lang.t("RETOUR", "BACK")
                ),
                const SizedBox(width: 10),
                _navButton(
                    onPressed: () => _launchURL(cvUrl),
                    icon: Icons.file_download_outlined,
                    label: isMobile ? "" : "CV"
                ),
                const SizedBox(width: 10),
                _navButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactPage())),
                    icon: Icons.alternate_email,
                    label: isMobile ? "" : "CONTACT"
                ),
              ],
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(top: isMobile ? 100 : 150, bottom: 100),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      children: [
                        _buildSkillsSection(context, lang, isMobile).animate().fadeIn(duration: 800.ms).moveY(begin: 30, end: 0),
                        const SizedBox(height: 80),
                        _buildProjectsSection(context, lang, isMobile),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
    );
  }

  Widget _navButton({required VoidCallback onPressed, required IconData icon, required String label}) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: Colors.blueAccent),
      label: label.isEmpty
          ? const SizedBox.shrink()
          : Text(label, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12, decoration: TextDecoration.none)),
    );
  }

  Widget _buildSkillsSection(BuildContext context, LanguageProvider lang, bool isMobile) {
    final skills = {
      'Flutter': 'flutter', 'React': 'react', 'Dart': 'dart',
      'JS': 'js', 'Python': 'python', 'Django': 'django', 'AI/ML': 'ai'
    };
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 40),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(children: [
        _sectionTitle(lang.t("STACK TECHNIQUE", "TECHNICAL STACK")),
        const SizedBox(height: 40),
        Wrap(
          spacing: isMobile ? 25 : 50,
          runSpacing: isMobile ? 25 : 40,
          alignment: WrapAlignment.center,
          children: skills.entries.map((skill) => _buildSkillIcon(skill.key, skill.value, isMobile)).toList(),
        ),
      ]),
    );
  }

  Widget _buildSkillIcon(String name, String iconName, bool isMobile) {
    double size = isMobile ? 60 : 80;
    return Column(children: [
      Container(
        height: size, width: size, padding: EdgeInsets.all(isMobile ? 12 : 18),
        decoration: BoxDecoration(
          color: const Color(0xFF112240).withOpacity(0.5),
          borderRadius: BorderRadius.circular(isMobile ? 15 : 24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: SvgPicture.asset(
          'assets/icon/$iconName.svg',
        ),
      ),
      const SizedBox(height: 12),
      Text(
          name,
          style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              decoration: TextDecoration.none
          )
      ),
    ]);
  }

  Widget _buildProjectsSection(BuildContext context, LanguageProvider lang, bool isMobile) {
    return Column(children: [
      _sectionTitle(lang.t("RÉALISATIONS", "PROJECTS")),
      const SizedBox(height: 50),
      FutureBuilder<List<Project>>(
        future: _futureProjects,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
          }
          if (snapshot.hasError) return _buildErrorWidget(lang);
          final projects = snapshot.data ?? [];

          if (projects.isEmpty) {
            return Text(
                lang.t("Aucun projet de développement trouvé.", "No development projects found."),
                style: const TextStyle(color: Colors.white24, decoration: TextDecoration.none)
            );
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              crossAxisSpacing: 25,
              mainAxisSpacing: 25,
              childAspectRatio: isMobile ? 0.8 : 0.85,
            ),
            itemCount: projects.length,
            itemBuilder: (context, index) => _buildProjectCard(projects[index], lang)
                .animate().fadeIn(duration: 600.ms, delay: (index * 100).ms),
          );
        },
      ),
    ]);
  }

  Widget _buildProjectCard(Project project, LanguageProvider lang) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectDetailPage(project: project)));
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF112240).withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                flex: 5,
                child: project.cardImage != null
                    ? Image.network(
                  project.cardImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image, color: Colors.white10)),
                )
                    : Container(color: Colors.white10, width: double.infinity, child: const Icon(Icons.code, size: 50, color: Colors.blueAccent)),
              ),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      lang.isFrench ? project.titleFr : project.titleEn,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, decoration: TextDecoration.none),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                        lang.isFrench ? project.shortDescriptionFr : project.shortDescriptionEn,
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, height: 1.4, decoration: TextDecoration.none),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis
                    ),
                    const Spacer(),
                    Wrap(
                      spacing: 6, runSpacing: 6,
                      children: project.tools.take(2).map((t) => _buildMiniTag(t.name)).toList(),
                    ),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(LanguageProvider lang) {
    return Column(children: [
      const Icon(Icons.cloud_off, size: 40, color: Colors.white24),
      const SizedBox(height: 10),
      Text(
          lang.t("Serveur déconnecté", "Server disconnected"),
          style: const TextStyle(color: Colors.white24, decoration: TextDecoration.none)
      ),
      TextButton(
          onPressed: () => setState(() { _futureProjects = ApiService.fetchProjects(); }),
          child: Text(lang.t("Réessayer", "Retry"))
      )
    ]);
  }

  Widget _buildMiniTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: const TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Expanded(child: Container(height: 1, color: Colors.blueAccent.withOpacity(0.3))),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 15), child: Text(title, style: const TextStyle(letterSpacing: 2, fontWeight: FontWeight.w800, color: Colors.white, fontSize: 12, decoration: TextDecoration.none))),
      Expanded(child: Container(height: 1, color: Colors.blueAccent.withOpacity(0.3))),
    ]);
  }
}
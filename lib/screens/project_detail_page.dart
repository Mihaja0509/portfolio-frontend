import 'dart:ui'; // Obligatoire pour le flou
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:portfolio_front/widgets/main_layout.dart';
import 'package:portfolio_front/models/project_model.dart';
import 'package:portfolio_front/providers/language_provider.dart';

class ProjectDetailPage extends StatelessWidget {
  final Project project;

  const ProjectDetailPage({super.key, required this.project});

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(imageUrl, fit: BoxFit.contain),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        debugPrint('Erreur : $url');
      }
    } catch (e) {
      debugPrint('Lien invalide : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final bool isFrench = lang.isFrench;
    final bool isDev = project.categorySlug == 'dev';

    final bool hasNativeVideo = project.videoFile != null &&
        (project.videoFile!.toLowerCase().contains('.mp4') || project.videoFile!.toLowerCase().contains('.mov'));

    String? mainVideoUrl = project.videoExternalUrl;
    if (mainVideoUrl == null || mainVideoUrl.isEmpty) {
      final videoLink = project.links.where((l) => l.type.toLowerCase().contains('video')).toList();
      if (videoLink.isNotEmpty) {
        mainVideoUrl = videoLink.first.url;
      }
    }

    return LayoutBuilder(builder: (context, constraints) {
      bool isMobile = constraints.maxWidth < 800;

      return Material(
        color: Colors.black,
        child: MainLayout(
          navActions: [
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios, size: 16, color: Colors.blueAccent),
              label: Text(lang.t("RETOUR", "BACK"),
                  style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
            ),
          ],
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                vertical: isMobile ? 80 : 120,
                horizontal: isMobile ? 15 : 20
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.currentTitle(isFrench).toUpperCase(),
                      style: TextStyle(
                          fontSize: isMobile ? 28 : 42,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 3,
                          decoration: TextDecoration.none
                      ),
                    ).animate().fadeIn(duration: 600.ms).moveX(begin: -30, end: 0),

                    const SizedBox(height: 15),
                    _buildCategoryBadge(isDev ? lang.t("DÉVELOPPEMENT", "DEVELOPMENT") : "CREATIVE DESIGN"),
                    const SizedBox(height: 40),

                    _buildPriorityMedia(context, hasNativeVideo, mainVideoUrl, lang, isMobile),

                    if (!hasNativeVideo && mainVideoUrl != null && mainVideoUrl.isNotEmpty) ...[
                      const SizedBox(height: 30),
                      _buildExternalVideoButton(mainVideoUrl, lang, isMobile),
                    ],

                    const SizedBox(height: 60),
                    _buildMainContent(context, lang, isMobile),

                    if (project.gallery.isNotEmpty) ...[
                      const SizedBox(height: 80),
                      _sectionHeader(lang.t("GALERIE DU PROJET", "PROJECT GALLERY")),
                      const SizedBox(height: 30),
                      _buildGalleryGrid(context, isMobile),
                    ],

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildPriorityMedia(BuildContext context, bool hasNativeVideo, String? externalUrl, LanguageProvider lang, bool isMobile) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isMobile ? 15 : 30),
          boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.1), blurRadius: 50, spreadRadius: -10)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isMobile ? 15 : 30),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: hasNativeVideo
                ? NativeVideoPlayer(url: project.videoFile!)
                : _buildAdaptiveImageContainer(context),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.98, 0.98));
  }

  // Cette méthode gère le fond flou pour les images portraits
  Widget _buildAdaptiveImageContainer(BuildContext context) {
    final String imageUrl = project.gallery.isNotEmpty ? project.gallery.first : (project.cardImage ?? "");

    if (imageUrl.isEmpty) return const Center(child: Icon(Icons.broken_image, color: Colors.white24));

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Fond flou
        Image.network(imageUrl, fit: BoxFit.cover),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(color: Colors.black.withOpacity(0.4)),
        ),
        // 2. Image nette au centre
        GestureDetector(
          onTap: () => _showImageDialog(context, imageUrl),
          child: Image.network(imageUrl, fit: BoxFit.contain),
        ),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context, LanguageProvider lang, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(lang.t("À PROPOS", "ABOUT")),
        const SizedBox(height: 20),
        Text(
          project.currentFullDesc(lang.isFrench),
          style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: isMobile ? 16 : 18,
              height: 1.8,
              decoration: TextDecoration.none
          ),
        ),
        const SizedBox(height: 50),
        _sectionHeader("TECH STACK"),
        const SizedBox(height: 20),
        Wrap(spacing: 10, runSpacing: 10, children: project.tools.map((t) => _buildToolChip(t.name)).toList()),

        if (project.links.isNotEmpty) ...[
          const SizedBox(height: 60),
          _sectionHeader(lang.t("LIENS DU PROJET", "PROJECT LINKS")),
          const SizedBox(height: 25),
          // Affichage en grille pour les liens pour éviter le vide
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 2,
              mainAxisExtent: 70,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: project.links.length,
            itemBuilder: (context, index) => _buildEnhancedLinkButton(project.links[index]),
          ),
        ],
      ],
    );
  }

  // Nouveau design de bouton pour les liens (plus "rempli")
  Widget _buildEnhancedLinkButton(ProjectLink link) {
    return InkWell(
      onTap: () => _launchURL(link.url),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.link, color: Colors.blueAccent, size: 20),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                link.label.isNotEmpty ? link.label.toUpperCase() : link.typeDisplay.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryGrid(BuildContext context, bool isMobile) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 2,
        mainAxisSpacing: 20, crossAxisSpacing: 20, childAspectRatio: 1.6,
      ),
      itemCount: project.gallery.length,
      itemBuilder: (context, index) => GestureDetector(
        onTap: () => _showImageDialog(context, project.gallery[index]),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            // Ici aussi on peut mettre BoxFit.contain pour la grille si tu préfères
            child: Image.network(project.gallery[index], fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  // --- WIDGETS DE STYLE ---
  Widget _sectionHeader(String title) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 13, decoration: TextDecoration.none)),
    const SizedBox(height: 8),
    Container(width: 40, height: 2, color: Colors.blueAccent),
  ]);

  Widget _buildToolChip(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(color: const Color(0xFF112240), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.blueAccent.withOpacity(0.2))),
    child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
  );

  Widget _buildCategoryBadge(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blueAccent.withOpacity(0.3))),
    child: Text(label, style: const TextStyle(color: Colors.blueAccent, fontSize: 11, fontWeight: FontWeight.w800)),
  );

  Widget _buildExternalVideoButton(String url, LanguageProvider lang, bool isMobile) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => _launchURL(url),
        icon: const Icon(Icons.play_circle_fill, size: 24),
        label: Text(lang.t("VOIR LA DÉMO", "WATCH DEMO")),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 30 : 50, vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}

class NativeVideoPlayer extends StatefulWidget {
  final String url;
  const NativeVideoPlayer({super.key, required this.url});

  @override
  State<NativeVideoPlayer> createState() => _NativeVideoPlayerState();
}

class _NativeVideoPlayerState extends State<NativeVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController,
            aspectRatio: _videoPlayerController.value.aspectRatio,
            autoPlay: false,
            allowFullScreen: true,
            materialProgressColors: ChewieProgressColors(
              playedColor: Colors.blueAccent,
              handleColor: Colors.blueAccent,
            ),
          );
        });
      });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _chewieController != null
        ? Chewie(controller: _chewieController!)
        : const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
  }
}
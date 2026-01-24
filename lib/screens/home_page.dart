import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:portfolio_front/screens/projects_page.dart';
import 'package:portfolio_front/screens/contact_page.dart';
import 'package:portfolio_front/widgets/main_layout.dart';
import 'package:portfolio_front/providers/language_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'design_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isDevHovered = false;
  bool _isDesignHovered = false;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _aboutSectionKey = GlobalKey();

  void _scrollToAbout() {
    final context = _aboutSectionKey.currentContext;
    if (context != null && context.mounted) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOutCubic,
        alignment: 0.1,
      );
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      debugPrint('Erreur sur le lien : $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return LayoutBuilder(builder: (context, constraints) {
      bool isMobile = constraints.maxWidth < 950;
      bool isVerySmall = constraints.maxWidth < 600;

      return Scaffold(
        backgroundColor: Colors.black,
        drawer: isVerySmall ? _buildMobileDrawer(lang) : null,
        body: MainLayout(
          navActions: isVerySmall
              ? [
            Builder(
              builder: (innerContext) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.blueAccent),
                onPressed: () {
                  Scaffold.of(innerContext).openDrawer();
                },
              ),
            ),
            const SizedBox(width: 10),
            _buildLanguageSelector(lang),
          ]
              : [
            _navButton(lang.t('À propos', 'About'), onTap: _scrollToAbout),
            const SizedBox(width: 10),
            _navButton(lang.t('Contact', 'Contact'), onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactPage()));
            }),
            const SizedBox(width: 20),
            _buildLanguageSelector(lang),
          ],
          child: ListView(
            controller: _scrollController,
            cacheExtent: 3000,
            padding: EdgeInsets.only(top: isMobile ? 100 : 200, bottom: 100),
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: isMobile
                      ? Column(
                    children: [
                      _buildClickablePanel(
                        isMobile: isMobile,
                        image: lang.isFrench ? 'assets/dev.jpg' : 'assets/devEN.jpg',
                        isHovered: _isDevHovered,
                        onHover: (val) => setState(() => _isDevHovered = val),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectsPage())),
                      ).animate().fadeIn().slideY(begin: 0.1),
                      const SizedBox(height: 40),
                      _buildClickablePanel(
                        isMobile: isMobile,
                        image: lang.isFrench ? 'assets/design.jpg' : 'assets/designEN.jpg',
                        isHovered: _isDesignHovered,
                        onHover: (val) => setState(() => _isDesignHovered = val),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DesignPage())),
                      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                    ],
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildClickablePanel(
                        isMobile: isMobile,
                        image: lang.isFrench ? 'assets/dev.jpg' : 'assets/devEN.jpg',
                        isHovered: _isDevHovered,
                        onHover: (val) => setState(() => _isDevHovered = val),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectsPage())),
                      ).animate().fadeIn().slideX(begin: -0.1),
                      const SizedBox(width: 60),
                      _buildClickablePanel(
                        isMobile: isMobile,
                        image: lang.isFrench ? 'assets/design.jpg' : 'assets/designEN.jpg',
                        isHovered: _isDesignHovered,
                        onHover: (val) => setState(() => _isDesignHovered = val),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DesignPage())),
                      ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 100),
              // --- SECTION À PROPOS ---
              Center(
                child: Container(
                  key: _aboutSectionKey,
                  child: _buildAboutSection(lang, isMobile),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildMobileDrawer(LanguageProvider lang) {
    return Drawer(
      backgroundColor: const Color(0xFF0A192F),
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white10))),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(radius: 35, backgroundImage: AssetImage('assets/moi.png')),
                  const SizedBox(height: 10),
                  Text(lang.t("Andrianina Mihaja", "Andrianina Mihaja"), style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.blueAccent),
            title: Text(lang.t('À PROPOS', 'ABOUT'), style: const TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _scrollToAbout();
            },
          ),
          ListTile(
            leading: const Icon(Icons.mail, color: Colors.blueAccent),
            title: Text(lang.t('CONTACT', 'CONTACT'), style: const TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactPage()));
            },
          ),
        ],
      ),
    );
  }

  Widget _navButton(String text, {VoidCallback? onTap}) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(foregroundColor: Colors.white70),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildLanguageSelector(LanguageProvider lang) {
    return GestureDetector(
      onTap: () => lang.toggleLanguage(),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24),
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.05),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('FR', style: TextStyle(fontWeight: lang.isFrench ? FontWeight.bold : FontWeight.normal, fontSize: 12, color: lang.isFrench ? Colors.blueAccent : Colors.white60)),
              const Text(' / ', style: TextStyle(color: Colors.white24)),
              Text('EN', style: TextStyle(fontWeight: !lang.isFrench ? FontWeight.bold : FontWeight.normal, fontSize: 12, color: !lang.isFrench ? Colors.blueAccent : Colors.white60)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClickablePanel({
    required String image,
    required bool isHovered,
    required Function(bool) onHover,
    required VoidCallback onTap,
    required bool isMobile,
  }) {
    double width = isMobile ? 280 : 450;
    double height = isMobile ? 400 : 645;

    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: width, height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [if (isHovered) BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 40, spreadRadius: 5)],
            image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
          ),
          transform: isHovered ? (Matrix4.identity()..scale(1.02)) : Matrix4.identity(),
        ),
      ),
    );
  }

  Widget _buildAboutSection(LanguageProvider lang, bool isMobile) {
    return Container(
      width: 1000,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(isMobile ? 30 : 50),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.9),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white10),
      ),
      child: Flex(
        direction: isMobile ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Colors.blueAccent, Colors.purpleAccent])),
            child: CircleAvatar(radius: isMobile ? 70 : 110, backgroundImage: const AssetImage('assets/moi.png')),
          ),
          SizedBox(width: isMobile ? 0 : 60, height: isMobile ? 30 : 0),
          Expanded(
            flex: isMobile ? 0 : 1,
            child: Column(
              crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                Text("Andrianina Mihaja", textAlign: isMobile ? TextAlign.center : TextAlign.start, style: TextStyle(fontSize: isMobile ? 26 : 38, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 15),
                Wrap(
                  spacing: 10, runSpacing: 10, alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
                  children: [
                    _buildSkillBadge(lang.t("Développeur", "Developer"), Colors.blue),
                    _buildSkillBadge("Data Scientist", Colors.green),
                    _buildSkillBadge("Graphic Designer", Colors.orange),
                    _buildSkillBadge(lang.t("Monteur Vidéo", "Video Editor"), Colors.redAccent),
                  ],
                ),
                const SizedBox(height: 25),
                Text(lang.t("Expert pluridisciplinaire, je transforme les données en insights et les idées en expériences visuelles et interactives.", "Multidisciplinary expert, I transform data into insights and ideas into visual and interactive experiences."), textAlign: isMobile ? TextAlign.center : TextAlign.start, style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.white70)),
                const SizedBox(height: 30),
                _buildSocialLinks(isMobile),
              ],
            ),
          ),
        ],
      ),
    ).animate().moveY(begin: 50, end: 0).fadeIn();
  }

  Widget _buildSkillBadge(String label, Color color) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.5))), child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)));
  }

  Widget _buildSocialLinks(bool isMobile) {
    return Wrap(spacing: 25, runSpacing: 15, alignment: isMobile ? WrapAlignment.center : WrapAlignment.start, children: [
      _contactItem(FontAwesomeIcons.envelope, "Email", "mailto:contact@andrianina.com"),
      _contactItem(FontAwesomeIcons.whatsapp, "WhatsApp", "https://wa.me/261322111322"),
      _contactItem(FontAwesomeIcons.linkedin, "LinkedIn", "https://www.linkedin.com/public-profile/settings?lipi=urn%3Ali%3Apage%3Ad_flagship3_profile_self_edit_contact-info%3BAvGu2y8%2BRFeKajhH2IpMIw%3D%3D"),
      _contactItem(FontAwesomeIcons.github, "GitHub", "https://github.com/Mihaja0509"),
    ]);
  }

  Widget _contactItem(IconData icon, String text, String url) {
    return InkWell(onTap: () => _launchURL(url), borderRadius: BorderRadius.circular(8), child: Padding(padding: const EdgeInsets.all(4.0), child: Row(mainAxisSize: MainAxisSize.min, children: [FaIcon(icon, color: Colors.blueAccent, size: 18), const SizedBox(width: 10), Text(text, style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500))])));
  }
}
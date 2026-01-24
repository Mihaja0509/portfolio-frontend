import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:portfolio_front/widgets/main_layout.dart';
import 'package:portfolio_front/providers/language_provider.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSending = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  Future<void> _submitForm(LanguageProvider lang) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    const String apiUrl = "https://portfolio-backend-6fvo.onrender.com/api/contact/";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'subject': _subjectController.text.trim(),
          'message': _messageController.text.trim(),
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          _showStatusSnackBar(
            lang.t("Message envoyé avec succès !", "Message sent successfully!"),
            isError: false,
          );
          _nameController.clear();
          _emailController.clear();
          _subjectController.clear();
          _messageController.clear();
          FocusScope.of(context).unfocus();
        }
      } else {
        debugPrint("Erreur API : ${response.body}");
        if (mounted) {
          _showStatusSnackBar(
            lang.t("Erreur lors de l'envoi. Veuillez réessayer.", "Error while sending. Please try again."),
            isError: true,
          );
        }
      }
    } catch (e) {
      debugPrint("Exception lors de l'envoi : $e");
      if (mounted) {
        _showStatusSnackBar(
          lang.t("Impossible de contacter le serveur.", "Unable to contact server."),
          isError: true,
        );
      }
    } finally {
      // 5. Arrêt du loader dans tous les cas
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _showStatusSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Poppins')),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Erreur lien : $url');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 700;

          return Material(
            color: Colors.black,
            child: MainLayout(
              navActions: [
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios, size: 16, color: Colors.blueAccent),
                  label: Text(
                      isMobile ? "" : lang.t("RETOUR", "BACK"),
                      style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, decoration: TextDecoration.none, fontSize: 12)
                  ),
                ),
              ],
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(top: isMobile ? 100 : 150, bottom: 100, left: 20, right: 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      children: [
                        _buildProfileHeader(lang, isMobile)
                            .animate().fadeIn(duration: 600.ms).moveY(begin: 20, end: 0),
                        const SizedBox(height: 60),
                        _buildContactForm(lang, isMobile)
                            .animate().fadeIn(duration: 600.ms, delay: 200.ms).moveY(begin: 20, end: 0),
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

  Widget _buildProfileHeader(LanguageProvider lang, bool isMobile) {
    return Column(
      children: [
        Container(
          height: isMobile ? 120 : 150, width: isMobile ? 120 : 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 3),
            image: const DecorationImage(
              image: AssetImage('assets/moi.png'),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(color: Colors.blueAccent.withOpacity(0.1), blurRadius: 30, spreadRadius: 5),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "Andrianina Mihaja",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: isMobile ? 26 : 32, fontWeight: FontWeight.bold, letterSpacing: 2, decoration: TextDecoration.none),
        ),
        const SizedBox(height: 10),
        Text(
          lang.t("Développeur Fullstack & Designer Graphique", "Fullstack Developer & Graphic Designer"),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.blueAccent, fontSize: 14, fontWeight: FontWeight.w500, decoration: TextDecoration.none),
        ),
        const SizedBox(height: 30),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: [
            _socialIcon(FontAwesomeIcons.whatsapp, "https://wa.me/261322111322", Colors.greenAccent),
            _socialIcon(FontAwesomeIcons.envelope, "mailto:contact@andrianina.com", Colors.redAccent),
            _socialIcon(FontAwesomeIcons.github, "https://github.com/Mihaja0509", Colors.white),
            _socialIcon(FontAwesomeIcons.linkedin, "https://www.linkedin.com/public-profile/settings?lipi=urn%3Ali%3Apage%3Ad_flagship3_profile_self_edit_contact-info%3BAvGu2y8%2BRFeKajhH2IpMIw%3D%3D", Colors.blue),
          ],
        ),
      ],
    );
  }

  Widget _socialIcon(IconData icon, String url, Color hoverColor) {
    return IconButton(
      onPressed: () => _launchURL(url),
      icon: FaIcon(icon, color: Colors.white70, size: 28),
      hoverColor: hoverColor.withOpacity(0.1),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
        .shimmer(delay: 3.seconds, duration: 2.seconds, color: Colors.blueAccent.withOpacity(0.2));
  }

  Widget _buildContactForm(LanguageProvider lang, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 25 : 40),
      decoration: BoxDecoration(
        color: const Color(0xFF112240).withOpacity(0.5),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lang.t("ENVOYEZ-MOI UN MESSAGE", "SEND ME A MESSAGE"),
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 3, decoration: TextDecoration.none),
            ),
            const SizedBox(height: 30),
            _buildTextField(
                label: lang.t("Nom complet", "Full Name"),
                controller: _nameController,
                icon: Icons.person_outline,
                lang: lang
            ),
            const SizedBox(height: 20),
            _buildTextField(
                label: "Email",
                controller: _emailController,
                icon: Icons.alternate_email,
                isEmail: true,
                lang: lang
            ),
            const SizedBox(height: 20),
            _buildTextField(
                label: lang.t("Sujet", "Subject"),
                controller: _subjectController,
                icon: Icons.topic_outlined,
                lang: lang
            ),
            const SizedBox(height: 20),
            _buildTextField(
                label: "Message",
                controller: _messageController,
                icon: Icons.chat_bubble_outline,
                maxLines: 5,
                lang: lang
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSending ? null : () => _submitForm(lang),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  disabledBackgroundColor: Colors.grey.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: _isSending
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(lang.t("ENVOYER", "SEND"), style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required LanguageProvider lang,
    int maxLines = 1,
    bool isEmail = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      validator: (value) {
        if (value == null || value.isEmpty) return lang.t("Ce champ est requis", "Required field");
        if (isEmail && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return lang.t("Entrez un email valide", "Enter a valid email");
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.blueAccent, size: 20),
        filled: true,
        fillColor: Colors.black.withOpacity(0.2),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
    );
  }
}
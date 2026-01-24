import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:portfolio_front/screens/home_page.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final List<Widget>? navActions;

  const MainLayout({super.key, required this.child, this.navActions});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmall = screenWidth < 500;

    return Container(
      color: Colors.black,
      child: Stack(
        children: [

          Positioned.fill(
            child: Image.asset('assets/background.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withOpacity(0.4)),
            ),
          ),


          Positioned.fill(child: child),

          Positioned(
            top: 20, left: 10, right: 10,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    padding: EdgeInsets.symmetric(
                        horizontal: isSmall ? 15 : 30,
                        vertical: 15
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const HomePage()),
                                      (route) => false,
                                );
                              },
                              child: Text(
                                isSmall ? 'A.M' : 'ANDRIANINA MIHAJA',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                  color: Colors.blueAccent,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),

                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: navActions ?? [],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // FOOTER
          Positioned(
            bottom: 20, left: 0, right: 0,
            child: Center(
              child: Text(
                '© 2026 - Andrianina Mihaja',
                style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
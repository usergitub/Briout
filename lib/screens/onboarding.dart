import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'login.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/onboarding1.svg",
      "title": "Acheter des médicaments en ligne",
      "description": "Choisissez et achetez les médicaments nécessaires sans vous rendre à la pharmacie."
    },
    {
      "image": "assets/images/onboarding2.svg",
      "title": "Tout en une place",
      "description": "Télémédecine, commande de médicaments ou de remèdes homéopathiques, tout est là."
    },
    {
      "image": "assets/images/onboarding3.svg",
      "title": "Livraison rapide à partir de 15 minutes",
      "description": "Nous livrons vos médicaments rapidement. Les coursiers portent un équipement de protection."
    },
  ];

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool showSkipButton = _currentIndex < 2; // "Sauter" visible sur les pages 0 et 1
    bool isLastPage = _currentIndex == onboardingData.length;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: onboardingData.length + 1,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  if (index < onboardingData.length) {
                    return _buildOnboardingPage(data: onboardingData[index]);
                  } else {
                    return _buildOnboardingPage(
                      isWelcomePage: true,
                      data: {
                        "image": "assets/images/onboarding4.svg",
                        "title": "Bienvenue à Briout",
                        "description": "Notre équipe travaille dur pour ajouter de nouvelles fonctionnalités. Restez à l'écoute.",
                      },
                    );
                  }
                },
              ),
            ),
            
            // Nouvelle disposition du bas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // Ligne pour les indicateurs, alignés à gauche
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(
                      onboardingData.length + 1,
                      (index) => _buildIndicator(index),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Ligne pour les boutons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 80,
                        child: showSkipButton
                            ? TextButton(
                                onPressed: _navigateToLogin,
                                child: const Text(
                                  "Sauter",
                                  style: TextStyle(color: Colors.grey, fontSize: 16),
                                ),
                              )
                            : null, // Espace vide pour garder l'alignement
                      ),
                      SizedBox(
                        width: isLastPage ? 140 : 120,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (isLastPage) {
                              _navigateToLogin();
                            } else {
                              _controller.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeIn,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isLastPage ? "Continue" : "Suivant",
                                style: const TextStyle(fontSize: 16, color: Colors.white),
                              ),
                              if (!isLastPage) const SizedBox(width: 8),
                              if (!isLastPage) const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
             const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Page générique pour tous les slides, pour garantir la cohérence
  Widget _buildOnboardingPage({required Map<String, String> data, bool isWelcomePage = false}) {
    // Le texte est centré pour la page de bienvenue, sinon à gauche
    CrossAxisAlignment alignementTexte = isWelcomePage ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    TextAlign alignementParagraphe = isWelcomePage ? TextAlign.center : TextAlign.left;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: alignementTexte,
        children: [
          const Spacer(flex: 2),
          // Conteneur unifié pour l'image avec ombre portée
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26), // 10% d'opacité
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: SvgPicture.asset(data['image']!, height: 250),
            ),
          ),
          const SizedBox(height: 50),
          Text(
            data['title']!,
            textAlign: alignementParagraphe,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 16),
          Text(
            data['description']!,
            textAlign: alignementParagraphe,
            style: const TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }

  Widget _buildIndicator(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: _currentIndex == index ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentIndex == index ? Colors.blueAccent : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
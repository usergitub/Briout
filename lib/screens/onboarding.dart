import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'login.dart'; // Import de l’écran de connexion

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
      "title": "Bienvenue sur Briout",
      "description": "La plateforme santé qui vous connecte à ce dont vous avez besoin."
    },
    {
      "image": "assets/images/onboarding2.svg",
      "title": "Trouvez vos médicaments",
      "description": "Recherchez et commandez vos produits facilement, où que vous soyez."
    },
    {
      "image": "assets/images/onboarding3.svg",
      "title": "Gérez votre santé",
      "description": "Recevez des rappels, suivez vos ordonnances et plus encore."
    },
  ];

  void _nextPage() {
    if (_currentIndex < onboardingData.length) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Widget _buildIndicator(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentIndex == index ? 12 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentIndex == index ? Colors.indigo : Colors.grey,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _onboarding4Widget() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/onboarding4.svg',
            height: 250,
          ),
          const SizedBox(height: 32),
          const Text(
            'Bienvenue à Briout',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            "Notre équipe travaille dur pour ajouter de nouvelles fonctionnalités pour vous aider dans les situations de santé. Restez à l'écoute pour la prochaine mise à jour de Briout.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: onboardingData.length + 1,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  if (index < onboardingData.length) {
                    final data = onboardingData[index];
                    return Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            data['image']!,
                            height: 250,
                          ),
                          const SizedBox(height: 40),
                          Text(
                            data['title']!,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            data['description']!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  } else {
                    return _onboarding4Widget();
                  }
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(onboardingData.length + 1, _buildIndicator),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 10),
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _currentIndex == onboardingData.length ? "Commencer" : "Suivant",
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

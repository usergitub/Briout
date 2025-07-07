import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:briout/screens/onboarding.dart'; // Pour la redirection après déconnexion

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Fonction pour gérer la déconnexion
  Future<void> _signOut(BuildContext context) async {
    try {
      // Déconnecte l'utilisateur de Firebase
      await FirebaseAuth.instance.signOut();

      // Redirige l'utilisateur vers l'écran d'onboarding et supprime
      // toutes les autres pages de l'historique de navigation.
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      // Gérer les erreurs de déconnexion si nécessaire
      debugPrint("Erreur lors de la déconnexion: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Récupère l'utilisateur actuellement connecté pour afficher son email
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Profil"),
        centerTitle: true,
        backgroundColor: Colors.grey[50],
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (user != null) ...[
              const Icon(Icons.person_pin, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                "Connecté en tant que :",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                user.displayName ?? user.email ?? user.phoneNumber ?? "Utilisateur",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
            ],
            ElevatedButton.icon(
              onPressed: () => _signOut(context),
              icon: const Icon(Icons.logout),
              label: const Text("Déconnexion"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:briout/screens/onboarding.dart'; // Pour la redirection
import 'edit_profile_screen.dart'; // Page pour modifier le profil
import 'help_screen.dart'; // Page d'aide
import 'my_appointments_screen.dart'; // Page des rendez-vous
import 'language_screen.dart'; // Page de langue

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Fonction pour la déconnexion
  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profil", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Section informations utilisateur
              const CircleAvatar(
                radius: 40,
                // Remplacez par une vraie image de profil si disponible
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                user?.displayName ?? "Utilisateur",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                },
                child: const Text("Voir le profil"),
              ),
              const SizedBox(height: 20),

              // Menu d'options
              _buildProfileMenuItem(
                icon: Icons.calendar_today_outlined,
                title: "Mes rendez-vous",
                onTap: () {
                   Navigator.push(context, MaterialPageRoute(builder: (context) => const MyAppointmentsScreen()));
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.people_outline,
                title: "Mes docteurs",
                onTap: () {}, // Ajoutez la navigation ici
              ),
              _buildProfileMenuItem(
                icon: Icons.medical_services_outlined,
                title: "Dossiers médicaux",
                onTap: () {}, // Ajoutez la navigation ici
              ),
              _buildProfileMenuItem(
                icon: Icons.payment_outlined,
                title: "Paiements",
                onTap: () {}, // Ajoutez la navigation ici
              ),
               _buildProfileMenuItem(
                icon: Icons.language_outlined,
                title: "Langue",
                onTap: () {
                   Navigator.push(context, MaterialPageRoute(builder: (context) => const LanguageScreen()));
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.help_outline,
                title: "Aide & Support",
                onTap: () {
                   Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpScreen()));
                },
              ),
              const SizedBox(height: 20),
              // Bouton de déconnexion
              TextButton(
                onPressed: () => _signOut(context),
                child: const Text(
                  "Se déconnecter",
                  style: TextStyle(color: Colors.redAccent, fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget réutilisable pour chaque élément du menu
  Widget _buildProfileMenuItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.blue.shade700),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }
}
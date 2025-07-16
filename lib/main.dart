import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth
import 'screens/onboarding.dart';
import 'firebase_options.dart';
import 'package:briout/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Briout',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true, // Vous pouvez laisser à true si vous avez remplacé country_pickers
      ),
      // On utilise un Widget "AuthWrapper" pour choisir la bonne page
      home: const AuthWrapper(),
    );
  }
}

// Ce widget écoute les changements d'état d'authentification
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // En attendant la vérification
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        // Si l'utilisateur est connecté (snapshot contient des données)
        if (snapshot.hasData) {
          return const MainScreen();
        }
        
        // Si l'utilisateur n'est pas connecté
        return const OnboardingScreen();
      },
    );
  }
}
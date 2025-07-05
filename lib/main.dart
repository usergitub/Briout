import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/onboarding.dart'; // Point d'entrée de l'UI
import 'firebase_options.dart';

void main() async {
  // Assure que le moteur Flutter est prêt
  WidgetsFlutterBinding.ensureInitialized();
  // Initialise Firebase pour votre projet
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
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      home: const OnboardingScreen(),
    );
  }
}
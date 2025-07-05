import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'login.dart'; // L'import pour LoginScreen est bien ici

class HomeScreen extends StatefulWidget {
  final Position position;
  const HomeScreen({super.key, required this.position});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData() async {
    if (currentUser == null) {
      throw Exception("Aucun utilisateur n'est connecté.");
    }
    return FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Page d'accueil"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              
              // Correction de l'avertissement "use_build_context_synchronously"
              if (!context.mounted) return;

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()), 
                (Route<dynamic> route) => false
              );
            },
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: getUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text("Erreur : ${snapshot.error}");
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Text("Données de l'utilisateur introuvables.");
              }

              final userData = snapshot.data!.data();
              final userName = userData?['name'] ?? 'Utilisateur';

              return Text(
                'Coucou $userName,\nvotre position est :\n\nLatitude: ${widget.position.latitude.toStringAsFixed(4)}\nLongitude: ${widget.position.longitude.toStringAsFixed(4)}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20),
              );
            },
          ),
        ),
      ),
    );
  }
}
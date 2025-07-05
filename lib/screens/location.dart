import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'home.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() => _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  bool _isLoading = false;

  Future<void> _requestLocationPermission() async {
    setState(() => _isLoading = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!mounted) return;

    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Le service de localisation est désactivé.")));
      setState(() => _isLoading = false);
      return;
    }

    final status = await Permission.location.request();
    if (!mounted) return;

    if (status.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(position: position)),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Impossible d'obtenir la position.")));
        }
      }
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    } else {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("L'accès à la localisation est requis.")));
    }
   
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Icon(Icons.location_on_outlined, size: 100, color: Colors.blue[800]),
              const SizedBox(height: 32),
              const Text("Quelle est votre position ?", textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text("Nous avons besoin de votre emplacement pour vous suggérer des services à proximité.", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              const Spacer(flex: 3),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _requestLocationPermission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Autoriser l'accès à la localisation", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                // Le commentaire a été retiré, le bouton ne fait rien pour l'instant.
                onPressed: () {}, 
                child: Text("Saisir l'emplacement manuellement", style: TextStyle(fontSize: 16, color: Colors.blue[800])),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
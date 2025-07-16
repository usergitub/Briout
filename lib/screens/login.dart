import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:briout/widgets/auth_toggle_button.dart'; // Importer le nouveau widget
import 'signup.dart';
import 'otp.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // On initialise avec les données pour la Côte d'Ivoire
  Country _selectedCountry = Country(
    phoneCode: '225',
    countryCode: 'CI',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'Côte d\'Ivoire',
    example: '07xxxxxxxx',
    displayName: 'Côte d\'Ivoire',
    displayNameNoCountryCode: 'CI',
    e164Key: '',
  );

  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  // Nouvelle fonction pour ouvrir le sélecteur de pays
  void _openCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      countryListTheme: CountryListThemeData(
        bottomSheetHeight: 500, // Ajuste la hauteur
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        inputDecoration: InputDecoration(
          labelText: 'Rechercher',
          hintText: 'Commencez à taper le nom du pays',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: const Color(0xFF8C98A8).withAlpha(51),
            ),
          ),
        ),
      ),
      onSelect: (Country country) {
        setState(() {
          _selectedCountry = country;
        });
      },
    );
  }

  void _handleLogin() {
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Veuillez entrer un numéro de téléphone.")),
      );
      return;
    }

    setState(() => _isLoading = true);
    String phoneNumber =
        "+${_selectedCountry.phoneCode}${_phoneController.text.trim()}";

    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {
        if (mounted) setState(() => _isLoading = false);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur : ${e.message}")),
          );
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    OtpScreen(verificationId: verificationId)),
          );
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (mounted) setState(() => _isLoading = false);
      },
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text('Akwaba!',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800])),
                const SizedBox(height: 8),
                Text('Connectez-vous à votre compte',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                const SizedBox(height: 40),

                // NOUVEAUX BOUTONS
                AuthToggleButton(
                  isLoginActive: true,
                  onLoginTapped:
                      () {}, // Ne fait rien car on est déjà sur la page
                  onSignupTapped: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const SignupScreen(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),
                Text('Numéro de téléphone',
                    style: TextStyle(
                        color: Colors.grey[800], fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    InkWell(
                      onTap: _openCountryPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            Text(_selectedCountry.flagEmoji,
                                style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 8),
                            Text("+${_selectedCountry.phoneCode}"),
                            const Icon(Icons.arrow_drop_down,
                                color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: '000 000 0000',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Se connecter',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, color: Colors.white),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

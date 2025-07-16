import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:briout/widgets/auth_toggle_button.dart';
import 'login.dart';
import 'otp.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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

  bool _isPasswordObscured = true;
  bool _isLoading = false;
  Color _nameBorderColor = Colors.grey;
  Color _passwordBorderColor = Colors.grey;
  String? _passwordHelperText;

  void _handleSignup() async {
    if (!mounted) return;

    if (_nameBorderColor != Colors.green || _passwordBorderColor != Colors.green || _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir correctement tous les champs.")),
      );
      return;
    }

    setState(() => _isLoading = true);
    String phoneNumber = "+${_selectedCountry.phoneCode}${_phoneController.text.trim()}";

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {
        if (mounted) setState(() => _isLoading = false);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur : ${e.message}")));
          setState(() => _isLoading = false);
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(
                verificationId: verificationId,
                userName: _nameController.text.trim(),
                password: _passwordController.text.trim(),
              ),
            ),
          );
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (mounted) setState(() => _isLoading = false);
      },
    );
  }

  void _openCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        setState(() {
          _selectedCountry = country;
        });
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
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
                Text('Akwaba!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                const SizedBox(height: 8),
                Text('Créez votre compte pour continuer', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                const SizedBox(height: 40),
                
                AuthToggleButton(
                  isLoginActive: false, // S'inscrire est actif
                  onLoginTapped: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const LoginScreen(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                  onSignupTapped: () {}, // Ne fait rien
                ),

                const SizedBox(height: 32),
                Text('Nom et prénom', style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  onChanged: (value) {
                    setState(() {
                      if (value.trim().isEmpty) {
                        _nameBorderColor = Colors.grey;
                      } else if (value.trim().contains(' ')) {
                        _nameBorderColor = Colors.green;
                      } else {
                        _nameBorderColor = Colors.red;
                      }
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Entrer votre nom complet',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _nameBorderColor, width: 1.5)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _nameBorderColor, width: 2)),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Numéro de téléphone', style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    InkWell(
                      onTap: _openCountryPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            Text(_selectedCountry.flagEmoji, style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 8),
                            Text("+${_selectedCountry.phoneCode}"),
                            const Icon(Icons.arrow_drop_down, color: Colors.grey),
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
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Créer un mot de passe', style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: _isPasswordObscured,
                  onChanged: (value) {
                    setState(() {
                      if (value.isEmpty) {
                        _passwordBorderColor = Colors.grey;
                        _passwordHelperText = null;
                      } else if (value.length < 8) {
                        _passwordBorderColor = Colors.red;
                        _passwordHelperText = 'Au moins 8 caractères requis';
                      } else {
                        _passwordBorderColor = Colors.green;
                        _passwordHelperText = 'Mot de passe valide';
                      }
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Entrer votre mot de passe',
                    helperText: _passwordHelperText,
                    helperStyle: TextStyle(color: _passwordBorderColor),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _passwordBorderColor, width: 1.5)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _passwordBorderColor, width: 2)),
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordObscured ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                      onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Suivant', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
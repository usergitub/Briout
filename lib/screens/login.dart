import 'package:flutter/material.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup.dart';
import 'otp.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Country _selectedCountry = CountryPickerUtils.getCountryByPhoneCode('225');
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  void _openCountryPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(primaryColor: Colors.blue[800]),
        child: CountryPickerDialog(
          titlePadding: const EdgeInsets.all(8.0),
          searchCursorColor: Colors.blue[800],
          isSearchable: true,
          title: const Text('Sélectionnez votre pays'),
          onValuePicked: (Country country) => setState(() => _selectedCountry = country),
          itemBuilder: (Country country) => Row(
            children: [
              CountryPickerUtils.getDefaultFlagImage(country),
              const SizedBox(width: 8.0),
              Text("+${country.phoneCode}"),
              const SizedBox(width: 8.0),
              Flexible(child: Text(country.name)),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez entrer un numéro de téléphone.")),
      );
      return;
    }

    setState(() => _isLoading = true);
    String phoneNumber = "+${_selectedCountry.phoneCode}${_phoneController.text.trim()}";

    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {
         setState(() => _isLoading = false);
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : ${e.message}")),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() => _isLoading = false);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OtpScreen(verificationId: verificationId)),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() => _isLoading = false);
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text('Akwaba!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue[800])),
                const SizedBox(height: 8),
                Text('Connectez-vous à votre compte', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                const SizedBox(height: 40),
                Row(
                   children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Se connecter', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignupScreen()));
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.blue[800]!),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text('S\'inscrire', style: TextStyle(color: Colors.blue[800], fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text('Numéro de téléphone', style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    InkWell(
                      onTap: () => _openCountryPicker(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16.5),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            CountryPickerUtils.getDefaultFlagImage(_selectedCountry),
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
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Se connecter', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
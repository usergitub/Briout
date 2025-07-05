import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pinput/pinput.dart';
import 'location.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  final String? userName;
  final String? password;

  const OtpScreen({
    super.key,
    required this.verificationId,
    this.userName,
    this.password,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  void _verifyOtp() async {
    if (_otpController.text.length < 6) return;
    setState(() => _isLoading = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _otpController.text.trim(),
      );
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      if (widget.userName != null && userCredential.user != null) {
        String uid = userCredential.user!.uid;
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'name': widget.userName,
          'phone': userCredential.user!.phoneNumber,
          'password': widget.password,
          'createdAt': Timestamp.now(),
        });
      }

      // CORRECTION : On vérifie si le widget est toujours monté avant de naviguer
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LocationPermissionScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      // CORRECTION : On vérifie si le widget est toujours monté avant d'afficher la SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Code OTP invalide : ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(fontSize: 22, color: Colors.black, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
    );
    return Scaffold(
      appBar: AppBar(title: const Text("Vérification")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Text("Vérification", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text("Nous avons envoyé un code à 6 chiffres pour vérifier votre numéro.", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 50),
                Pinput(
                  length: 6,
                  controller: _otpController,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      border: Border.all(color: Colors.blueAccent),
                    ),
                  ),
                  onCompleted: (pin) => _verifyOtp(),
                ),
                const SizedBox(height: 50),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Vérifier et continuer", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
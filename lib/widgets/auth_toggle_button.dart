// lib/widgets/auth_toggle_button.dart
import 'package:flutter/material.dart';

class AuthToggleButton extends StatelessWidget {
  final bool isLoginActive;
  final VoidCallback onLoginTapped;
  final VoidCallback onSignupTapped;

  const AuthToggleButton({
    super.key,
    required this.isLoginActive,
    required this.onLoginTapped,
    required this.onSignupTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildButton("Se connecter", isLoginActive, onLoginTapped),
          ),
          Expanded(
            child: _buildButton("S'inscrire", !isLoginActive, onSignupTapped),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isActive ? Colors.blueAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:briout/screens/achats.dart';
import 'package:briout/screens/home.dart';
import 'package:briout/screens/ordonnance_screen.dart';
import 'package:briout/screens/profile_screen.dart';
import 'package:briout/screens/search_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // La liste de toutes nos pages principales
  static const List<Widget> _pages = <Widget>[
    HomeScreen(),
    SearchScreen(),
    OrdonnanceScreen(),
    AchatsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Affiche la page sélectionnée
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          // Superpose la barre de navigation flottante par-dessus
          _buildFloatingNavBar(),
        ],
      ),
    );
  }

  // Widget pour la barre de navigation flottante
Widget _buildFloatingNavBar() {
  return Positioned(
    bottom: 25,
    left: 20,
    right: 20,
    // On ajoute SafeArea ici pour qu'il pousse la barre vers le haut,
    // au-dessus des boutons de navigation du téléphone.
    child: SafeArea( 
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.shade700,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(51), // (0.2 * 255 = 51)
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(icon: Icons.home, label: "Home", index: 0),
            _buildNavItem(icon: Icons.search, label: "Search", index: 1),
            _buildNavItem(icon: Icons.qr_code_scanner_rounded, label: "Ordonnance", index: 2),
            _buildNavItem(icon: Icons.shopping_cart_outlined, label: "Cart", index: 3),
            _buildNavItem(icon: Icons.person_outline, label: "Profile", index: 4),
          ],
        ),
      ),
    ),
  );
}

  // Widget pour chaque bouton de la barre de navigation
  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    bool isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
            : const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.blue.shade700 : Colors.white.withAlpha(204), size: 26),
            if (isSelected)
              const SizedBox(width: 6),
            if (isSelected)
              Text(
                label,
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
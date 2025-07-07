import 'package:flutter/material.dart';

class AchatsScreen extends StatelessWidget {
  const AchatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              const SizedBox(height: 24),
              _buildActionButtons(),
              const SizedBox(height: 24),
              _buildInsuranceBanner(),
              const SizedBox(height: 32),
              _buildCategorySection(),
            ],
          ),
        ),
      ),
    );
  }

  // Construit la barre d'applications
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'iPharmacie',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.account_balance_wallet_outlined, color: Colors.black54),
        ),
      ],
    );
  }

  // Construit la barre de recherche
  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher Medicament; Autre...',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
          ),
        )
      ],
    );
  }

  // Construit les 3 boutons d'action rapide
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _actionButton(
          label: 'Traitement',
          icon: Icons.link,
          color: Colors.blue.shade100,
          iconColor: Colors.blue.shade800,
        ),
        _actionButton(
          label: 'Produit image',
          icon: Icons.image_outlined,
          color: Colors.orange.shade100,
          iconColor: Colors.orange.shade800,
        ),
        _actionButton(
          label: 'Pharmacien assistant',
          icon: Icons.support_agent,
          color: Colors.green.shade100,
          iconColor: Colors.green.shade800,
        ),
      ],
    );
  }

  // Widget pour un bouton d'action
  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color iconColor,
  }) {
    return Column(
      children: [
        Container(
          width: 90,
          height: 70,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, size: 32, color: iconColor),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // Construit le bandeau pour l'assurance
  Widget _buildInsuranceBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, color: Colors.blue.shade800, size: 32),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ajoutez votre assurance',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'pour le payement de votre ordonance',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  // Construit la section des catégories
  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categorie',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _categoryCard('SANTE')),
            const SizedBox(width: 16),
            Expanded(child: _categoryCard('SOINS')),
          ],
        ),
      ],
    );
  }

  // Widget pour une carte de catégorie
  Widget _categoryCard(String title) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }

}
import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 2 onglets : FAQ et Licence
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Aide"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.blueAccent,
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "FAQ"),
              Tab(text: "LICENCE"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Contenu de l'onglet FAQ
            _buildFaqTab(),
            // Contenu de l'onglet Licence
            _buildLicenseTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Ici vous mettriez la barre de recherche et la bannière COVID
        const Text("FAQ - Questions fréquentes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _buildExpansionTile("Qu'est-ce que Briout ?"),
        _buildExpansionTile("Comment puis-je prendre un rendez-vous ?"),
        _buildExpansionTile("Comment sont gérées mes données ?"),
      ],
    );
  }

  Widget _buildLicenseTab() {
    return const Center(
      child: Text("Contenu de la page Licence"),
    );
  }

  Widget _buildExpansionTile(String title) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        children: const [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("commment tu bas efbeof oz peifk ejc eozb jbefn c ezblingrzlfv oprgfzrf zpnef oczclkncl"),
          )
        ],
      ),
    );
  }
}
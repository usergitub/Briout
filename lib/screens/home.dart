import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Un modèle simple pour organiser les données de chaque lieu
class Place {
  final LatLng point;
  final String name;
  final String type; // ex: "hospital", "pharmacy"

  const Place({required this.point, required this.name, required this.type});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Place &&
          runtimeType == other.runtimeType &&
          point == other.point &&
          name == other.name &&
          type == other.type;

  @override
  int get hashCode => Object.hash(point, name, type);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController _mapController = MapController();

  // Variables d'état pour l'interface dynamique
  String _userName = "...";
  String _userLocation = "Chargement...";
  bool _isDayTime = true;
  bool _isLoading = true;

  // Variables pour la gestion des filtres et des lieux
  final List<String> _filterTags = const ["Hôpital", "Pharmacie", "Clinique", "Dentiste", "Laboratoire"];
  String _selectedTag = "Hôpital";
  List<Place> _allPlaces = [];
  List<Marker> _filteredMarkers = [];
  Place? _selectedPlace;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  // Fonction principale qui charge toutes les données au démarrage de l'écran
  Future<void> _initializeScreen() async {
    if (mounted) setState(() => _isLoading = true);
    _determineDayNight();
    await _loadUserData();
    
    // Pour cet exemple, nous utilisons des coordonnées fixes pour Abidjan.
    const userPosition = LatLng(5.3600, -4.0083);
    
    await _updateUserLocationName(userPosition);
    await _fetchNearbyPlaces(userPosition);
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _determineDayNight() {
    final hour = DateTime.now().hour;
    if (mounted) {
      setState(() {
        _isDayTime = hour > 6 && hour < 19;
      });
    }
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (mounted && doc.exists && doc.data()!.containsKey('name')) {
        setState(() {
          _userName = doc.data()!['name'];
        });
      }
    } catch (e) {
      debugPrint("Erreur de chargement du nom d'utilisateur: $e");
    }
  }

  Future<void> _updateUserLocationName(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (mounted && placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        setState(() {
          _userLocation = "${placemark.locality}, ${placemark.country}";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userLocation = "Position inconnue";
        });
      }
    }
  }

  Uri _buildOverpassUrl(LatLng position, int radius) {
    final query = """
      [out:json][timeout:25];
      area(3600192779)->.searchArea;
      (
        node[amenity~"^(hospital|pharmacy|doctors|clinic|dentist)\$"](around:$radius,${position.latitude},${position.longitude});
        way[amenity~"^(hospital|pharmacy|doctors|clinic|dentist)\$"](around:$radius,${position.latitude},${position.longitude});
        node[healthcare="laboratory"](around:$radius,${position.latitude},${position.longitude});
        way[healthcare="laboratory"](around:$radius,${position.latitude},${position.longitude});
      )->.nearby_places;
      (
        node.nearby_places(area.searchArea);
        way.nearby_places(area.searchArea);
      );
      out center;
    """;
    return Uri.parse('https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(query)}');
  }

  Future<void> _fetchNearbyPlaces(LatLng position) async {
    final url = _buildOverpassUrl(position, 25000);

    try {
      final response = await http.get(url);
      if (mounted && response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List elements = data['elements'];
        List<Place> places = [];
        for (var element in elements) {
          final tags = element['tags'];
          if (tags != null && (element['lat'] != null || element['center']?['lat'] != null)) {
            String type = tags['amenity'] ?? tags['healthcare'] ?? 'unknown';
            places.add(Place(
              point: LatLng(element['center']?['lat'] ?? element['lat'], element['center']?['lon'] ?? element['lon']),
              name: tags['name'] ?? 'Lieu inconnu',
              type: type,
            ));
          }
        }
        setState(() {
          _allPlaces = places;
          _updateFilteredMarkers();
        });
      }
    } catch (e) {
      debugPrint("Erreur de l'API Overpass : $e");
    }
  }

  void _updateFilteredMarkers() {
    const Map<String, String> tagMap = {
      "Hôpital": "hospital",
      "Pharmacie": "pharmacy",
      "Clinique": "clinic",
      "CHU": "clinic",
      "Dentiste": "dentist",
      "Laboratoire": "laboratory",
    };
    final osmTag = tagMap[_selectedTag] ?? _selectedTag.toLowerCase();
    
    final filteredPlaces = _allPlaces.where((place) => place.type == osmTag).toList();

    final markers = filteredPlaces.map((place) {
      bool isSelected = _selectedPlace == place;
      return Marker(
        point: place.point,
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedPlace = place;
              _updateFilteredMarkers(); 
            });
            _mapController.move(place.point, 15.0);
          },
          child: Icon(
            _getIconForPlaceType(place.type),
            color: isSelected ? Colors.blueAccent : Colors.redAccent,
            size: isSelected ? 45 : 40,
          ),
        ),
      );
    }).toList();

    if(mounted) {
      setState(() {
        _filteredMarkers = markers;
      });
    }
  }
  
  IconData _getIconForPlaceType(String type) {
    switch(type) {
      case 'hospital': return Icons.local_hospital;
      case 'pharmacy': return Icons.local_pharmacy;
      case 'clinic':
      case 'doctors':
        return Icons.medical_services;
      case 'dentist': return Icons.local_hospital;
      case 'laboratory': return Icons.science;
      default: return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ce Scaffold n'a PAS de barre de navigation, car elle est gérée par main_screen.dart
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(5.3600, -4.0083),
              initialZoom: 12.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.briout',
              ),
              MarkerLayer(markers: _filteredMarkers),
            ],
          ),
          
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
          
          _buildCustomAppBar(),
          
          _buildDraggableSheet(),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black.withAlpha(128),
                    child: Icon(_isDayTime ? Icons.wb_sunny : Icons.nightlight_round, color: Colors.white),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          "Akwaba, $_userName!",
                          style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold, fontSize: 18),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_on, color: Colors.grey.shade700, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _userLocation,
                                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.layers_outlined, color: Colors.grey[800]),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filterTags.length,
                  itemBuilder: (context, index) {
                    final tag = _filterTags[index];
                    return _buildFilterChip(
                      tag,
                      isSelected: tag == _selectedTag,
                      onTap: () {
                        setState(() {
                          _selectedTag = tag;
                          _updateFilteredMarkers();
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        onPressed: onTap,
        label: Text(label),
        backgroundColor: isSelected ? Colors.blueAccent : Colors.white,
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black54, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: isSelected ? BorderSide.none : BorderSide(color: Colors.grey.shade300)
        ),
      ),
    );
  }
  
  Widget _buildDraggableSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.25,
      minChildSize: 0.15,
      maxChildSize: 0.6,
      builder: (BuildContext context, ScrollController scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Card(
            elevation: 12.0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _selectedPlace == null
                  ? _buildEmptySheetContent()
                  : _buildPlaceDetailsContent(_selectedPlace!),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptySheetContent() {
    return Column(
      children: [
        Center(
          child: Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Sélectionnez un lieu sur la carte",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        )
      ],
    );
  }

  Widget _buildPlaceDetailsContent(Place place) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.redAccent,
              child: Icon(_getIconForPlaceType(place.type), color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(place.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), overflow: TextOverflow.ellipsis),
                  Text(place.type, style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.grey),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }
}
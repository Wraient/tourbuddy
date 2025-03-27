import 'package:flutter/material.dart';
import 'models/place.dart';
import 'services/places_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TourBuddy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final PlacesService _placesService = PlacesService('AIzaSyB7VHklYRurHycmVHRDgHFOLFjYSpfWm3U'); // Replace with your API key
  bool _showPlaceDetails = false;
  bool _isLoading = false;
  Place? _selectedPlace;
  List<Place> _searchResults = [];
  double _bottomSheetSize = 0.3;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onSearch() async {
    if (_searchController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchResults = [];
      _showPlaceDetails = false;
    });

    try {
      print('Searching for: ${_searchController.text}');
      final results = await _placesService.searchPlaces(_searchController.text);
      print('Found ${results.length} results');
      
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
      
      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No places found. Try a different search term.')),
        );
      }
    } catch (e) {
      print('Error in _onSearch: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching places: $e')),
      );
    }
  }

  void _selectPlace(Place place) {
    setState(() {
      _selectedPlace = place;
      _showPlaceDetails = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for a place...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                onSubmitted: (_) => _onSearch(),
              ),
            ),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_searchResults.isNotEmpty && !_showPlaceDetails)
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final place = _searchResults[index];
                    return ListTile(
                      leading: place.imageUrl.isNotEmpty
                          ? Image.network(
                              place.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.place),
                      title: Text(place.name),
                      subtitle: Text(place.address),
                      onTap: () => _selectPlace(place),
                    );
                  },
                ),
              ),
            if (_showPlaceDetails && _selectedPlace != null) Expanded(
              child: Stack(
                children: [
                  // Place Image with AnimatedOpacity
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _bottomSheetSize > 0.5 ? 0.0 : 1.0,
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: Image.network(
                        _selectedPlace!.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Bottom Sheet
                  NotificationListener<DraggableScrollableNotification>(
                    onNotification: (notification) {
                      setState(() {
                        _bottomSheetSize = notification.extent;
                      });
                      return true;
                    },
                    child: DraggableScrollableSheet(
                      initialChildSize: 0.3,
                      minChildSize: 0.2,
                      maxChildSize: 0.8,
                      builder: (context, scrollController) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Drag Handle
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 12),
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              // Content
                              Expanded(
                                child: SingleChildScrollView(
                                  controller: scrollController,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedPlace!.name,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.star, color: Colors.amber),
                                            const SizedBox(width: 4),
                                            Text(
                                              _selectedPlace!.rating.toString(),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        _buildInfoRow(Icons.monetization_on, 'Entry Fee', _selectedPlace!.entryFee),
                                        _buildInfoRow(Icons.access_time, 'Opening Hours', _selectedPlace!.openingHours),
                                        _buildInfoRow(Icons.location_on, 'Location', _selectedPlace!.address),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Description',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _selectedPlace!.description,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        if (_selectedPlace!.photos.isNotEmpty) ...[
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Photos',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          SizedBox(
                                            height: 150,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: _selectedPlace!.photos.length,
                                              itemBuilder: (context, index) {
                                                return Padding(
                                                  padding: const EdgeInsets.only(right: 8.0),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(8),
                                                    child: Image.network(
                                                      _selectedPlace!.photos[index],
                                                      width: 150,
                                                      height: 150,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

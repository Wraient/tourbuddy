import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/place.dart';
import 'gemini_service.dart';

class PlacesService {
  static const String _baseUrl = 'https://places.googleapis.com/v1/places:searchText';
  final String _apiKey;
  late final GeminiService _geminiService;

  PlacesService(this._apiKey) {
    _geminiService = GeminiService(_apiKey);
  }

  Future<List<Place>> searchPlaces(String query) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': _apiKey,
          'X-Goog-FieldMask': 'places.displayName,places.formattedAddress,places.photos,places.rating,places.location'
        },
        body: jsonEncode({
          'textQuery': query,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['places'] != null) {
          final places = data['places'] as List;
          return Future.wait(places.map((place) async {
            final name = place['displayName']?['text'] ?? '';
            final description = await _geminiService.getPlaceDescription(name);
            
            return Place(
              name: name,
              description: description,
              imageUrl: place['photos']?.isNotEmpty == true 
                  ? 'https://places.googleapis.com/v1/${place['photos'][0]['name']}/media?key=$_apiKey&maxHeightPx=400'
                  : '',
              address: place['formattedAddress'] ?? '',
              openingHours: 'Hours not available',
              entryFee: 'Price information not available',
              rating: (place['rating'] ?? 0.0).toDouble(),
              photos: place['photos']?.map<String>((photo) => 
                'https://places.googleapis.com/v1/${photo['name']}/media?key=$_apiKey&maxHeightPx=400'
              )?.toList() ?? [],
              latitude: place['location']?['latitude'] ?? 0.0,
              longitude: place['location']?['longitude'] ?? 0.0,
            );
          }).toList());
        }
      }
      print('API Error: ${response.body}');
      return [];
    } catch (e, stackTrace) {
      print('Error searching places: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  Future<Place?> getPlaceDetails(String placeId) async {
    try {
      final response = await http.get(
        Uri.parse('https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_apiKey&fields=opening_hours,price_level,editorial_summary'),
      );

      print('Details URL: ${Uri.parse('https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_apiKey&fields=opening_hours,price_level,editorial_summary')}');
      print('Details status: ${response.statusCode}');
      print('Details body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final result = data['result'];
          return Place(
            name: '',  // We don't need these fields as they're used internally
            description: result['editorial_summary']?['overview'] ?? 'No description available',
            imageUrl: '',
            address: '',
            openingHours: result['opening_hours']?['weekday_text']?.join('\n') ?? 'Hours not available',
            entryFee: result['price_level'] != null 
                ? '\$' * result['price_level'] 
                : 'Price information not available',
            rating: 0.0,
            photos: [],
            latitude: 0.0,
            longitude: 0.0,
          );
        } else {
          print('Details API returned non-OK status: ${data['status']}');
          return null;
        }
      }
      print('Details API Error: ${response.body}');
      return null;
    } catch (e, stackTrace) {
      print('Error getting place details: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }
} 
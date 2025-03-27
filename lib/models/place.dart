class Place {
  final String name;
  final String description;
  final String imageUrl;
  final String address;
  final String openingHours;
  final String entryFee;
  final double rating;
  final List<String> photos;
  final double latitude;
  final double longitude;

  Place({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.address,
    required this.openingHours,
    required this.entryFee,
    required this.rating,
    required this.photos,
    required this.latitude,
    required this.longitude,
  });

  @override
  String toString() {
    return 'Place{name: $name, address: $address, rating: $rating}';
  }

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      address: json['address'] ?? '',
      openingHours: json['openingHours'] ?? '',
      entryFee: json['entryFee'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      photos: List<String>.from(json['photos'] ?? []),
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
    );
  }
} 
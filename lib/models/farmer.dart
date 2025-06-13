class Farmer {
  final String id;
  final String name;
  final String location;
  final String image;
  final List<String> specialties;
  final double rating;
  final String distance;
  
  Farmer({
    required this.id,
    required this.name,
    required this.location,
    required this.image,
    required this.specialties,
    required this.rating,
    required this.distance,
  });

  static Farmer fromMap(Map<String, dynamic> data) {
    return Farmer(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      image: data['image'] ?? '',
      specialties: List<String>.from(data['productTypes'] ?? []),
      rating: (data['rating'] ?? 0).toDouble(),
      distance: data['distance'] ?? '',
    );
  }
}
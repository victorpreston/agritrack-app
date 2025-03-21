class Farm {
  final String id;
  final String name;
  final String location;
  final String totalArea;
  final String ownerId;

  Farm({
    this.id = '', // Default to empty string for new farms
    required this.name,
    required this.location,
    required this.totalArea,
    required this.ownerId,
  });

  Map<String, dynamic> toJson() {
    // Don't include empty ID in the JSON when creating a new record
    final json = {
      'name': name,
      'location': location,
      'total_area': totalArea,
      'owner_id': ownerId,
    };

    // Only include ID if it's not empty (for updates)
    if (id.isNotEmpty) {
      json['id'] = id;
    }

    return json;
  }

  // Factory constructor to create a Farm from a JSON map
  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      totalArea: json['total_area'] ?? '',
      ownerId: json['owner_id'] ?? '',
    );
  }
}
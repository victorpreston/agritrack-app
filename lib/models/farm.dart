class Farm {
  final String id;
  final String name;
  final String location;
  final String totalArea;
  final String ownerId;

  Farm({
    this.id = '',
    required this.name,
    required this.location,
    required this.totalArea,
    required this.ownerId,
  });

  Map<String, dynamic> toJson() {
    final json = {
      'name': name,
      'location': location,
      'total_area': totalArea,
      'owner_id': ownerId,
    };

    if (id.isNotEmpty) {
      json['id'] = id;
    }

    return json;
  }

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
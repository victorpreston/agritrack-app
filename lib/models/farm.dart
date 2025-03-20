class Farm {
  final String id;
  final String name;
  final String location;
  final String totalArea;
  final String ownerId;

  Farm({
    required this.id,
    required this.name,
    required this.location,
    required this.totalArea,
    required this.ownerId,
  });

  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      totalArea: json['total_area'],
      ownerId: json['owner_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'total_area': totalArea,
      'owner_id': ownerId,
    };
  }
}
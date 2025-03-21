class Crop {
  final String id;
  final String name;
  final String farmId;
  final String type;

  Crop({
    this.id = '',
    required this.name,
    required this.farmId,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    final json = {
      'name': name,
      'type': type,
    };

    // Only include ID if it's not empty
    if (id.isNotEmpty) {
      json['id'] = id;
    }

    // Only include farmId if it's not empty
    if (farmId.isNotEmpty) {
      json['farm_id'] = farmId;
    }

    return json;
  }

  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      farmId: json['farm_id'] ?? '',
      type: json['type'] ?? '',
    );
  }
}
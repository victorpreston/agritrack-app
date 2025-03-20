class Crop {
  final String id;
  final String name;
  final String farmId;
  final String type;

  Crop({
    required this.id,
    required this.name,
    required this.farmId,
    required this.type,
  });

  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      id: json['id'],
      name: json['name'],
      farmId: json['farm_id'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'farm_id': farmId,
      'type': type,
    };
  }
}
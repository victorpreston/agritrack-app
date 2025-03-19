class Treatment {
  final int id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final List<String> targetDiseases;
  final String usage;

  Treatment({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.targetDiseases,
    required this.usage,
  });
}
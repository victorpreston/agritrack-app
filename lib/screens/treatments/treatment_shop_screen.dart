import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'treatment_detail_screen.dart';
import '../../models/treatment.dart';

class TreatmentShopScreen extends StatefulWidget {
  const TreatmentShopScreen({super.key});

  @override
  State<TreatmentShopScreen> createState() => _TreatmentShopScreenState();
}

class _TreatmentShopScreenState extends State<TreatmentShopScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Fungicides', 'Insecticides', 'Herbicides', 'Fertilizers'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Treatment Shop'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.shopping_cart_outlined,
              size: 24,
              color: AppTheme.primaryColor,
            ),
            onPressed: () {
              // Navigate to cart
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search treatments...',
                prefixIcon: const Icon(
                  Icons.search,
                  size: 24,
                  color: Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      }
                    },
                    backgroundColor: Colors.grey.shade200,
                    selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primaryColor : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedCategory == 'All' ? 'All Treatments' : _selectedCategory,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _getFilteredTreatments().length,
                      itemBuilder: (context, index) {
                        final treatment = _getFilteredTreatments()[index];
                        return _buildTreatmentCard(treatment);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Treatment> _getFilteredTreatments() {
    if (_selectedCategory == 'All') {
      return allTreatments;
    } else {
      return allTreatments.where((t) => t.category == _selectedCategory).toList();
    }
  }

  Widget _buildTreatmentCard(Treatment treatment) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TreatmentDetailScreen(treatment: treatment),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.asset(
                treatment.imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    treatment.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    treatment.category,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${treatment.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final List<Treatment> allTreatments = [
  Treatment(
    id: 1,
    name: 'BioFungal Pro',
    description: 'An organic fungicide effective against a wide range of fungal diseases in crops.',
    price: 29.99,
    category: 'Fungicides',
    imageUrl: 'assets/detection/antifungal.png',
    targetDiseases: ['Northern Leaf Blight', 'Gray Leaf Spot'],
    usage: 'Mix 10ml per gallon of water and spray every 7-10 days.',
  ),
  Treatment(
    id: 2,
    name: 'InsectGuard Plus',
    description: 'A broad-spectrum insecticide that controls a variety of crop-damaging insects.',
    price: 34.99,
    category: 'Insecticides',
    imageUrl: 'assets/detection/antifungal.png',
    targetDiseases: ['Corn Earworm', 'Aphids'],
    usage: 'Apply 5ml per gallon of water.',
  ),
];

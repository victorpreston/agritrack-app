import 'package:flutter/material.dart';
import '../../widgets/disease_history_card.dart';

class DiseaseDetectionTab extends StatefulWidget {
  const DiseaseDetectionTab({super.key});

  @override
  State<DiseaseDetectionTab> createState() => _DiseaseDetectionTabState();
}

class _DiseaseDetectionTabState extends State<DiseaseDetectionTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disease Detection'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Camera Section
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Take a photo of your crop',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Our AI will analyze and detect any diseases',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            // Take photo with camera
                          },
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Take Photo'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          onPressed: () {
                            // Upload from gallery
                          },
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Upload'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tips Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tips for Better Detection',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTipItem('Take clear, well-lit photos of the affected area'),
                    _buildTipItem('Include both healthy and diseased parts for comparison'),
                    _buildTipItem('Avoid shadows and glare on the plant surface'),
                    _buildTipItem('Take multiple photos from different angles if needed'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Detection History
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detection History',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const DiseaseHistoryCard(
                cropName: 'Tomato',
                diseaseName: 'Early Blight',
                date: '2 days ago',
                severity: 'Moderate',
                imagePath: 'assets/detection/leaf.png',
              ),
              const SizedBox(height: 12),
              const DiseaseHistoryCard(
                cropName: 'Potato',
                diseaseName: 'Late Blight',
                date: '1 week ago',
                severity: 'Severe',
                imagePath: 'assets/detection/leaf.png',
              ),
              const SizedBox(height: 12),
              const DiseaseHistoryCard(
                cropName: 'Corn',
                diseaseName: 'Northern Leaf Blight',
                date: '2 weeks ago',
                severity: 'Mild',
                imagePath: 'assets/detection/leaf.png',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
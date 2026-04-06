import 'package:flutter/material.dart';
import 'plant.dart';

class PlantDetailScreen extends StatelessWidget {
  final Plant plant;

  const PlantDetailScreen({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    final daysSinceWatered = DateTime.now()
        .difference(plant.lastWatered)
        .inDays;
    final needsWater = daysSinceWatered >= plant.wateringDays;

    return Scaffold(
      body: Stack(
        children: [
          Hero(
            tag: plant.name,
            child: Image.network(
              plant.imageUrl,
              height: 400,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.green[200],
                child: const Icon(Icons.local_florist, size: 100),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.55,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant.name,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      plant.species,
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Icon(
                          needsWater ? Icons.warning_amber : Icons.check_circle,
                          color: needsWater ? Colors.orange : Colors.green,
                          size: 40,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          needsWater
                              ? 'Услах цаг болжээ! 🚰'
                              : 'Усалгаа хэвийн 🌿',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Усалсан гэж тэмдэглэлээ! 🌱'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.water_drop),
                      label: const Text('Усалсан гэж тэмдэглэх'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

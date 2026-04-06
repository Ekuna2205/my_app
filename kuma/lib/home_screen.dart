import 'package:flutter/material.dart';
import 'plant.dart';
import 'detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // const-г устгасан – DateTime const биш учраас list ч const байж болохгүй
  // const-г эндээс устга (list дээр)
  final List<Plant> plants = [
    // <-- const байхгүй болго!
    Plant(
      // <-- const байхгүй
      name: "Monstera",
      species: "Deliciosa",
      imageUrl: "https://picsum.photos/seed/monstera/400",
      wateringDays: 7,
      lastWatered: DateTime(2025, 12, 10),
    ),
    Plant(
      name: "Snake Plant",
      species: "Trifasciata",
      imageUrl: "https://picsum.photos/seed/snake/400",
      wateringDays: 14,
      lastWatered: DateTime(2025, 12, 5),
    ),
    Plant(
      name: "Fiddle Leaf Fig",
      species: "Lyrata",
      imageUrl: "https://picsum.photos/seed/fiddle/400",
      wateringDays: 10,
      lastWatered: DateTime(2025, 12, 8),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Миний Ургамлууд'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: plants.length,
          itemBuilder: (context, index) {
            final plant = plants[index];
            return PlantCard(plant: plant);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Шинэ ургамал нэмэх удахгүй! 🌱')),
          );
        },
        backgroundColor: Colors.green[600],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class PlantCard extends StatelessWidget {
  final Plant plant;

  const PlantCard({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PlantDetailScreen(plant: plant)),
        );
      },
      child: Hero(
        tag: plant.name,
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Image.network(
                  plant.imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.green[100],
                    child: const Icon(Icons.local_florist, size: 60),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      plant.species,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.water_drop,
                          color: Colors.blue[600],
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text('${plant.wateringDays} хоногт нэг'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

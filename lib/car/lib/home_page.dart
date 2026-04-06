import 'package:flutter/material.dart';

import '../common/service.dart';
import '../common/service_card.dart';
import '../common/car_type.dart';
import 'select_time_page.dart';
import 'my_bookings_page.dart';
import 'admin_login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CarType? _selectedCarType;

  static final List<Service> services = [
    Service(
      id: '1',
      name: 'Гадна угаалга',
      durationMinutes: 20,
      price: 25000,
      description: 'Машины гадна талыг цэвэрлэнэ',
    ),
    Service(
      id: '2',
      name: 'Иж бүрэн угаалга',
      durationMinutes: 50,
      price: 55000,
      description: 'Гадна + дотор + хөдөлгүүр',
    ),
    Service(
      id: '3',
      name: 'Вакс + өнгөлгөө',
      durationMinutes: 80,
      price: 90000,
      description: 'Гялалзсан өнгөлгөө + вакс',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Авто угаалга',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Админ',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminLoginPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'Миний захиалгууд',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyBookingsPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D47A1),
              Color(0xFF42A5F5),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Машины ангилал гарчиг
                const Text(
                  'Машины ангилал сонгоно уу',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 12),

                /// Машины төрөл сонгох хэсэг
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: CarType.allTypes.length,
                    itemBuilder: (context, index) {
                      final type = CarType.allTypes[index];
                      final isSelected = _selectedCarType == type;

                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ChoiceChip(
                          label: Text(type.name),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCarType = selected ? type : null;
                            });
                          },
                          selectedColor: Colors.white,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          labelStyle: const TextStyle(
                            color: Color(0xFF0D47A1), // бүгд ижил цэнхэр
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),

                /// Үйлчилгээ гарчиг
                const Text(
                  'Үйлчилгээ сонгоно уу',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 12),

                /// Үйлчилгээний жагсаалт
                Expanded(
                  child: ListView.builder(
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];

                      return Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        margin: const EdgeInsets.only(bottom: 14),
                        child: ServiceCard(
                          service: service,
                          onTap: _selectedCarType == null
                              ? () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Эхлээд машины ангилал сонгоно уу'),
                                    ),
                                  );
                                }
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SelectTimePage(
                                        service: service,
                                        carType: _selectedCarType!,
                                      ),
                                    ),
                                  );
                                },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

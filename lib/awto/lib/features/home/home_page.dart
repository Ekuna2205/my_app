import 'package:flutter/material.dart';

import '../../../common/models/service.dart';
import '../../../common/widgets/service_card.dart';
import '../booking/select_time_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key}); // ← const-г АРИЛГАЛАА

  late final List<Service> _services;

  @override
  Widget build(BuildContext context) {
    _services = const [
      Service(
        id: '1',
        name: 'Гадна угаалга',
        durationMinutes: 20,
        price: 25000,
        description: 'Машины гадна талыг бүрэн цэвэрлэнэ',
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
      Service(
        id: '4',
        name: 'Хөдөлгүүр угаалга',
        durationMinutes: 40,
        price: 35000,
        description: 'Хөдөлгүүрийг гүн цэвэрлэнэ',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Авто угаалга - Цаг захиалга'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Үйлчилгээ сонгоно уу',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: _services.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final service = _services[index];
                  return ServiceCard(
                    service: service,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SelectTimePage(service: service),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

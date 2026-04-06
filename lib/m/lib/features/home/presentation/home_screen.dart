import 'package:flutter/material.dart';
import '../../manual_wash/screens/wash_list_screen.dart'; // жагсаалт руу холбоно
// import '../../manual_wash/screens/wash_form_screen.dart'; // шаардлагатай бол нэм

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Угаалгын Удирдлага'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Тавтай морил!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            ElevatedButton.icon(
              icon: const Icon(Icons.list_alt, size: 28),
              label: const Text(
                'Өнөөдрийн угаалга харах',
                style: TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WashListScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle, size: 28),
              label: const Text(
                'Шинэ угаалга бүртгэх',
                style: TextStyle(fontSize: 18),
              ),
              onPressed: () {
                // Navigator.push(context, MaterialPageRoute(builder: (_) => const WashFormScreen()));
                // Одоогоор байхгүй бол comment хэвээр үлдээ
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            const SizedBox(height: 40),
            const Text(
              'Дараа нэмэх: Self-service QR, Тайлан, Ажилчин удирдах',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

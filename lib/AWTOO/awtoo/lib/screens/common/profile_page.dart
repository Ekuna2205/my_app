import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final String name;

  const ProfilePage({super.key, required this.name});

  Widget buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),

            const SizedBox(height: 20),

            Text(
              name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            buildInfoTile(icon: Icons.person, title: "Нэр", value: name),

            buildInfoTile(icon: Icons.work, title: "Role", value: "Admin"),

            buildInfoTile(
              icon: Icons.phone_android,
              title: "System",
              value: "Auto Wash Management",
            ),
          ],
        ),
      ),
    );
  }
}

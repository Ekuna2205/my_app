import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool darkMode = false;
  bool notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "General Settings",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          SwitchListTile(
            title: const Text("Dark Mode"),
            value: darkMode,
            onChanged: (value) {
              setState(() {
                darkMode = value;
              });
            },
            secondary: const Icon(Icons.dark_mode),
          ),

          SwitchListTile(
            title: const Text("Notifications"),
            value: notifications,
            onChanged: (value) {
              setState(() {
                notifications = value;
              });
            },
            secondary: const Icon(Icons.notifications),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.cleaning_services),
            title: const Text("Clear Cache"),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("About"),
            subtitle: const Text("Auto Wash System v1.0"),
          ),
        ],
      ),
    );
  }
}

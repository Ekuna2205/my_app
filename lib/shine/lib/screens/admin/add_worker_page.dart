import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class AddWorkerPage extends StatefulWidget {
  const AddWorkerPage({super.key});

  @override
  State<AddWorkerPage> createState() => _AddWorkerPageState();
}

class _AddWorkerPageState extends State<AddWorkerPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool loading = false;

  Future<void> addWorker() async {
    final String name = nameController.text.trim();
    final String username = usernameController.text.trim();
    final String password = passwordController.text.trim();

    if (name.isEmpty || username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Бүх талбарыг бөглөнө үү')));
      return;
    }

    setState(() => loading = true);

    try {
      await DatabaseHelper.instance.addWorker(
        fullName: name,
        username: username,
        password: password,
      );

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Амжилттай'),
          content: const Text('Ажилчин бүртгэгдлээ'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username давхардсан байна')),
      );
    }

    setState(() => loading = false);
  }

  Widget buildField({
    required TextEditingController controller,
    required String label,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ажилчин нэмэх'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(height: 10),

            buildField(controller: nameController, label: 'Овог нэр'),

            const SizedBox(height: 14),

            buildField(controller: usernameController, label: 'Нэвтрэх нэр'),

            const SizedBox(height: 14),

            buildField(
              controller: passwordController,
              label: 'Нууц үг',
              isPassword: true,
            ),

            const SizedBox(height: 24),

            loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: addWorker,
                    icon: const Icon(Icons.add),
                    label: const Text('Бүртгэх'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

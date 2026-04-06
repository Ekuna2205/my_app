import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class AddWorkerPage extends StatefulWidget {
  const AddWorkerPage({super.key});

  @override
  State<AddWorkerPage> createState() => _AddWorkerPageState();
}

class _AddWorkerPageState extends State<AddWorkerPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool loading = false;
  bool hidePassword = true;

  Future<void> saveWorker() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => loading = true);

    try {
      await DatabaseHelper.instance.addWorker(
        fullName: fullNameController.text.trim(),
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ажилчин амжилттай бүртгэгдлээ')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      String message = 'Алдаа гарлаа';

      final String errorText = e.toString().toLowerCase();

      if (errorText.contains('unique') || errorText.contains('username')) {
        message = 'Нэвтрэх нэр давхцаж байна';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  String? validateRequired(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label оруулна уу';
    }
    return null;
  }

  @override
  void dispose() {
    fullNameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget buildTopCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ажилчин бүртгэх',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Шинэ ажилчны мэдээллийг оруулна уу',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
              controller: fullNameController,
              validator: (value) => validateRequired(value, 'Овог нэр'),
              decoration: const InputDecoration(
                labelText: 'Овог нэр',
                prefixIcon: Icon(Icons.badge),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: usernameController,
              validator: (value) => validateRequired(value, 'Нэвтрэх нэр'),
              decoration: const InputDecoration(
                labelText: 'Нэвтрэх нэр',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: passwordController,
              obscureText: hidePassword,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Нууц үг оруулна уу';
                }
                if (value.trim().length < 4) {
                  return 'Нууц үг хамгийн багадаа 4 тэмдэгт байна';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Нууц үг',
                prefixIcon: const Icon(Icons.lock),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      hidePassword = !hidePassword;
                    });
                  },
                  icon: Icon(
                    hidePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: loading ? null : saveWorker,
                icon: loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(loading ? 'Хадгалж байна...' : 'Хадгалах'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.15)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.blue),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Ажилчин бүртгэгдэх үед worker code автоматаар үүснэ. '
              'Жишээ нь: 26A01, 26A02 ...',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ажилчин бүртгэх'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildTopCard(),
          const SizedBox(height: 16),
          buildInfoCard(),
          const SizedBox(height: 16),
          buildFormCard(),
        ],
      ),
    );
  }
}

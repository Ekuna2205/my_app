import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../theme/app_theme.dart';

class CustomerRegisterPage extends StatefulWidget {
  const CustomerRegisterPage({super.key});

  @override
  State<CustomerRegisterPage> createState() => _CustomerRegisterPageState();
}

class _CustomerRegisterPageState extends State<CustomerRegisterPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController plateController = TextEditingController();

  bool obscurePassword = true;
  bool loading = false;

  String selectedType = 'Жижиг';

  final List<String> carTypes = <String>[
    'Жижиг',
    'Дунд',
    'Том',
    'Гэр бүлийн',
    'Ачааны',
  ];

  String? validateText(String? v, String label) {
    if ((v ?? '').trim().isEmpty) {
      return '$label оруулна уу';
    }
    return null;
  }

  String? validatePhone(String? v) {
    final String value = (v ?? '').trim();
    if (value.isEmpty) {
      return 'Утас оруулна уу';
    }
    if (value.length < 8) {
      return 'Утасны дугаар буруу байна';
    }
    return null;
  }

  String? validatePassword(String? v) {
    final String value = (v ?? '').trim();
    if (value.isEmpty) {
      return 'Нууц үг оруулна уу';
    }
    if (value.length < 4) {
      return 'Нууц үг хамгийн багадаа 4 тэмдэгт байна';
    }
    return null;
  }

  Future<void> register() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    setState(() {
      loading = true;
    });

    try {
      await DatabaseHelper.instance.addCustomer(
        fullName: nameController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text.trim(),
        carPlate: '${plateController.text.trim()} / $selectedType',
      );

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Амжилттай бүртгэгдлээ')));

      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Энэ утасны дугаар өмнө нь бүртгэгдсэн байна'),
        ),
      );
    }
  }

  Widget buildBackground({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1D4ED8), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(child: child),
    );
  }

  Widget buildHeader() {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person_add, color: Colors.white, size: 46),
        ),
        const SizedBox(height: 14),
        const Text(
          'Бүртгүүлэх',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Шинэ хэрэглэгчийн бүртгэл',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

  Widget buildCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
              controller: nameController,
              validator: (v) => validateText(v, 'Нэр'),
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person),
                labelText: 'Нэр',
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: phoneController,
              validator: validatePhone,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.phone),
                labelText: 'Утас',
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              validator: validatePassword,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock),
                labelText: 'Нууц үг',
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                  icon: Icon(
                    obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: plateController,
              validator: (v) => validateText(v, 'Машины дугаар'),
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.pin),
                labelText: 'Машины дугаар',
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selectedType,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.directions_car),
                labelText: 'Машины төрөл',
                filled: true,
                fillColor: Colors.white,
              ),
              items: carTypes.map((String e) {
                return DropdownMenuItem<String>(value: e, child: Text(e));
              }).toList(),
              onChanged: (String? v) {
                if (v == null) return;
                setState(() {
                  selectedType = v;
                });
              },
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                children: [
                  const Icon(Icons.directions_car, color: Colors.white),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Сонгосон төрөл',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Text(
                    selectedType,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: loading ? null : register,
                child: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Бүртгүүлэх',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Аль хэдийн бүртгэлтэй юу? Нэвтрэх',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                children: [
                  buildHeader(),
                  const SizedBox(height: 20),
                  buildCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

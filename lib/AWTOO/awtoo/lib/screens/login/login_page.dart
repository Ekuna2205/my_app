import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import '../admin/admin_dashboard.dart';
import '../customer/customer_dashboard.dart';
import '../customer/customer_register_page.dart';
import '../public/booking_calendar_page.dart';
import '../worker/worker_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String role = 'customer';
  bool loading = false;
  bool rememberMe = true;
  bool obscurePassword = true;

  Future<void> login() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    final String username = usernameController.text.trim();
    final String password = passwordController.text.trim();

    setState(() {
      loading = true;
    });

    try {
      if (role == 'admin') {
        if (username == 'admin' && password == '1234') {
          await SessionService.saveSession(
            role: 'admin',
            identifier: 'admin',
            displayName: 'Administrator',
            rememberMe: rememberMe,
          );

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboard()),
          );
          return;
        } else {
          showMessage('Админ нэр эсвэл нууц үг буруу байна');
        }
      }

      if (role == 'worker') {
        final Map<String, dynamic>? worker = await DatabaseHelper.instance
            .loginWorker(username: username, password: password);

        if (worker != null) {
          await DatabaseHelper.instance.setWorkerActiveByUsername(
            username: username,
            isActive: true,
          );

          await SessionService.saveSession(
            role: 'worker',
            identifier: username,
            displayName: worker['fullName']?.toString() ?? '',
            rememberMe: rememberMe,
          );

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => WorkerDashboard(
                workerName: worker['fullName']?.toString() ?? '',
                workerUsername: username,
              ),
            ),
          );
          return;
        } else {
          showMessage('Ажилчны нэр эсвэл нууц үг буруу байна');
        }
      }

      if (role == 'customer') {
        final Map<String, dynamic>? customer = await DatabaseHelper.instance
            .loginCustomer(phone: username, password: password);

        if (customer != null) {
          await SessionService.saveSession(
            role: 'customer',
            identifier: customer['phone']?.toString() ?? '',
            displayName: customer['fullName']?.toString() ?? '',
            rememberMe: rememberMe,
          );

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  CustomerDashboard(phone: customer['phone']?.toString() ?? ''),
            ),
          );
          return;
        } else {
          showMessage('Утасны дугаар эсвэл нууц үг буруу байна');
        }
      }
    } catch (_) {
      showMessage('Нэвтрэх үед алдаа гарлаа');
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  String? validateUsername(String? value) {
    final String v = value?.trim() ?? '';
    if (v.isEmpty) {
      return role == 'customer'
          ? 'Утасны дугаараа оруулна уу'
          : 'Нэвтрэх нэрээ оруулна уу';
    }

    if (role == 'customer' && v.length < 8) {
      return 'Утасны дугаар буруу байна';
    }

    if (role != 'customer' && v.length < 3) {
      return 'Хэт богино байна';
    }

    return null;
  }

  String? validatePassword(String? value) {
    final String v = value?.trim() ?? '';
    if (v.isEmpty) return 'Нууц үгээ оруулна уу';
    if (v.length < 4) return 'Нууц үг хамгийн багадаа 4 тэмдэгт байна';
    return null;
  }

  Widget buildRoleCard({
    required String value,
    required String label,
    required IconData icon,
  }) {
    final bool selected = role == value;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          setState(() {
            role = value;
            usernameController.clear();
            passwordController.clear();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: selected ? Colors.white : Colors.white24),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected ? AppColors.primary : Colors.white,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected ? AppColors.primary : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget topArea() {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24),
          ),
          child: const Icon(
            Icons.local_car_wash,
            color: Colors.white,
            size: 50,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Шинэ авто угаалга',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Ухаалаг захиалга, хурдан үйлчилгээ',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

  Widget loginCard() {
    final bool isCustomer = role == 'customer';

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
            Row(
              children: [
                buildRoleCard(
                  value: 'customer',
                  label: 'Хэрэглэгч',
                  icon: Icons.person,
                ),
                const SizedBox(width: 10),
                buildRoleCard(
                  value: 'worker',
                  label: 'Ажилчин',
                  icon: Icons.engineering,
                ),
                const SizedBox(width: 10),
                buildRoleCard(
                  value: 'admin',
                  label: 'Aдмин',
                  icon: Icons.admin_panel_settings,
                ),
              ],
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: usernameController,
              validator: validateUsername,
              keyboardType: isCustomer
                  ? TextInputType.phone
                  : TextInputType.text,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  isCustomer ? Icons.phone : Icons.person_outline,
                ),
                labelText: isCustomer ? 'Утасны дугаар' : 'Нэвтрэх нэр',
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
                prefixIcon: const Icon(Icons.lock_outline),
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
            const SizedBox(height: 6),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: rememberMe,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: Colors.white,
              checkColor: AppColors.primary,
              title: const Text(
                'Remember me',
                style: TextStyle(color: Colors.white),
              ),
              onChanged: (bool? value) {
                setState(() {
                  rememberMe = value ?? true;
                });
              },
            ),
            const SizedBox(height: 6),
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
                onPressed: loading ? null : login,
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Нэвтрэх',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),

            if (isCustomer) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CustomerRegisterPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Бүртгүүлэх',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 10),
            const Divider(color: Colors.white24),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BookingCalendarPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.event_available),
                label: const Text('Нэвтрэхгүйгээр цаг захиалах'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1D4ED8), Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  children: [
                    topArea(),
                    const SizedBox(height: 22),
                    loginCard(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

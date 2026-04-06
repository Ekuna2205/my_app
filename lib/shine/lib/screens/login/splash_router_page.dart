import 'package:flutter/material.dart';
import '../../services/session_service.dart';
import '../admin/admin_dashboard.dart';
import '../customer/customer_dashboard.dart';
import '../worker/worker_dashboard.dart';
import 'login_page.dart';

class SplashRouterPage extends StatefulWidget {
  const SplashRouterPage({super.key});

  @override
  State<SplashRouterPage> createState() => _SplashRouterPageState();
}

class _SplashRouterPageState extends State<SplashRouterPage> {
  @override
  void initState() {
    super.initState();
    routeUser();
  }

  Future<void> routeUser() async {
    final Map<String, dynamic> session = await SessionService.getSession();

    if (!mounted) return;

    final bool loggedIn = session['loggedIn'] as bool;
    final bool rememberMe = session['rememberMe'] as bool;
    final String role = session['role'] as String;
    final String identifier = session['identifier'] as String;
    final String displayName = session['displayName'] as String;

    if (!loggedIn || !rememberMe) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }

    if (role == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboard()),
      );
      return;
    }

    if (role == 'worker') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => WorkerDashboard(
            workerName: displayName,
            workerUsername: identifier,
          ),
        ),
      );
      return;
    }

    if (role == 'customer') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => CustomerDashboard(phone: identifier)),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';

class CustomerProfilePage extends StatefulWidget {
  final String phone;

  const CustomerProfilePage({super.key, required this.phone});

  @override
  State<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController carPlateController = TextEditingController();

  bool loading = true;
  bool obscurePassword = true;
  int? customerId;

  String selectedVehicleType = 'Жижиг';

  List<Map<String, dynamic>> washHistory = <Map<String, dynamic>>[];
  int totalWashCount = 0;
  int totalSpent = 0;
  int paidCount = 0;
  int unpaidCount = 0;

  final List<String> vehicleTypes = <String>[
    'Жижиг',
    'Дунд',
    'Том',
    'Гэр бүлийн',
    'Ачааны',
  ];

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  String normalizeVehicleType(String raw) {
    final String value = raw.trim();

    if (vehicleTypes.contains(value)) {
      return value;
    }

    return 'Жижиг';
  }

  Future<void> loadProfile() async {
    final Map<String, dynamic>? customer = await DatabaseHelper.instance
        .getCustomerByPhone(widget.phone);

    final Map<String, dynamic> stats = await DatabaseHelper.instance
        .getCustomerWashStatsByPhone(widget.phone);

    final List<Map<String, dynamic>> history = await DatabaseHelper.instance
        .getCustomerWashHistoryByPhone(widget.phone);

    if (!mounted) return;

    if (customer != null) {
      final String plate = customer['carPlate']?.toString() ?? '';

      String plateNumber = plate;
      String type = 'Жижиг';

      if (plate.contains('/')) {
        final List<String> parts = plate.split('/');
        plateNumber = parts[0].trim();
        if (parts.length > 1) {
          type = parts[1].trim();
        }
      }

      type = normalizeVehicleType(type);

      setState(() {
        customerId = customer['id'];
        nameController.text = customer['fullName']?.toString() ?? '';
        phoneController.text = customer['phone']?.toString() ?? '';
        passwordController.text = customer['password']?.toString() ?? '';
        carPlateController.text = plateNumber;
        selectedVehicleType = type;

        washHistory = history;
        totalWashCount = ((stats['totalWashCount'] as num?) ?? 0).toInt();
        totalSpent = ((stats['totalSpent'] as num?) ?? 0).toInt();
        paidCount = ((stats['paidCount'] as num?) ?? 0).toInt();
        unpaidCount = ((stats['unpaidCount'] as num?) ?? 0).toInt();

        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> updateProfile() async {
    if (customerId == null) return;

    await DatabaseHelper.instance.updateCustomerProfile(
      id: customerId!,
      fullName: nameController.text.trim(),
      phone: phoneController.text.trim(),
      password: passwordController.text.trim(),
      carPlate: '${carPlateController.text.trim()} / $selectedVehicleType',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Амжилттай хадгалагдлаа')));

    await loadProfile();
  }

  Map<String, String> splitWashType(String value) {
    if (value.contains('/')) {
      final List<String> parts = value.split('/');
      final String washType = parts.isNotEmpty ? parts[0].trim() : '';
      final String carType = parts.length > 1 ? parts[1].trim() : '';
      return <String, String>{'washType': washType, 'carType': carType};
    }

    return <String, String>{'washType': value, 'carType': '-'};
  }

  String formatDate(String raw) {
    if (raw.isEmpty) return '-';
    if (raw.length >= 16) {
      return raw.substring(0, 16).replaceFirst('T', ' ');
    }
    return raw;
  }

  Color paymentColor(String status) {
    return status == 'paid' ? AppColors.success : AppColors.danger;
  }

  String paymentText(String status) {
    return status == 'paid' ? 'Төлсөн' : 'Төлөөгүй';
  }

  Widget buildPageBackground({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3B0764), Color(0xFF7E22CE), Color(0xFFBE185D)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(child: child),
    );
  }

  Widget buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9333EA), Color(0xFFC026D3), Color(0xFFE11D48)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.24),
            blurRadius: 18,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 34,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, size: 34, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nameController.text.isEmpty
                      ? 'Хэрэглэгч'
                      : nameController.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  phoneController.text,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMiniStat({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStatsCard() {
    return AppCard(
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.analytics, color: AppColors.secondary),
              SizedBox(width: 8),
              Text(
                'Миний статистик',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              buildMiniStat(
                title: 'Нийт угаалт',
                value: '$totalWashCount',
                icon: Icons.local_car_wash,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 10),
              buildMiniStat(
                title: 'Нийт зардал',
                value: '$totalSpent₮',
                icon: Icons.payments,
                color: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              buildMiniStat(
                title: 'Төлсөн',
                value: '$paidCount',
                icon: Icons.check_circle,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              buildMiniStat(
                title: 'Төлөөгүй',
                value: '$unpaidCount',
                icon: Icons.error,
                color: AppColors.danger,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textLight),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget buildHistorySection() {
    return AppCard(
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.history, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Миний угаалтын түүх',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (washHistory.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Угаалтын түүх алга'),
            )
          else
            ...List.generate(washHistory.length, (int index) {
              final Map<String, dynamic> item = washHistory[index];
              final String carNumber = item['carNumber']?.toString() ?? '';
              final String rawWashType = item['washType']?.toString() ?? '';
              final int price = ((item['price'] as num?) ?? 0).toInt();
              final String date = item['date']?.toString() ?? '';
              final String paymentStatus =
                  item['paymentStatus']?.toString() ?? 'unpaid';

              final Map<String, String> parsed = splitWashType(rawWashType);
              final String washType = parsed['washType'] ?? '-';
              final String carType = parsed['carType'] ?? '-';

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.directions_car, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            carNumber,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          paymentText(paymentStatus),
                          style: TextStyle(
                            color: paymentColor(paymentStatus),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    infoRow('Угаалгын төрөл', washType),
                    infoRow('Машины төрөл', carType),
                    infoRow('Үнэ', '$price₮'),
                    infoRow('Огноо', formatDate(date)),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget buildFormSection() {
    return AppCard(
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.edit, color: AppColors.success),
              SizedBox(width: 8),
              Text(
                'Профайл засах',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.person),
              labelText: 'Нэр',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: phoneController,
            readOnly: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.phone),
              labelText: 'Утас',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: passwordController,
            obscureText: obscurePassword,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock),
              labelText: 'Нууц үг',
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
          TextField(
            controller: carPlateController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.pin),
              labelText: 'Машины дугаар',
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: vehicleTypes.contains(selectedVehicleType)
                ? selectedVehicleType
                : null,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.directions_car),
              labelText: 'Машины төрөл',
            ),
            items: vehicleTypes
                .map(
                  (String e) =>
                      DropdownMenuItem<String>(value: e, child: Text(e)),
                )
                .toList(),
            onChanged: (String? value) {
              if (value == null) return;
              setState(() {
                selectedVehicleType = value;
              });
            },
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.directions_car, color: AppColors.secondary),
                const SizedBox(width: 10),
                const Expanded(child: Text('Сонгосон төрөл')),
                Text(
                  selectedVehicleType,
                  style: const TextStyle(
                    color: AppColors.secondary,
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
                backgroundColor: AppColors.secondary,
              ),
              onPressed: updateProfile,
              child: const Text(
                'Хадгалах',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    carPlateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профайл'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: loadProfile, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: buildPageBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                children: [
                  buildHeader(),
                  const SizedBox(height: 14),
                  buildStatsCard(),
                  const SizedBox(height: 14),
                  buildHistorySection(),
                  const SizedBox(height: 14),
                  buildFormSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

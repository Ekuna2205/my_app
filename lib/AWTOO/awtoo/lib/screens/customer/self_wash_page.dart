import 'dart:async';
import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../payment/payment_page.dart';

class SelfWashPage extends StatefulWidget {
  final String? customerPhone;

  const SelfWashPage({super.key, this.customerPhone});

  @override
  State<SelfWashPage> createState() => _SelfWashPageState();
}

class _SelfWashPageState extends State<SelfWashPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController plateController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  String selectedType = 'Жижиг';
  int seconds = 0;
  Timer? timer;
  int basePrice = 15000;
  int totalPrice = 15000;
  bool isRunning = false;

  final List<String> carTypes = <String>[
    'Жижиг',
    'Дунд',
    'Том',
    'Гэр бүлийн',
    'Ачааны',
  ];

  int getPrice(String type) {
    switch (type) {
      case 'Жижиг':
        return 15000;
      case 'Дунд':
        return 20000;
      case 'Том':
        return 25000;
      case 'Гэр бүлийн':
        return 28000;
      case 'Ачааны':
        return 35000;
      default:
        return 15000;
    }
  }

  String? validatePlate(String? value) {
    final String v = value?.trim() ?? '';
    if (v.isEmpty) return 'Машины дугаар оруулна уу';
    return null;
  }

  void startWash() {
    if (!(formKey.currentState?.validate() ?? false)) return;

    basePrice = getPrice(selectedType);

    setState(() {
      isRunning = true;
      seconds = 0;
      totalPrice = basePrice;
    });

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        seconds++;
        final int minutes = seconds ~/ 60;
        if (minutes > 60) {
          totalPrice = basePrice + ((minutes - 60) * 1000);
        } else {
          totalPrice = basePrice;
        }
      });
    });
  }

  Future<void> finishWash() async {
    timer?.cancel();

    final int recordId = await DatabaseHelper.instance.insertWashRecord({
      'carNumber': plateController.text.trim().toUpperCase(),
      'workerName': 'Customer Self Wash',
      'washType': 'Өөрөө угаах / $selectedType',
      'price': totalPrice,
      'date': DateTime.now().toIso8601String(),
      'paymentStatus': 'unpaid',
      'customerPhone': widget.customerPhone,
    });

    if (!mounted) return;

    final dynamic paid = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(amount: totalPrice, recordId: recordId),
      ),
    );

    if (paid == true && mounted) {
      resetForm();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Төлбөр амжилттай хийгдлээ')),
      );
    }
  }

  void resetForm() {
    setState(() {
      isRunning = false;
      seconds = 0;
      selectedType = 'Жижиг';
      basePrice = getPrice(selectedType);
      totalPrice = basePrice;
      plateController.clear();
      noteController.clear();
    });
  }

  String formatTime() {
    final int m = seconds ~/ 60;
    final int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Widget buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF14532D), Color(0xFF16A34A), Color(0xFF22C55E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Өөрөө угаах',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Цаг автоматаар явж, төлбөр бодогдоно',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget buildTimerCard() {
    return AppCard(
      child: Column(
        children: [
          const Text(
            'Угаалтын хугацаа',
            style: TextStyle(color: AppColors.textLight, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            formatTime(),
            style: const TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPriceCard() {
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.success.withValues(alpha: 0.15),
            child: const Icon(Icons.payments, color: AppColors.success),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Нийт төлбөр'),
                SizedBox(height: 4),
                Text(
                  '60 минутаас хойш минут тутам 1000₮ нэмэгдэнэ',
                  style: TextStyle(fontSize: 12, color: AppColors.textLight),
                ),
              ],
            ),
          ),
          Text(
            '$totalPrice₮',
            style: const TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildActionButton() {
    if (!isRunning) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
          onPressed: startWash,
          icon: const Icon(Icons.play_arrow),
          label: const Text(
            'Эхлүүлэх',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
        onPressed: finishWash,
        icon: const Icon(Icons.check_circle),
        label: const Text(
          'Угааж дууссан',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget buildPageBackground({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF052E16), Color(0xFF14532D), Color(0xFF166534)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(child: child),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    plateController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Өөрөө угаах'), centerTitle: true),
      body: buildPageBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    buildHeader(),
                    const SizedBox(height: 14),
                    AppCard(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: plateController,
                            validator: validatePlate,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.pin),
                              labelText: 'Машины дугаар',
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: selectedType,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.directions_car),
                              labelText: 'Машины төрөл',
                            ),
                            items: carTypes.map((String type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                            onChanged: isRunning
                                ? null
                                : (String? value) {
                                    if (value == null) return;
                                    setState(() {
                                      selectedType = value;
                                      basePrice = getPrice(value);
                                      totalPrice = basePrice;
                                    });
                                  },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: noteController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.edit_note),
                              labelText: 'Нэмэлт тайлбар',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    buildTimerCard(),
                    const SizedBox(height: 12),
                    buildPriceCard(),
                    const SizedBox(height: 14),
                    buildActionButton(),
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

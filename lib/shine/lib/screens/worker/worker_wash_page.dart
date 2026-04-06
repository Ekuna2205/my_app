import 'dart:async';
import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';

class WorkerWashPage extends StatefulWidget {
  final String workerName;

  const WorkerWashPage({super.key, required this.workerName});

  @override
  State<WorkerWashPage> createState() => _WorkerWashPageState();
}

class _WorkerWashPageState extends State<WorkerWashPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController plateController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  String selectedCarType = 'Жижиг';
  String selectedWashType = 'Бүтэн';

  int basePrice = 40000;
  int totalPrice = 40000;
  int seconds = 0;
  Timer? timer;
  bool isRunning = false;

  final List<String> carTypes = <String>[
    'Жижиг',
    'Дунд',
    'Том',
    'Гэр бүлийн',
    'Ачааны',
  ];

  final Map<String, int> washPrices = <String, int>{
    'Бүтэн': 40000,
    'Гадар': 30000,
    'Дотор': 30000,
    'Чэнж': 250000,
    'Тааз': 30000,
    'Шал': 30000,
  };

  String? validatePlate(String? value) {
    final String v = value?.trim() ?? '';
    if (v.isEmpty) {
      return 'Машины дугаар оруулна уу';
    }
    return null;
  }

  void startWash() {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      isRunning = true;
      seconds = 0;
      basePrice = washPrices[selectedWashType] ?? 40000;
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

    await DatabaseHelper.instance.insertWashRecord({
      'carNumber': plateController.text.trim(),
      'workerName': widget.workerName,
      'washType': '$selectedWashType / $selectedCarType',
      'price': totalPrice,
      'date': DateTime.now().toIso8601String(),
      'paymentStatus': 'unpaid',
    });

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Амжилттай'),
        content: Text(
          'Угаалт хадгалагдлаа\n'
          'Машины төрөл: $selectedCarType\n'
          'Угаалгын төрөл: $selectedWashType\n'
          'Нийт үнэ: $totalPrice₮',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              resetForm();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void resetForm() {
    setState(() {
      isRunning = false;
      seconds = 0;
      selectedCarType = 'Жижиг';
      selectedWashType = 'Бүтэн';
      basePrice = washPrices[selectedWashType] ?? 40000;
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

  Widget buildPageBackground({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFF2563EB)],
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
          colors: [Color(0xFF1D4ED8), Color(0xFF2563EB), Color(0xFF60A5FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.24),
            blurRadius: 18,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Машин угаах',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ажилчин: ${widget.workerName}',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget buildSelectedInfoBox() {
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: const Icon(
                  Icons.directions_car,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(child: Text('Сонгосон машины төрөл')),
              Text(
                selectedCarType,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.success.withValues(alpha: 0.12),
                child: const Icon(
                  Icons.cleaning_services,
                  color: AppColors.success,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(child: Text('Сонгосон угаалгын төрөл')),
              Text(
                selectedWashType,
                style: const TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
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
            backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
            child: const Icon(Icons.payments, color: AppColors.secondary),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Нийт үнэ'),
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
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
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
            style: TextStyle(color: AppColors.textLight),
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

  Widget buildActionButton() {
    if (!isRunning) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: startWash,
          icon: const Icon(Icons.play_arrow),
          label: const Text(
            'Угаалт эхлүүлэх',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
        onPressed: finishWash,
        icon: const Icon(Icons.save),
        label: const Text(
          'Угаалт хадгалах',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
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
      appBar: AppBar(title: const Text('Машин угаах'), centerTitle: true),
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
                            initialValue: selectedCarType,
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
                                      selectedCarType = value;
                                    });
                                  },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: selectedWashType,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.cleaning_services),
                              labelText: 'Угаалгын төрөл',
                            ),
                            items: washPrices.keys.map((String type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text('$type - ${washPrices[type]}₮'),
                              );
                            }).toList(),
                            onChanged: isRunning
                                ? null
                                : (String? value) {
                                    if (value == null) return;
                                    setState(() {
                                      selectedWashType = value;
                                      basePrice = washPrices[value] ?? 40000;
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
                    buildSelectedInfoBox(),
                    const SizedBox(height: 12),
                    buildPriceCard(),
                    const SizedBox(height: 12),
                    buildTimerCard(),
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

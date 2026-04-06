import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class PublicBookingPage extends StatefulWidget {
  const PublicBookingPage({super.key});

  @override
  State<PublicBookingPage> createState() => _PublicBookingPageState();
}

class _PublicBookingPageState extends State<PublicBookingPage> {
  DateTime selectedDate = DateTime.now();
  String selectedService = 'Бүтэн';
  String? selectedTime;

  List<String> slots = <String>[];
  List<Map<String, dynamic>> workers = <Map<String, dynamic>>[];
  Map<String, dynamic>? selectedWorker;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController plateController = TextEditingController();

  String get date => selectedDate.toIso8601String().substring(0, 10);

  @override
  void initState() {
    super.initState();
    loadSlots();
  }

  Future<void> loadSlots() async {
    final int duration = DatabaseHelper.instance.getDuration(selectedService);

    final List<String> data = await DatabaseHelper.instance.getSlots(
      date: date,
      duration: duration,
    );

    if (!mounted) return;

    setState(() {
      slots = data;
      selectedTime = null;
      workers = <Map<String, dynamic>>[];
      selectedWorker = null;
    });
  }

  Future<void> loadWorkers(String time) async {
    final int duration = DatabaseHelper.instance.getDuration(selectedService);

    final List<Map<String, dynamic>> data = await DatabaseHelper.instance
        .getAvailableWorkers(date: date, time: time, duration: duration);

    if (!mounted) return;

    setState(() {
      selectedTime = time;
      workers = data;
      selectedWorker = null;
    });
  }

  Future<void> save() async {
    if (selectedWorker == null || selectedTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Сонголт дутуу байна')));
      return;
    }

    try {
      await DatabaseHelper.instance.createBooking(
        customerName: nameController.text.trim(),
        phone: phoneController.text.trim(),
        carPlate: plateController.text.trim().toUpperCase(),
        bookingDate: date,
        bookingTime: selectedTime!,
        serviceType: selectedService,
        workerId: ((selectedWorker!['id'] as num?) ?? 0).toInt(),
        workerName: selectedWorker!['fullName']?.toString() ?? '',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Захиалга амжилттай')));

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Алдаа: $e')));
    }
  }

  Widget buildSlotSection() {
    if (slots.isEmpty) {
      return const Text('Сул цаг алга');
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: slots.map((String e) {
        return ChoiceChip(
          label: Text(e),
          selected: selectedTime == e,
          onSelected: (_) => loadWorkers(e),
        );
      }).toList(),
    );
  }

  Widget buildWorkerSection() {
    if (workers.isEmpty) {
      return const Text('Сул ажилчин алга');
    }

    return DropdownButtonFormField<int>(
      initialValue: selectedWorker == null
          ? null
          : ((selectedWorker!['id'] as num?) ?? 0).toInt(),
      decoration: const InputDecoration(
        labelText: 'Ажилчин',
        border: OutlineInputBorder(),
      ),
      items: workers.map<DropdownMenuItem<int>>((w) {
        final int id = ((w['id'] as num?) ?? 0).toInt();
        final String code = w['workerCode']?.toString() ?? 'N/A';
        final String name = w['fullName']?.toString() ?? '-';

        return DropdownMenuItem<int>(value: id, child: Text('$code - $name'));
      }).toList(),
      onChanged: (int? v) {
        if (v == null) return;

        setState(() {
          selectedWorker = workers.firstWhere(
            (e) => ((e['id'] as num?) ?? 0).toInt() == v,
          );
        });
      },
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Нийтийн захиалга')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              initialValue: selectedService,
              decoration: const InputDecoration(
                labelText: 'Үйлчилгээ',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Бүтэн', child: Text('Бүтэн')),
                DropdownMenuItem(value: 'Гадар', child: Text('Гадар')),
                DropdownMenuItem(value: 'Дотор', child: Text('Дотор')),
              ],
              onChanged: (String? v) {
                if (v == null) return;
                setState(() => selectedService = v);
                loadSlots();
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final DateTime? d = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );

                if (d != null) {
                  setState(() => selectedDate = d);
                  loadSlots();
                }
              },
              child: Text('Огноо: $date'),
            ),
            const SizedBox(height: 12),
            buildSlotSection(),
            const SizedBox(height: 12),
            buildWorkerSection(),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Нэр',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Утас',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: plateController,
              decoration: const InputDecoration(
                labelText: 'Дугаар',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: save, child: const Text('Захиалах')),
          ],
        ),
      ),
    );
  }
}

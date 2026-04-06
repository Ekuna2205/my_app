import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class BookingCalendarPage extends StatefulWidget {
  const BookingCalendarPage({super.key});

  @override
  State<BookingCalendarPage> createState() => _BookingCalendarPageState();
}

class _BookingCalendarPageState extends State<BookingCalendarPage> {
  DateTime selectedDate = DateTime.now();

  String selectedService = 'Бүтэн';

  List<String> availableSlots = <String>[];
  List<Map<String, dynamic>> availableWorkers = <Map<String, dynamic>>[];

  String? selectedTime;
  Map<String, dynamic>? selectedWorker;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController plateController = TextEditingController();

  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadSlots();
  }

  String get bookingDate => selectedDate.toIso8601String().substring(0, 10);

  Future<void> loadSlots() async {
    setState(() => loading = true);

    final int duration = DatabaseHelper.instance.getDuration(selectedService);

    final List<String> slots = await DatabaseHelper.instance.getSlots(
      date: bookingDate,
      duration: duration,
    );

    if (!mounted) return;

    setState(() {
      availableSlots = slots;
      selectedTime = null;
      availableWorkers = <Map<String, dynamic>>[];
      selectedWorker = null;
      loading = false;
    });
  }

  Future<void> loadWorkers(String time) async {
    final int duration = DatabaseHelper.instance.getDuration(selectedService);

    final List<Map<String, dynamic>> workers = await DatabaseHelper.instance
        .getAvailableWorkers(date: bookingDate, time: time, duration: duration);

    if (!mounted) return;

    setState(() {
      selectedTime = time;
      availableWorkers = workers;
      selectedWorker = null;
    });
  }

  Future<void> saveBooking() async {
    if (selectedTime == null || selectedWorker == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Цаг болон ажилчин сонгоно уу')),
      );
      return;
    }

    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        plateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Мэдээллээ бүрэн оруулна уу')),
      );
      return;
    }

    try {
      await DatabaseHelper.instance.createBooking(
        customerName: nameController.text.trim(),
        phone: phoneController.text.trim(),
        carPlate: plateController.text.trim().toUpperCase(),
        bookingDate: bookingDate,
        bookingTime: selectedTime!,
        serviceType: selectedService,
        workerId: ((selectedWorker!['id'] as num?) ?? 0).toInt(),
        workerName: selectedWorker!['fullName']?.toString() ?? '',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Захиалга амжилттай үүслээ')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Алдаа: $e')));
    }
  }

  Widget buildTimeSlots() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (availableSlots.isEmpty) {
      return const Text('Сул цаг алга');
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableSlots.map((String time) {
        final bool isSelected = selectedTime == time;

        return ChoiceChip(
          label: Text(time),
          selected: isSelected,
          onSelected: (_) => loadWorkers(time),
        );
      }).toList(),
    );
  }

  Widget buildWorkerDropdown() {
    if (selectedTime == null) {
      return const Text('Эхлээд цаг сонгоно уу');
    }

    if (availableWorkers.isEmpty) {
      return const Text('Энэ цагт сул ажилчин алга');
    }

    return DropdownButtonFormField<int>(
      initialValue: selectedWorker == null
          ? null
          : ((selectedWorker!['id'] as num?) ?? 0).toInt(),
      decoration: const InputDecoration(
        labelText: 'Сул ажилчин сонгох',
        border: OutlineInputBorder(),
      ),
      items: availableWorkers.map<DropdownMenuItem<int>>((worker) {
        final int id = ((worker['id'] as num?) ?? 0).toInt();
        final String code = worker['workerCode']?.toString() ?? 'N/A';
        final String name = worker['fullName']?.toString() ?? '-';

        return DropdownMenuItem<int>(value: id, child: Text('$code - $name'));
      }).toList(),
      onChanged: (int? value) {
        if (value == null) return;

        setState(() {
          selectedWorker = availableWorkers.firstWhere(
            (w) => ((w['id'] as num?) ?? 0).toInt() == value,
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
      appBar: AppBar(title: const Text('Цаг захиалах'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            initialValue: selectedService,
            decoration: const InputDecoration(
              labelText: 'Үйлчилгээний төрөл',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'Бүтэн', child: Text('Бүтэн')),
              DropdownMenuItem(value: 'Гадар', child: Text('Гадар')),
              DropdownMenuItem(value: 'Дотор', child: Text('Дотор')),
            ],
            onChanged: (String? value) {
              if (value == null) return;
              setState(() {
                selectedService = value;
              });
              loadSlots();
            },
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );

              if (picked != null) {
                setState(() {
                  selectedDate = picked;
                });
                loadSlots();
              }
            },
            child: Text('Огноо: $bookingDate'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Сул цагууд',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          buildTimeSlots(),
          const SizedBox(height: 16),
          buildWorkerDropdown(),
          const SizedBox(height: 16),
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
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: plateController,
            decoration: const InputDecoration(
              labelText: 'Машины дугаар',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: saveBooking,
              child: const Text('Захиалах'),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../theme/app_theme.dart';

class PublicBookingPage extends StatefulWidget {
  const PublicBookingPage({super.key});

  @override
  State<PublicBookingPage> createState() => _PublicBookingPageState();
}

class _PublicBookingPageState extends State<PublicBookingPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController plateController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  String? selectedTime;

  bool loading = true;

  String selectedService = 'Ажилтан угаах';
  int selectedPrice = 25000;
  int selectedDuration = 60;
  String selectedTariff =
      'Тариф: Ажилтан угаах үйлчилгээний суурь үнэ 25000₮, стандарт хугацаа 60 минут.';

  final List<Map<String, dynamic>> services = <Map<String, dynamic>>[
    <String, dynamic>{
      'name': 'Ажилтан угаах',
      'price': 25000,
      'duration': 60,
      'tariff':
          'Тариф: Ажилтан угаах үйлчилгээний суурь үнэ 25000₮, стандарт хугацаа 60 минут.',
    },
    <String, dynamic>{
      'name': 'Өөрөө угаах',
      'price': 20000,
      'duration': 60,
      'tariff':
          'Тариф: Эхний 60 минут 20000₮. Илүү минут ашиглавал нэмэлт тарифтай.',
    },
    <String, dynamic>{
      'name': 'Гадар',
      'price': 15000,
      'duration': 30,
      'tariff':
          'Тариф: Гадар угаалтын суурь үнэ 15000₮, стандарт хугацаа 30 минут.',
    },
    <String, dynamic>{
      'name': 'Дотор',
      'price': 12000,
      'duration': 30,
      'tariff':
          'Тариф: Дотор угаалтын суурь үнэ 12000₮, стандарт хугацаа 30 минут.',
    },
    <String, dynamic>{
      'name': 'Бүтэн',
      'price': 25000,
      'duration': 60,
      'tariff':
          'Тариф: Бүтэн угаалтын суурь үнэ 25000₮, стандарт хугацаа 60 минут.',
    },
  ];

  List<String> bookedTimes = <String>[];
  List<Map<String, dynamic>> availableWorkers = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    loadInitial();
  }

  String get bookingDate => selectedDate.toIso8601String().substring(0, 10);

  Future<void> loadInitial() async {
    await loadBookedTimes();
  }

  void updateServiceInfo(String serviceName) {
    final Map<String, dynamic> service = services.firstWhere(
      (e) => e['name'] == serviceName,
      orElse: () => services.first,
    );

    setState(() {
      selectedService = service['name']?.toString() ?? 'Ажилтан угаах';
      selectedPrice = ((service['price'] as num?) ?? 0).toInt();
      selectedDuration = ((service['duration'] as num?) ?? 60).toInt();
      selectedTariff = service['tariff']?.toString() ?? '';
      selectedTime = null;
      availableWorkers = <Map<String, dynamic>>[];
    });
  }

  Future<void> loadBookedTimes() async {
    setState(() => loading = true);

    final List<Map<String, dynamic>> booked = await DatabaseHelper.instance
        .getBookedSlotsForDate(bookingDate);

    if (!mounted) return;

    setState(() {
      bookedTimes = booked
          .map((e) => e['bookingTime']?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
      loading = false;
    });
  }

  Future<void> loadWorkersForTime(String time) async {
    final List<Map<String, dynamic>> workers = await DatabaseHelper.instance
        .getAvailableWorkers(
          date: bookingDate,
          time: time,
          duration: selectedDuration,
        );

    if (!mounted) return;

    setState(() {
      selectedTime = time;
      availableWorkers = workers;
    });
  }

  Future<void> pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked == null) return;

    setState(() {
      selectedDate = picked;
      selectedTime = null;
      availableWorkers = <Map<String, dynamic>>[];
    });

    await loadBookedTimes();
  }

  Future<void> saveBooking() async {
    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        plateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Мэдээллээ бүрэн оруулна уу')),
      );
      return;
    }

    if (selectedTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Цаг сонгоно уу')));
      return;
    }

    final List<Map<String, dynamic>> workers = await DatabaseHelper.instance
        .getAvailableWorkers(
          date: bookingDate,
          time: selectedTime!,
          duration: selectedDuration,
        );

    if (workers.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Энэ цагт сул ажилчин алга')),
      );
      await loadBookedTimes();
      return;
    }

    final Map<String, dynamic> worker = workers.first;
    final int workerId = ((worker['id'] as num?) ?? 0).toInt();
    final String workerName = worker['fullName']?.toString() ?? '';

    try {
      await DatabaseHelper.instance.createBooking(
        customerName: nameController.text.trim(),
        phone: phoneController.text.trim(),
        carPlate: plateController.text.trim().toUpperCase(),
        bookingDate: bookingDate,
        bookingTime: selectedTime!,
        serviceType: selectedService,
        workerId: workerId,
        workerName: workerName,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Захиалга амжилттай. Ажилчин: ${worker['workerCode'] ?? ''} - $workerName',
          ),
        ),
      );

      nameController.clear();
      phoneController.clear();
      plateController.clear();

      setState(() {
        selectedTime = null;
        availableWorkers = <Map<String, dynamic>>[];
      });

      await loadBookedTimes();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Алдаа: $e')));
    }
  }

  Widget buildServiceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.blue.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.price_check, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Үнийн мэдээлэл',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Сонгосон үйлчилгээ',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
              Text(
                selectedService,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(
                child: Text('Үнэ', style: TextStyle(color: Colors.black54)),
              ),
              Text(
                '$selectedPrice₮',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(
                child: Text('Хугацаа', style: TextStyle(color: Colors.black54)),
              ),
              Text(
                '$selectedDuration минут',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              selectedTariff,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTimeSlot(String time) {
    final bool isBooked = bookedTimes.contains(time);
    final bool isSelected = selectedTime == time;

    Color bgColor = Colors.white;
    Color textColor = Colors.black87;
    Color borderColor = Colors.grey.shade300;

    if (isBooked) {
      bgColor = Colors.red.withValues(alpha: 0.10);
      textColor = Colors.red;
      borderColor = Colors.red;
    } else if (isSelected) {
      bgColor = AppColors.primary;
      textColor = Colors.white;
      borderColor = AppColors.primary;
    }

    return GestureDetector(
      onTap: isBooked
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('❌ Энэ цаг аль хэдийн захиалагдсан'),
                ),
              );
            }
          : () async {
              await loadWorkersForTime(time);
            },
      child: AnimatedScale(
        scale: isSelected ? 1.04 : 1,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                time,
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
              if (isBooked)
                const Positioned(
                  right: 6,
                  top: 6,
                  child: Icon(Icons.lock, size: 14, color: Colors.red),
                ),
              if (isSelected)
                const Positioned(
                  right: 6,
                  top: 6,
                  child: Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTimeSection() {
    final List<String> times = <String>[
      '08:00',
      '09:00',
      '10:00',
      '11:00',
      '12:00',
      '13:00',
      '14:00',
      '15:00',
      '16:00',
      '17:00',
      '18:00',
      '19:00',
      '20:00',
      '21:00',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.schedule, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Цаг сонгох',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Улаан = захиалагдсан, Цэнхэр = сонгосон, Цагаан = сул',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Icon(Icons.circle, color: Colors.red, size: 12),
              SizedBox(width: 4),
              Text('Захиалагдсан'),
              SizedBox(width: 12),
              Icon(Icons.circle, color: AppColors.primary, size: 12),
              SizedBox(width: 4),
              Text('Сонгосон'),
              SizedBox(width: 12),
              Icon(Icons.circle, color: Colors.grey, size: 12),
              SizedBox(width: 4),
              Text('Сул'),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: times.map((time) {
              return SizedBox(width: 88, child: buildTimeSlot(time));
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget buildWorkerInfo() {
    if (selectedTime == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.engineering, color: AppColors.success),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              availableWorkers.isEmpty
                  ? 'Энэ цагт сул ажилчин алга'
                  : 'Сул ажилчин: ${availableWorkers.length} хүн',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: availableWorkers.isEmpty
                    ? Colors.red
                    : AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFormSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.person),
              labelText: 'Нэр',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.phone),
              labelText: 'Утас',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: plateController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.directions_car),
              labelText: 'Машины дугаар',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: saveBooking,
              child: const Text('Цаг захиалах'),
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
    plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Нэвтрэхгүйгээр цаг захиалах'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: loadBookedTimes,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadBookedTimes,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Цаг захиалах',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Нэвтрэхгүйгээр шууд цаг захиална',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: selectedService,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.local_car_wash),
                      labelText: 'Үйлчилгээ сонгох',
                      border: OutlineInputBorder(),
                    ),
                    items: services.map((service) {
                      return DropdownMenuItem<String>(
                        value: service['name']?.toString() ?? '',
                        child: Text(service['name']?.toString() ?? ''),
                      );
                    }).toList(),
                    onChanged: (String? value) async {
                      if (value == null) return;

                      updateServiceInfo(value);
                      await loadBookedTimes();
                    },
                  ),
                  const SizedBox(height: 14),

                  ElevatedButton.icon(
                    onPressed: pickDate,
                    icon: const Icon(Icons.calendar_month),
                    label: Text('Огноо: $bookingDate'),
                  ),
                  const SizedBox(height: 14),

                  buildServiceCard(),
                  const SizedBox(height: 14),

                  buildTimeSection(),
                  const SizedBox(height: 14),

                  buildWorkerInfo(),
                  const SizedBox(height: 14),

                  buildFormSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}

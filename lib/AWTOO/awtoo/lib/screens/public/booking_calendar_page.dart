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
  String selectedVehicleType = 'Жижиг';

  List<String> bookedTimes = <String>[];
  List<Map<String, dynamic>> availableWorkers = <Map<String, dynamic>>[];
  Map<String, int> slotWorkerCounts = <String, int>{};

  String? selectedTime;
  Map<String, dynamic>? selectedWorker;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController plateController = TextEditingController();

  bool loading = false;

  int selectedPrice = 25000;
  int selectedDuration = 60;
  String selectedTariff =
      'Тариф: Бүтэн угаалтын суурь үнэ 25000₮, стандарт хугацаа 60 минут.';

  final List<String> vehicleTypes = <String>[
    'Жижиг',
    'Дунд',
    'Том',
    'Гэр бүлийн',
    'Ачааны',
  ];

  final List<Map<String, dynamic>> services = <Map<String, dynamic>>[
    <String, dynamic>{
      'name': 'Бүтэн',
      'price': 25000,
      'duration': 60,
      'tariff':
          'Тариф: Бүтэн угаалтын суурь үнэ 25000₮, стандарт хугацаа 60 минут.',
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
      'name': 'Өөрөө угаах',
      'price': 20000,
      'duration': 60,
      'tariff':
          'Тариф: Эхний 60 минут 20000₮. Илүү минут ашиглавал минутын нэмэлт тарифтай.',
    },
  ];

  final List<String> allTimes = <String>[
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

  @override
  void initState() {
    super.initState();
    updateServiceInfo(selectedService);
    loadSlots();
  }

  String get bookingDate => selectedDate.toIso8601String().substring(0, 10);

  int getVehicleExtraPrice(String vehicleType) {
    switch (vehicleType) {
      case 'Жижиг':
        return 0;
      case 'Дунд':
        return 5000;
      case 'Том':
        return 10000;
      case 'Гэр бүлийн':
        return 15000;
      case 'Ачааны':
        return 20000;
      default:
        return 0;
    }
  }

  void updateServiceInfo(String serviceName) {
    final Map<String, dynamic> service = services.firstWhere(
      (e) => e['name'] == serviceName,
      orElse: () => services.first,
    );

    final int basePrice = ((service['price'] as num?) ?? 0).toInt();
    final int extraPrice = getVehicleExtraPrice(selectedVehicleType);
    final int totalPrice = basePrice + extraPrice;

    selectedService = service['name']?.toString() ?? 'Бүтэн';
    selectedPrice = totalPrice;
    selectedDuration = ((service['duration'] as num?) ?? 60).toInt();
    selectedTariff =
        '${service['tariff']?.toString() ?? ''}\n'
        'Машины хэмжээний нэмэгдэл: ${extraPrice}₮';
  }

  Future<void> loadSlots() async {
    setState(() => loading = true);

    final List<Map<String, dynamic>> booked = await DatabaseHelper.instance
        .getBookedSlotsForDate(bookingDate);

    final Map<String, int> counts = <String, int>{};

    for (final String time in allTimes) {
      if (selectedService == 'Өөрөө угаах') {
        counts[time] = 1;
      } else {
        final List<Map<String, dynamic>> workers = await DatabaseHelper.instance
            .getAvailableWorkers(
              date: bookingDate,
              time: time,
              duration: selectedDuration,
            );
        counts[time] = workers.length;
      }
    }

    if (!mounted) return;

    setState(() {
      bookedTimes = booked
          .map((e) => e['bookingTime']?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();

      slotWorkerCounts = counts;
      selectedTime = null;
      availableWorkers = <Map<String, dynamic>>[];
      selectedWorker = null;
      loading = false;
    });
  }

  Future<void> loadWorkers(String time) async {
    if (selectedService == 'Өөрөө угаах') {
      if (!mounted) return;
      setState(() {
        selectedTime = time;
        availableWorkers = <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 0,
            'workerCode': 'SELF',
            'fullName': 'Өөрөө угаах',
          },
        ];
        selectedWorker = availableWorkers.first;
      });
      return;
    }

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
      selectedWorker = null;
    });
  }

  Future<void> saveBooking() async {
    if (selectedTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Цаг сонгоно уу')));
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
      final String finalServiceType = '$selectedService / $selectedVehicleType';

      if (selectedService == 'Өөрөө угаах') {
        await DatabaseHelper.instance.createBooking(
          customerName: nameController.text.trim(),
          phone: phoneController.text.trim(),
          carPlate: plateController.text.trim().toUpperCase(),
          bookingDate: bookingDate,
          bookingTime: selectedTime!,
          serviceType: finalServiceType,
          workerId: 0,
          workerName: 'Customer Self Wash',
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Өөрөө угаах захиалга амжилттай бүртгэгдлээ'),
          ),
        );

        nameController.clear();
        phoneController.clear();
        plateController.clear();

        setState(() {
          selectedTime = null;
          availableWorkers = <Map<String, dynamic>>[];
          selectedWorker = null;
        });

        await loadSlots();
        return;
      }

      Map<String, dynamic>? worker = selectedWorker;

      worker ??= await DatabaseHelper.instance.autoAssignWorker(
        bookingDate: bookingDate,
        bookingTime: selectedTime!,
        serviceType: selectedService,
      );

      if (worker == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Энэ цагт сул ажилчин алга')),
        );
        return;
      }

      await DatabaseHelper.instance.createBooking(
        customerName: nameController.text.trim(),
        phone: phoneController.text.trim(),
        carPlate: plateController.text.trim().toUpperCase(),
        bookingDate: bookingDate,
        bookingTime: selectedTime!,
        serviceType: finalServiceType,
        workerId: ((worker['id'] as num?) ?? 0).toInt(),
        workerName: worker['fullName']?.toString() ?? '',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Захиалга амжилттай. Ажилчин: ${worker['workerCode'] ?? ''} - ${worker['fullName']}',
          ),
        ),
      );

      nameController.clear();
      phoneController.clear();
      plateController.clear();

      setState(() {
        selectedTime = null;
        availableWorkers = <Map<String, dynamic>>[];
        selectedWorker = null;
      });

      await loadSlots();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Алдаа: $e')));
    }
  }

  Widget buildServiceInfoCard() {
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
              Icon(Icons.price_check, color: Colors.blue),
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
                child: Text(
                  'Машины хэмжээ',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
              Text(
                selectedVehicleType,
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
    final int freeCount = slotWorkerCounts[time] ?? 0;

    Color bgColor = Colors.white;
    Color textColor = Colors.black87;
    Color borderColor = Colors.grey.shade300;

    if (isBooked) {
      bgColor = Colors.red.withValues(alpha: 0.10);
      textColor = Colors.red;
      borderColor = Colors.red;
    } else if (isSelected) {
      bgColor = Colors.blue;
      textColor = Colors.white;
      borderColor = Colors.blue;
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
              await loadWorkers(time);
            },
      child: AnimatedScale(
        scale: isSelected ? 1.04 : 1,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isBooked ? 'захиалгатай' : 'сул: $freeCount',
                    style: TextStyle(
                      fontSize: 11,
                      color: textColor.withValues(alpha: 0.0),
                    ),
                  ),
                ],
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

  Widget buildTimeSlots() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Сул цагууд',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
              Icon(Icons.circle, color: Colors.blue, size: 12),
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
            spacing: 8,
            runSpacing: 8,
            children: allTimes.map((String time) {
              return SizedBox(width: 102, child: buildTimeSlot(time));
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget buildWorkerDropdown() {
    if (selectedTime == null) {
      return const Text('Эхлээд цаг сонгоно уу');
    }

    if (selectedService == 'Өөрөө угаах') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            Icon(Icons.self_improvement, color: Colors.blue),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Өөрөө угаах үйлчилгээ сонгогдсон. Ажилчин сонгох шаардлагагүй.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    if (availableWorkers.isEmpty) {
      return const Text(
        'Энэ цагт сул ажилчин алга',
        style: TextStyle(color: Colors.red),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Сул ажилчин: ${availableWorkers.length} хүн',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<int>(
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

            return DropdownMenuItem<int>(
              value: id,
              child: Text('$code - $name'),
            );
          }).toList(),
          onChanged: (int? value) {
            if (value == null) return;

            setState(() {
              selectedWorker = availableWorkers.firstWhere(
                (w) => ((w['id'] as num?) ?? 0).toInt() == value,
              );
            });
          },
        ),
      ],
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
        title: const Text('Цаг захиалах'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: loadSlots, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            initialValue: selectedService,
            decoration: const InputDecoration(
              labelText: 'Үйлчилгээний төрөл',
              border: OutlineInputBorder(),
            ),
            items: services.map((service) {
              final String name = service['name']?.toString() ?? '';
              return DropdownMenuItem<String>(value: name, child: Text(name));
            }).toList(),
            onChanged: (String? value) {
              if (value == null) return;
              setState(() {
                updateServiceInfo(value);
              });
              loadSlots();
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: selectedVehicleType,
            decoration: const InputDecoration(
              labelText: 'Машины хэмжээ',
              border: OutlineInputBorder(),
            ),
            items: vehicleTypes.map((String type) {
              return DropdownMenuItem<String>(value: type, child: Text(type));
            }).toList(),
            onChanged: (String? value) {
              if (value == null) return;
              setState(() {
                selectedVehicleType = value;
                updateServiceInfo(selectedService);
              });
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
          buildServiceInfoCard(),
          const SizedBox(height: 16),
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

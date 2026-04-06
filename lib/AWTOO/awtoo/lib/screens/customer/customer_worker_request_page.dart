import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class CustomerWorkerRequestPage extends StatefulWidget {
  final String phone;

  const CustomerWorkerRequestPage({super.key, required this.phone});

  @override
  State<CustomerWorkerRequestPage> createState() =>
      _CustomerWorkerRequestPageState();
}

class _CustomerWorkerRequestPageState extends State<CustomerWorkerRequestPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController plateController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  bool loading = false;
  bool workerLoading = true;

  String selectedVehicleType = 'Жижиг';
  List<Map<String, dynamic>> activeWorkers = <Map<String, dynamic>>[];

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
    phoneController.text = widget.phone;
    loadCustomerInfo();
    loadActiveWorkers();
  }

  Future<void> loadCustomerInfo() async {
    final Map<String, dynamic>? customer = await DatabaseHelper.instance
        .getCustomerByPhone(widget.phone);

    if (!mounted) return;

    if (customer != null) {
      setState(() {
        nameController.text = customer['fullName']?.toString() ?? '';
      });
    }
  }

  Future<void> loadActiveWorkers() async {
    final List<Map<String, dynamic>> workers = await DatabaseHelper.instance
        .getActiveWorkers();

    if (!mounted) return;

    setState(() {
      activeWorkers = workers;
      workerLoading = false;
    });
  }

  String? validateText(String? value, String label) {
    if ((value ?? '').trim().isEmpty) {
      return '$label оруулна уу';
    }
    return null;
  }

  Future<void> sendRequest() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await DatabaseHelper.instance.createWashRequest(
        customerName: nameController.text.trim(),
        customerPhone: phoneController.text.trim(),
        carPlate: plateController.text.trim(),
        vehicleType: selectedVehicleType,
        note: noteController.text.trim(),
      );

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Амжилттай'),
          content: const Text('Ажилчин дуудах хүсэлт амжилттай илгээгдлээ'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Хүсэлт илгээх үед алдаа гарлаа')),
      );
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Widget buildTopHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8A00), Color(0xFFFF5F6D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ажилчин дуудах',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Ойр байгаа ажилтанд хүсэлт илгээнэ',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget buildActiveWorkersBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: workerLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Одоо ажиллаж байгаа ажилчид',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                if (activeWorkers.isEmpty)
                  const Text(
                    '• Одоогоор ажиллаж байгаа ажилчин алга',
                    style: TextStyle(color: Colors.black87),
                  )
                else
                  ...activeWorkers.map((Map<String, dynamic> worker) {
                    final String name =
                        worker['fullName']?.toString() ?? 'Ажилчин';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '• $name',
                        style: const TextStyle(fontSize: 15),
                      ),
                    );
                  }),
              ],
            ),
    );
  }

  Widget buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.96),
        border: const UnderlineInputBorder(),
        enabledBorder: const UnderlineInputBorder(),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.orange, width: 2),
        ),
      ),
    );
  }

  Widget buildVehicleDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: selectedVehicleType,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.directions_car),
        labelText: 'Машины төрөл',
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.96),
        border: const UnderlineInputBorder(),
        enabledBorder: const UnderlineInputBorder(),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.orange, width: 2),
        ),
      ),
      items: vehicleTypes.map((String type) {
        return DropdownMenuItem<String>(value: type, child: Text(type));
      }).toList(),
      onChanged: (String? value) {
        if (value == null) return;
        setState(() {
          selectedVehicleType = value;
        });
      },
    );
  }

  Widget buildSelectedVehicleBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.orange.withValues(alpha: 0.15),
            child: const Icon(
              Icons.directions_car,
              color: Colors.orange,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Сонгосон машины төрөл',
              style: TextStyle(fontSize: 15),
            ),
          ),
          Text(
            selectedVehicleType,
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white24),
      ),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            buildField(
              controller: nameController,
              label: 'Нэр',
              icon: Icons.person,
              validator: (value) => validateText(value, 'Нэр'),
            ),
            const SizedBox(height: 12),
            buildField(
              controller: phoneController,
              label: 'Утасны дугаар',
              icon: Icons.phone,
              readOnly: true,
              keyboardType: TextInputType.phone,
              validator: (value) => validateText(value, 'Утасны дугаар'),
            ),
            const SizedBox(height: 12),
            buildField(
              controller: plateController,
              label: 'Машины дугаар',
              icon: Icons.pin,
              validator: (value) => validateText(value, 'Машины дугаар'),
            ),
            const SizedBox(height: 12),
            buildVehicleDropdown(),
            const SizedBox(height: 14),
            buildSelectedVehicleBox(),
            const SizedBox(height: 12),
            buildField(
              controller: noteController,
              label: 'Нэмэлт тайлбар',
              icon: Icons.edit_note,
              maxLines: 3,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: loading ? null : sendRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.send),
                label: loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Хүсэлт илгээх',
                        style: TextStyle(fontWeight: FontWeight.bold),
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
    plateController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ажилчин дуудах'), centerTitle: true),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE0B2), Color(0xFFFFF3E0), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                buildTopHeader(),
                const SizedBox(height: 14),
                buildActiveWorkersBox(),
                const SizedBox(height: 14),
                buildFormCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

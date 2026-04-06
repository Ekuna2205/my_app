import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class AdminCustomerListPage extends StatefulWidget {
  const AdminCustomerListPage({super.key});

  @override
  State<AdminCustomerListPage> createState() => _AdminCustomerListPageState();
}

class _AdminCustomerListPageState extends State<AdminCustomerListPage> {
  bool loading = true;
  List<Map<String, dynamic>> customers = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    final List<Map<String, dynamic>> data = await DatabaseHelper.instance
        .getCustomers();

    if (!mounted) {
      return;
    }

    setState(() {
      customers = data;
      loading = false;
    });
  }

  Future<void> removeCustomer(int id) async {
    await DatabaseHelper.instance.deleteCustomer(id);
    await loadCustomers();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Хэрэглэгч устгагдлаа')));
  }

  Widget buildCustomerCard(Map<String, dynamic> item) {
    final int id = item['id'] as int;
    final String fullName = item['fullName']?.toString() ?? '';
    final String phone = item['phone']?.toString() ?? '';
    final String carPlate = item['carPlate']?.toString() ?? '';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Утас: $phone\nМашины дугаар: $carPlate'),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            removeCustomer(id);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Хэрэглэгчдийн бүртгэл'),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : customers.isEmpty
          ? const Center(
              child: Text(
                'Бүртгэгдсэн хэрэглэгч алга',
                style: TextStyle(fontSize: 18),
              ),
            )
          : RefreshIndicator(
              onRefresh: loadCustomers,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: customers.length,
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(height: 10);
                },
                itemBuilder: (BuildContext context, int index) {
                  return buildCustomerCard(customers[index]);
                },
              ),
            ),
    );
  }
}

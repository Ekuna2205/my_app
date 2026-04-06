// lib/car/lib/select_time_page.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../common/service.dart';
import '../common/car_type.dart';
import 'confirm_booking_page.dart';

class SelectTimePage extends StatefulWidget {
  final Service service;
  final CarType carType;

  const SelectTimePage({
    super.key,
    required this.service,
    required this.carType,
  });

  @override
  State<SelectTimePage> createState() => _SelectTimePageState();
}

class _SelectTimePageState extends State<SelectTimePage> {
  DateTime _selectedDay = DateTime.now();
  String? _selectedTime;

  final List<String> availableTimes = [
    "09:00",
    "10:00",
    "11:00",
    "13:00",
    "14:00",
    "15:00",
    "16:00",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Захиалга өгөх",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D47A1),
              Color(0xFF42A5F5),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Үйлчилгээний нэр
                Text(
                  widget.service.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 16),

                /// Calendar
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: TableCalendar(
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(
                      const Duration(days: 30),
                    ),
                    focusedDay: _selectedDay,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Цаг сонгоно уу",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 12),

                /// Цагийн сонголт
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: availableTimes.map((time) {
                    final isSelected = _selectedTime == time;

                    return ChoiceChip(
                      label: Text(time),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedTime = selected ? time : null;
                        });
                      },
                      selectedColor: Colors.white,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      labelStyle: const TextStyle(
                        color: Color(0xFF0D47A1),
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList(),
                ),

                const Spacer(),

                /// Баталгаажуулах товч
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _selectedTime == null
                        ? null
                        : () {
                            final hour =
                                int.parse(_selectedTime!.split(":")[0]);
                            final minute =
                                int.parse(_selectedTime!.split(":")[1]);

                            final selectedDateTime = DateTime(
                              _selectedDay.year,
                              _selectedDay.month,
                              _selectedDay.day,
                              hour,
                              minute,
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ConfirmBookingPage(
                                  service: widget.service,
                                  dateTime: selectedDateTime,
                                ),
                              ),
                            );
                          },
                    child: const Text(
                      "Баталгаажуулах",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

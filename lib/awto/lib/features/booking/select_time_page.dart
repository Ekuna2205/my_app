import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart'; // огноо форматлахад хэрэглэнэ (шаардлагатай бол)

import '../../../common/models/service.dart'; // Service класс байгаа газар
import '../../../common/widgets/primary_button.dart'; // таны PrimaryButton

class SelectTimePage extends StatefulWidget {
  final Service service;

  const SelectTimePage({super.key, required this.service});

  @override
  State<SelectTimePage> createState() => _SelectTimePageState();
}

class _SelectTimePageState extends State<SelectTimePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _selectedTimeSlot;

  // Жишээ: 09:00 - 18:30 хүртэл 30 минут тутамд цаг гаргах
  final List<int> _slotHours = List.generate(20, (index) => 9 + index ~/ 2);
  final List<int> _slotMinutes = List.generate(20, (index) => (index % 2) * 30);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.service.name} цаг захиалах"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          // Календарь
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 60)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _selectedTimeSlot =
                    null; // шинэ өдөр сонгогдоход цагийг цэвэрлэх
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              outsideDaysVisible: false,
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),

          const SizedBox(height: 16),
          const Divider(),

          // Цагийн сонголтууд
          Expanded(
            child: _selectedDay == null
                ? const Center(
                    child: Text(
                      'Өдөр сонгоно уу',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 1.6,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: _slotHours.length,
                    itemBuilder: (context, index) {
                      final hour = _slotHours[index];
                      final minute = _slotMinutes[index];

                      final slotTime = DateTime(
                        _selectedDay!.year,
                        _selectedDay!.month,
                        _selectedDay!.day,
                        hour,
                        minute,
                      );

                      // Энд жинхэнэ шалгалт хийх ёстой (Firestore-оос)
                      final isAvailable = true; // туршилтын хувьд
                      final isSelected = _selectedTimeSlot == slotTime;

                      return GestureDetector(
                        onTap: isAvailable
                            ? () {
                                setState(() {
                                  _selectedTimeSlot = slotTime;
                                });
                              }
                            : null,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue[800]
                                : isAvailable
                                ? Colors.blue[50]
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(color: Colors.blue[900]!, width: 2)
                                : null,
                          ),
                          child: Text(
                            "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected || !isAvailable
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Доод талын баталгаажуулах товч
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PrimaryButton(
              text: _selectedTimeSlot != null
                  ? "Үргэлжлүүлэх"
                  : "Цаг сонгоно уу",
              onPressed: _selectedTimeSlot != null
                  ? () {
                      // Дараагийн хуудас руу шилжих
                      // Navigator.push(...);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Сонгосон цаг: ${DateFormat('yyyy-MM-dd HH:mm').format(_selectedTimeSlot!)}",
                          ),
                        ),
                      );
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

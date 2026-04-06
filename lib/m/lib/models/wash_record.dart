class WashRecord {
  final String id; // Firestore doc ID
  final String plateNumber; // машины дугаар
  final String carType; // 'суудлын', 'жийп', 'микро'
  final String washType; // 'гадна', 'дотор', 'бүтэн', 'вакуум'
  final String workerId; // ажилчин
  final DateTime startTime;
  DateTime? endTime;
  final double price;
  final bool isCompleted;

  WashRecord({
    required this.id,
    required this.plateNumber,
    required this.carType,
    required this.washType,
    required this.workerId,
    required this.startTime,
    this.endTime,
    required this.price,
    this.isCompleted = false,
  });

  // Firestore-д хадгалахад зориулсан map
  Map<String, dynamic> toMap() => {
    'plateNumber': plateNumber,
    'carType': carType,
    'washType': washType,
    'workerId': workerId,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'price': price,
    'isCompleted': isCompleted,
  };

  factory WashRecord.fromMap(Map<String, dynamic> map, String id) => WashRecord(
    id: id,
    plateNumber: map['plateNumber'],
    carType: map['carType'],
    washType: map['washType'],
    workerId: map['workerId'],
    startTime: DateTime.parse(map['startTime']),
    endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
    price: map['price'].toDouble(),
    isCompleted: map['isCompleted'],
  );
}

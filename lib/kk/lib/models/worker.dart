class Worker {
  int? id;
  String name;
  String role;

  Worker({this.id, required this.name, required this.role});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'role': role};
  }

  factory Worker.fromMap(Map<String, dynamic> map) {
    return Worker(id: map['id'], name: map['name'], role: map['role']);
  }
}

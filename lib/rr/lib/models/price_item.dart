class PriceItem {
  final int? id;
  final String service; // Гар угаалга / Өөрөө угаах гэх мэт
  final String type; // Гадна/Дотор/Бүтэн/Вакум эсвэл "Минут"
  final int price; // төгрөг

  const PriceItem({
    this.id,
    required this.service,
    required this.type,
    required this.price,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'service': service,
    'type': type,
    'price': price,
  };

  factory PriceItem.fromMap(Map<String, dynamic> map) => PriceItem(
    id: map['id'] as int?,
    service: map['service'] as String,
    type: map['type'] as String,
    price: map['price'] as int,
  );
}

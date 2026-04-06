class Plant {
  final String name;
  final String species;
  final String imageUrl;
  final int wateringDays;
  final DateTime lastWatered;

  Plant({
    required this.name,
    required this.species,
    required this.imageUrl,
    required this.wateringDays,
    required this.lastWatered,
  });
}

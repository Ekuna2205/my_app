class CarType {
  final String name;

  const CarType(this.name);

  static const CarType sedan = CarType('Седан');
  static const CarType suv = CarType('SUV');
  static const CarType truck = CarType('Ачааны');

  static const List<CarType> allTypes = [sedan, suv, truck];
}

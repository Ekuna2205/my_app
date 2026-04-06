class PriceCalculator {
  static int calculate(String carType, String washType) {
    int base = 0;

    if (carType == "Суудлын") base = 10000;
    if (carType == "Жийп") base = 15000;
    if (carType == "Микро") base = 20000;

    if (washType == "Гадна") return base;
    if (washType == "Дотор") return base + 5000;
    if (washType == "Бүтэн") return base + 8000;
    if (washType == "Вакум") return 3000;

    return base;
  }
}

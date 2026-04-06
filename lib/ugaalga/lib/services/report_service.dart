class ReportService {
  static int calculateTotal(List records) {
    return records.fold<int>(0, (int sum, item) => sum + (item.price as int));
  }
}

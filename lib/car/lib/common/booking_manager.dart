import 'booking.dart';
import 'service.dart';

class BookingManager {
  static final List<Booking> _bookings = [];

  /// Захиалга нэмэх (local-д л хадгална)
  static bool addBooking(Booking booking) {
    // Давхардал шалгах (optional, хүсвэл устгаж болно)
    for (final b in _bookings) {
      final bEnd = b.dateTime.add(Duration(minutes: b.service.durationMinutes));
      final bookingEnd = booking.dateTime
          .add(Duration(minutes: booking.service.durationMinutes));

      if (booking.dateTime.isBefore(bEnd) && bookingEnd.isAfter(b.dateTime)) {
        return false; // давхардсан
      }
    }

    _bookings.add(booking);
    return true;
  }

  /// Цаг боломжтой эсэхийг шалгах
  static bool isSlotAvailable(Service service, DateTime dateTime) {
    final endTime = dateTime.add(Duration(minutes: service.durationMinutes));

    for (final b in _bookings) {
      if (b.service.id == service.id) {
        final bEnd =
            b.dateTime.add(Duration(minutes: b.service.durationMinutes));
        if (dateTime.isBefore(bEnd) && endTime.isAfter(b.dateTime)) {
          return false;
        }
      }
    }
    return true;
  }

  /// Бүх захиалга авах (local жагсаалт)
  static List<Booking> getUserBookings() {
    return List.unmodifiable(_bookings);
  }
}

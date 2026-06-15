import 'flight.dart';

class BookingResponse {
  final int id;
  final int userId;
  final Flight? flight;
  final String bookingDate;

  BookingResponse({
    required this.id,
    required this.userId,
    this.flight,
    required this.bookingDate,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      flight: json['flight'] != null ? Flight.fromJson(json['flight']) : null,
      bookingDate: json['bookingDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'flight': flight?.toJson(),
      'bookingDate': bookingDate,
    };
  }
}

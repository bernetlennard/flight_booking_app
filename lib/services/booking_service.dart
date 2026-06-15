import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/booking_request.dart';
import '../models/booking_response.dart';

class BookingService {
  static const String baseUrl = 'http://10.0.2.2:8080';

  Future<BookingResponse> createBooking(int flightId, String token) async {
    final bookingRequest = BookingRequest(flightId: flightId);
    final response = await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(bookingRequest.toJson()),
    );

    if (response.statusCode == 200) {
      return BookingResponse.fromJson(jsonDecode(response.body));
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Buchung fehlgeschlagen');
    }
  }

  Future<List<BookingResponse>> getMyBookings(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/bookings'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => BookingResponse.fromJson(item)).toList();
    } else {
      throw Exception('Buchungen konnten nicht geladen werden');
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/flight.dart';

class FlightService {
  // Use 10.0.2.2 if you are using an Android emulator to access localhost of your machine
  static const String baseUrl = 'http://10.0.2.2:8080';

  Future<List<Flight>> getFlights() async {
    final response = await http.get(Uri.parse('$baseUrl/flights'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Flight.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load flights');
    }
  }
}

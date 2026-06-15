import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/flight.dart';

import '../utils/constants.dart';

class FlightService {
  static const String baseUrl = Constants.baseUrl;

  Future<List<Flight>> getFlights({
    String? departureLocation,
    String? arrivalLocation,
    String? departureDate,
    String? airline,
    double? maxPrice,
  }) async {
    final Map<String, String> queryParameters = {};
    if (departureLocation != null && departureLocation.isNotEmpty) {
      queryParameters['departureLocation'] = departureLocation;
    }
    if (arrivalLocation != null && arrivalLocation.isNotEmpty) {
      queryParameters['arrivalLocation'] = arrivalLocation;
    }
    if (departureDate != null && departureDate.isNotEmpty) {
      queryParameters['departureDate'] = departureDate;
    }
    if (airline != null && airline.isNotEmpty) {
      queryParameters['airline'] = airline;
    }
    if (maxPrice != null) {
      queryParameters['maxPrice'] = maxPrice.toString();
    }

    final uri = Uri.parse('$baseUrl/flights').replace(queryParameters: queryParameters);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Flight.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load flights');
    }
  }
}

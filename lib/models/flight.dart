class LocalTime {
  final int hour;
  final int minute;
  final int second;
  final int nano;

  LocalTime({
    required this.hour,
    required this.minute,
    this.second = 0,
    this.nano = 0,
  });

  factory LocalTime.fromJson(dynamic json) {
    if (json is String) {
      // Falls das Backend "10:30:00" schickt
      List<String> parts = json.split(':');
      return LocalTime(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
        second: parts.length > 2 ? int.parse(parts[2].split('.')[0]) : 0,
      );
    } else if (json is Map<String, dynamic>) {
      // Falls das Backend ein Objekt schickt
      return LocalTime(
        hour: json['hour'] ?? 0,
        minute: json['minute'] ?? 0,
        second: json['second'] ?? 0,
        nano: json['nano'] ?? 0,
      );
    }
    return LocalTime(hour: 0, minute: 0);
  }

  @override
  String toString() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}

class Flight {
  final int id;
  final String departureLocation;
  final String arrivalLocation;
  final String departureDate;
  final LocalTime departureTime;
  final String airline;
  final double price;
  final int availableTickets;

  Flight({
    required this.id,
    required this.departureLocation,
    required this.arrivalLocation,
    required this.departureDate,
    required this.departureTime,
    required this.airline,
    required this.price,
    required this.availableTickets,
  });

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      id: json['id'] ?? 0,
      departureLocation: json['departureLocation'] ?? 'Unbekannt',
      arrivalLocation: json['arrivalLocation'] ?? 'Unbekannt',
      departureDate: json['departureDate'] ?? '',
      departureTime: LocalTime.fromJson(json['departureTime']),
      airline: json['airline'] ?? 'Unbekannt',
      price: (json['price'] ?? 0).toDouble(),
      availableTickets: json['availableTickets'] ?? 0,
    );
  }
}

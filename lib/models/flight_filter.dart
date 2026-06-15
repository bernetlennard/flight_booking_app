import 'flight.dart';

class FlightFilter {
  String departureLocation;
  String arrivalLocation;
  String departureDate;
  String airline;
  double? maxPrice;
  String fromTime;
  String toTime;
  bool onlyAvailable;

  FlightFilter({
    this.departureLocation = '',
    this.arrivalLocation = '',
    this.departureDate = '',
    this.airline = '',
    this.maxPrice,
    this.fromTime = '',
    this.toTime = '',
    this.onlyAvailable = false,
  });

  bool matches(Flight? flight) {
    if (flight == null) return true;

    bool matchesDeparture = departureLocation.isEmpty || 
        flight.departureLocation.toLowerCase().contains(departureLocation.toLowerCase());
    bool matchesArrival = arrivalLocation.isEmpty || 
        flight.arrivalLocation.toLowerCase().contains(arrivalLocation.toLowerCase());
    bool matchesDate = departureDate.isEmpty || 
        flight.departureDate == departureDate;
    bool matchesAirline = airline.isEmpty || 
        flight.airline.toLowerCase().contains(airline.toLowerCase());
    
    bool matchesPrice = true;
    if (maxPrice != null && flight.price > maxPrice!) {
      matchesPrice = false;
    }

    bool matchesTime = true;
    int flightMin = flight.departureTime.toMinutes();

    if (fromTime.isNotEmpty) {
      List<String> parts = fromTime.split(':');
      int fromMin = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      if (flightMin < fromMin) matchesTime = false;
    }

    if (toTime.isNotEmpty) {
      List<String> parts = toTime.split(':');
      int toMin = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      if (flightMin > toMin) matchesTime = false;
    }

    bool matchesAvailability = true;
    if (onlyAvailable) {
      matchesAvailability = flight.availableTickets > 0;
    }

    return matchesDeparture && matchesArrival && matchesDate && matchesAirline && matchesPrice && matchesTime && matchesAvailability;
  }
}

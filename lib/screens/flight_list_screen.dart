import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flight.dart';
import '../services/flight_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

class FlightListScreen extends StatefulWidget {
  const FlightListScreen({super.key});

  @override
  State<FlightListScreen> createState() => _FlightListScreenState();
}

class _FlightListScreenState extends State<FlightListScreen> {
  late Future<List<Flight>> futureFlights;
  final FlightService flightService = FlightService();

  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _arrivalController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _airlineController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final TextEditingController _fromTimeController = TextEditingController();
  final TextEditingController _toTimeController = TextEditingController();
  bool _onlyAvailable = false;

  bool _isFilterVisible = false;

  @override
  void initState() {
    super.initState();
    _searchFlights();
  }

  void _searchFlights() {
    setState(() {
      futureFlights = flightService.getFlights(
        departureLocation: _departureController.text,
        arrivalLocation: _arrivalController.text,
        departureDate: _dateController.text,
        airline: _airlineController.text,
        maxPrice: double.tryParse(_maxPriceController.text),
      ).then((flights) {
        return flights.where((flight) {
          bool matchesTime = true;
          int flightMin = flight.departureTime.toMinutes();

          if (_fromTimeController.text.isNotEmpty) {
            List<String> parts = _fromTimeController.text.split(':');
            int fromMin = int.parse(parts[0]) * 60 + int.parse(parts[1]);
            if (flightMin < fromMin) matchesTime = false;
          }

          if (_toTimeController.text.isNotEmpty) {
            List<String> parts = _toTimeController.text.split(':');
            int toMin = int.parse(parts[0]) * 60 + int.parse(parts[1]);
            if (flightMin > toMin) matchesTime = false;
          }
          
          bool matchesAvailability = true;
          if (_onlyAvailable) {
            matchesAvailability = flight.availableTickets > 0;
          }
          
          return matchesTime && matchesAvailability;
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verfügbare Flüge'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_isFilterVisible ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () => setState(() => _isFilterVisible = !_isFilterVisible),
          ),
          IconButton(
            icon: Icon(authService.isAuthenticated ? Icons.person : Icons.login),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => authService.isAuthenticated 
                      ? const ProfileScreen() 
                      : const LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isFilterVisible) _buildFilterMask(),
          Expanded(
            child: FutureBuilder<List<Flight>>(
              future: futureFlights,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                } else if (snapshot.hasData) {
                  final flights = snapshot.data!;
                  if (flights.isEmpty) {
                    return const Center(child: Text('Keine Flüge gefunden.'));
                  }
                  return ListView.builder(
                    itemCount: flights.length,
                    itemBuilder: (context, index) => _buildFlightCard(flights[index]),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterMask() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _departureController,
                decoration: const InputDecoration(labelText: 'Abreiseort', prefixIcon: Icon(Icons.flight_takeoff)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _arrivalController,
                decoration: const InputDecoration(labelText: 'Zielort', prefixIcon: Icon(Icons.flight_land)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Datum (YYYY-MM-DD)', prefixIcon: Icon(Icons.calendar_today)),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    _dateController.text = pickedDate.toString().split(' ')[0];
                  }
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _airlineController,
                decoration: const InputDecoration(labelText: 'Airline', prefixIcon: Icon(Icons.business)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _maxPriceController,
                decoration: const InputDecoration(labelText: 'Max. Preis', prefixIcon: Icon(Icons.attach_money)),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _fromTimeController,
                      decoration: const InputDecoration(labelText: 'Ab Zeit', prefixIcon: Icon(Icons.access_time)),
                      readOnly: true,
                      onTap: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: const TimeOfDay(hour: 0, minute: 0),
                        );
                        if (pickedTime != null) {
                          _fromTimeController.text = '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _toTimeController,
                      decoration: const InputDecoration(labelText: 'Bis Zeit', prefixIcon: Icon(Icons.access_time)),
                      readOnly: true,
                      onTap: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: const TimeOfDay(hour: 23, minute: 59),
                        );
                        if (pickedTime != null) {
                          _toTimeController.text = '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: _onlyAvailable,
                    onChanged: (bool? value) => setState(() => _onlyAvailable = value ?? false),
                  ),
                  const Text('Nur verfügbare'),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _searchFlights,
                    icon: const Icon(Icons.search),
                    label: const Text('Suchen'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlightCard(Flight flight) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: const Icon(Icons.flight_takeoff, color: Colors.blue),
        title: Text('${flight.departureLocation} -> ${flight.arrivalLocation}', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${flight.airline} | ${flight.departureDate} ${flight.departureTime}\nTickets: ${flight.availableTickets}'),
        isThreeLine: true,
        trailing: Text('${flight.price.toStringAsFixed(2)} CHF',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Fehler: $error', textAlign: TextAlign.center),
          ),
          ElevatedButton(
            onPressed: _searchFlights,
            child: const Text('Erneut versuchen'),
          ),
        ],
      ),
    );
  }
}

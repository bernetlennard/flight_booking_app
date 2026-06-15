import 'package:flutter/material.dart';
import 'models/flight.dart';
import 'services/flight_service.dart';

void main() {
  runApp(const FlightBookingApp());
}

class FlightBookingApp extends StatelessWidget {
  const FlightBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flight Booking App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const FlightListScreen(),
    );
  }
}

class FlightListScreen extends StatefulWidget {
  const FlightListScreen({super.key});

  @override
  State<FlightListScreen> createState() => _FlightListScreenState();
}

class _FlightListScreenState extends State<FlightListScreen> {
  late Future<List<Flight>> futureFlights;
  final FlightService flightService = FlightService();

  @override
  void initState() {
    super.initState();
    futureFlights = flightService.getFlights();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verfügbare Flüge'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: FutureBuilder<List<Flight>>(
          future: futureFlights,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Flight> flights = snapshot.data!;
              return ListView.builder(
                itemCount: flights.length,
                itemBuilder: (context, index) {
                  Flight flight = flights[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      leading: const Icon(Icons.flight_takeoff),
                      title: Text('${flight.departureLocation} -> ${flight.arrivalLocation}'),
                      subtitle: Text('${flight.airline} | ${flight.departureDate} ${flight.departureTime}'),
                      trailing: Text('${flight.price.toStringAsFixed(2)} €', 
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Fehler: ${snapshot.error}'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        futureFlights = flightService.getFlights();
                      });
                    },
                    child: const Text('Erneut versuchen'),
                  ),
                ],
              );
            }

            // By default, show a loading spinner.
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

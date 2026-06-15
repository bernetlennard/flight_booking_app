import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flight.dart';
import '../models/flight_filter.dart';
import '../services/flight_service.dart';
import '../services/auth_service.dart';
import '../services/booking_service.dart';
import '../widgets/flight_filter_widget.dart';
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
  final BookingService bookingService = BookingService();

  FlightFilter _filter = FlightFilter();
  bool _isFilterVisible = false;

  @override
  void initState() {
    super.initState();
    _searchFlights();
  }

  void _searchFlights() {
    setState(() {
      futureFlights = flightService.getFlights(
        departureLocation: _filter.departureLocation,
        arrivalLocation: _filter.arrivalLocation,
        departureDate: _filter.departureDate,
        airline: _filter.airline,
        maxPrice: _filter.maxPrice,
      ).then((flights) {
        return flights.where((flight) => _filter.matches(flight)).toList();
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
          if (_isFilterVisible) 
            FlightFilterWidget(
              initialFilter: _filter,
              showOnlyAvailable: true,
              onFilterChanged: (newFilter) {
                _filter = newFilter;
                _searchFlights();
              },
            ),
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

  Widget _buildFlightCard(Flight flight) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        onTap: () => _handleFlightTap(flight),
        leading: const Icon(Icons.flight_takeoff, color: Colors.blue),
        title: Text('${flight.departureLocation} -> ${flight.arrivalLocation}', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${flight.airline} | ${flight.departureDate} ${flight.departureTime}\nTickets: ${flight.availableTickets}'),
        isThreeLine: true,
        trailing: Text('${flight.price.toStringAsFixed(2)} CHF',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
      ),
    );
  }

  Future<void> _handleFlightTap(Flight flight) async {
    // 1. Prüfen ob eingeloggt (ohne zu "hören", da wir im async Block sind)
    AuthService authService = Provider.of<AuthService>(context, listen: false);
    
    if (!authService.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte melden Sie sich an, um diesen Flug zu buchen.')),
      );
      
      // 2. Zum Login navigieren und warten
      await Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => const LoginScreen())
      );
      
      // 3. WICHTIG: Nach dem Pop müssen wir den Service NEU abrufen, 
      // da sich der State geändert hat und wir sichergehen müssen, dass das Widget noch da ist.
      if (!mounted) return;
      authService = Provider.of<AuthService>(context, listen: false);
      
      if (!authService.isAuthenticated) return;
    }

    // 4. Buchungs-Logik (Flug könnte in der Zwischenzeit ausgebucht sein -> neu prüfen macht Sinn, aber hier reicht lokaler Check)
    if (flight.availableTickets <= 0) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Flug ausgebucht'),
          content: const Text('Leider sind für diesen Flug keine Tickets mehr verfügbar.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
    } else {
      _showBookingDialog(flight);
    }
  }

  void _showBookingDialog(Flight flight) {
    bool isBooking = false;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Flug buchen?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Flug: ${flight.departureLocation} nach ${flight.arrivalLocation}'),
                Text('Datum: ${flight.departureDate}'),
                Text('Preis: ${flight.price.toStringAsFixed(2)} CHF'),
                const SizedBox(height: 16),
                const Text('Möchten Sie diesen Flug jetzt verbindlich buchen?'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isBooking ? null : () => Navigator.pop(context),
                child: const Text('Abbrechen'),
              ),
              ElevatedButton(
                onPressed: isBooking ? null : () async {
                  setDialogState(() => isBooking = true);
                  try {
                    final authService = Provider.of<AuthService>(context, listen: false);
                    await bookingService.createBooking(flight.id, authService.token!);
                    
                    if (mounted) {
                      Navigator.pop(context); // Dialog schließen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Flug erfolgreich gebucht!'), backgroundColor: Colors.green),
                      );
                      _searchFlights(); // Liste aktualisieren (Ticketanzahl)
                    }
                  } catch (e) {
                    if (mounted) {
                      setDialogState(() => isBooking = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
                child: isBooking 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Kostenpflichtig buchen'),
              ),
            ],
          );
        }
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

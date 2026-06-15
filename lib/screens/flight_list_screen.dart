import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flight.dart';
import '../models/flight_filter.dart';
import '../services/flight_service.dart';
import '../services/auth_service.dart';
import '../services/booking_service.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/flight_filter_widget.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

class FlightListScreen extends StatefulWidget {
  const FlightListScreen({super.key});

  @override
  State<FlightListScreen> createState() => _FlightListScreenState();
}

class _FlightListScreenState extends State<FlightListScreen> {
  final FlightService _flightService = FlightService();
  final BookingService _bookingService = BookingService();
  late Future<List<Flight>> _futureFlights;

  FlightFilter _filter = FlightFilter();
  bool _isFilterVisible = false;

  @override
  void initState() {
    super.initState();
    _searchFlights();
  }

  void _searchFlights() {
    setState(() {
      _futureFlights = _flightService
          .getFlights(
            departureLocation: _filter.departureLocation,
            arrivalLocation: _filter.arrivalLocation,
            departureDate: _filter.departureDate,
            airline: _filter.airline,
            maxPrice: _filter.maxPrice,
          )
          .then((flights) => _applyFilter(flights));
    });
  }

  List<Flight> _applyFilter(List<Flight> flights) {
    return flights.where((flight) => _filter.matches(flight)).toList();
  }

  void _toggleFilterVisibility() {
    setState(() => _isFilterVisible = !_isFilterVisible);
  }

  void _onFilterChanged(FlightFilter newFilter) {
    _filter = newFilter;
    _searchFlights();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (_isFilterVisible) _buildFilterWidget(),
          Expanded(child: _buildFlightList()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final authService = context.watch<AuthService>();
    return AppBar(
      title: const Text('Verfügbare Flüge'),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      actions: [
        IconButton(
          icon: Icon(_isFilterVisible ? Icons.filter_list_off : Icons.filter_list),
          onPressed: _toggleFilterVisibility,
        ),
        IconButton(
          icon: Icon(authService.isAuthenticated ? Icons.person : Icons.login),
          onPressed: () => _navigateToProfileOrLogin(authService.isAuthenticated),
        ),
      ],
    );
  }

  void _navigateToProfileOrLogin(bool isAuthenticated) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => isAuthenticated ? const ProfileScreen() : const LoginScreen(),
      ),
    );
  }

  Widget _buildFilterWidget() {
    return FlightFilterWidget(
      initialFilter: _filter,
      showOnlyAvailable: true,
      onFilterChanged: _onFilterChanged,
    );
  }

  Widget _buildFlightList() {
    return FutureBuilder<List<Flight>>(
      future: _futureFlights,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return ErrorStateWidget(
            error: snapshot.error.toString(),
            onRetry: _searchFlights,
          );
        }

        final flights = snapshot.data ?? [];
        if (flights.isEmpty) {
          return const Center(child: Text('Keine Flüge gefunden.'));
        }

        return ListView.builder(
          itemCount: flights.length,
          itemBuilder: (context, index) => _FlightListItem(
            flight: flights[index],
            onTap: () => _handleFlightTap(flights[index]),
          ),
        );
      },
    );
  }

  Future<void> _handleFlightTap(Flight flight) async {
    final authService = context.read<AuthService>();

    if (!authService.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte melden Sie sich an, um diesen Flug zu buchen.')),
      );
      await Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));

      if (!mounted || !context.read<AuthService>().isAuthenticated) return;
    }

    if (flight.availableTickets <= 0) {
      _showSoldOutDialog();
    } else {
      _showBookingDialog(flight);
    }
  }

  void _showSoldOutDialog() {
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
                onPressed: isBooking
                    ? null
                    : () async {
                        setDialogState(() => isBooking = true);
                        try {
                          final authService = context.read<AuthService>();
                          await _bookingService.createBooking(flight.id, authService.token!);

                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Flug erfolgreich gebucht!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            _searchFlights();
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
        },
      ),
    );
  }
}

class _FlightListItem extends StatelessWidget {
  final Flight flight;
  final VoidCallback onTap;

  const _FlightListItem({required this.flight, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.flight_takeoff, color: Colors.blue),
        title: Text(
          '${flight.departureLocation} -> ${flight.arrivalLocation}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${flight.airline} | ${flight.departureDate} ${flight.departureTime}\nTickets: ${flight.availableTickets}',
        ),
        isThreeLine: true,
        trailing: Text(
          '${flight.price.toStringAsFixed(2)} CHF',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

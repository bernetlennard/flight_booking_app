import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/booking_response.dart';
import '../models/flight_filter.dart';
import '../services/booking_service.dart';
import '../services/auth_service.dart';
import '../widgets/flight_filter_widget.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  late Future<List<BookingResponse>> futureBookings;
  final BookingService bookingService = BookingService();

  FlightFilter _filter = FlightFilter();
  bool _isFilterVisible = false;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (!authService.isAuthenticated) return;

    setState(() {
      futureBookings = bookingService.getMyBookings(authService.token!).then((bookings) {
        return bookings.where((booking) => _filter.matches(booking.flight)).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meine Buchungen'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_isFilterVisible ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () => setState(() => _isFilterVisible = !_isFilterVisible),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isFilterVisible) 
            FlightFilterWidget(
              initialFilter: _filter,
              buttonLabel: 'Filtern',
              onFilterChanged: (newFilter) {
                _filter = newFilter;
                _loadBookings();
              },
            ),
          Expanded(
            child: FutureBuilder<List<BookingResponse>>(
              future: futureBookings,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                } else if (snapshot.hasData) {
                  final bookings = snapshot.data!;
                  if (bookings.isEmpty) {
                    return const Center(child: Text('Keine Buchungen gefunden.'));
                  }
                  return ListView.builder(
                    itemCount: bookings.length,
                    itemBuilder: (context, index) => _buildBookingCard(bookings[index]),
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

  Widget _buildBookingCard(BookingResponse booking) {
    final flight = booking.flight;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: const Icon(Icons.bookmark, color: Colors.blue),
        title: Text(flight != null 
          ? '${flight.departureLocation} -> ${flight.arrivalLocation}'
          : 'Flug Details nicht verfügbar', 
          style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(flight != null 
          ? '${flight.airline} | ${flight.departureDate} ${flight.departureTime}\nGebucht am: ${booking.bookingDate.split('T')[0]}'
          : 'Gebucht am: ${booking.bookingDate.split('T')[0]}'),
        isThreeLine: true,
        trailing: flight != null 
          ? Text('${flight.price.toStringAsFixed(2)} CHF',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16))
          : null,
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
            onPressed: _loadBookings,
            child: const Text('Erneut versuchen'),
          ),
        ],
      ),
    );
  }
}

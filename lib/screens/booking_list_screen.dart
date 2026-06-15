import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/booking_response.dart';
import '../models/flight_filter.dart';
import '../services/booking_service.dart';
import '../services/auth_service.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/flight_filter_widget.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  final BookingService _bookingService = BookingService();
  late Future<List<BookingResponse>> _futureBookings;

  FlightFilter _filter = FlightFilter();
  bool _isFilterVisible = false;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
    final authService = context.read<AuthService>();
    
    if (!authService.isAuthenticated) {
      _futureBookings = Future.error('Nicht angemeldet. Bitte loggen Sie sich ein.');
      return;
    }

    setState(() {
      _futureBookings = _bookingService
          .getMyBookings(authService.token!)
          .then((bookings) => _applyFilter(bookings));
    });
  }

  List<BookingResponse> _applyFilter(List<BookingResponse> bookings) {
    return bookings
        .where((booking) => _filter.matches(booking.flight))
        .toList();
  }

  void _toggleFilterVisibility() {
    setState(() => _isFilterVisible = !_isFilterVisible);
  }

  void _onFilterChanged(FlightFilter newFilter) {
    _filter = newFilter;
    _loadBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (_isFilterVisible) _buildFilterWidget(),
          Expanded(child: _buildBookingList()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Meine Buchungen'),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      actions: [
        IconButton(
          icon: Icon(_isFilterVisible ? Icons.filter_list_off : Icons.filter_list),
          onPressed: _toggleFilterVisibility,
        ),
      ],
    );
  }

  Widget _buildFilterWidget() {
    return FlightFilterWidget(
      initialFilter: _filter,
      buttonLabel: 'Filtern',
      onFilterChanged: _onFilterChanged,
    );
  }

  Widget _buildBookingList() {
    return FutureBuilder<List<BookingResponse>>(
      future: _futureBookings,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return ErrorStateWidget(
            error: snapshot.error.toString(),
            onRetry: _loadBookings,
          );
        }

        final bookings = snapshot.data ?? [];
        if (bookings.isEmpty) {
          return const Center(child: Text('Keine Buchungen gefunden.'));
        }

        return ListView.builder(
          itemCount: bookings.length,
          itemBuilder: (context, index) => _BookingListItem(booking: bookings[index]),
        );
      },
    );
  }
}

class _BookingListItem extends StatelessWidget {
  final BookingResponse booking;

  const _BookingListItem({required this.booking});

  @override
  Widget build(BuildContext context) {
    final flight = booking.flight;
    final bookingDate = booking.bookingDate.split('T')[0];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: const Icon(Icons.bookmark, color: Colors.blue),
        title: Text(
          flight != null
              ? '${flight.departureLocation} -> ${flight.arrivalLocation}'
              : 'Flug Details nicht verfügbar',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          flight != null
              ? '${flight.airline} | ${flight.departureDate} ${flight.departureTime}\nGebucht am: $bookingDate'
              : 'Gebucht am: $bookingDate',
        ),
        isThreeLine: true,
        trailing: flight != null
            ? Text(
                '${flight.price.toStringAsFixed(2)} CHF',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 16,
                ),
              )
            : null,
      ),
    );
  }
}

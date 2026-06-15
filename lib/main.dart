import 'package:flutter/material.dart';
import 'models/flight.dart';
import 'models/user.dart';
import 'models/user_registration.dart';
import 'services/flight_service.dart';
import 'services/auth_service.dart';

// Globaler Service (für dieses Beispiel)
final AuthService authService = AuthService();

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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    try {
      await authService.login(_emailController.text, _passwordController.text);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anmelden')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Passwort'), obscureText: true),
            const SizedBox(height: 20),
            _isLoading 
              ? const CircularProgressIndicator()
              : ElevatedButton(onPressed: _login, child: const Text('Login')),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
              child: const Text('Noch kein Konto? Registrieren'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _register() async {
    setState(() => _isLoading = true);
    try {
      await authService.register(UserRegistration(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrierung erfolgreich! Bitte anmelden.')),
        );
        Navigator.pop(context); // Zurück zum Login
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrieren')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Passwort'), obscureText: true),
            const SizedBox(height: 20),
            _isLoading 
              ? const CircularProgressIndicator()
              : ElevatedButton(onPressed: _register, child: const Text('Registrieren')),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Mein Profil')),
      body: Center(
        child: user == null 
          ? const Text('Nicht angemeldet')
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_circle, size: 100, color: Colors.blue),
                const SizedBox(height: 20),
                Text('Name: ${user.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('Email: ${user.email}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () {
                    authService.logout();
                    Navigator.pop(context, true);
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Abmelden'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade100),
                ),
              ],
            ),
      ),
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
        // Client-seitige Filterung für Felder, die die API (noch) nicht unterstützt
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verfügbare Flüge'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_isFilterVisible ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () {
              setState(() {
                _isFilterVisible = !_isFilterVisible;
              });
            },
          ),
          IconButton(
            icon: Icon(authService.isAuthenticated ? Icons.person : Icons.login),
            onPressed: () async {
              if (authService.isAuthenticated) {
                await Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
              } else {
                await Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
              }
              setState(() {}); // UI aktualisieren falls sich Login-Status geändert hat
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isFilterVisible)
            Padding(
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
                            onChanged: (bool? value) {
                              setState(() {
                                _onlyAvailable = value ?? false;
                              });
                            },
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
            ),
          Expanded(
            child: FutureBuilder<List<Flight>>(
              future: futureFlights,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData) {
                  List<Flight> flights = snapshot.data!;
                  if (flights.isEmpty) {
                    return const Center(child: Text('Keine Flüge gefunden.'));
                  }
                  return ListView.builder(
                    itemCount: flights.length,
                    itemBuilder: (context, index) {
                      Flight flight = flights[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          leading: const Icon(Icons.flight_takeoff),
                          title: Text('${flight.departureLocation} -> ${flight.arrivalLocation}'),
                          subtitle: Text('${flight.airline} | ${flight.departureDate} ${flight.departureTime}\nTickets: ${flight.availableTickets}'),
                          isThreeLine: true,
                          trailing: Text('${flight.price.toStringAsFixed(2)} CHF',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 60),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Fehler: ${snapshot.error}'),
                        ),
                        ElevatedButton(
                          onPressed: _searchFlights,
                          child: const Text('Erneut versuchen'),
                        ),
                      ],
                    ),
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
}

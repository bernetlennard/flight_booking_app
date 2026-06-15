import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'booking_list_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Mein Profil')),
      body: user == null 
          ? const Center(child: Text('Nicht angemeldet'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Icon(Icons.account_circle, size: 80, color: Colors.blue),
                      const SizedBox(height: 10),
                      Text(user.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      Text(user.email, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          authService.logout();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Abmelden'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade100,
                          foregroundColor: Colors.red.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.list_alt),
                  title: const Text('Meine Buchungen'),
                  subtitle: const Text('Alle Ihre getätigten Buchungen ansehen'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BookingListScreen()),
                    );
                  },
                ),
                const Divider(),
              ],
            ),
    );
  }
}

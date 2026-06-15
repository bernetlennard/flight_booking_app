import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    
    return Scaffold(
      appBar: AppBar(title: const Text('Mein Profil')),
      body: Center(
        child: user == null 
          ? const Text('Nicht angemeldet')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_circle, size: 120, color: Colors.blue),
                  const SizedBox(height: 20),
                  Text(user.name, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(user.email, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600])),
                  const SizedBox(height: 48),
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
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}

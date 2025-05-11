import 'package:flutter/material.dart';

class DonationScreen extends StatelessWidget {
  const DonationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donate'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Select a Charity and Amount to Donate',
              style: TextStyle(fontSize: 20),
            ),
            // List of charities can be fetched from a database
            ListTile(
              title: const Text('Charity A'),
              subtitle: const Text('Supports clean water projects'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                // Implement donation logic
              },
            ),
            ListTile(
              title: const Text('Charity B'),
              subtitle: const Text('Supports education for children'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                // Implement donation logic
              },
            ),
          ],
        ),
      ),
    );
  }
}

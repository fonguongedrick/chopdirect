import 'package:chopdirect/models/farmer.dart';
import 'package:chopdirect/screens/buyer/farmer_profile_overview.dart' as farmer_profile;
import 'package:chopdirect/services/firebase_service.dart';
import 'package:flutter/material.dart';

class AllFarmersScreen extends StatelessWidget {
  const AllFarmersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Farmers'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Farmer>>(
        stream: fetchFarmers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading farmers'));
          }
          final farmers = snapshot.data ?? [];
          if (farmers.isEmpty) {
            return const Center(child: Text('No farmers found.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: farmers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final farmer = farmers[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => farmer_profile.FarmerProfileScreen(farmer: farmer),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green[50],
                      child: Text(farmer.image, style: const TextStyle(fontSize: 28)),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            farmer.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        // if (farmer.verified == true)
                          const Padding(
                            padding: EdgeInsets.only(left: 4.0),
                            child: Icon(Icons.verified, color: Colors.blue, size: 18),
                          ),
                      ],
                    ),
                    subtitle: Text(
                      '${farmer.location} • ${farmer.rating.toStringAsFixed(1)} ★',
                      style: const TextStyle(fontSize: 13),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.green),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
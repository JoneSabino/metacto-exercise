import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/feature_model.dart';
import '../utils/device_identifier.dart';
import 'add_feature_screen.dart';

class FeatureListScreen extends StatefulWidget {
  const FeatureListScreen({super.key});

  @override
  _FeatureListScreenState createState() => _FeatureListScreenState();
}

class _FeatureListScreenState extends State<FeatureListScreen> {
  late Future<List<Feature>> _featuresFuture;

  @override
  void initState() {
    super.initState();
    _loadFeatures();
  }

  void _loadFeatures() {
    setState(() {
      _featuresFuture = ApiService.fetchFeatures();
    });
  }

  Future<void> _vote(String featureId) async {
    try {
      final userId = await getDeviceIdentifier();
      await ApiService.voteForFeature(featureId, userId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vote registered!'), backgroundColor: Colors.green),
      );
      _loadFeatures(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString().replaceAll("Exception: ", "")}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feature Suggestions')),
      body: FutureBuilder<List<Feature>>(
        future: _featuresFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No features yet. Be the first!'));
          }

          final features = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _loadFeatures(),
            child: ListView.builder(
              itemCount: features.length,
              itemBuilder: (context, index) {
                final feature = features[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(feature.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(feature.description ?? 'No description.'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(feature.votes.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        SizedBox(
                          height: 30,
                          child: ElevatedButton(
                            onPressed: () => _vote(feature.id),
                            child: const Text('Vote'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddFeatureScreen()),
          );
          // If a feature was added, refresh the list
          if (result == true) {
            _loadFeatures();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
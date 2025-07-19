import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/feature_model.dart';

class ApiService {
  // IMPORTANT: Replace with your actual Render API URL
  static const String _baseUrl = 'YOUR_RENDER_API_URL_HERE';

  static Future<List<Feature>> fetchFeatures() async {
    final response = await http.get(Uri.parse('$_baseUrl/features'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Feature> features =
          body.map((dynamic item) => Feature.fromJson(item)).toList();
      features.sort((a, b) => b.votes.compareTo(a.votes)); // Sort by votes
      print('Fetched ${features.length} features.');
      return features;
    } else {
      print('Failed to load features. Status code: ${response.statusCode}');
      throw Exception('Failed to load features');
    }
  }

  static Future<void> addFeature(String title, String description) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/features'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title, 'description': description}),
    );

    if (response.statusCode == 201) {
      print('Feature added successfully.');
    } else {
      print('Failed to add feature. Status code: ${response.statusCode}');
      throw Exception('Failed to add feature');
    }
  }

  static Future<void> voteForFeature(String featureId, String userId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/features/$featureId/vote'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_identifier': userId}),
    );

    if (response.statusCode == 200) {
      print('Vote registered for feature $featureId.');
    } else {
      // Handle specific error like "Already voted"
      String errorMessage = 'Failed to vote';
      if (response.statusCode == 409) {
        final body = jsonDecode(response.body);
        errorMessage = body['detail'] ?? 'Already voted.';
      }
      print('Failed to vote. Status code: ${response.statusCode}');
      throw Exception(errorMessage);
    }
  }
}
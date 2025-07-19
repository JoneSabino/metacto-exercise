import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddFeatureScreen extends StatefulWidget {
  const AddFeatureScreen({super.key});

  @override
  _AddFeatureScreenState createState() => _AddFeatureScreenState();
}

class _AddFeatureScreenState extends State<AddFeatureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitFeature() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await ApiService.addFeature(
          _titleController.text,
          _descriptionController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feature submitted successfully!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true); // Return true to signal success
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add a New Feature')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                 maxLines: 3,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitFeature,
                      child: const Text('Submit'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
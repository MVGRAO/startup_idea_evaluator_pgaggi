import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/idea.dart';

class IdeaSubmissionScreen extends StatefulWidget {
  static const List<String> categories = [
    'Technology',
    'Health',
    'Education',
    'Finance',
    'Entertainment',
    'General', // Default category
  ];

  final VoidCallback toggleTheme;
  final bool isDarkMode;
  final Function(int) onNavigationChange;

  const IdeaSubmissionScreen({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
    required this.onNavigationChange,
  });

  @override
  State<IdeaSubmissionScreen> createState() => _IdeaSubmissionScreenState();
}

class _IdeaSubmissionScreenState extends State<IdeaSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String _selectedCategory = 'General';

  void _submitIdea() {
    if (_formKey.currentState!.validate()) {
      // Create a new idea with the selected category
      final newIdea = Idea(
        name: _titleController.text,
        tagline: "A great startup idea", // You might want to add a tagline field
        description: _descController.text,
        category: _selectedCategory,
        rating: 0,
        votes: 0,
      );

      // Save the idea to shared preferences
      _saveIdea(newIdea);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Idea Submitted Successfully!")),
      );
      _titleController.clear();
      _descController.clear();
    }
  }

  Future<void> _saveIdea(Idea idea) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('ideas') ?? [];
    stored.add(jsonEncode(idea.toMap()));
    await prefs.setStringList('ideas', stored);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Submit Startup Idea"),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.wb_sunny : Icons.nights_stay),
            onPressed: widget.toggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.lightbulb),
            onPressed: () => widget.onNavigationChange(0), // Navigate to Ideas
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events),
            onPressed: () => widget.onNavigationChange(2), // Navigate to Leaderboard
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center( // Center the form container
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: "Enter your idea title",
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Title cannot be empty" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    hintText: "Describe your idea",
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 5,
                  validator: (value) =>
                      value!.isEmpty ? "Description cannot be empty" : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    hintText: "Select a category",
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: IdeaSubmissionScreen.categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                  },
                  validator: (value) =>
                      value == null ? "Category cannot be empty" : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _submitIdea,
                  icon: const Icon(Icons.send),
                  label: const Text("Submit Idea"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

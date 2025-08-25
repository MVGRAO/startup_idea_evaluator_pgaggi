import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/idea.dart';

class LeaderboardScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;
  final Function(int) onNavigationChange;

  const LeaderboardScreen({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
    required this.onNavigationChange,
  });

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<Idea> _ideas = [];

  @override
  void initState() {
    super.initState();
    _loadIdeas();
  }

  Future<void> _loadIdeas() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('ideas') ?? [];
    final loaded = stored.map((e) => Idea.fromMap(jsonDecode(e))).toList();

    loaded.sort((a, b) => b.votes.compareTo(a.votes));
    setState(() {
      _ideas = loaded.take(5).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
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
            icon: const Icon(Icons.add_circle),
            onPressed: () => widget.onNavigationChange(1), // Navigate to Submit
          ),
        ],
      ),
      body: _ideas.isEmpty
          ? const Center(
              child: Text("No ideas yet to rank ",
                  style: TextStyle(fontSize: 18)),
            )
          : Column(
              children: [
                const SizedBox(height: 20),
                const Icon(Icons.emoji_events,
                    size: 80, color: Colors.amber),
                const Text("Top Startup Ideas",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: _ideas.length,
                    itemBuilder: (context, i) {
                      final idea = _ideas[i];
                      final medal = i == 0
                          ? "🥇"
                          : i == 1
                              ? "🥈"
                              : i == 2
                                  ? "🥉"
                                  : "⭐";
                      return Card(
                        margin:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        child: ListTile(
                          leading: Text(medal, style: const TextStyle(fontSize: 28)),
                          title: Text(idea.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(idea.tagline),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: idea.votes /
                                    (_ideas.first.votes == 0
                                        ? 1
                                        : _ideas.first.votes),
                                color: Colors.deepPurple,
                                backgroundColor: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 4),
                              Text("👍 ${idea.votes} votes | ⭐ ${idea.rating}"),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

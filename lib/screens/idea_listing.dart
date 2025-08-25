import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import '../models/idea.dart';
import 'idea_submission.dart';

class IdeaListingScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;
  final Function(int) onNavigationChange;

  const IdeaListingScreen({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
    required this.onNavigationChange,
  });

  @override
  State<IdeaListingScreen> createState() => _IdeaListingScreenState();
}

class _IdeaListingScreenState extends State<IdeaListingScreen> {
  List<Idea> _ideas = [];
  bool _sortByVotes = true;
  final Map<int, bool> _expanded = {};

  List<String> _categories = IdeaSubmissionScreen.categories;
  String _selectedCategory = 'All'; // For filtering

  @override
  void initState() {
    super.initState();
    _loadIdeas();
  }

  Future<void> _loadIdeas() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('ideas') ?? [];
    final loaded = stored.map((e) => Idea.fromMap(jsonDecode(e))).toList();
    setState(() {
      _ideas = loaded;
      _sortIdeas();
    });
  }

  Future<void> _saveIdeas() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = _ideas.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList('ideas', stored);
  }

  void _sortIdeas() {
    setState(() {
      if (_sortByVotes) {
        _ideas.sort((a, b) => b.votes.compareTo(a.votes));
      } else {
        _ideas.sort((a, b) => b.rating.compareTo(a.rating));
      }
    });
  }

  void _filterIdeas(String category) {
    if (category == 'All') {
      _loadIdeas(); // Reload all ideas
    } else {
      setState(() {
        _ideas = _ideas.where((idea) => idea.category == category).toList();
      });
    }
  }

  void _upvote(Idea idea) {
    setState(() {
      idea.votes++;
    });
    _saveIdeas();
    Fluttertoast.showToast(
      msg: "👍 Upvoted ${idea.name}",
      backgroundColor: Theme.of(context).colorScheme.primary,
      textColor: Theme.of(context).colorScheme.onPrimary,
    );
  }

  void _delete(Idea idea) {
    setState(() {
      _ideas.remove(idea);
    });
    _saveIdeas();
    Fluttertoast.showToast(
      msg: "🗑️ Deleted ${idea.name}",
      backgroundColor: Theme.of(context).colorScheme.error,
      textColor: Theme.of(context).colorScheme.onError,
    );
  }

  void _share(Idea idea) {
    Share.share(
      "Startup Idea: ${idea.name}\n\n${idea.tagline}\n\n${idea.description}\n\n⭐ Rating: ${idea.rating}\n👍 Votes: ${idea.votes}",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup Ideas'),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Toggle Theme',
            icon: Icon(widget.isDarkMode ? Icons.wb_sunny : Icons.nights_stay),
            onPressed: widget.toggleTheme,
          ),
          IconButton(
            tooltip: 'Leaderboard',
            icon: const Icon(Icons.emoji_events_outlined),
            onPressed: () => widget.onNavigationChange(2),
          ),
          IconButton(
            tooltip: 'Add New Idea',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => widget.onNavigationChange(1),
          ),
        ],
      ),
      body: _ideas.isEmpty
          ? Center(
              child: Text(
                "No ideas yet \nSubmit your first one!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7)),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: SegmentedButton<bool>(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.surface.withOpacity(0.1)),
                            foregroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.onSurface),
                          ),
                          segments: const [
                            ButtonSegment(value: true, label: Text("Sort by Votes")),
                            ButtonSegment(value: false, label: Text("Sort by Rating")),
                          ],
                          selected: {_sortByVotes},
                          onSelectionChanged: (s) {
                            setState(() {
                              _sortByVotes = s.first;
                              _sortIdeas();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _selectedCategory,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        dropdownColor: Theme.of(context).colorScheme.surface,
                        items: ['All', ..._categories].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue!;
                            _filterIdeas(_selectedCategory);
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _ideas.length,
                    itemBuilder: (context, i) {
                      final idea = _ideas[i];
                      final expanded = _expanded[i] ?? false;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Theme.of(context).colorScheme.surface,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.shadow.withOpacity(0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                title: Text(
                                  idea.name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Theme.of(context).colorScheme.onSurface),
                                ),
                                subtitle: Text(
                                  idea.tagline,
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.share,
                                          color: Theme.of(context).colorScheme.onSurface),
                                      onPressed: () => _share(idea),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete_forever,
                                          color: Theme.of(context).colorScheme.onSurface),
                                      onPressed: () => _delete(idea),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        _buildInfoChip("⭐ ${idea.rating}"),
                                        _buildInfoChip("👍 ${idea.votes}"),
                                        _buildCategoryChip(idea.category),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context).colorScheme.primary,
                                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30)),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 10),
                                        ),
                                        onPressed: () => _upvote(idea),
                                        icon: const Icon(Icons.thumb_up_alt),
                                        label: const Text("Upvote"),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedCrossFade(
                                firstChild: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    idea.description.length > 120
                                        ? idea.description.substring(0, 120) +
                                            "..."
                                        : idea.description,
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                  ),
                                ),
                                secondChild: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    idea.description,
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                  ),
                                ),
                                crossFadeState: expanded
                                    ? CrossFadeState.showSecond
                                    : CrossFadeState.showFirst,
                                duration: const Duration(milliseconds: 300),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _expanded[i] = !expanded;
                                    });
                                  },
                                  child: Text(
                                    expanded ? "Read less" : "Read more ",
                                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                                  ),
                                ),
                              ),
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

  Widget _buildInfoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer, 
            fontWeight: FontWeight.w600, 
            fontSize: 14),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category,
        style: TextStyle(
            color: Theme.of(context).colorScheme.onSecondaryContainer, 
            fontWeight: FontWeight.w600, 
            fontSize: 14),
      ),
    );
  }
}

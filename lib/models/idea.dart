class Idea {
  String name;
  String tagline;
  String description;
  String category;
  int rating;
  int votes;

  Idea({
    required this.name,
    required this.tagline,
    required this.description,
    required this.category,
    required this.rating,
    this.votes = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'tagline': tagline,
      'description': description,
      'category': category,
      'rating': rating,
      'votes': votes,
    };
  }

  factory Idea.fromMap(Map<String, dynamic> map) {
    return Idea(
      name: map['name'],
      tagline: map['tagline'],
      description: map['description'],
      category: map['category'] ?? 'General', // Handle backward compatibility
      rating: map['rating'],
      votes: map['votes'],
    );
  }
}

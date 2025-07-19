class Feature {
  final String id;
  final String title;
  final String? description;
  final int votes;

  Feature({
    required this.id,
    required this.title,
    this.description,
    required this.votes,
  });

  factory Feature.fromJson(Map<String, dynamic> json) {
    return Feature(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      votes: json['votes'],
    );
  }
}
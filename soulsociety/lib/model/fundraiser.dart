class Fundraiser {
  final String? name;
  final String? description;
  final String? location;
  final String? profileUrl;
  final String? coverImageUrl;

  Fundraiser({
    required this.name,
    this.description,
    this.location,
    this.profileUrl,
    this.coverImageUrl,
  });

  factory Fundraiser.fromJson(Map<String, dynamic> json) {
    return Fundraiser(
      name: json['name'],
      description: json['description'],
      location: json['location'],
      profileUrl: json['profileUrl'],
      coverImageUrl: json['coverImageUrl'],
    );
  }
}

enum MovieType { film, serie }
enum MovieStatus { aVoir, enCours, vu }

class Movie {
  final String id;
  final String title;
  final MovieType type;
  final MovieStatus status;
  final double? rating;
  final String description;
  final String imageUrl;

  Movie({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    this.rating,
    required this.description,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'rating': rating,
      'description': description,
      'imageUrl': imageUrl,
    };
  }

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      type: MovieType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      status: MovieStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      rating: json['rating'],
      description: json['description'],
      imageUrl: json['imageUrl'],
    );
  }
} 
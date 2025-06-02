import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/movie.dart';

class MovieService {
  static const String _moviesKey = 'movies';
  static final _uuid = Uuid();

  static Future<List<Movie>> getMovies() async {
    final prefs = await SharedPreferences.getInstance();
    final moviesJson = prefs.getStringList(_moviesKey) ?? [];
    return moviesJson
        .map((json) => Movie.fromJson(jsonDecode(json)))
        .toList();
  }

  static Future<void> addMovie(Movie movie) async {
    final prefs = await SharedPreferences.getInstance();
    final movies = await getMovies();
    
    final newMovie = Movie(
      id: _uuid.v4(),
      title: movie.title,
      type: movie.type,
      status: movie.status,
      rating: movie.rating,
      description: movie.description,
      imageUrl: movie.imageUrl,
    );

    movies.add(newMovie);
    await _saveMovies(movies);
  }

  static Future<void> updateMovie(Movie movie) async {
    final movies = await getMovies();
    final index = movies.indexWhere((m) => m.id == movie.id);
    if (index != -1) {
      movies[index] = movie;
      await _saveMovies(movies);
    }
  }

  static Future<void> deleteMovie(String id) async {
    final movies = await getMovies();
    movies.removeWhere((movie) => movie.id == id);
    await _saveMovies(movies);
  }

  static Future<void> _saveMovies(List<Movie> movies) async {
    final prefs = await SharedPreferences.getInstance();
    final moviesJson = movies
        .map((movie) => jsonEncode(movie.toJson()))
        .toList();
    await prefs.setStringList(_moviesKey, moviesJson);
  }
} 
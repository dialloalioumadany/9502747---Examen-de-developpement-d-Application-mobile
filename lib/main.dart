import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/movie_form.dart';
import 'services/auth_service.dart';
import 'services/movie_service.dart';
import 'models/movie.dart';
import 'widgets/auth_guard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ma Collection de Films',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const AuthGuard(
              child: MyHomePage(title: 'Ma Collection'),
            ),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/edit-movie') {
          final movie = settings.arguments as Movie;
          return MaterialPageRoute(
            builder: (context) => MovieForm(
              movie: movie,
              onSubmit: (updatedMovie) async {
                await MovieService.updateMovie(updatedMovie);
                if (context.mounted) {
                  Navigator.pop(context, updatedMovie);
                }
              },
            ),
          );
        }
        return null;
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Movie> _movies = [];
  List<Movie> _filteredMovies = [];
  bool _isLoading = true;
  MovieType? _selectedType;
  MovieStatus? _selectedStatus;

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    setState(() => _isLoading = true);
    try {
      final movies = await MovieService.getMovies();
      setState(() {
        _movies = movies;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors du chargement des films')),
        );
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredMovies = _movies.where((movie) {
        if (_selectedType != null && movie.type != _selectedType) {
          return false;
        }
        if (_selectedStatus != null && movie.status != _selectedStatus) {
          return false;
        }
        return true;
      }).toList();
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filtrer les films'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<MovieType?>(
                value: _selectedType,
                isExpanded: true,
                hint: const Text('Tous les types'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Tous les types'),
                  ),
                  ...MovieType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type == MovieType.film ? 'Film' : 'Série'),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() => _selectedType = value);
                },
              ),
              const SizedBox(height: 16),
              const Text('Statut', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<MovieStatus?>(
                value: _selectedStatus,
                isExpanded: true,
                hint: const Text('Tous les statuts'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Tous les statuts'),
                  ),
                  ...MovieStatus.values.map((status) {
                    String statusText;
                    switch (status) {
                      case MovieStatus.aVoir:
                        statusText = 'À voir';
                        break;
                      case MovieStatus.enCours:
                        statusText = 'En cours';
                        break;
                      case MovieStatus.vu:
                        statusText = 'Vu';
                        break;
                    }
                    return DropdownMenuItem(
                      value: status,
                      child: Text(statusText),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() => _selectedStatus = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                this.setState(() {
                  _selectedType = null;
                  _selectedStatus = null;
                });
                _applyFilters();
                Navigator.pop(context);
              },
              child: const Text('Réinitialiser'),
            ),
            ElevatedButton(
              onPressed: () {
                this.setState(() {});
                _applyFilters();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Appliquer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addMovie() async {
    final result = await Navigator.push<Movie>(
      context,
      MaterialPageRoute(
        builder: (context) => MovieForm(
          onSubmit: (movie) async {
            await MovieService.addMovie(movie);
            if (mounted) {
              Navigator.pop(context, movie);
            }
          },
        ),
      ),
    );

    if (result != null) {
      _loadMovies();
    }
  }

  Future<void> _editMovie(Movie movie) async {
    final result = await Navigator.push<Movie>(
      context,
      MaterialPageRoute(
        builder: (context) => MovieForm(
          movie: movie,
          onSubmit: (updatedMovie) async {
            await MovieService.updateMovie(updatedMovie);
            if (mounted) {
              Navigator.pop(context, updatedMovie);
            }
          },
        ),
      ),
    );

    if (result != null) {
      _loadMovies();
    }
  }

  Future<void> _deleteMovie(Movie movie) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer "${movie.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await MovieService.deleteMovie(movie.id);
      _loadMovies();
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filtrer',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Se déconnecter',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredMovies.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _movies.isEmpty
                            ? 'Aucun film dans votre collection'
                            : 'Aucun film ne correspond aux filtres',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      if (_movies.isEmpty)
                        ElevatedButton.icon(
                          onPressed: _addMovie,
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter un film'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        )
                      else
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedType = null;
                              _selectedStatus = null;
                            });
                            _applyFilters();
                          },
                          icon: const Icon(Icons.clear),
                          label: const Text('Réinitialiser les filtres'),
                        ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _filteredMovies.length,
                  itemBuilder: (context, index) {
                    final movie = _filteredMovies[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            movie.imageUrl,
                            width: 60,
                            height: 90,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 60,
                                height: 90,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              print('Erreur de chargement de l\'image: $error');
                              return Container(
                                width: 60,
                                height: 90,
                                color: Colors.grey[300],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.movie, size: 24),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Erreur',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        title: Text(
                          movie.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(context, Icons.movie, 'Type', movie.type == MovieType.film ? 'Film' : 'Série'),
                            _buildInfoRow(context, Icons.visibility, 'Statut', movie.status == MovieStatus.aVoir ? 'À voir' : movie.status == MovieStatus.enCours ? 'En cours' : 'Vu'),
                            if (movie.rating != null) _buildInfoRow(context, Icons.star, 'Note', '${movie.rating!.toStringAsFixed(1)}/5'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editMovie(movie),
                              tooltip: 'Modifier',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteMovie(movie),
                              tooltip: 'Supprimer',
                              color: Colors.red,
                            ),
                          ],
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                                  child: Image.network(
                                                    movie.imageUrl,
                                                    width: double.infinity,
                                                    height: 200,
                                                    fit: BoxFit.cover,
                                                    loadingBuilder: (context, child, loadingProgress) {
                                                      if (loadingProgress == null) return child;
                                                      return Container(
                                                        width: double.infinity,
                                                        height: 200,
                                                        color: Colors.grey[200],
                                                        child: const Center(
                                                          child: CircularProgressIndicator(),
                                                        ),
                                                      );
                                                    },
                                                    errorBuilder: (context, error, stackTrace) {
                                                      print('Erreur de chargement de l\'image: $error');
                                                      return Container(
                                                        width: double.infinity,
                                                        height: 200,
                                                        color: Colors.grey[300],
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            const Icon(Icons.movie, size: 48),
                                                            const SizedBox(height: 8),
                                                            Text(
                                                              'Erreur de chargement de l\'image',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors.grey[600],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 8,
                                                  right: 8,
                                                  child: IconButton(
                                                    icon: const Icon(Icons.close, color: Colors.white),
                                                    onPressed: () => Navigator.pop(context),
                                                    style: IconButton.styleFrom(
                                                      backgroundColor: Colors.black54,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    movie.title,
                                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  _buildInfoRow(context, Icons.movie, 'Type', movie.type == MovieType.film ? 'Film' : 'Série'),
                                                  const SizedBox(height: 8),
                                                  _buildInfoRow(context, Icons.visibility, 'Statut', movie.status == MovieStatus.aVoir ? 'À voir' : movie.status == MovieStatus.enCours ? 'En cours' : 'Vu'),
                                                  if (movie.rating != null) ...[
                                                    const SizedBox(height: 8),
                                                    _buildInfoRow(context, Icons.star, 'Note', '${movie.rating!.toStringAsFixed(1)}/5'),
                                                  ],
                                                  const SizedBox(height: 16),
                                                  const Text(
                                                    'Description/Commentaire',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    movie.description,
                                                    style: const TextStyle(fontSize: 14),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMovie,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

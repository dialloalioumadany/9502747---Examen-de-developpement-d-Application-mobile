import 'package:flutter/material.dart';
import '../models/movie.dart';

class MovieForm extends StatefulWidget {
  final Movie? movie;
  final Function(Movie) onSubmit;

  const MovieForm({
    Key? key,
    this.movie,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<MovieForm> createState() => _MovieFormState();
}

class _MovieFormState extends State<MovieForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController;
  late MovieType _type;
  late MovieStatus _status;
  double? _rating;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.movie?.title ?? '');
    _descriptionController = TextEditingController(text: widget.movie?.description ?? '');
    _imageUrlController = TextEditingController(text: widget.movie?.imageUrl ?? '');
    _type = widget.movie?.type ?? MovieType.film;
    _status = widget.movie?.status ?? MovieStatus.aVoir;
    _rating = widget.movie?.rating;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final movie = Movie(
        id: widget.movie?.id ?? '',
        title: _titleController.text,
        type: _type,
        status: _status,
        rating: _rating,
        description: _descriptionController.text,
        imageUrl: _imageUrlController.text,
      );
      widget.onSubmit(movie);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie == null ? 'Ajouter un film' : 'Modifier le film'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<MovieType>(
                value: _type,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                items: MovieType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type == MovieType.film ? 'Film' : 'Série'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _type = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<MovieStatus>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Statut',
                  border: OutlineInputBorder(),
                ),
                items: MovieStatus.values.map((status) {
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
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _status = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL de l\'image',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une URL d\'image';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description/Commentaire',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Note (optionnelle): '),
                  Expanded(
                    child: Slider(
                      value: _rating ?? 0,
                      min: 0,
                      max: 5,
                      divisions: 10,
                      label: _rating?.toStringAsFixed(1) ?? '0',
                      onChanged: (value) {
                        setState(() => _rating = value);
                      },
                    ),
                  ),
                  Text(_rating?.toStringAsFixed(1) ?? '0'),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  widget.movie == null ? 'Ajouter' : 'Modifier',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
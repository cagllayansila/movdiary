import 'package:flutter/material.dart';
import 'package:movdiary/providers/app_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/movie.dart';
import '../models/post_model.dart';
import '../utils/responsive.dart';

class AddScreen extends StatefulWidget {
  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  int selectedRating = 0;
  File? selectedImage;
  Movie? selectedMovie;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController commentController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  List<Movie> searchResults = [];
  bool isSearching = false;

  final String apiKey = '8265bd1679663a7ea12ac168da84d2e8';
  final String baseUrl = 'https://api.themoviedb.org/3';
  final String imgBaseUrl = 'https://image.tmdb.org/t/p/w500';

  @override
  void dispose() {
    commentController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> searchMovies(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
      return;
    }

    setState(() => isSearching = true);
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search/movie?api_key=$apiKey&language=tr-TR&query=$query'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final movieList = (data['results'] as List)
            .take(10)
            .map((json) => Movie.fromJson(json))
            .toList();
        setState(() {
          searchResults = movieList;
          isSearching = false;
        });
      }
    } catch (e) {
      print('Hata: $e');
      setState(() => isSearching = false);
    }
  }

  Future<void> pickImage() async {
    final status = await Permission.photos.request();

    if (status.isGranted) {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
        });
      }
    } else if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fotoğraf erişim izni gerekli')),
      );
    } else if (status.isPermanentlyDenied) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('İzin Gerekli'),
          content: Text(
              'Fotoğraf eklemek için uygulama ayarlarından izin vermeniz gerekiyor.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                openAppSettings();
                Navigator.pop(context);
              },
              child: Text('Ayarlara Git'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> handleShare() async {
    if (selectedMovie == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen bir film seçin')),
      );
      return;
    }

    if (commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen bir yorum yazın')),
      );
      return;
    }

    if (selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen bir puan verin')),
      );
      return;
    }

    final provider = context.read<AppProvider>();

    try {
      final post = PostModel(
        id: '',
        userId: provider.currentUser!.uid,
        username: provider.username,
        movieTitle: selectedMovie!.title,
        comment: commentController.text.trim(),
        rating: selectedRating,
        imageUrl: selectedImage?.path,
        createdAt: DateTime.now(),
        likes: 0,
      );

      await provider.addPost(post);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gönderi Paylaşıldı!'), backgroundColor: Colors.green),
      );

      // Formu temizle
      setState(() {
        selectedMovie = null;
        selectedImage = null;
        selectedRating = 0;
        commentController.clear();
        searchController.clear();
        searchResults = [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.getHorizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Paylaş'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Film Seç', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Film ara...',
                    suffixIcon: isSearching
                        ? Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : Icon(Icons.search),
                  ),
                  onChanged: searchMovies,
                ),
                if (selectedMovie != null)
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        if (selectedMovie!.posterPath.isNotEmpty)
                          Image.network(
                            '$imgBaseUrl${selectedMovie!.posterPath}',
                            width: 40,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedMovie!.title,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                selectedMovie!.releaseDate.isNotEmpty
                                    ? selectedMovie!.releaseDate.split('-').first
                                    : '',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => setState(() => selectedMovie = null),
                        ),
                      ],
                    ),
                  ),
                if (searchResults.isNotEmpty && selectedMovie == null)
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final movie = searchResults[index];
                        return ListTile(
                          leading: movie.posterPath.isNotEmpty
                              ? Image.network(
                                  '$imgBaseUrl${movie.posterPath}',
                                  width: 40,
                                  fit: BoxFit.cover,
                                )
                              : Icon(Icons.movie),
                          title: Text(movie.title),
                          subtitle: Text(
                            movie.releaseDate.isNotEmpty
                                ? movie.releaseDate.split('-').first
                                : '',
                          ),
                          onTap: () {
                            setState(() {
                              selectedMovie = movie;
                              searchResults = [];
                              searchController.clear();
                            });
                          },
                        );
                      },
                    ),
                  ),
                SizedBox(height: 16),
                Text('Yorumunuz', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                TextField(
                  controller: commentController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Film hakkında düşüncelerinizi paylaşın...',
                  ),
                ),
                SizedBox(height: 16),
                Text('Puan', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Row(
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < selectedRating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                      onPressed: () => setState(() => selectedRating = index + 1),
                    );
                  }),
                ),
                SizedBox(height: 16),
                if (selectedImage != null) ...[
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(selectedImage!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: pickImage,
                    icon: Icon(Icons.photo_camera),
                    label: Text(
                      selectedImage == null ? 'Fotoğraf Ekle' : 'Fotoğrafı Değiştir',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.all(16),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: handleShare,
                    child: Text('Paylaş'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
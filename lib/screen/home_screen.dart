import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert' show json;
import '../models/movie.dart';
import '../utils/responsive.dart';
import 'notifications_screen.dart';
import 'package:movdiary/providers/app_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Movie> movies = [];
  List<Movie> searchSuggestions = [];
  bool isLoading = true;
  bool showSearch = false;
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  final String apiKey = '8265bd1679663a7ea12ac168da84d2e8';
  final String baseUrl = 'https://api.themoviedb.org/3';
  final String imgBaseUrl = 'https://image.tmdb.org/t/p/w500';

  @override
  void initState() {
    super.initState();
    fetchPopularMovies();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchPopularMovies() async {
    // Sayfa kapaliysa i;lem yapma
 
    if (!mounted) return;
    setState(() => isLoading = true);
    try { 
      final response = await http.get(
        Uri.parse('$baseUrl/movie/popular?api_key=$apiKey&language=tr-TR&page=1'),
      );
      
      // Veri geldiginde sayfa hala acik mi? (KRITIK DUZELTME)
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final movieList = (data['results'] as List)
            .take(12)
            .map((json) => Movie.fromJson(json))
            .toList();
            
        setState(() {
          movies = movieList;
          isLoading = false;
        });

          if (mounted) {
             context.read<AppProvider>().updateMovies(movieList);
          }
      }
    } catch (e) {
      print('Hata: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> searchMovies(String query) async {
    if (!mounted) return;

    if (query.trim().isEmpty) {
      setState(() {
        searchSuggestions = [];
        isSearching = false;
      });
      return;
    }

    setState(() => isSearching = true);
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search/movie?api_key=$apiKey&language=tr-TR&query=$query'),
      );

      // Arama sonucu geldiÄŸinde sayfa hala aÃ§Ä±k mÄ±? (KRÄ°TÄ°K DÃœZELTME)
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final movieList = (data['results'] as List)
            .take(5)
            .map((json) => Movie.fromJson(json))
            .toList();
            
        setState(() {
          searchSuggestions = movieList;
          isSearching = false;
        });
      }
    } catch (e) {
      print('Hata: $e');
      if (mounted) {
        setState(() => isSearching = false);
      }
    }
  }

  void selectMovie(Movie movie) {
    if (!mounted) return;
    
    setState(() {
      movies = [movie];
      showSearch = false;
      searchController.clear();
      searchSuggestions = [];
    });
    context.read<AppProvider>().updateMovies([movie]);
  }

  int get unreadCount {
    // Provider'Ä± gÃ¼venli bir ÅŸekilde dinlemek iÃ§in
    try {
       return context.watch<AppProvider>().notifications
        .where((n) => !n.isRead).length;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final crossAxisCount = Responsive.getGridCrossAxisCount(context);
    final padding = Responsive.getHorizontalPadding(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (showSearch)
              Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Film ara...',
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              showSearch = false;
                              searchController.clear();
                              searchSuggestions = [];
                            });
                            fetchPopularMovies();
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: searchMovies,
                    ),
                    if (isSearching)
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(),
                      ),
                    if (searchSuggestions.isNotEmpty && !isSearching)
                      Card(
                        margin: EdgeInsets.only(top: 8),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: searchSuggestions.length,
                          itemBuilder: (context, index) {
                            final movie = searchSuggestions[index];
                            return ListTile(
                              leading: movie.posterPath.isNotEmpty
                                  ? Image.network(
                                      '$imgBaseUrl${movie.posterPath}',
                                      width: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Icon(Icons.movie),
                                    )
                                  : Icon(Icons.movie),
                              title: Text(movie.title),
                              subtitle: Text(
                                movie.releaseDate.isNotEmpty
                                    ? movie.releaseDate.split('-').first
                                    : '',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star, color: Colors.amber, size: 16),
                                  Text(movie.voteAverage.toStringAsFixed(1)),
                                ],
                              ),
                              onTap: () => selectMovie(movie),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            if (!showSearch)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: padding, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Popüler Filmler',
                      style: TextStyle(
                        fontSize: Responsive.getFontSize(context, 24),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.search, size: 28),
                          onPressed: () => setState(() => showSearch = true),
                        ),
                        Stack(
                          children: [
                            IconButton(
                              icon: Icon(Icons.notifications_outlined, size: 28),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NotificationsScreen(notifications: [], onRead: () {  },),
                                  ),
                                );
                              },
                            ),
                            if (unreadCount > 0)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  child: Text(
                                    unreadCount.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      padding: EdgeInsets.all(padding),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.6,
                      ),
                      itemCount: movies.length,
                      itemBuilder: (context, index) {
                        final movie = movies[index];
                        final isSaved = provider.savedMovies.contains(movie.id);
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: movie.posterPath.isNotEmpty
                                        ? Image.network(
                                            '$imgBaseUrl${movie.posterPath}',
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.purple[200],
                                                child: Center(child: Icon(Icons.broken_image, size: 50)),
                                              );
                                            },
                                          )
                                        : Container(
                                            color: Colors.purple[200],
                                            child: Center(
                                              child: Icon(Icons.movie, size: 50),
                                            ),
                                          ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          movie.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              movie.releaseDate.isNotEmpty
                                                  ? movie.releaseDate.split('-').first
                                                  : '',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 11,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Icon(Icons.star,
                                                    color: Colors.amber, size: 14),
                                                Text(
                                                  movie.voteAverage.toStringAsFixed(1),
                                                  style: TextStyle(fontSize: 11),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => provider.toggleSaveMovie(movie.id),
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isSaved ? Icons.favorite : Icons.favorite_border,
                                      color: isSaved ? Colors.red : Colors.grey,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
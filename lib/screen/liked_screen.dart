import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movdiary/providers/app_provider.dart';
import '../utils/responsive.dart';

class LikedScreen extends StatelessWidget {
  const LikedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Favoriler'),
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.purple,
            labelColor: Colors.purple,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.movie), text: 'Filmler'),
              Tab(icon: Icon(Icons.article), text: 'Gönderiler'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _MoviesTab(),
            _PostsTab(),
          ],
        ),
      ),
    );
  }
}

// Filmler sekmesi için ayrı widget - context.watch ile otomatik güncelleme
class _MoviesTab extends StatelessWidget {
  const _MoviesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Her değişiklikte bu widget yeniden build edilecek
    final provider = context.watch<AppProvider>();
    final savedMovieIds = provider.savedMovies;
    final allMovies = provider.allMovies;
    
    // Debug için
    print('🎬 Favori film sayısı: ${savedMovieIds.length}');
    print('📽️ Toplam film sayısı: ${allMovies.length}');
    
    // Favorilere eklenen filmleri filtrele
    final likedMovies = allMovies
        .where((movie) => savedMovieIds.contains(movie.id))
        .toList();
    
    print('❤️ Filtrelenmiş favori filmler: ${likedMovies.length}');

    const imgBaseUrl = 'https://image.tmdb.org/t/p/w500';
    final crossAxisCount = Responsive.getGridCrossAxisCount(context);
    final padding = Responsive.getHorizontalPadding(context);

    // Eğer favori film yoksa
    if (likedMovies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Henüz kaydedilmiş film yok',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Ana sayfadan filmleri favorilere eklemek için kalp ikonuna dokunun',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Favori filmler grid'i
    return GridView.builder(
      padding: EdgeInsets.all(padding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.6,
      ),
      itemCount: likedMovies.length,
      itemBuilder: (context, index) {
        final movie = likedMovies[index];
        final isSaved = savedMovieIds.contains(movie.id);
        
        return Card(
          clipBehavior: Clip.antiAlias,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster
                  Expanded(
                    child: movie.posterPath.isNotEmpty
                        ? Image.network(
                            '$imgBaseUrl${movie.posterPath}',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.purple[100],
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.purple[100],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.purple[100],
                            child: const Center(
                              child: Icon(Icons.movie, size: 50, color: Colors.grey),
                            ),
                          ),
                  ),
                  // Film bilgileri
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              movie.releaseDate.isNotEmpty
                                  ? movie.releaseDate.split('-').first
                                  : 'N/A',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 14,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  movie.voteAverage.toStringAsFixed(1),
                                  style: const TextStyle(fontSize: 11),
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
              // Favori butonu (sağ üst köşe)
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // Favorilerden çıkar
                      provider.toggleSaveMovie(movie.id);
                      
                      // Kullanıcıya geri bildirim
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${movie.title} favorilerden çıkarıldı'),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isSaved ? Icons.favorite : Icons.favorite_border,
                        color: isSaved ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Gönderiler sekmesi için ayrı widget
class _PostsTab extends StatelessWidget {
  const _PostsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final userPosts = provider.userPosts;
    final padding = Responsive.getHorizontalPadding(context);

    if (userPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Henüz gönderi yok',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'İlk gönderinizi paylaşın!',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(padding),
      itemCount: userPosts.length,
      itemBuilder: (context, index) {
        final post = userPosts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kullanıcı bilgisi
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      child: Text(
                        post.username.isNotEmpty
                            ? post.username[0].toUpperCase()
                            : '?',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.username,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            _formatDate(post.createdAt),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Gönderi görseli
                if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      post.imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.purple, Colors.pink],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(Icons.broken_image, size: 50, color: Colors.white),
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.purple, Colors.pink],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('🎬', style: TextStyle(fontSize: 50)),
                    ),
                  ),
                const SizedBox(height: 12),
                // Film başlığı
                Text(
                  post.movieTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                // Yıldız puanı
                Row(
                  children: List.generate(5, (i) {
                    return Icon(
                      Icons.star,
                      size: 20,
                      color: i < post.rating ? Colors.amber : Colors.grey[300],
                    );
                  }),
                ),
                const SizedBox(height: 8),
                // Yorum
                Text(
                  post.comment,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 12),
                // Beğeni sayısı
                Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.red, size: 20),
                    const SizedBox(width: 4),
                    Text('${post.likes} beğeni'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }
}
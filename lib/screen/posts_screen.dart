import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movdiary/providers/app_provider.dart';
import '../utils/responsive.dart';

class PostsScreen extends StatelessWidget {
  const PostsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. Provider'dan gerçek verileri çekiyoruz
    final provider = context.watch<AppProvider>();
    final providerPosts = provider.allPosts;
    
    final padding = Responsive.getHorizontalPadding(context);

    // 2. Manuel (Sabit) Verileriniz
    final List<Map<String, dynamic>> manualPosts = [
      {
        'user': 'Ahmet K.',
        'movie': 'Inception',
        'comment': 'Muhteşem bir film! Akıl oyunları severseniz mutlaka izleyin.',
        'time': '2 saat önce',
        'likes': 24,
        'rating': 5,
        'image': 'https://image.tmdb.org/t/p/w500/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg'
      },
      {
        'user': 'Zeynep M.',
        'movie': 'The Godfather',
        'comment': 'Klasiklerin klasiği. Her izleyişimde yeni detaylar keşfediyorum.',
        'time': '5 saat önce',
        'likes': 18,
        'rating': 5,
        'image': null
      },
      {
        'user': 'Can Y.',
        'movie': 'Pulp Fiction',
        'comment': 'Tarantino\'nun en iyi işi. Diyaloglar efsane!',
        'time': '1 gün önce',
        'likes': 31,
        'rating': 4,
        'image': 'https://image.tmdb.org/t/p/w500/d5iIlFn5s0ImszYzBPb8JPIfbXD.jpg'
      },
    ];

    // 3. Provider verilerini Manuel veri formatına (Map'e) dönüştürüyoruz
    // Böylece tek bir liste yapısında birleştirebiliriz.
    final List<Map<String, dynamic>> convertedProviderPosts = providerPosts.map((post) {
      return {
        'user': post.username,
        'movie': post.movieTitle,
        'comment': post.comment,
        'time': _formatDate(post.createdAt), // Tarihi string'e çeviriyoruz
        'likes': post.likes,
        'rating': post.rating,
        'image': post.imageUrl,
      };
    }).toList();

    // 4. İki listeyi birleştiriyoruz (Önce Provider'dan gelenler, sonra manueller veya tam tersi)
    // [...convertedProviderPosts, ...manualPosts] -> Yeni eklenenler en üstte görünür
    final allCombinedPosts = [...convertedProviderPosts, ...manualPosts];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keşfet'),
        elevation: 0,
      ),
      body: allCombinedPosts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.explore, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Henüz gönderi yok', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(padding),
              itemCount: allCombinedPosts.length,
              itemBuilder: (context, index) {
                final post = allCombinedPosts[index];

                return GestureDetector(
                  onTap: () => _showPostDetailDialog(context, post),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- Kullanıcı Bilgisi ---
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                                child: Text(post['user'][0].toUpperCase()),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      post['user'],
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      post['time'],
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // --- Görsel ---
                          if (post['image'] != null && post['image'].isNotEmpty)
                            Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(post['image']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          else
                            Container(
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.purple, Colors.pink],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text('🎬', style: TextStyle(fontSize: 40)),
                              ),
                            ),
                          const SizedBox(height: 12),

                          // --- İçerik ---
                          Text(
                            post['movie'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            post['comment'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 12),

                          // --- Alt Bilgiler ---
                          Row(
                            children: [
                              const Icon(Icons.favorite, color: Colors.red, size: 20),
                              const SizedBox(width: 4),
                              Text('${post['likes']} beğeni'),
                              const Spacer(),
                              const Text(
                                'Detay için tıklayın',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  // Tarih formatlayıcı (Provider verisi için gerekli)
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

  // Detay Diyaloğu
  void _showPostDetailDialog(BuildContext context, Map<String, dynamic> post) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      child: Text(post['user'][0].toUpperCase()),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post['user'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            post['time'],
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (post['image'] != null && post['image'].isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      post['image'],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  post['movie'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (i) {
                    return Icon(
                      Icons.star,
                      size: 20,
                      color: i < post['rating'] ? Colors.amber : Colors.grey[300],
                    );
                  }),
                ),
                const SizedBox(height: 12),
                Text(
                  post['comment'],
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.red, size: 24),
                    const SizedBox(width: 6),
                    Text('${post['likes']} beğeni', style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
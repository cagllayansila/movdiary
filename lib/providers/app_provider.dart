import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie.dart';
import '../models/notification_model.dart';
import '../models/post_model.dart';

class AppProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User state
  User? _currentUser;
  String _username = 'Kullanıcı';
  bool _isLoading = false;

  // Movie state
  List<Movie> _movies = [];
  List<Movie> _allMovies = [];
  Set<int> _savedMovies = {};

  // Post state
  List<PostModel> _userPosts = [];
  List<PostModel> _allPosts = [];

  // Notification state
  List<AppNotification> _notifications = [];

  // Theme state
  ThemeMode _themeMode = ThemeMode.light;

  // Getters
  User? get currentUser => _currentUser;
  String get username => _username;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  List<Movie> get movies => _movies;
  List<Movie> get allMovies => _allMovies;
  Set<int> get savedMovies => _savedMovies;
  List<PostModel> get userPosts => _userPosts;
  List<PostModel> get allPosts => _allPosts;
  List<AppNotification> get notifications => _notifications;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  AppProvider() {
    _initializeAuth();
    _loadAllPosts();
  }

  void _initializeAuth() {
    _auth.authStateChanges().listen((User? user) {
      _currentUser = user;
      if (user != null) {
        _loadUserData();
      }
      notifyListeners();
    });
  }


  // Auth Methods
  Future<String?> signUp(String email, String password, String username) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': username,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _username = username;
      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      if (e.code == 'weak-password') {
        return 'Şifre çok zayıf';
      } else if (e.code == 'email-already-in-use') {
        return 'Bu email zaten kullanımda';
      }
      return 'Kayıt başarısız: ${e.message}';
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Bir hata oluştu';
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      if (e.code == 'user-not-found') {
        return 'Kullanıcı bulunamadı';
      } else if (e.code == 'wrong-password') {
        return 'Hatalı şifre';
      }
      return 'Giriş başarısız: ${e.message}';
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Bir hata oluştu';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _username = 'Kullanıcı';
    _savedMovies.clear();
    _userPosts.clear();
    notifyListeners();
  }
  // app_provider.dart dosyanÄ±za bu fonksiyonu ekleyin
// signOut() fonksiyonundan sonra ekleyebilirsiniz

Future<void> updateUsername(String newUsername) async {
  if (_currentUser == null) return;

  try {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .update({'username': newUsername});

    _username = newUsername;
    notifyListeners();

    // KullanÄ±cÄ±nÄ±n tÃ¼m postlarÄ±ndaki username'i de gÃ¼ncelle
    final userPosts = await _firestore
        .collection('posts')
        .where('userId', isEqualTo: _currentUser!.uid)
        .get();

    final batch = _firestore.batch();
    for (var doc in userPosts.docs) {
      batch.update(doc.reference, {'username': newUsername});
    }
    await batch.commit();

    // Local postlarÄ± da gÃ¼ncelle
    _userPosts = _userPosts.map((post) {
      if (post.userId == _currentUser!.uid) {
        return PostModel(
          id: post.id,
          userId: post.userId,
          username: newUsername,
          movieTitle: post.movieTitle,
          comment: post.comment,
          rating: post.rating,
          imageUrl: post.imageUrl,
          createdAt: post.createdAt,
          likes: post.likes,
        );
      }
      return post;
    }).toList();

    _allPosts = _allPosts.map((post) {
      if (post.userId == _currentUser!.uid) {
        return PostModel(
          id: post.id,
          userId: post.userId,
          username: newUsername,
          movieTitle: post.movieTitle,
          comment: post.comment,
          rating: post.rating,
          imageUrl: post.imageUrl,
          createdAt: post.createdAt,
          likes: post.likes,
        );
      }
      return post;
    }).toList();

    notifyListeners();
  } catch (e) {
    print('Kullanıcı adı güncellenemedi: $e');
    rethrow;
  }
}

  Future<void> _loadUserData() async {
    if (_currentUser == null) return;

    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      if (userDoc.exists) {
        _username = userDoc.data()?['username'] ?? 'Kullanıcı';
      }

      await _loadSavedMovies();
      await _loadUserPosts();
      notifyListeners();
    } catch (e) {
      print('Kullanıcı verisi yüklenemedi: $e');
    }
  }

  Future<void> _loadSavedMovies() async {
    if (_currentUser == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('savedMovies')
          .get();

      _savedMovies = snapshot.docs.map((doc) => doc.data()['movieId'] as int).toSet();
      notifyListeners();
    } catch (e) {
      print('Kaydedilen filmler yüklenemedi: $e');
    }
  }

  Future<void> _loadUserPosts() async {
    if (_currentUser == null) return;

    try {
      final snapshot = await _firestore
          .collection('posts')
          .where('userId', isEqualTo: _currentUser!.uid)
          .orderBy('createdAt', descending: true)
          .get();

      _userPosts = snapshot.docs
          .map((doc) => PostModel.fromFirestore(doc))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Gönderiler yüklenemedi: $e');
    }
  }

  Future<void> _loadAllPosts() async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      _allPosts = snapshot.docs
          .map((doc) => PostModel.fromFirestore(doc))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Tüm gönderiler yüklenemedi: $e');
    }
  }

  // Movie Methods
  void updateMovies(List<Movie> movies) {
    _movies = movies;
    for (var movie in movies) {
      if (!_allMovies.any((m) => m.id == movie.id)) {
        _allMovies.add(movie);
      }
    }
    notifyListeners();
  }

  Future<void> toggleSaveMovie(int movieId) async {
 
  if (_currentUser == null) return; 

  // 1. Önce YEREL işlemi yap ve EKRANI GÜNCELLE
  if (_savedMovies.contains(movieId)) {
    _savedMovies.remove(movieId);
    notifyListeners(); // <--- Kalp hemen söner

    // 2. Sonra veritabanı işlemini yap
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid) 
        .collection('savedMovies')
        .doc(movieId.toString())
        .delete();
  } else {
    _savedMovies.add(movieId);
    notifyListeners(); // <--- Kalp hemen dolar

    // 2. Veritabanı işlemi
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid) 
        .collection('savedMovies')
        .doc(movieId.toString())
        .set({'movieId': movieId});
  }
}

  // Post Methods
  Future<void> addPost(PostModel post) async {
    if (_currentUser == null) return;

    try {
      final docRef = await _firestore.collection('posts').add({
        'userId': _currentUser!.uid,
        'username': _username,
        'movieTitle': post.movieTitle,
        'comment': post.comment,
        'rating': post.rating,
        'imageUrl': post.imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'likes': 0,
      });

      final newPost = PostModel(
        id: docRef.id,
        userId: _currentUser!.uid,
        username: _username,
        movieTitle: post.movieTitle,
        comment: post.comment,
        rating: post.rating,
        imageUrl: post.imageUrl,
        createdAt: DateTime.now(),
        likes: 0,
      );

      _userPosts.insert(0, newPost);
      _allPosts.insert(0, newPost);
      notifyListeners();
    } catch (e) {
      print('Gonderi eklenemedi: $e');
      rethrow;
    }
  }

  // Notification Methods
  void markNotificationsAsRead() {
    _notifications = _notifications.map((n) => AppNotification(
      user: n.user,
      action: n.action,
      movieTitle: n.movieTitle,
      time: n.time,
      isRead: true,
    )).toList();
    notifyListeners();
  }

  // Theme Methods
  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
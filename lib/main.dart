import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movdiary/providers/app_provider.dart';
import 'package:movdiary/screen/auth/login_screen.dart';
import 'package:movdiary/screen/main_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Giriş ekranını görebilmek için geçici çıkış kodu
  await FirebaseAuth.instance.signOut(); 

  runApp(const MovieDiaryApp());
}

class MovieDiaryApp extends StatelessWidget {
  const MovieDiaryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      // BAK BURASI ÇOK ÖNEMLİ: Consumer DEĞİL Selector OLACAK
      child: Selector<AppProvider, ThemeMode>(
        selector: (context, provider) => provider.themeMode,
        builder: (context, themeMode, child) {
          return MaterialApp(
            title: 'Movie Diary',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: ThemeData(
              primarySwatch: Colors.purple,
              brightness: Brightness.light,
              scaffoldBackgroundColor: Colors.grey[50],
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.purple,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: Colors.grey[900],
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.grey[850],
              ),
            ),
            home: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }
                if (snapshot.hasData) {
                  return MainScreen();
                }
                return LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}

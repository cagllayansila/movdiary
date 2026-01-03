import 'package:flutter/material.dart';

void main() {
  runApp(const MovieDiaryApp());
}

class MovieDiaryApp extends StatelessWidget {
  const MovieDiaryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Diary',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        brightness: Brightness.light,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Movie Diary Test'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.movie,
                size: 100,
                color: Colors.purple,
              ),
              SizedBox(height: 20),
              Text(
                'Movie Diary',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              SizedBox(height: 20),
              Text('Uygulama çalışıyor! ✓'),
            ],
          ),
        ),
      ),
    );
  }
}
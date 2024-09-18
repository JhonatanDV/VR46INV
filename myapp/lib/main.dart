import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Elimina el banner de debug
      theme: ThemeData(
        primaryColor: const Color(0xFF0033A0), // Color azul Yamaha aclarado
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0033A0), // Color azul Yamaha aclarado para la AppBar
          foregroundColor: Colors.white, // Color de texto y iconos en la AppBar
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // Importe isto
import 'login_screen.dart';
import 'main_screen.dart';

void main() {
  // Inicializa a formatação de data/hora para o locale desejado
  initializeDateFormatting('pt_BR', null).then((_) => runApp(const MyApp()));
  // TODO: Adicionar inicialização do Firebase aqui quando for usar
  // runApp(const MyApp()); // Mova o runApp para dentro do .then()
}

// Cores
const Color primaryPurple = Color(0xFF8A2BE2);
const Color accentCoral = Color(0xFFFF7F50);
const Color textWhite = Colors.white;
const Color textWhiteSecondary = Colors.white70;
const Color inputFillColor = Colors.white24;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DentalCare App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryPurple,
          brightness: Brightness.dark,
          primary: accentCoral,
          onPrimary: textWhite,
          background: primaryPurple,
          onBackground: textWhite,
          surface: primaryPurple,
          onSurface: textWhite,
          secondary: accentCoral,
          onSecondary: textWhite,
        ),
        scaffoldBackgroundColor: primaryPurple,
        textTheme: const TextTheme(
          // Mantenha seus TextTheme
          displayLarge: TextStyle(
            color: textWhite,
            fontWeight: FontWeight.bold,
          ),
          displayMedium: TextStyle(
            color: textWhite,
            fontWeight: FontWeight.bold,
          ),
          displaySmall: TextStyle(
            color: textWhite,
            fontWeight: FontWeight.bold,
          ),
          headlineLarge: TextStyle(
            color: textWhite,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            color: textWhite,
            fontWeight: FontWeight.bold,
          ),
          headlineSmall: TextStyle(
            color: textWhite,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: TextStyle(color: textWhite),
          titleMedium: TextStyle(color: textWhite),
          titleSmall: TextStyle(color: textWhite),
          bodyLarge: TextStyle(color: textWhite),
          bodyMedium: TextStyle(color: textWhite),
          bodySmall: TextStyle(color: textWhiteSecondary),
          labelLarge: TextStyle(color: textWhite, fontWeight: FontWeight.bold),
          labelMedium: TextStyle(color: textWhite),
          labelSmall: TextStyle(color: textWhite),
        ),
        inputDecorationTheme: InputDecorationTheme(
          // Mantenha seu InputDecorationTheme
          filled: true,
          fillColor: inputFillColor,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 20.0,
          ),
          hintStyle: const TextStyle(color: textWhiteSecondary),
          labelStyle: const TextStyle(color: textWhiteSecondary),
          prefixIconColor: textWhiteSecondary,
          suffixIconColor: textWhiteSecondary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: const BorderSide(color: accentCoral, width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
          ),
          errorStyle: const TextStyle(color: Colors.redAccent),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          // Mantenha seu ElevatedButtonTheme
          style: ElevatedButton.styleFrom(
            backgroundColor: accentCoral,
            foregroundColor: textWhite,
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 24.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            elevation: 2,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          // Mantenha seu TextButtonTheme
          style: TextButton.styleFrom(
            foregroundColor: textWhite,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        ),
        iconTheme: const IconThemeData(color: textWhite),
        appBarTheme: const AppBarTheme(
          // Mantenha seu AppBarTheme
          backgroundColor: primaryPurple,
          foregroundColor: textWhite,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: textWhite),
          titleTextStyle: TextStyle(
            color: textWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainScreen(),
      },
    );
  }
}

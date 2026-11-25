import 'package:flutter/material.dart'; //trae las herramientas del diseño de flutter como ThemeData, Color, ColorSchema

class AppTheme {
  //AppTheme -> solo un contenedor

  static ThemeData get tema => ThemeData(
    //static porque permite usarlo sin tener que crear un objeto || get tema por detras ejecuta codigo y devuelve ThemeData

    useMaterial3: true, //activa la version actual del diseño de google
    colorScheme: ColorScheme.fromSeed(
      //ColorScheme -> Paleta Completa || fromSeed -> genera all paleta de un solo color seed

      seedColor: const Color(0xFF00695C),
      secondary: const Color(0xFFFF8F00),
    ),
    appBarTheme: const AppBarTheme(
      //definiendo como se va a ver el appbar en todas las pages

      backgroundColor: Color(0xFF00695C),
      foregroundColor: Colors.white,
    ),
  );
}

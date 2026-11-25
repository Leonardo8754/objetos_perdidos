import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:objetos_perdidos/pages/auth_wrapper.dart';
import 'package:objetos_perdidos/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Objetos Perdidos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.tema,
      home: const AuthWrapper(),
    );
  }
}

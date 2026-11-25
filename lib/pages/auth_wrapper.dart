import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:objetos_perdidos/pages/home_page.dart';
import 'package:objetos_perdidos/pages/login_page.dart';

class AuthWrapper extends StatelessWidget {
  //stateless porque no guarda datos que cambien, los datos vienen de afuera, del stream
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // SB hace la pantalla c/vez q llega algo nuevo || User? avisa que dato llega
      stream: FirebaseAuth.instance.authStateChanges(), //un stream es un flujo de datos que da valores en el time || authStateChanges emite cambios de estado de sesion (user o null)
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // mientras firebase comprueba si hay sesion, le tiramos una pantalla de carga
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const HomePage();
        }
        return const LoginPage();
      },
    );
  }
}

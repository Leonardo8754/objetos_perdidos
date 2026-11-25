import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:objetos_perdidos/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool cargando = false;
  String mensajeError = '';

  Future<void> _ingresar() async {
    setState(() {
      cargando = true;
      mensajeError = '';
    });
    try {
      await AuthService().iniciarSesionConGoogle();
    } on GoogleSignInException catch (e) {
      if (e.code != GoogleSignInExceptionCode.canceled) {
        mensajeError = 'No se pudo iniciar sesión con Google';
      }
    } catch (_) {
      mensajeError = 'No se pudo iniciar sesión con Google';
    }
    if (!mounted) return;
    setState(() => cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colores.primary,
      body: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.image_search, size: 60, color: colores.secondary),
              const SizedBox(height: 12),
              Text(
                'Objetos Perdidos',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colores.primary,
                ),
              ), //@
              const SizedBox(height: 8),
              const Text(
                'Publica y encuentra objetos en la sede',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: cargando ? null : _ingresar,
                  icon: cargando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.login),
                  label: const Text('Ingresar con Google'),
                ),
              ),
              if (mensajeError.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(mensajeError, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

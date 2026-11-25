import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static const _serverClientId = //constante con el id del cliente web del proyect, para entregar el token que despues usará firebase || " _ " -> const privada
      '261265531918-lg59j1kjtiv2l3boksqfkooa3n5t8lom.apps.googleusercontent.com'; //  "cliente_type" : 3 en google_services.json
  static bool _inicializado = false;

  Future<void> _inicializar() async {
    if (_inicializado) return; //si está incializado, sale sin hacer nada
    await GoogleSignIn.instance.initialize(
      serverClientId: _serverClientId,
    ); //sino manda a inicializar con el id del cliente ...
    _inicializado = true; // ... y marca que está listo
  }

  User? get usuarioActual => FirebaseAuth.instance.currentUser; //devuelve el usuario con la sesion inciada, del cual queremos sacar el nombre

  //funcion mas importante
  Future<void> iniciarSesionConGoogle() async {
    await _inicializar(); //debe estar incializado para pasar a esta funcion, por eso lo espera
    final cuenta = await GoogleSignIn.instance
        .authenticate(); // ventana donde eliges tu cuenta de google
    final credencial = GoogleAuthProvider.credential(
      idToken: cuenta.authentication.idToken, // armamos la credencial con este idToken para que lo entienda FireBase
    );
    await FirebaseAuth.instance.signInWithCredential(credencial);
    //signIn pasa la credencial a firebase que incia sesion, authState...() avisa al AuthWrapper y la pantalla cambia sola a la home
  }

  Future<void> cerrarSesion() async {
    await _inicializar();
    await GoogleSignIn.instance.signOut();
    await FirebaseAuth.instance.signOut();
    //Cierra la sesion en ambos lados si solo cierra en firebase se quedaria la otra en google y entraria sin preguntar who you are?
  }
}

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:objetos_perdidos/services/auth_service.dart';

class FsService {
  final _db = FirebaseFirestore
      .instance; //guarda la conex a la bd pa no repetirla tanto

  Future<List<String>> categorias() async {
    final consulta = await _db.collection('categorias').get();
    final nombres = consulta.docs
        .map((doc) => doc['nombre'] as String)
        .toList();
    nombres.sort();
    return nombres;
    //consulto con get(), convierto c/doc a su txt nombre Devuelvo Furture pq las categ las necesitamos una sola vez para el cmb
  }

  Stream<QuerySnapshot> publicaciones() {
    return _db
        .collection('publicaciones')
        .orderBy('fecha', descending: true)
        .snapshots();
  }

  Future<void> publicar({
    required String titulo,
    required String descripcion,
    required String tipo,
    required String categoria,
    required String lugar,
    required DateTime fecha,
    required Uint8List foto,
  }) {
    final usuario = AuthService().usuarioActual!;
    return _db.collection('publicaciones').add({
      'titulo': titulo,
      'descripcion': descripcion,
      'tipo': tipo,
      'categoria': categoria,
      'lugar': lugar,
      'fecha': Timestamp.fromDate(fecha),
      'foto': Blob(foto),
      'estado': 'Vigente',
      'autorUid': usuario.uid,
      'autorNombre': usuario.displayName ?? 'Anónimo',
    });
  }

  Future<void> marcarDevuelto(String id) {
    return _db.collection('publicaciones').doc(id).update({
      'estado': 'Devuelto',
    });
  }

  Future<void> borrar(String id) {
    return _db.collection('publicaciones').doc(id).delete();
  }
}

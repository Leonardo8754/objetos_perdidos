//detalle, marcar como devuelto y borrar
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:objetos_perdidos/services/auth_service.dart';
import 'package:objetos_perdidos/services/fs_service.dart';

class DetallePage extends StatelessWidget {
  final QueryDocumentSnapshot doc;

  const DetallePage({super.key, required this.doc});

  Future<void> _confirmarBorrado(BuildContext context) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Borrar Publicación'),
        content: const Text(
          '¿Confirmas que quieres borrar la publicación? la eliminación es permanente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmado != true) return;
    await FsService().borrar(doc.id);
    if (!context.mounted) return;
    Navigator.pop(context);
  }

  Future<void> _marcarDevuelto(BuildContext context) async {
    await FsService().marcarDevuelto(doc.id);
    if (!context.mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final autor = doc['autorUid'] == AuthService().usuarioActual?.uid;
    final vigente = doc['estado'] == 'Vigente';
    final fecha = (doc['fecha'] as Timestamp).toDate();

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Objeto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.memory((doc['foto'] as Blob).bytes, width: double.infinity),
            Text('Título: ${doc['titulo']}'),
            Text('Descripción: ${doc['descripcion']}'),
            Text('Tipo: ${doc['tipo']}'),
            Text('Categoría: ${doc['categoria']}'),
            Text('Lugar: ${doc['lugar']}'),
            Text('Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(fecha)}'),
            Text('Estado: ${doc['estado']}'),
            Text('Autor: ${doc['autorNombre']}'),
            if (autor && vigente)
              FilledButton(
                onPressed: () => _marcarDevuelto(context),
                child: const Text('Marcar como devuelto'),
              ),
            if (autor)
              TextButton(
                onPressed: () => _confirmarBorrado(context),
                child: const Text('Borrar Publicación'),
              ),
          ],
        ),
      ),
    );
  }
}

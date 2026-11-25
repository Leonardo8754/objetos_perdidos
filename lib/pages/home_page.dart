import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:objetos_perdidos/pages/detalle_page.dart';
import 'package:objetos_perdidos/pages/publicar_page.dart';
import 'package:objetos_perdidos/services/auth_service.dart';
import 'package:objetos_perdidos/services/fs_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool misPub = false;

  @override
  Widget build(BuildContext context) {
    final usuario = AuthService().usuarioActual;
    final colores = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(usuario?.displayName ?? 'Usuario'),
        actions: [
          IconButton(
            tooltip: misPub ? 'Ver todas' : 'Ver solo mis publicaciones',
            onPressed: () => setState(() => misPub = !misPub),
            icon: Icon(misPub ? Icons.filter_alt : Icons.filter_alt_outlined),
          ),
          PopupMenuButton<String>(
            onSelected: (_) => AuthService().cerrarSesion(),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'logout', child: Text('Cerrar sesión')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (misPub)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text('Mostrando solo mis publicaciones'),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FsService().publicaciones(),
              builder: (context, snapshot) {
                //Validacionesss
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('-Las publicaciones no se lograron cargar-'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var docs = snapshot.data!.docs;
                if (misPub) {
                  docs = docs
                      .where((d) => d['autorUid'] == usuario?.uid)
                      .toList();
                }
                //docs es la lista de documentos que llegó
                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      misPub
                          ? 'No has publicado objetos aún'
                          : 'Aún no hay publicaciones',
                    ),
                  );
                }

                //si llegó todo dibujamos la listaa
                return ListView.separated(
                  padding: const EdgeInsets.all(8),
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final devuelto = doc['estado'] == 'Devuelto';
                    return Opacity(
                      opacity: devuelto ? 0.55 : 1,
                      child: ListTile(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetallePage(doc: doc),
                          ),
                        ),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            (doc['foto'] as Blob).bytes,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          doc['titulo'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${doc['tipo']} - ${doc['categoria']}'),
                        trailing: Chip(
                          label: Text(doc['estado']),
                          backgroundColor: devuelto
                              ? Colors.grey.shade300
                              : colores.secondaryContainer,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PublicarPage()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Publicar'),
      ),
    );
  }
}

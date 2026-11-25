import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:objetos_perdidos/services/fs_service.dart';

class PublicarPage extends StatefulWidget {
  const PublicarPage({super.key});

  @override
  State<PublicarPage> createState() => _PublicarPageState();
}

class _PublicarPageState extends State<PublicarPage> {
  static const _maxBytesFoto = 900 * 1024;

  final formKey = GlobalKey<FormState>();
  final tituloCtrl = TextEditingController();
  final descripcionCtrl = TextEditingController();
  final lugarCtrl = TextEditingController();
  final fechaCtrl = TextEditingController();

  List<String> categorias = [];
  String? tipo;
  String? categoria;
  DateTime? fecha;
  Uint8List? foto;
  String errorFoto = '';
  bool guardando = false;

  @override
  void initState() {
    super.initState();
    FsService().categorias().then((lista) {
      if (!mounted) return;
      setState(() => categorias = lista);
    });
  }

  @override
  void dispose() {
    tituloCtrl.dispose();
    descripcionCtrl.dispose();
    lugarCtrl.dispose();
    fechaCtrl.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final ahora = DateTime.now();
    final dia = await showDatePicker(
      context: context,
      firstDate: DateTime(2006),
      lastDate: ahora,
    );
    if (dia == null || !mounted) return;
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(ahora),
    );
    if (hora == null) return;
    setState(() {
      fecha = DateTime(dia.year, dia.month, dia.day, hora.hour, hora.minute);
      fechaCtrl.text = DateFormat('dd/MM/yyyy HH:mm').format(fecha!);
    });
  }

  Future<void> _elegirFoto(ImageSource origen) async {
    final archivo = await ImagePicker().pickImage(
      source: origen,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    if (archivo == null) return;
    final bytes = await archivo.readAsBytes();
    setState(() {
      if (bytes.length > _maxBytesFoto) {
        foto = null;
        errorFoto = 'la foto pasa el limite de 1MB, elige otra';
      } else {
        foto = bytes;
        errorFoto = '';
      }
    });
  }

  Future<void> _publicar() async {
    final formValido = formKey.currentState!.validate();
    if (foto == null && errorFoto.isEmpty) {
      setState(() => errorFoto = 'Debe colocar una foto');
    }
    if (!formValido || foto == null) return;

    setState(() => guardando = true);
    try {
      await FsService().publicar(
        titulo: tituloCtrl.text.trim(),
        descripcion: descripcionCtrl.text.trim(),
        tipo: tipo!,
        categoria: categoria!,
        lugar: lugarCtrl.text.trim(),
        fecha: fecha!,
        foto: foto!,
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() => guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El objeto no se pudo publicar.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Publicar Objeto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: tituloCtrl,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Indique el Título' : null,
              ),
              TextFormField(
                controller: descripcionCtrl,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Indique la Descripción'
                    : null,
              ),
              DropdownButtonFormField<String>(
                initialValue: tipo,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: ['Perdido', 'Encontrado']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => tipo = v),
                validator: (v) => v == null ? 'Seleccione el Tipo' : null,
              ),
              DropdownButtonFormField<String>(
                initialValue: categoria,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: categorias
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => categoria = v),
                validator: (v) => v == null ? 'Seleccione la categoría' : null,
              ),
              TextFormField(
                controller: lugarCtrl,
                decoration: const InputDecoration(
                  labelText: 'Lugar del campus',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Indique el lugar' : null,
              ),
              TextFormField(
                controller: fechaCtrl,
                readOnly: true,
                onTap: _elegirFecha,
                decoration: const InputDecoration(
                  labelText: 'Fecha y hora (DD/MM/AAAA hh:mm)',
                ),
                validator: (v) {
                  if (fecha == null) return 'Indique la fecha y hora';
                  if (fecha!.isAfter(DateTime.now())) {
                    return 'La fecha no puede superar el dia de hoy';
                  }
                  return null;
                },
              ),
              if (foto != null) Image.memory(foto!, height: 200),
              if (errorFoto.isNotEmpty)
                Text(errorFoto, style: const TextStyle(color: Colors.red)),
              Row(
                children: [
                  TextButton(
                    onPressed: () => _elegirFoto(ImageSource.camera),
                    child: const Text('Tomar foto'),
                  ),
                  TextButton(
                    onPressed: () => _elegirFoto(ImageSource.gallery),
                    child: const Text('Elegir de la galería'),
                  ),
                ],
              ),
              FilledButton(
                onPressed: guardando ? null : _publicar,
                child: const Text('Publicar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

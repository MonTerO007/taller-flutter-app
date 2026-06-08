import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';

class HistorialTecnicoScreen extends StatefulWidget {
  final int equipoId;

  const HistorialTecnicoScreen({
    super.key,
    required this.equipoId,
  });

  @override
  State<HistorialTecnicoScreen> createState() => _HistorialTecnicoScreenState();
}

class _HistorialTecnicoScreenState extends State<HistorialTecnicoScreen> {
  final notaController = TextEditingController();

  List<Map<String, dynamic>> notas = [];

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarNotas();
  }

  @override
  void dispose() {
    notaController.dispose();
    super.dispose();
  }

  Future<void> cargarNotas() async {
    final datos = await DatabaseHelper.instance.obtenerNotasPorEquipo(
      widget.equipoId,
    );

    if (!mounted) return;

    setState(() {
      notas = datos;
      cargando = false;
    });
  }

  Future<void> guardarNota() async {
    final texto = notaController.text.trim();

    if (texto.isEmpty) return;

    final fecha = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(DateTime.now());

    await DatabaseHelper.instance.insertarNotaTecnica(
      equipoId: widget.equipoId,
      nota: texto,
      fecha: fecha,
    );

    notaController.clear();

    await cargarNotas();
  }

  Future<void> eliminarNota(int id) async {
    await DatabaseHelper.instance.eliminarNotaTecnica(id);

    await cargarNotas();
  }

  Future<void> confirmarEliminar(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar nota'),
          content: const Text(
            '¿Seguro que deseas eliminar esta nota técnica?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      await eliminarNota(id);
    }
  }

  Widget tarjetaNota(Map<String, dynamic> nota) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: ListTile(
        title: Text(
          nota['nota'] ?? '',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          nota['fecha'] ?? '',
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.delete_outline,
            color: Colors.red,
          ),
          onPressed: () {
            confirmarEliminar(nota['id']);
          },
        ),
      ),
    );
  }

  Widget listaNotas() {
    if (cargando) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (notas.isEmpty) {
      return const Center(
        child: Text(
          'No hay notas técnicas registradas',
        ),
      );
    }

    return ListView.builder(
      itemCount: notas.length,
      itemBuilder: (context, index) {
        return tarjetaNota(notas[index]);
      },
    );
  }

  Widget formularioNota() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            controller: notaController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Agregar nota técnica',
              hintText: 'Ejemplo: Se cambiaron tiras LED y equipo quedó en prueba.',
              prefixIcon: const Icon(Icons.note_add),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: guardarNota,
              icon: const Icon(Icons.save),
              label: const Text('Guardar nota'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial Técnico'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          formularioNota(),
          const Divider(),
          Expanded(
            child: listaNotas(),
          ),
        ],
      ),
    );
  }
}
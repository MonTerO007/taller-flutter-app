import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/repuesto.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  List<Repuesto> repuestos = [];

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarRepuestos();
  }

  Future<void> cargarRepuestos() async {
    final datos =
        await DatabaseHelper.instance.obtenerRepuestos();

    if (!mounted) return;

    setState(() {
      repuestos = datos;
      cargando = false;
    });
  }

  Future<void> agregarRepuesto() async {
    final nombreController =
        TextEditingController();

    final categoriaController =
        TextEditingController();

    final cantidadController =
        TextEditingController();

    final costoController =
        TextEditingController();

    final ventaController =
        TextEditingController();

    final proveedorController =
        TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Nuevo repuesto',
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nombreController,
                  decoration:
                      const InputDecoration(
                    labelText: 'Nombre',
                  ),
                ),
                TextField(
                  controller:
                      categoriaController,
                  decoration:
                      const InputDecoration(
                    labelText: 'Categoría',
                  ),
                ),
                TextField(
                  controller:
                      cantidadController,
                  keyboardType:
                      TextInputType.number,
                  decoration:
                      const InputDecoration(
                    labelText: 'Cantidad',
                  ),
                ),
                TextField(
                  controller:
                      costoController,
                  keyboardType:
                      TextInputType.number,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Costo compra',
                  ),
                ),
                TextField(
                  controller:
                      ventaController,
                  keyboardType:
                      TextInputType.number,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Precio venta',
                  ),
                ),
                TextField(
                  controller:
                      proveedorController,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Proveedor',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child:
                  const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final repuesto =
                    Repuesto(
                  nombre:
                      nombreController.text,
                  categoria:
                      categoriaController.text,
                  cantidad:
                      int.tryParse(
                            cantidadController
                                .text,
                          ) ??
                          0,
                  costoCompra:
                      double.tryParse(
                            costoController
                                .text,
                          ) ??
                          0,
                  precioVenta:
                      double.tryParse(
                            ventaController
                                .text,
                          ) ??
                          0,
                  proveedor:
                      proveedorController
                          .text,
                );

                await DatabaseHelper
                    .instance
                    .insertarRepuesto(
                  repuesto,
                );

                if (!mounted) return;

                Navigator.pop(context);

                cargarRepuestos();
              },
              child: const Text(
                'Guardar',
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> eliminarRepuesto(
      int id) async {
    await DatabaseHelper.instance
        .eliminarRepuesto(id);

    cargarRepuestos();
  }

  Widget tarjetaRepuesto(
      Repuesto repuesto) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            repuesto.cantidad.toString(),
          ),
        ),
        title: Text(
          repuesto.nombre,
        ),
        subtitle: Text(
          'Categoría: ${repuesto.categoria}\n'
          'Costo: \$${repuesto.costoCompra}\n'
          'Venta: \$${repuesto.precioVenta}',
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
          ),
          onPressed: () {
            eliminarRepuesto(
              repuesto.id!,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inventario',
        ),
      ),
      body: cargando
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount:
                  repuestos.length,
              itemBuilder:
                  (context, index) {
                return tarjetaRepuesto(
                  repuestos[index],
                );
              },
            ),
      floatingActionButton:
          FloatingActionButton(
        onPressed: agregarRepuesto,
        child: const Icon(Icons.add),
      ),
    );
  }
}
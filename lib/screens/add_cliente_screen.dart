import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../models/cliente.dart';
import '../models/equipo.dart';

class AddClienteScreen extends StatefulWidget {
  const AddClienteScreen({super.key});

  @override
  State<AddClienteScreen> createState() =>
      _AddClienteScreenState();
}

class _AddClienteScreenState
    extends State<AddClienteScreen> {
  final _formKey = GlobalKey<FormState>();

  /// =========================
  /// Controladores cliente
  /// =========================

  final nombreController =
      TextEditingController();

  final apellidoController =
      TextEditingController();

  final identificacionController =
      TextEditingController();

  final telefonoController =
      TextEditingController();

  final correoController =
      TextEditingController();

  /// =========================
  /// Controladores equipo
  /// =========================

  final tipoEquipoController =
      TextEditingController();

  final marcaController =
      TextEditingController();

  final modeloController =
      TextEditingController();

  final problemaController =
      TextEditingController();

  final observacionesController =
      TextEditingController();

  /// NUEVO
  final repuestosController =
      TextEditingController();

  final costoEstimadoController =
      TextEditingController();

  final costoFinalController =
      TextEditingController();

  /// Estado actual del trabajo.
  String estado = 'Pendiente';

  @override
  void dispose() {
    nombreController.dispose();
    apellidoController.dispose();
    identificacionController.dispose();
    telefonoController.dispose();
    correoController.dispose();

    tipoEquipoController.dispose();
    marcaController.dispose();
    modeloController.dispose();
    problemaController.dispose();
    observacionesController.dispose();

    repuestosController.dispose();

    costoEstimadoController.dispose();
    costoFinalController.dispose();

    super.dispose();
  }

  /// =======================================================
  /// Guarda el registro completo
  /// =======================================================

  Future<void> guardarRegistro() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final fechaActual = DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).format(DateTime.now());

      final codigoRecibo =
          'REC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      final cliente = Cliente(
        nombre: nombreController.text.trim(),
        apellido:
            apellidoController.text.trim(),
        identificacion:
            identificacionController.text.trim(),
        telefono:
            telefonoController.text.trim(),
        correo: correoController.text.trim(),
      );

      await DatabaseHelper.instance
          .registrarClienteConEquipo(
        cliente: cliente,

        crearEquipo: (clienteId) {
          return Equipo(
            clienteId: clienteId,

            tipoEquipo:
                tipoEquipoController.text.trim(),

            marca:
                marcaController.text.trim(),

            modelo:
                modeloController.text.trim(),

            problema:
                problemaController.text.trim(),

            observaciones:
                observacionesController.text.trim(),

            /// NUEVO
            repuestos:
                repuestosController.text.trim(),

            codigoRecibo:
                codigoRecibo,

            estado: estado,

            fechaIngreso:
                fechaActual,

            fechaEntrega: '',

            costoEstimado:
                double.tryParse(
                      costoEstimadoController.text.trim(),
                    ) ??
                    0,

            costoFinal:
                double.tryParse(
                      costoFinalController.text.trim(),
                    ) ??
                    0,
          );
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Registro guardado correctamente',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Error al guardar: $e',
          ),
        ),
      );
    }
  }

  /// =======================================================
  /// Campo reutilizable
  /// =======================================================

  Widget campoTexto({
    required TextEditingController controller,
    required String label,
    required IconData icono,
    int maxLines = 1,
    TextInputType tipo =
        TextInputType.text,
    bool obligatorio = true,
  }) {
    return TextFormField(
      controller: controller,

      keyboardType: tipo,

      maxLines: maxLines,

      decoration: InputDecoration(
        labelText: label,

        prefixIcon: Icon(icono),

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
        ),
      ),

      validator: (value) {
        if (obligatorio &&
            (value == null ||
                value.trim().isEmpty)) {
          return 'Este campo es obligatorio';
        }

        return null;
      },
    );
  }

  Widget tituloSeccion(
    String texto,
    IconData icono,
  ) {
    return Row(
      children: [
        Icon(icono, color: Colors.blue),

        const SizedBox(width: 8),

        Text(
          texto,

          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget espacio() {
    return const SizedBox(height: 14);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Nuevo Registro WFC4'),

        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Card(
          elevation: 2,

          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),

          child: Padding(
            padding:
                const EdgeInsets.all(16),

            child: Form(
              key: _formKey,

              child: Column(
                children: [
                  tituloSeccion(
                    'Datos del cliente',
                    Icons.person,
                  ),

                  espacio(),

                  campoTexto(
                    controller:
                        nombreController,

                    label: 'Nombre',

                    icono:
                        Icons.person_outline,
                  ),

                  espacio(),

                  campoTexto(
                    controller:
                        apellidoController,

                    label: 'Apellido',

                    icono:
                        Icons.badge_outlined,
                  ),

                  espacio(),

                  campoTexto(
                    controller:
                        identificacionController,

                    label: 'Cédula / ID',

                    icono:
                        Icons.credit_card,
                  ),

                  espacio(),

                  campoTexto(
                    controller:
                        telefonoController,

                    label:
                        'Teléfono / WhatsApp',

                    icono: Icons.phone,

                    tipo:
                        TextInputType.phone,
                  ),

                  espacio(),

                  campoTexto(
                    controller:
                        correoController,

                    label:
                        'Correo electrónico',

                    icono:
                        Icons.email_outlined,

                    tipo: TextInputType
                        .emailAddress,

                    obligatorio: false,
                  ),

                  const SizedBox(height: 24),

                  tituloSeccion(
                    'Datos del equipo',
                    Icons.devices,
                  ),

                  espacio(),

                  campoTexto(
                    controller:
                        tipoEquipoController,

                    label:
                        'Tipo de equipo',

                    icono:
                        Icons.devices_other,
                  ),

                  espacio(),

                  campoTexto(
                    controller:
                        marcaController,

                    label: 'Marca',

                    icono:
                        Icons.label_outline,

                    obligatorio: false,
                  ),

                  espacio(),

                  campoTexto(
                    controller:
                        modeloController,

                    label: 'Modelo',

                    icono:
                        Icons.confirmation_number_outlined,

                    obligatorio: false,
                  ),

                  espacio(),

                  campoTexto(
                    controller:
                        problemaController,

                    label:
                        'Problema reportado',

                    icono: Icons.build,

                    maxLines: 3,
                  ),

                  espacio(),

                  campoTexto(
                    controller:
                        observacionesController,

                    label:
                        'Observaciones tipo libreta',

                    icono:
                        Icons.note_alt_outlined,

                    maxLines: 4,

                    obligatorio: false,
                  ),

                  espacio(),

                  /// NUEVO
                  campoTexto(
                    controller:
                        repuestosController,

                    label:
                        'Repuestos utilizados',

                    icono:
                        Icons.memory,

                    maxLines: 4,

                    obligatorio: false,
                  ),

                  espacio(),

                  campoTexto(
                    controller:
                        costoEstimadoController,

                    label:
                        'Costo estimado',

                    icono:
                        Icons.attach_money,

                    tipo:
                        TextInputType.number,

                    obligatorio: false,
                  ),

                  espacio(),

                  campoTexto(
                    controller:
                        costoFinalController,

                    label:
                        'Costo final',

                    icono:
                        Icons.payments_outlined,

                    tipo:
                        TextInputType.number,

                    obligatorio: false,
                  ),

                  espacio(),

                  DropdownButtonFormField<
                      String>(
                    value: estado,

                    decoration:
                        InputDecoration(
                      labelText:
                          'Estado del trabajo',

                      prefixIcon:
                          const Icon(
                        Icons.info,
                      ),

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),
                    ),

                    items: const [
                      DropdownMenuItem(
                        value: 'Pendiente',
                        child:
                            Text('Pendiente'),
                      ),

                      DropdownMenuItem(
                        value:
                            'En revisión',
                        child: Text(
                          'En revisión',
                        ),
                      ),

                      DropdownMenuItem(
                        value: 'Reparado',
                        child:
                            Text('Reparado'),
                      ),

                      DropdownMenuItem(
                        value: 'Entregado',
                        child:
                            Text('Entregado'),
                      ),
                    ],

                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          estado = value;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,

                    height: 52,

                    child:
                        ElevatedButton.icon(
                      onPressed:
                          guardarRegistro,

                      icon:
                          const Icon(Icons.save),

                      label: const Text(
                        'Guardar Registro',

                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
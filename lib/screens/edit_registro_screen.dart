import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/cliente.dart';
import '../models/equipo.dart';

/// =======================================================
/// Pantalla de edición de registros WFC4
/// =======================================================
///
/// Esta pantalla permite:
/// - Editar datos del cliente.
/// - Editar datos del equipo.
/// - Actualizar estados.
/// - Modificar costos.
/// - Guardar fecha de entrega.
/// - Editar repuestos utilizados.
/// - Guardar cambios en SQLite.
///
/// =======================================================

class EditRegistroScreen extends StatefulWidget {
  final Map<String, dynamic> registro;

  const EditRegistroScreen({
    super.key,
    required this.registro,
  });

  @override
  State<EditRegistroScreen> createState() =>
      _EditRegistroScreenState();
}

class _EditRegistroScreenState
    extends State<EditRegistroScreen> {
  final _formKey = GlobalKey<FormState>();

  /// =========================
  /// Controladores cliente
  /// =========================

  late final TextEditingController
      nombreController;

  late final TextEditingController
      apellidoController;

  late final TextEditingController
      identificacionController;

  late final TextEditingController
      telefonoController;

  late final TextEditingController
      correoController;

  /// =========================
  /// Controladores equipo
  /// =========================

  late final TextEditingController
      tipoEquipoController;

  late final TextEditingController
      marcaController;

  late final TextEditingController
      modeloController;

  late final TextEditingController
      problemaController;

  late final TextEditingController
      observacionesController;

  /// NUEVO
  late final TextEditingController
      repuestosController;

  late final TextEditingController
      costoEstimadoController;

  late final TextEditingController
      costoFinalController;

  late String estado;

  @override
  void initState() {
    super.initState();

    nombreController =
        TextEditingController(
      text:
          '${widget.registro['nombre'] ?? ''}',
    );

    apellidoController =
        TextEditingController(
      text:
          '${widget.registro['apellido'] ?? ''}',
    );

    identificacionController =
        TextEditingController(
      text:
          '${widget.registro['identificacion'] ?? ''}',
    );

    telefonoController =
        TextEditingController(
      text:
          '${widget.registro['telefono'] ?? ''}',
    );

    correoController =
        TextEditingController(
      text:
          '${widget.registro['correo'] ?? ''}',
    );

    tipoEquipoController =
        TextEditingController(
      text:
          '${widget.registro['tipo_equipo'] ?? ''}',
    );

    marcaController =
        TextEditingController(
      text:
          '${widget.registro['marca'] ?? ''}',
    );

    modeloController =
        TextEditingController(
      text:
          '${widget.registro['modelo'] ?? ''}',
    );

    problemaController =
        TextEditingController(
      text:
          '${widget.registro['problema'] ?? ''}',
    );

    observacionesController =
        TextEditingController(
      text:
          '${widget.registro['observaciones'] ?? ''}',
    );

    /// NUEVO
    repuestosController =
        TextEditingController(
      text:
          '${widget.registro['repuestos'] ?? ''}',
    );

    costoEstimadoController =
        TextEditingController(
      text:
          '${widget.registro['costo_estimado'] ?? 0}',
    );

    costoFinalController =
        TextEditingController(
      text:
          '${widget.registro['costo_final'] ?? 0}',
    );

    estado =
        '${widget.registro['estado'] ?? 'Pendiente'}';
  }

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
  /// Guarda los cambios actualizados
  /// =======================================================

  Future<void> guardarCambios() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    try {
      final clienteActualizado =
          Cliente(
        id: widget.registro['cliente_id'],

        nombre:
            nombreController.text.trim(),

        apellido:
            apellidoController.text.trim(),

        identificacion:
            identificacionController.text
                .trim(),

        telefono:
            telefonoController.text.trim(),

        correo:
            correoController.text.trim(),
      );

      final fechaEntregaActual =
          '${widget.registro['fecha_entrega'] ?? ''}';

      final fechaEntregaNueva =
          estado == 'Entregado'
              ? DateTime.now()
                  .toString()
                  .substring(0, 19)
              : fechaEntregaActual;

      final equipoActualizado =
          Equipo(
        id: widget.registro['equipo_id'],

        clienteId:
            widget.registro['cliente_id'],

        tipoEquipo:
            tipoEquipoController.text.trim(),

        marca:
            marcaController.text.trim(),

        modelo:
            modeloController.text.trim(),

        problema:
            problemaController.text.trim(),

        observaciones:
            observacionesController.text
                .trim(),

        /// NUEVO
        repuestos:
            repuestosController.text.trim(),

        codigoRecibo:
            widget.registro[
                    'codigo_recibo'] ??
                'REC-SIN-CODIGO',

        estado: estado,

        fechaIngreso:
            '${widget.registro['fecha_ingreso'] ?? ''}',

        fechaEntrega:
            fechaEntregaNueva,

        costoEstimado:
            double.tryParse(
                  costoEstimadoController
                      .text
                      .trim(),
                ) ??
                0,

        costoFinal:
            double.tryParse(
                  costoFinalController
                      .text
                      .trim(),
                ) ??
                0,
      );

      await DatabaseHelper.instance
          .actualizarCliente(
              clienteActualizado);

      await DatabaseHelper.instance
          .actualizarEquipo(
              equipoActualizado);

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Registro actualizado correctamente',
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
            'Error al actualizar: $e',
          ),
        ),
      );
    }
  }

  /// =======================================================
  /// Campo reutilizable
  /// =======================================================

  Widget campoTexto({
    required TextEditingController
        controller,

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
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget espacio() =>
      const SizedBox(height: 14);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Editar Registro'),

        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),

        child: Card(
          elevation: 2,

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              18,
            ),
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

                    label:
                        'Cédula / ID',

                    icono:
                        Icons.credit_card,
                  ),

                  espacio(),

                  campoTexto(
                    controller:
                        telefonoController,

                    label:
                        'Teléfono / WhatsApp',

                    icono:
                        Icons.phone,

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

                    tipo:
                        TextInputType
                            .emailAddress,

                    obligatorio: false,
                  ),

                  const SizedBox(
                    height: 24,
                  ),

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

                    icono:
                        Icons.build,

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
                        value:
                            'Pendiente',

                        child: Text(
                          'Pendiente',
                        ),
                      ),

                      DropdownMenuItem(
                        value:
                            'En revisión',

                        child: Text(
                          'En revisión',
                        ),
                      ),

                      DropdownMenuItem(
                        value:
                            'Reparado',

                        child: Text(
                          'Reparado',
                        ),
                      ),

                      DropdownMenuItem(
                        value:
                            'Entregado',

                        child: Text(
                          'Entregado',
                        ),
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

                  const SizedBox(
                    height: 24,
                  ),

                  SizedBox(
                    width: double.infinity,

                    height: 52,

                    child:
                        ElevatedButton.icon(
                      onPressed:
                          guardarCambios,

                      icon: const Icon(
                        Icons.save,
                      ),

                      label: const Text(
                        'Guardar Cambios',

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
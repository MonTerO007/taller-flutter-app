import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

import '../database/database_helper.dart';
import '../models/equipo.dart';
import 'edit_registro_screen.dart';
import 'historial_tecnico_screen.dart';

class DetalleClienteScreen extends StatefulWidget {
  final Map<String, dynamic> registro;

  const DetalleClienteScreen({
    super.key,
    required this.registro,
  });

  @override
  State<DetalleClienteScreen> createState() => _DetalleClienteScreenState();
}

class _DetalleClienteScreenState extends State<DetalleClienteScreen> {
  late Map<String, dynamic> registroActual;
  late String estadoSeleccionado;

  @override
  void initState() {
    super.initState();

    registroActual = widget.registro;
    estadoSeleccionado = registroActual['estado'] ?? 'Pendiente';
  }

  int calcularDias(String fechaIngreso) {
    try {
      final fecha = DateFormat('yyyy-MM-dd HH:mm:ss').parse(fechaIngreso);
      return DateTime.now().difference(fecha).inDays;
    } catch (_) {
      return 0;
    }
  }

  Future<void> actualizarEstado() async {
    final equipo = Equipo(
      id: registroActual['equipo_id'],
      clienteId: registroActual['cliente_id'],
      tipoEquipo: registroActual['tipo_equipo'] ?? '',
      marca: registroActual['marca'] ?? '',
      modelo: registroActual['modelo'] ?? '',
      problema: registroActual['problema'] ?? '',
      observaciones: registroActual['observaciones'] ?? '',
      repuestos: registroActual['repuestos'] ?? '',
      codigoRecibo: registroActual['codigo_recibo'] ?? 'REC-SIN-CODIGO',
      estado: estadoSeleccionado,
      fechaIngreso: registroActual['fecha_ingreso'] ?? '',
      fechaEntrega: registroActual['fecha_entrega'] ?? '',
      costoEstimado: (registroActual['costo_estimado'] ?? 0).toDouble(),
      costoFinal: (registroActual['costo_final'] ?? 0).toDouble(),
    );

    await DatabaseHelper.instance.actualizarEquipo(equipo);

    if (!mounted) return;

    setState(() {
      registroActual['estado'] = estadoSeleccionado;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Estado actualizado correctamente'),
      ),
    );
  }

  Future<void> enviarWhatsApp() async {
    final telefono = '${registroActual['telefono']}'.replaceAll(' ', '');

    final mensaje = '''
Hola ${registroActual['nombre']},

Le saluda WFC4 TECH.

Le compartimos el estado actualizado de su equipo:

Código de recibo:
${registroActual['codigo_recibo']}

Equipo:
${registroActual['tipo_equipo']}

Marca:
${registroActual['marca']}

Modelo:
${registroActual['modelo']}

Estado actual:
${registroActual['estado']}

Problema reportado:
${registroActual['problema']}

Repuestos utilizados:
${registroActual['repuestos']}

Costo estimado:
\$${registroActual['costo_estimado']}

Costo final:
\$${registroActual['costo_final']}

Fecha de ingreso:
${registroActual['fecha_ingreso']}

Fecha de entrega:
${registroActual['fecha_entrega']}

Gracias por confiar en nuestro servicio técnico.

WFC4 TECH
''';

    final url =
        'https://wa.me/507$telefono?text=${Uri.encodeComponent(mensaje)}';

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir WhatsApp'),
        ),
      );
    }
  }

  Future<void> generarPdf() async {
  final pdf = pw.Document();

  final notasTecnicas =
      await DatabaseHelper.instance.obtenerNotasPorEquipo(
    registroActual['equipo_id'],
  );

  final logoBytes = await rootBundle.load(
    'assets/images/logo_wfc4.png',
  );

  final logoImage = pw.MemoryImage(
    logoBytes.buffer.asUint8List(),
  );

  final nombreCompleto =
      '${registroActual['nombre']} ${registroActual['apellido']}';

  final dias = calcularDias(
    registroActual['fecha_ingreso'] ?? '',
  );

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,

      margin: const pw.EdgeInsets.all(32),

      build: (context) {
        return [
          pw.Center(
            child: pw.Column(
              children: [
                pw.Image(
                  logoImage,
                  height: 90,
                ),

                pw.SizedBox(height: 8),

                pw.Text(
                  'RECIBO DE RECEPCIÓN',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.Text(
                  'Servicio técnico electrónico',
                ),

                pw.Text(
                  'Reparación de celulares, laptops y TVs',
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 18),

          pw.Divider(),

          pw.SizedBox(height: 12),

          datoPdf('Cliente', nombreCompleto),

          datoPdf(
            'Código',
            '${registroActual['codigo_recibo']}',
          ),

          datoPdf(
            'ID',
            '${registroActual['identificacion']}',
          ),

          datoPdf(
            'Teléfono',
            '${registroActual['telefono']}',
          ),

          datoPdf(
            'Correo',
            '${registroActual['correo']}',
          ),

          datoPdf(
            'Equipo',
            '${registroActual['tipo_equipo']}',
          ),

          datoPdf(
            'Marca',
            '${registroActual['marca']}',
          ),

          datoPdf(
            'Modelo',
            '${registroActual['modelo']}',
          ),

          datoPdf(
            'Problema',
            '${registroActual['problema']}',
          ),

          datoPdf(
            'Observaciones',
            '${registroActual['observaciones']}',
          ),

          datoPdf(
            'Repuestos',
            '${registroActual['repuestos']}',
          ),

          datoPdf(
            'Costo estimado',
            '\$${registroActual['costo_estimado']}',
          ),

          datoPdf(
            'Costo final',
            '\$${registroActual['costo_final']}',
          ),

          datoPdf(
            'Estado',
            '${registroActual['estado']}',
          ),

          datoPdf(
            'Fecha ingreso',
            '${registroActual['fecha_ingreso']}',
          ),

          datoPdf(
            'Fecha entrega',
            '${registroActual['fecha_entrega']}',
          ),

          datoPdf(
            'Días en local',
            '$dias días',
          ),

          pw.SizedBox(height: 15),

          pw.Text(
            'Historial técnico',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 8),

          if (notasTecnicas.isEmpty)
            pw.Text(
              'No existen notas técnicas registradas.',
            ),

          ...notasTecnicas.map(
            (nota) => pw.Container(
              margin: const pw.EdgeInsets.only(
                bottom: 8,
              ),

              padding: const pw.EdgeInsets.all(8),

              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  color: PdfColors.grey300,
                ),
              ),

              child: pw.Column(
                crossAxisAlignment:
                    pw.CrossAxisAlignment.start,

                children: [
                  pw.Text(
                    nota['fecha'] ?? '',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight:
                          pw.FontWeight.bold,
                    ),
                  ),

                  pw.SizedBox(height: 4),

                  pw.Text(
                    nota['nota'] ?? '',
                  ),
                ],
              ),
            ),
          ),

          pw.SizedBox(height: 15),

          pw.Divider(),

          pw.Text(
            'Condiciones:',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 6),

          pw.Text(
            'El equipo se recibe para revisión técnica. '
            'El diagnóstico, reparación o costo final será informado '
            'al cliente antes de proceder. El tiempo máximo recomendado '
            'de permanencia del equipo en el local es de 15 días.',
            textAlign: pw.TextAlign.justify,
          ),

          pw.SizedBox(height: 45),

          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  children: [
                    pw.Divider(),
                    pw.Text(
                      'Firma del cliente',
                    ),
                  ],
                ),
              ),

              pw.SizedBox(width: 40),

              pw.Expanded(
                child: pw.Column(
                  children: [
                    pw.Divider(),
                    pw.Text(
                      'Firma del técnico',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ];
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (format) async => pdf.save(),
  );
}

  pw.Widget datoPdf(String titulo, String valor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 115,
            child: pw.Text(
              '$titulo:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            child: pw.Text(valor),
          ),
        ],
      ),
    );
  }

  Widget filaDato(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$titulo:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(valor),
          ),
        ],
      ),
    );
  }

  Color colorAlertaDias(int dias) {
    if (dias >= 15) return Colors.red;
    if (dias >= 10) return Colors.orange;
    return Colors.green;
  }

  String textoAlertaDias(int dias) {
    if (dias >= 15) return 'Máximo superado';
    if (dias >= 10) return 'Debe notificarse al cliente';
    return 'Dentro del tiempo permitido';
  }

  Widget alertaDias() {
    final dias = calcularDias(registroActual['fecha_ingreso'] ?? '');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colorAlertaDias(dias).withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorAlertaDias(dias)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: colorAlertaDias(dias),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Días en local: $dias - ${textoAlertaDias(dias)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorAlertaDias(dias),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget lineaSeparadora() {
    return const Divider(thickness: 1);
  }

  @override
  Widget build(BuildContext context) {
    final nombreCompleto =
        '${registroActual['nombre']} ${registroActual['apellido']}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recibo WFC4'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/logo_wfc4.png',
                        height: 120,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'RECIBO DE RECEPCIÓN',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('Servicio técnico electrónico'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                lineaSeparadora(),
                const SizedBox(height: 16),
                alertaDias(),
                filaDato('Cliente', nombreCompleto),
                filaDato('Código', '${registroActual['codigo_recibo']}'),
                filaDato('ID', '${registroActual['identificacion']}'),
                filaDato('Teléfono', '${registroActual['telefono']}'),
                filaDato('Correo', '${registroActual['correo']}'),
                lineaSeparadora(),
                filaDato('Equipo', '${registroActual['tipo_equipo']}'),
                filaDato('Marca', '${registroActual['marca']}'),
                filaDato('Modelo', '${registroActual['modelo']}'),
                filaDato('Problema', '${registroActual['problema']}'),
                filaDato('Observaciones', '${registroActual['observaciones']}'),
                filaDato('Repuestos', '${registroActual['repuestos']}'),
                filaDato(
                  'Costo estimado',
                  '\$${registroActual['costo_estimado']}',
                ),
                filaDato(
                  'Costo final',
                  '\$${registroActual['costo_final']}',
                ),
                filaDato('Estado', '${registroActual['estado']}'),
                filaDato('Fecha ingreso', '${registroActual['fecha_ingreso']}'),
                filaDato('Fecha entrega', '${registroActual['fecha_entrega']}'),
                lineaSeparadora(),
                DropdownButtonFormField<String>(
                  value: estadoSeleccionado,
                  decoration: InputDecoration(
                    labelText: 'Cambiar estado del trabajo',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    prefixIcon: const Icon(Icons.update),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Pendiente',
                      child: Text('Pendiente'),
                    ),
                    DropdownMenuItem(
                      value: 'En revisión',
                      child: Text('En revisión'),
                    ),
                    DropdownMenuItem(
                      value: 'Reparado',
                      child: Text('Reparado'),
                    ),
                    DropdownMenuItem(
                      value: 'Entregado',
                      child: Text('Entregado'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        estadoSeleccionado = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: actualizarEstado,
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar cambio de estado'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final resultado = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditRegistroScreen(
                            registro: registroActual,
                          ),
                        ),
                      );

                      if (resultado == true && mounted) {
                        Navigator.pop(context, true);
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar Registro'),
                  ),
                ),

                                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HistorialTecnicoScreen(
                            equipoId: registroActual['equipo_id'],
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.history),
                    label: const Text('Historial Técnico'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: enviarWhatsApp,
                    icon: const Icon(Icons.message),
                    label: const Text('Enviar WhatsApp'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: generarPdf,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Generar PDF / Imprimir'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
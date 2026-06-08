/// =======================================================
/// Modelo Equipo
/// =======================================================
///
/// Este modelo representa cada equipo técnico
/// ingresado en el sistema WFC4.
///
/// Aquí se almacenan:
/// - Datos del equipo.
/// - Problema reportado.
/// - Observaciones del técnico.
/// - Repuestos utilizados.
/// - Código de recibo.
/// - Estado actual.
/// - Costos.
/// - Fecha de ingreso.
/// - Fecha de entrega.
///
/// El modelo también permite:
/// - Convertir datos a Map para SQLite.
/// - Reconstruir objetos desde la base de datos.
/// - Clonar objetos con copyWith().
///
/// =======================================================

class Equipo {
  /// ID único del equipo en SQLite.
  final int? id;

  /// Relación del equipo con el cliente.
  final int clienteId;

  /// Tipo de equipo.
  /// Ejemplo:
  /// TV, Laptop, Celular, Impresora.
  final String tipoEquipo;

  /// Marca del equipo.
  final String marca;

  /// Modelo específico del equipo.
  final String modelo;

  /// Problema reportado por el cliente.
  final String problema;

  /// Observaciones internas del técnico.
  final String observaciones;

  /// Repuestos utilizados en la reparación.
  /// Ejemplo:
  /// Tiras LED, flex, pantalla, IC de carga.
  final String repuestos;

  /// Código de recibo automático.
  /// Ejemplo:
  /// REC-12345.
  final String codigoRecibo;

  /// Estado actual del trabajo.
  /// Ejemplo:
  /// Pendiente, En revisión, Reparado, Entregado.
  final String estado;

  /// Fecha en la que ingresó el equipo.
  final String fechaIngreso;

  /// Fecha en la que se entrega el equipo.
  /// Si todavía no se ha entregado, queda vacío.
  final String fechaEntrega;

  /// Costo estimado inicial.
  final double costoEstimado;

  /// Costo final del trabajo.
  final double costoFinal;

  /// =======================================================
  /// Constructor principal
  /// =======================================================

  const Equipo({
    this.id,
    required this.clienteId,
    required this.tipoEquipo,
    required this.marca,
    required this.modelo,
    required this.problema,
    required this.observaciones,
    required this.repuestos,
    required this.codigoRecibo,
    required this.estado,
    required this.fechaIngreso,
    required this.fechaEntrega,
    required this.costoEstimado,
    required this.costoFinal,
  });

  /// =======================================================
  /// Convierte el objeto a Map
  /// =======================================================
  ///
  /// Utilizado para guardar datos en SQLite.
  ///
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cliente_id': clienteId,
      'tipo_equipo': tipoEquipo,
      'marca': marca,
      'modelo': modelo,
      'problema': problema,
      'observaciones': observaciones,
      'repuestos': repuestos,
      'codigo_recibo': codigoRecibo,
      'estado': estado,
      'fecha_ingreso': fechaIngreso,
      'fecha_entrega': fechaEntrega,
      'costo_estimado': costoEstimado,
      'costo_final': costoFinal,
    };
  }

  /// =======================================================
  /// Reconstrucción desde SQLite
  /// =======================================================
  ///
  /// Convierte un Map obtenido de SQLite
  /// nuevamente en un objeto Equipo.
  ///
  factory Equipo.fromMap(Map<String, dynamic> map) {
    return Equipo(
      id: map['id'],
      clienteId: map['cliente_id'],
      tipoEquipo: map['tipo_equipo'],
      marca: map['marca'],
      modelo: map['modelo'],
      problema: map['problema'],
      observaciones: map['observaciones'],
      repuestos: map['repuestos'] ?? '',
      codigoRecibo: map['codigo_recibo'] ?? 'REC-SIN-CODIGO',
      estado: map['estado'],
      fechaIngreso: map['fecha_ingreso'],
      fechaEntrega: map['fecha_entrega'] ?? '',
      costoEstimado: (map['costo_estimado'] ?? 0).toDouble(),
      costoFinal: (map['costo_final'] ?? 0).toDouble(),
    );
  }

  /// =======================================================
  /// copyWith()
  /// =======================================================
  ///
  /// Permite crear copias del objeto
  /// modificando solamente algunos valores.
  ///
  Equipo copyWith({
    int? id,
    int? clienteId,
    String? tipoEquipo,
    String? marca,
    String? modelo,
    String? problema,
    String? observaciones,
    String? repuestos,
    String? codigoRecibo,
    String? estado,
    String? fechaIngreso,
    String? fechaEntrega,
    double? costoEstimado,
    double? costoFinal,
  }) {
    return Equipo(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      tipoEquipo: tipoEquipo ?? this.tipoEquipo,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      problema: problema ?? this.problema,
      observaciones: observaciones ?? this.observaciones,
      repuestos: repuestos ?? this.repuestos,
      codigoRecibo: codigoRecibo ?? this.codigoRecibo,
      estado: estado ?? this.estado,
      fechaIngreso: fechaIngreso ?? this.fechaIngreso,
      fechaEntrega: fechaEntrega ?? this.fechaEntrega,
      costoEstimado: costoEstimado ?? this.costoEstimado,
      costoFinal: costoFinal ?? this.costoFinal,
    );
  }
}
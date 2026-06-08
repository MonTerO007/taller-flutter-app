class Repuesto {
  final int? id;
  final String nombre;
  final String categoria;
  final int cantidad;
  final double costoCompra;
  final double precioVenta;
  final String proveedor;

  const Repuesto({
    this.id,
    required this.nombre,
    required this.categoria,
    required this.cantidad,
    required this.costoCompra,
    required this.precioVenta,
    required this.proveedor,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'categoria': categoria,
      'cantidad': cantidad,
      'costo_compra': costoCompra,
      'precio_venta': precioVenta,
      'proveedor': proveedor,
    };
  }

  factory Repuesto.fromMap(Map<String, dynamic> map) {
    return Repuesto(
      id: map['id'],
      nombre: map['nombre'],
      categoria: map['categoria'],
      cantidad: map['cantidad'],
      costoCompra: (map['costo_compra'] ?? 0).toDouble(),
      precioVenta: (map['precio_venta'] ?? 0).toDouble(),
      proveedor: map['proveedor'],
    );
  }
}
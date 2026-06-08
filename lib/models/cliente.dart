class Cliente {
  final int? id;
  final String nombre;
  final String apellido;
  final String identificacion;
  final String telefono;
  final String correo;

  const Cliente({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.identificacion,
    required this.telefono,
    required this.correo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'identificacion': identificacion,
      'telefono': telefono,
      'correo': correo,
    };
  }

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map['id'],
      nombre: map['nombre'],
      apellido: map['apellido'],
      identificacion: map['identificacion'],
      telefono: map['telefono'],
      correo: map['correo'],
    );
  }

  Cliente copyWith({
    int? id,
    String? nombre,
    String? apellido,
    String? identificacion,
    String? telefono,
    String? correo,
  }) {
    return Cliente(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      identificacion: identificacion ?? this.identificacion,
      telefono: telefono ?? this.telefono,
      correo: correo ?? this.correo,
    );
  }

  String get nombreCompleto {
    return '$nombre $apellido'.trim();
  }
}
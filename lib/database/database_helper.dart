import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/cliente.dart';
import '../models/equipo.dart';

/// =======================================================
/// Ayudante de base de datos WFC4
/// =======================================================
///
/// Maneja la base local SQLite:
/// - Clientes.
/// - Equipos.
/// - Notas técnicas.
/// - Edición.
/// - Eliminación.
/// - Consultas.
///
/// =======================================================

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('wfc4_clientes.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 6,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clientes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        apellido TEXT NOT NULL,
        identificacion TEXT NOT NULL,
        telefono TEXT NOT NULL,
        correo TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE equipos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cliente_id INTEGER NOT NULL,
        tipo_equipo TEXT NOT NULL,
        marca TEXT NOT NULL,
        modelo TEXT NOT NULL,
        problema TEXT NOT NULL,
        observaciones TEXT NOT NULL,
        repuestos TEXT NOT NULL,
        codigo_recibo TEXT NOT NULL,
        estado TEXT NOT NULL,
        fecha_ingreso TEXT NOT NULL,
        fecha_entrega TEXT NOT NULL,
        costo_estimado REAL NOT NULL,
        costo_final REAL NOT NULL,
        FOREIGN KEY (cliente_id) REFERENCES clientes (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE notas_tecnicas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        equipo_id INTEGER NOT NULL,
        nota TEXT NOT NULL,
        fecha TEXT NOT NULL,
        FOREIGN KEY (equipo_id) REFERENCES equipos (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS notas_tecnicas');
    await db.execute('DROP TABLE IF EXISTS equipos');
    await db.execute('DROP TABLE IF EXISTS clientes');
    await _createDB(db, newVersion);
  }

  Future<void> registrarClienteConEquipo({
    required Cliente cliente,
    required Equipo Function(int clienteId) crearEquipo,
  }) async {
    final db = await instance.database;

    await db.transaction((txn) async {
      final clienteId = await txn.insert(
        'clientes',
        cliente.toMap(),
      );

      final equipo = crearEquipo(clienteId);

      await txn.insert(
        'equipos',
        equipo.toMap(),
      );
    });
  }

  Future<int> insertarCliente(Cliente cliente) async {
    final db = await instance.database;

    return await db.insert(
      'clientes',
      cliente.toMap(),
    );
  }

  Future<int> insertarEquipo(Equipo equipo) async {
    final db = await instance.database;

    return await db.insert(
      'equipos',
      equipo.toMap(),
    );
  }

  Future<List<Map<String, dynamic>>> obtenerClientesConEquipos() async {
    final db = await instance.database;

    return await db.rawQuery('''
      SELECT 
        clientes.id AS cliente_id,
        clientes.nombre,
        clientes.apellido,
        clientes.identificacion,
        clientes.telefono,
        clientes.correo,
        equipos.id AS equipo_id,
        equipos.tipo_equipo,
        equipos.marca,
        equipos.modelo,
        equipos.problema,
        equipos.observaciones,
        equipos.repuestos,
        equipos.codigo_recibo,
        equipos.estado,
        equipos.fecha_ingreso,
        equipos.fecha_entrega,
        equipos.costo_estimado,
        equipos.costo_final
      FROM clientes
      INNER JOIN equipos ON clientes.id = equipos.cliente_id
      ORDER BY equipos.id DESC
    ''');
  }

  Future<int> actualizarCliente(Cliente cliente) async {
    final db = await instance.database;

    return await db.update(
      'clientes',
      cliente.toMap(),
      where: 'id = ?',
      whereArgs: [cliente.id],
    );
  }

  Future<int> actualizarEquipo(Equipo equipo) async {
    final db = await instance.database;

    return await db.update(
      'equipos',
      equipo.toMap(),
      where: 'id = ?',
      whereArgs: [equipo.id],
    );
  }

  Future<int> eliminarCliente(int id) async {
    final db = await instance.database;

    return await db.delete(
      'clientes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> eliminarEquipo(int id) async {
    final db = await instance.database;

    return await db.delete(
      'equipos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Guarda una nota técnica para un equipo.
  Future<int> insertarNotaTecnica({
    required int equipoId,
    required String nota,
    required String fecha,
  }) async {
    final db = await instance.database;

    return await db.insert(
      'notas_tecnicas',
      {
        'equipo_id': equipoId,
        'nota': nota,
        'fecha': fecha,
      },
    );
  }

  /// Obtiene las notas técnicas de un equipo.
  Future<List<Map<String, dynamic>>> obtenerNotasPorEquipo(int equipoId) async {
    final db = await instance.database;

    return await db.query(
      'notas_tecnicas',
      where: 'equipo_id = ?',
      whereArgs: [equipoId],
      orderBy: 'id DESC',
    );
  }

  /// Elimina una nota técnica.
  Future<int> eliminarNotaTecnica(int id) async {
    final db = await instance.database;

    return await db.delete(
      'notas_tecnicas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> cerrarDB() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }
}
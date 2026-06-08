import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import 'add_cliente_screen.dart';
import 'detalle_cliente_screen.dart';
import 'login_screen.dart';
import 'inventario_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> registros = [];
  List<Map<String, dynamic>> registrosFiltrados = [];

  bool cargando = true;
  bool buscando = false;

  String filtroEstado = 'Todos';

  final buscarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarRegistros();
  }

  @override
  void dispose() {
    buscarController.dispose();
    super.dispose();
  }

  Future<void> cargarRegistros() async {
    final datos = await DatabaseHelper.instance.obtenerClientesConEquipos();

    if (!mounted) return;

    setState(() {
      registros = datos;
      registrosFiltrados = datos;
      cargando = false;
      filtroEstado = 'Todos';
    });
  }

  void filtrarRegistros(String texto) {
    final busqueda = texto.toLowerCase();

    setState(() {
      registrosFiltrados = registros.where((registro) {
        final nombre =
            '${registro['nombre']} ${registro['apellido']}'.toLowerCase();
        final telefono = '${registro['telefono']}'.toLowerCase();
        final identificacion = '${registro['identificacion']}'.toLowerCase();
        final equipo = '${registro['tipo_equipo'] ?? ''}'.toLowerCase();
        final estado = '${registro['estado'] ?? ''}'.toLowerCase();
        final codigoRecibo = '${registro['codigo_recibo'] ?? ''}'.toLowerCase();

        return nombre.contains(busqueda) ||
            telefono.contains(busqueda) ||
            identificacion.contains(busqueda) ||
            equipo.contains(busqueda) ||
            estado.contains(busqueda) ||
            codigoRecibo.contains(busqueda);
      }).toList();
    });
  }

  void aplicarFiltroEstado(String filtro) {
    setState(() {
      filtroEstado = filtro;

      if (filtro == 'Todos') {
        registrosFiltrados = registros;
        return;
      }

      if (filtro == 'Alertas 10+ días') {
        registrosFiltrados = registros.where((registro) {
          final dias = calcularDias(registro['fecha_ingreso'] ?? '');
          return dias >= 10 && registro['estado'] != 'Entregado';
        }).toList();
        return;
      }

      registrosFiltrados = registros.where((registro) {
        return registro['estado'] == filtro;
      }).toList();
    });
  }

  Future<void> abrirAgregarCliente() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddClienteScreen(),
      ),
    );

    if (resultado == true) {
      await cargarRegistros();
    }
  }

  Future<void> confirmarEliminar(Map<String, dynamic> registro) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar registro'),
          content: const Text(
            '¿Seguro que deseas eliminar este registro? Esta acción no se puede deshacer.',
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

    if (confirmar != true) return;

    final equipoId = registro['equipo_id'];

    if (equipoId != null) {
      await DatabaseHelper.instance.eliminarEquipo(equipoId);
    }

    await cargarRegistros();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registro eliminado correctamente'),
      ),
    );
  }

  int calcularDias(String fechaIngreso) {
    try {
      final fecha = DateFormat('yyyy-MM-dd HH:mm:ss').parse(fechaIngreso);
      return DateTime.now().difference(fecha).inDays;
    } catch (_) {
      return 0;
    }
  }

  Color colorEstado(String estado) {
    switch (estado) {
      case 'Pendiente':
        return Colors.orange;
      case 'En revisión':
        return Colors.blue;
      case 'Reparado':
        return Colors.green;
      case 'Entregado':
        return Colors.grey;
      default:
        return Colors.black54;
    }
  }

  Color colorAlertaDias(int dias) {
    if (dias >= 15) return Colors.red;
    if (dias >= 10) return Colors.orange;
    return Colors.green;
  }

  String textoAlertaDias(int dias) {
    if (dias >= 15) return 'Máximo superado';
    if (dias >= 10) return 'Notificar cliente';
    return 'Dentro del tiempo';
  }

  Widget indicadorResumen(String titulo, int cantidad) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$cantidad',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget resumenLocal() {
    final pendientes =
        registros.where((r) => r['estado'] == 'Pendiente').length;

    final enRevision =
        registros.where((r) => r['estado'] == 'En revisión').length;

    final reparados =
        registros.where((r) => r['estado'] == 'Reparado').length;

    final entregados =
        registros.where((r) => r['estado'] == 'Entregado').length;

    final activos = registros.where((r) => r['estado'] != 'Entregado').length;

    final alertas = registros.where((r) {
      final dias = calcularDias(r['fecha_ingreso'] ?? '');
      return dias >= 10 && r['estado'] != 'Entregado';
    }).length;

    final totalEstimado = registros.fold<double>(
      0,
      (suma, r) => suma + ((r['costo_estimado'] ?? 0) as num).toDouble(),
    );

    final totalFinal = registros.fold<double>(
      0,
      (suma, r) => suma + ((r['costo_final'] ?? 0) as num).toDouble(),
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade900,
            Colors.blue.shade700,
          ],
        ),
      ),
      child: Column(
        children: [
          Image.asset(
            'assets/images/logo_wfc4.png',
            height: 75,
          ),

          const SizedBox(height: 10),

          const Text(
            'Sistema Técnico WFC4',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              indicadorResumen('Registros', registros.length),
              indicadorResumen('Activos', activos),
              indicadorResumen('Alertas', alertas),
              indicadorResumen('Pendientes', pendientes),
              indicadorResumen('Revisión', enRevision),
              indicadorResumen('Reparados', reparados),
              indicadorResumen('Entregados', entregados),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            'Estimado: \$${totalEstimado.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            'Final: \$${totalFinal.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget tarjetaRegistro(Map<String, dynamic> registro) {
    final nombreCompleto = '${registro['nombre']} ${registro['apellido']}';
    final estado = registro['estado'] ?? 'Sin estado';
    final fechaIngreso = registro['fecha_ingreso'] ?? '';
    final dias = calcularDias(fechaIngreso);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorEstado(estado),
          child: Text(
            nombreCompleto.isNotEmpty ? nombreCompleto[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          nombreCompleto,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Código: ${registro['codigo_recibo'] ?? 'SIN-CODIGO'}\n'
            'Tel: ${registro['telefono']}\n'
            'Equipo: ${registro['tipo_equipo'] ?? 'Sin equipo'}\n'
            'Estado: $estado\n'
            'Días en local: $dias - ${textoAlertaDias(dias)}',
          ),
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'eliminar') {
              confirmarEliminar(registro);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'estado',
              enabled: false,
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    color: colorAlertaDias(dias),
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Text(textoAlertaDias(dias)),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'eliminar',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Eliminar'),
                ],
              ),
            ),
          ],
        ),
        onTap: () async {
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalleClienteScreen(registro: registro),
            ),
          );

          if (resultado == true) {
            await cargarRegistros();
          }
        },
      ),
    );
  }

  Widget filtroDesplegable() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonFormField<String>(
        value: filtroEstado,
        decoration: InputDecoration(
          labelText: 'Filtrar registros',
          prefixIcon: const Icon(Icons.filter_list),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        items: const [
          DropdownMenuItem(value: 'Todos', child: Text('Todos')),
          DropdownMenuItem(value: 'Pendiente', child: Text('Pendiente')),
          DropdownMenuItem(value: 'En revisión', child: Text('En revisión')),
          DropdownMenuItem(value: 'Reparado', child: Text('Reparado')),
          DropdownMenuItem(value: 'Entregado', child: Text('Entregado')),
          DropdownMenuItem(
            value: 'Alertas 10+ días',
            child: Text('Alertas 10+ días'),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            aplicarFiltroEstado(value);
          }
        },
      ),
    );
  }

  Widget contenido() {
    if (cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (registrosFiltrados.isEmpty) {
      return const Center(
        child: Text(
          'No hay registros encontrados',
          style: TextStyle(fontSize: 17),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: cargarRegistros,
      child: ListView.builder(
        itemCount: registrosFiltrados.length,
        itemBuilder: (context, index) {
          return tarjetaRegistro(registrosFiltrados[index]);
        },
      ),
    );
  }

  PreferredSizeWidget appBarNormal() {
    return AppBar(
      title: const Text('WFC4 Clientes'),
      actions: [
        IconButton(
        icon: const Icon(Icons.inventory_2),
        onPressed: () {
        Navigator.push(
        context,
      MaterialPageRoute(
        builder: (context) => const InventarioScreen(),
      ),
    );
  },
),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            setState(() {
              buscando = true;
            });
          },
        ),
      ],
    );
  }

  PreferredSizeWidget appBarBusqueda() {
    return AppBar(
      title: TextField(
        controller: buscarController,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Buscar cliente...',
          hintStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
        ),
        onChanged: filtrarRegistros,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            buscarController.clear();

            setState(() {
              buscando = false;
              registrosFiltrados = registros;
              filtroEstado = 'Todos';
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buscando ? appBarBusqueda() : appBarNormal(),
      body: Column(
        children: [
          resumenLocal(),
          filtroDesplegable(),
          const SizedBox(height: 10),
          Expanded(child: contenido()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: abrirAgregarCliente,
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
    );
  }
}
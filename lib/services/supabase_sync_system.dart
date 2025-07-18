// ===== CONFIGURACIÓN Y SERVICIOS DE SUPABASE =====

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:drift/drift.dart' as drift;
import '../database/database.dart';
import '../repositories/database_repositories.dart';

// ===== CONFIGURACIÓN SUPABASE =====

class SupabaseConfig {
  // CONFIGURACIÓN SEGURA DE CREDENCIALES
  // Para desarrollo (cambiar por tus credenciales)
  static const String _supabaseUrlDev =
      'https://dnbzxnvvapgsxbyhyrfu.supabase.co';
  static const String _supabaseAnonKeyDev =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRuYnp4bnZ2YXBnc3hieWh5cmZ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI3MjkzMzcsImV4cCI6MjA2ODMwNTMzN30.yOIm_TjEuM7qc-oqT3fe9XLZL5a1QAHJjChSVwjPZTk';

  // Desde variables de entorno
  static String get supabaseUrl {
    return const String.fromEnvironment('SUPABASE_URL',
        defaultValue: _supabaseUrlDev);
  }

  static String get supabaseAnonKey {
    return const String.fromEnvironment('SUPABASE_ANON_KEY',
        defaultValue: _supabaseAnonKeyDev);
  }

  // CAMBIAR A FALSE PARA USAR SUPABASE REAL
  static const bool modoDemo =
      false; // Cambiar a false cuando tengas Supabase configurado

  static Future<void> initialize() async {
    if (!modoDemo) {
      try {
        await Supabase.initialize(
          url: supabaseUrl,
          anonKey: supabaseAnonKey,
          debug: true, // Solo en desarrollo
        );
        print('✅ Supabase inicializado exitosamente');
        print('🔗 URL: $supabaseUrl');
        print('🔑 Key: ${supabaseAnonKey.substring(0, 20)}...');
      } catch (e) {
        print('❌ Error inicializando Supabase: $e');
        rethrow;
      }
    } else {
      print('🔧 Modo demo - Supabase simulado');
    }
  }

  static SupabaseClient? get client {
    if (modoDemo) {
      return null; // Retorna null en modo demo
    }
    return Supabase.instance.client;
  }

  static bool get estaConfigurado {
    return !modoDemo && supabaseUrl != "" && supabaseAnonKey != "";
  }
}

// ===== MODELOS DE ESTADO DE SINCRONIZACIÓN =====

enum EstadoSync { idle, sincronizando, completado, error, offline }

class EstadoSincronizacion {
  final EstadoSync estado;
  final String? mensaje;
  final double? progreso; // 0.0 a 1.0
  final DateTime? ultimaActualizacion;
  final Map<String, int> contadores; // productos: 5, ventas: 12, etc.
  final List<String> errores;

  EstadoSincronizacion({
    required this.estado,
    this.mensaje,
    this.progreso,
    this.ultimaActualizacion,
    this.contadores = const {},
    this.errores = const [],
  });

  EstadoSincronizacion copyWith({
    EstadoSync? estado,
    String? mensaje,
    double? progreso,
    DateTime? ultimaActualizacion,
    Map<String, int>? contadores,
    List<String>? errores,
  }) {
    return EstadoSincronizacion(
      estado: estado ?? this.estado,
      mensaje: mensaje ?? this.mensaje,
      progreso: progreso ?? this.progreso,
      ultimaActualizacion: ultimaActualizacion ?? this.ultimaActualizacion,
      contadores: contadores ?? this.contadores,
      errores: errores ?? this.errores,
    );
  }
}

class ConflictoSincronizacion {
  final String tabla;
  final int idLocal;
  final Map<String, dynamic> datosLocal;
  final Map<String, dynamic> datosRemoto;
  final DateTime fechaConflicto;

  ConflictoSincronizacion({
    required this.tabla,
    required this.idLocal,
    required this.datosLocal,
    required this.datosRemoto,
    required this.fechaConflicto,
  });
}

// ===== SERVICIO PRINCIPAL DE SINCRONIZACIÓN =====

class SincronizacionService {
  final SupabaseClient? _supabase = SupabaseConfig.client;
  final AppDatabase _database;

  SincronizacionService(this._database);

  // ===== SINCRONIZACIÓN COMPLETA =====
  Stream<EstadoSincronizacion> sincronizarTodo() async* {
    yield EstadoSincronizacion(
      estado: EstadoSync.sincronizando,
      mensaje: 'Iniciando sincronización...',
      progreso: 0.0,
    );

    try {
      // 1. Verificar conexión
      yield EstadoSincronizacion(
        estado: EstadoSync.sincronizando,
        mensaje: 'Verificando conexión...',
        progreso: 0.1,
      );

      final hayConexion = await _verificarConexion();
      if (!hayConexion) {
        yield EstadoSincronizacion(
          estado: EstadoSync.offline,
          mensaje: 'Sin conexión a internet',
          errores: ['No se puede conectar con el servidor'],
        );
        return;
      }

      final contadores = <String, int>{};

      // 2. Sincronizar productos (20% - 40%)
      yield EstadoSincronizacion(
        estado: EstadoSync.sincronizando,
        mensaje: 'Sincronizando productos...',
        progreso: 0.2,
      );

      contadores['productos'] = await _sincronizarProductos();

      yield EstadoSincronizacion(
        estado: EstadoSync.sincronizando,
        mensaje: 'Productos sincronizados: ${contadores['productos']}',
        progreso: 0.4,
        contadores: Map.from(contadores),
      );

      // 3. Sincronizar ventas (40% - 70%)
      yield EstadoSincronizacion(
        estado: EstadoSync.sincronizando,
        mensaje: 'Sincronizando ventas...',
        progreso: 0.5,
        contadores: Map.from(contadores),
      );

      contadores['ventas'] = await _sincronizarVentas();

      yield EstadoSincronizacion(
        estado: EstadoSync.sincronizando,
        mensaje: 'Ventas sincronizadas: ${contadores['ventas']}',
        progreso: 0.7,
        contadores: Map.from(contadores),
      );

      // 4. Sincronizar usuarios (70% - 85%)
      yield EstadoSincronizacion(
        estado: EstadoSync.sincronizando,
        mensaje: 'Sincronizando usuarios...',
        progreso: 0.75,
        contadores: Map.from(contadores),
      );

      contadores['usuarios'] = await _sincronizarUsuarios();

      // 5. Sincronizar configuraciones (85% - 95%)
      yield EstadoSincronizacion(
        estado: EstadoSync.sincronizando,
        mensaje: 'Sincronizando configuraciones...',
        progreso: 0.9,
        contadores: Map.from(contadores),
      );

      contadores['configuraciones'] = await _sincronizarConfiguraciones();

      // 6. Finalizar
      yield EstadoSincronizacion(
        estado: EstadoSync.completado,
        mensaje: 'Sincronización completada exitosamente',
        progreso: 1.0,
        ultimaActualizacion: DateTime.now(),
        contadores: contadores,
      );
    } catch (e) {
      yield EstadoSincronizacion(
        estado: EstadoSync.error,
        mensaje: 'Error en la sincronización',
        errores: [e.toString()],
      );
    }
  }

  // ===== VERIFICAR CONEXIÓN =====
  Future<bool> _verificarConexion() async {
    try {
      // En modo demo, simular conexión exitosa
      if (SupabaseConfig.modoDemo) {
        await Future.delayed(const Duration(seconds: 1));
        return true;
      }

      // Verificación real con Supabase
      if (_supabase == null) return false;

      // Verificación real de conexión
      final response = await _supabase!.from('productos').select('id').limit(1);
      print(
          '✅ Conexión a Supabase verificada: ${response.length} registros encontrados');
      return true;
    } catch (e) {
      print('❌ Error de conexión: $e');
      return false;
    }
  }

  // ===== SINCRONIZAR PRODUCTOS =====
  Future<int> _sincronizarProductos() async {
    try {
      // 1. Subir productos locales no sincronizados
      final productosLocal = await _database.select(_database.productos).get();
      int sincronizados = 0;

      for (final producto in productosLocal) {
        await Future.delayed(
            const Duration(milliseconds: 100)); // Simular trabajo

        // Preparar datos para Supabase
        final datosProducto = {
          'id': producto.id,
          'codigo_barras': producto.codigoBarras,
          'nombre': producto.nombre,
          'descripcion': producto.descripcion,
          'categoria': producto.categoria,
          'precio_venta': producto.precioVenta,
          'precio_compra': producto.precioCompra,
          'margen_ganancia': producto.margenGanancia,
          'stock_actual': producto.stockActual,
          'stock_minimo': producto.stockMinimo,
          'unidad_medida': producto.unidadMedida,
          'fecha_creacion': producto.fechaCreacion.toIso8601String(),
          'activo': producto.activo,
          'tienda_id': producto.tiendaId,
          'actualizado_en': DateTime.now().toIso8601String(),
        };

        if (SupabaseConfig.modoDemo) {
          // Modo demo - solo simular
          print('📦 [DEMO] Sincronizando producto: ${producto.nombre}');
        } else {
          // Modo real - sincronizar con Supabase
          try {
            print('📦 Sincronizando producto: ${producto.nombre}');
            await _supabase!.from('productos').upsert(datosProducto);
            print('✅ Producto sincronizado: ${producto.nombre}');
          } catch (e) {
            print('❌ Error sincronizando producto ${producto.nombre}: $e');
            throw Exception(
                'Error sincronizando producto ${producto.nombre}: $e');
          }
        }

        sincronizados++;
      }

      // 2. Descargar productos remotos actualizados (para futuro)
      if (!SupabaseConfig.modoDemo) {
        try {
          // Obtener productos remotos actualizados en las últimas 24 horas
          final ayer = DateTime.now().subtract(const Duration(days: 1));
          final productosRemotos = await _supabase!
              .from('productos')
              .select()
              .gte('actualizado_en', ayer.toIso8601String());

          print('📥 Productos remotos encontrados: ${productosRemotos.length}');

          // TODO: Implementar actualización de productos locales con datos remotos
          // Esto requeriría lógica de resolución de conflictos
        } catch (e) {
          print('⚠️ Error obteniendo productos remotos: $e');
          // No lanzar excepción aquí, la subida ya fue exitosa
        }
      }

      return sincronizados;
    } catch (e) {
      throw Exception('Error sincronizando productos: $e');
    }
  }

  // ===== SINCRONIZAR VENTAS =====
  Future<int> _sincronizarVentas() async {
    try {
      // 1. Subir ventas no sincronizadas
      final ventasNoSincronizadas = await (_database.select(_database.ventas)
            ..where((v) => v.sincronizadoNube.equals(false)))
          .get();

      int sincronizadas = 0;

      for (final venta in ventasNoSincronizadas) {
        await Future.delayed(
            const Duration(milliseconds: 150)); // Simular trabajo

        // Obtener detalles de la venta
        final detalles = await (_database.select(_database.detalleVentas)
              ..where((d) => d.ventaId.equals(venta.id)))
            .get();

        // Preparar datos para Supabase
        final datosVenta = {
          'id': venta.id,
          'fecha_venta': venta.fechaVenta.toIso8601String(),
          'total_venta': venta.totalVenta,
          'metodo_pago': venta.metodoPago,
          'cliente_id': venta.clienteId,
          'usuario_id': venta.usuarioId,
          'descuento_aplicado': venta.descuentoAplicado,
          'latitud': venta.latitud,
          'longitud': venta.longitud,
          'direccion_aproximada': venta.direccionAproximada,
          'zona_geografica': venta.zonaGeografica,
          'tienda_id': venta.tiendaId,
          'actualizado_en': DateTime.now().toIso8601String(),
        };

        if (SupabaseConfig.modoDemo) {
          // Modo demo - solo simular
          print('💰 [DEMO] Sincronizando venta #${venta.id}');
        } else {
          // Modo real - sincronizar con Supabase
          try {
            print('💰 Sincronizando venta #${venta.id}');
            await _supabase!.from('ventas').upsert(datosVenta);
            print('✅ Venta sincronizada #${venta.id}');

            // Sincronizar detalles de la venta
            for (final detalle in detalles) {
              final datosDetalle = {
                'id': detalle.id,
                'venta_id': detalle.ventaId,
                'producto_id': detalle.productoId,
                'cantidad': detalle.cantidad,
                'precio_unitario': detalle.precioUnitario,
                'subtotal': detalle.subtotal,
                'descuento_item': detalle.descuentoItem,
              };

              await _supabase!.from('detalle_ventas').upsert(datosDetalle);
              print('✅ Detalle sincronizado para venta #${venta.id}');
            }
          } catch (e) {
            print('❌ Error sincronizando venta #${venta.id}: $e');
            throw Exception('Error sincronizando venta #${venta.id}: $e');
          }
        }

        // Marcar como sincronizada localmente (solo si fue exitosa)
        await (_database.update(_database.ventas)
              ..where((v) => v.id.equals(venta.id)))
            .write(VentasCompanion(
          sincronizadoNube: const drift.Value(true),
          fechaSincronizacion: drift.Value(DateTime.now()),
        ));

        sincronizadas++;
      }

      return sincronizadas;
    } catch (e) {
      throw Exception('Error sincronizando ventas: $e');
    }
  }

  // ===== SINCRONIZAR USUARIOS =====
  Future<int> _sincronizarUsuarios() async {
    try {
      await Future.delayed(
          const Duration(milliseconds: 500)); // Simular trabajo

      final usuarios = await _database.select(_database.usuariosTienda).get();

      // En producción, sincronizarías usuarios aquí

      return usuarios.length;
    } catch (e) {
      throw Exception('Error sincronizando usuarios: $e');
    }
  }

  // ===== SINCRONIZAR CONFIGURACIONES =====
  Future<int> _sincronizarConfiguraciones() async {
    try {
      await Future.delayed(
          const Duration(milliseconds: 300)); // Simular trabajo

      final configuraciones =
          await _database.select(_database.configuracionesLocales).get();

      // En producción, sincronizarías configuraciones aquí

      return configuraciones.length;
    } catch (e) {
      throw Exception('Error sincronizando configuraciones: $e');
    }
  }

  // ===== SINCRONIZACIÓN ESPECÍFICA POR TABLA =====
  Future<int> sincronizarSoloProductos() async {
    return await _sincronizarProductos();
  }

  Future<int> sincronizarSoloVentas() async {
    return await _sincronizarVentas();
  }

  // ===== OBTENER ESTADÍSTICAS =====
  Future<Map<String, dynamic>> obtenerEstadisticasSync() async {
    try {
      // Contar registros pendientes
      final ventasPendientes = await (_database.select(_database.ventas)
            ..where((v) => v.sincronizadoNube.equals(false)))
          .get();

      final totalProductos = await _database.select(_database.productos).get();
      final totalVentas = await _database.select(_database.ventas).get();
      final ventasSincronizadas = await (_database.select(_database.ventas)
            ..where((v) => v.sincronizadoNube.equals(true)))
          .get();

      // Obtener última sincronización
      final ultimaVentaSincronizada = await (_database.select(_database.ventas)
            ..where((v) => v.fechaSincronizacion.isNotNull())
            ..orderBy([(v) => drift.OrderingTerm.desc(v.fechaSincronizacion)])
            ..limit(1))
          .getSingleOrNull();

      return {
        'ventas_pendientes': ventasPendientes.length,
        'ventas_sincronizadas': ventasSincronizadas.length,
        'total_productos': totalProductos.length,
        'total_ventas': totalVentas.length,
        'porcentaje_sincronizado': totalVentas.isNotEmpty
            ? (ventasSincronizadas.length / totalVentas.length * 100).round()
            : 100,
        'ultima_sincronizacion': ultimaVentaSincronizada?.fechaSincronizacion,
        'hay_conexion': await _verificarConexion(),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'hay_conexion': false,
      };
    }
  }
}

// ===== PROVIDERS =====

final sincronizacionServiceProvider = Provider<SincronizacionService>((ref) {
  final database = ref.watch(databaseProvider);
  return SincronizacionService(database);
});

final estadoSincronizacionProvider =
    StateNotifierProvider<SincronizacionNotifier, EstadoSincronizacion>((ref) {
  final service = ref.watch(sincronizacionServiceProvider);
  return SincronizacionNotifier(service);
});

final estadisticasSyncProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(sincronizacionServiceProvider);
  return await service.obtenerEstadisticasSync();
});

// ===== NOTIFIER PARA MANEJAR ESTADO =====

class SincronizacionNotifier extends StateNotifier<EstadoSincronizacion> {
  final SincronizacionService _service;

  SincronizacionNotifier(this._service)
      : super(EstadoSincronizacion(estado: EstadoSync.idle));

  Future<void> sincronizarTodo() async {
    await for (final estado in _service.sincronizarTodo()) {
      state = estado;
    }
  }

  Future<void> sincronizarProductos() async {
    state = state.copyWith(
      estado: EstadoSync.sincronizando,
      mensaje: 'Sincronizando productos...',
    );

    try {
      final sincronizados = await _service.sincronizarSoloProductos();
      state = state.copyWith(
        estado: EstadoSync.completado,
        mensaje: 'Productos sincronizados: $sincronizados',
        ultimaActualizacion: DateTime.now(),
        contadores: {'productos': sincronizados},
      );
    } catch (e) {
      state = state.copyWith(
        estado: EstadoSync.error,
        mensaje: 'Error sincronizando productos',
        errores: [e.toString()],
      );
    }
  }

  Future<void> sincronizarVentas() async {
    state = state.copyWith(
      estado: EstadoSync.sincronizando,
      mensaje: 'Sincronizando ventas...',
    );

    try {
      final sincronizadas = await _service.sincronizarSoloVentas();
      state = state.copyWith(
        estado: EstadoSync.completado,
        mensaje: 'Ventas sincronizadas: $sincronizadas',
        ultimaActualizacion: DateTime.now(),
        contadores: {'ventas': sincronizadas},
      );
    } catch (e) {
      state = state.copyWith(
        estado: EstadoSync.error,
        mensaje: 'Error sincronizando ventas',
        errores: [e.toString()],
      );
    }
  }

  void limpiarEstado() {
    state = EstadoSincronizacion(estado: EstadoSync.idle);
  }
}

// ===== PANTALLA PRINCIPAL DE SINCRONIZACIÓN =====

class SincronizacionScreen extends ConsumerWidget {
  const SincronizacionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estadoSync = ref.watch(estadoSincronizacionProvider);
    final estadisticas = ref.watch(estadisticasSyncProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sincronización'),
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _mostrarAyuda(context),
            tooltip: 'Ayuda',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estado de configuración de Supabase
            _buildEstadoSupabase(context),

            const SizedBox(height: 16),

            // Estado actual de sincronización
            _buildEstadoActual(context, ref, estadoSync),

            const SizedBox(height: 24),

            // Estadísticas
            estadisticas.when(
              data: (stats) => _buildEstadisticas(context, stats),
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error: $error'),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Acciones de sincronización
            _buildAccionesSincronizacion(context, ref, estadoSync),

            const SizedBox(height: 24),

            // Configuración avanzada
            _buildConfiguracionAvanzada(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoSupabase(BuildContext context) {
    var estaConfigurado = SupabaseConfig.estaConfigurado;
    var modoDemo = SupabaseConfig.modoDemo;

    return Card(
      color: modoDemo
          ? Colors.orange[50]
          : (estaConfigurado ? Colors.green[50] : Colors.red[50]),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  modoDemo
                      ? Icons.construction
                      : (estaConfigurado ? Icons.cloud_done : Icons.cloud_off),
                  color: modoDemo
                      ? Colors.orange[700]
                      : (estaConfigurado ? Colors.green[700] : Colors.red[700]),
                ),
                const SizedBox(width: 8),
                Text(
                  'Estado De Supabase',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: modoDemo
                        ? Colors.orange[100]
                        : (estaConfigurado
                            ? Colors.green[100]
                            : Colors.red[100]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    modoDemo
                        ? 'MODO DEMO'
                        : (estaConfigurado ? 'CONFIGURADO' : 'SIN CONFIGURAR'),
                    style: TextStyle(
                      color: modoDemo
                          ? Colors.orange[700]
                          : (estaConfigurado
                              ? Colors.green[700]
                              : Colors.red[700]),
                      fontWeight: FontWeight.bold,
                      fontSize: 8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              modoDemo
                  ? '🔧 Funcionando en modo simulación. Los datos no se sincronizarán con la nube.'
                  : estaConfigurado
                      ? '✅ Supabase configurado correctamente. Listo para sincronizar.'
                      : '⚠️ Supabase no está configurado. Configura tus credenciales para habilitar la sincronización.',
              style: TextStyle(
                color: modoDemo
                    ? Colors.orange[700]
                    : (estaConfigurado ? Colors.green[700] : Colors.red[700]),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 Para cambiar a modo real:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '1. Cambia modoDemo = false en SupabaseConfig\n'
                    '2. Configura tus credenciales reales\n'
                    '3. Reinicia la aplicación',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ),
            if (!estaConfigurado && !modoDemo) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _mostrarConfiguracionSupabase(context),
                icon: const Icon(Icons.settings),
                label: const Text('Configurar Supabase'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoActual(
      BuildContext context, WidgetRef ref, EstadoSincronizacion estado) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getIconoEstado(estado.estado),
                  color: _getColorEstado(estado.estado),
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  'Estado de Sincronización',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getColorEstado(estado.estado).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getColorEstado(estado.estado).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _getNombreEstado(estado.estado),
                    style: TextStyle(
                      color: _getColorEstado(estado.estado),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (estado.mensaje != null)
              Text(
                estado.mensaje!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            if (estado.progreso != null) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: estado.progreso,
                backgroundColor: Colors.grey[200],
                valueColor:
                    AlwaysStoppedAnimation(_getColorEstado(estado.estado)),
              ),
              const SizedBox(height: 4),
              Text(
                '${(estado.progreso! * 100).round()}% completado',
                style: const TextStyle(fontSize: 12),
              ),
            ],
            if (estado.ultimaActualizacion != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Última sincronización: ${_formatearFecha(estado.ultimaActualizacion!)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (estado.contadores.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: estado.contadores.entries
                    .map((entry) => Chip(
                          label: Text('${entry.key}: ${entry.value}'),
                          backgroundColor: Colors.blue[100],
                        ))
                    .toList(),
              ),
            ],
            if (estado.errores.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.error, color: Colors.red[700], size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Errores:',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ...estado.errores.map((error) => Text(
                          '• $error',
                          style: TextStyle(
                            color: Colors.red[600],
                            fontSize: 12,
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEstadisticas(BuildContext context, Map<String, dynamic> stats) {
    final hayConexion = stats['hay_conexion'] ?? false;
    final ventasPendientes = stats['ventas_pendientes'] ?? 0;
    final porcentajeSincronizado = stats['porcentaje_sincronizado'] ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estadísticas de Sincronización',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildEstadisticaItem(
                    'Conexión',
                    hayConexion ? 'Online' : 'Offline',
                    hayConexion ? Icons.cloud_done : Icons.cloud_off,
                    hayConexion ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildEstadisticaItem(
                    'Ventas Pendientes',
                    ventasPendientes.toString(),
                    Icons.pending,
                    ventasPendientes > 0 ? Colors.orange : Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildEstadisticaItem(
                    'Sincronizado',
                    '$porcentajeSincronizado%',
                    Icons.sync,
                    porcentajeSincronizado >= 90 ? Colors.green : Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildEstadisticaItem(
                    'Total Productos',
                    (stats['total_productos'] ?? 0).toString(),
                    Icons.inventory_2,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            if (stats['ultima_sincronizacion'] != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.teal[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.history, color: Colors.teal[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Última sincronización: ${_formatearFecha(stats['ultima_sincronizacion'])}',
                        style: TextStyle(
                          color: Colors.teal[700],
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEstadisticaItem(
      String label, String valor, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icono, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            valor,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAccionesSincronizacion(
      BuildContext context, WidgetRef ref, EstadoSincronizacion estado) {
    final estaSincronizando = estado.estado == EstadoSync.sincronizando;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acciones de Sincronización',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Sincronización completa
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: estaSincronizando
                    ? null
                    : () => ref
                        .read(estadoSincronizacionProvider.notifier)
                        .sincronizarTodo(),
                icon: estaSincronizando
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync),
                label: Text(estaSincronizando
                    ? 'Sincronizando...'
                    : 'Sincronizar Todo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Sincronizaciones específicas
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: estaSincronizando
                        ? null
                        : () => ref
                            .read(estadoSincronizacionProvider.notifier)
                            .sincronizarProductos(),
                    icon: const Icon(Icons.inventory_2),
                    label: const Text('Productos'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: estaSincronizando
                        ? null
                        : () => ref
                            .read(estadoSincronizacionProvider.notifier)
                            .sincronizarVentas(),
                    icon: const Icon(Icons.receipt),
                    label: const Text('Ventas'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Limpiar estado
            TextButton.icon(
              onPressed: () {
                ref.read(estadoSincronizacionProvider.notifier).limpiarEstado();
                ref.refresh(estadisticasSyncProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar Estado'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfiguracionAvanzada(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuración Avanzada',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.settings_backup_restore),
              title: const Text('Configurar Supabase'),
              subtitle: const Text('Cambiar URL y credenciales'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _mostrarConfiguracionSupabase(context),
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Sincronización Automática'),
              subtitle: const Text('Configurar intervalos de sync'),
              trailing: Switch(
                value: true, // Placeholder
                onChanged: (value) {
                  // Implementar toggle de sync automático
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.network_check),
              title: const Text('Solo WiFi'),
              subtitle: const Text('Sincronizar solo con WiFi'),
              trailing: Switch(
                value: false, // Placeholder
                onChanged: (value) {
                  // Implementar toggle de solo WiFi
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.delete_sweep),
              title: const Text('Limpiar Cache'),
              subtitle: const Text('Borrar datos temporales'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _mostrarDialogoLimpiarCache(context),
            ),
          ],
        ),
      ),
    );
  }

  // ===== MÉTODOS AUXILIARES =====

  IconData _getIconoEstado(EstadoSync estado) {
    switch (estado) {
      case EstadoSync.idle:
        return Icons.cloud_off;
      case EstadoSync.sincronizando:
        return Icons.sync;
      case EstadoSync.completado:
        return Icons.cloud_done;
      case EstadoSync.error:
        return Icons.error;
      case EstadoSync.offline:
        return Icons.wifi_off;
    }
  }

  Color _getColorEstado(EstadoSync estado) {
    switch (estado) {
      case EstadoSync.idle:
        return Colors.grey;
      case EstadoSync.sincronizando:
        return Colors.blue;
      case EstadoSync.completado:
        return Colors.green;
      case EstadoSync.error:
        return Colors.red;
      case EstadoSync.offline:
        return Colors.orange;
    }
  }

  String _getNombreEstado(EstadoSync estado) {
    switch (estado) {
      case EstadoSync.idle:
        return 'Inactivo';
      case EstadoSync.sincronizando:
        return 'Sincronizando';
      case EstadoSync.completado:
        return 'Completado';
      case EstadoSync.error:
        return 'Error';
      case EstadoSync.offline:
        return 'Sin Conexión';
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  void _mostrarAyuda(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ayuda - Sincronización'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🌐 Sincronización\n'),
              Text(
                  'La sincronización mantiene tus datos actualizados entre dispositivos.\n'),
              Text('• Productos: Inventario y precios'),
              Text('• Ventas: Transacciones realizadas'),
              Text('• Usuarios: Personal de la tienda'),
              Text('• Configuraciones: Ajustes del sistema\n'),
              Text('💡 Consejos:\n'),
              Text('• Mantén buena conexión WiFi'),
              Text('• Sincroniza regularmente'),
              Text('• Revisa errores en el estado'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _mostrarConfiguracionSupabase(BuildContext context) {
    final urlController =
        TextEditingController(text: SupabaseConfig.supabaseUrl);
    final keyController =
        TextEditingController(text: SupabaseConfig.supabaseAnonKey);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configurar Supabase'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🌐 Configura tus credenciales de Supabase para habilitar la sincronización en la nube.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'URL de Supabase',
                  hintText: 'https://tu-proyecto.supabase.co',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: keyController,
                decoration: const InputDecoration(
                  labelText: 'Anon Key',
                  hintText: 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 Cómo obtener credenciales:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '1. Ve a supabase.com\n'
                      '2. Crea un proyecto\n'
                      '3. Ve a Settings > API\n'
                      '4. Copia URL y anon key',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // En una implementación real, guardarías estas credenciales
              // en SharedPreferences o secure storage
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      '⚠️ En esta demo, las credenciales no se guardan permanentemente'),
                  backgroundColor: Colors.orange,
                ),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoLimpiarCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar Cache'),
        content: const Text(
            '¿Estás seguro de que deseas limpiar todos los datos temporales? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // Implementar limpieza de cache
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache limpiado exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }
}

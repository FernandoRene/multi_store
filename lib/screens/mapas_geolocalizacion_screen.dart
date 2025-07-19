import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;
import '../database/database.dart';
import '../models/database_models.dart';
import '../repositories/database_repositories.dart';

// ===== MODELOS PARA GEOLOCALIZACIÓN =====

class PuntoVenta {
  final LatLng ubicacion;
  final double totalVentas;
  final int numeroVentas;
  final DateTime fechaUltimaVenta;
  final String zona;
  final List<VentaCompleta> ventas;

  PuntoVenta({
    required this.ubicacion,
    required this.totalVentas,
    required this.numeroVentas,
    required this.fechaUltimaVenta,
    required this.zona,
    required this.ventas,
  });
}

class ZonaGeografica {
  final String nombre;
  final LatLng centro;
  final double radio;
  final double totalVentas;
  final int numeroVentas;
  final Color color;

  ZonaGeografica({
    required this.nombre,
    required this.centro,
    required this.radio,
    required this.totalVentas,
    required this.numeroVentas,
    required this.color,
  });
}

// ===== PROVIDERS PARA MAPAS =====

final ubicacionActualProvider = FutureProvider<Position?>((ref) async {
  try {
    // Verificar permisos
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    // Obtener ubicación
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  } catch (e) {
    print('Error obteniendo ubicación: $e');
    return null;
  }
});

final ventasConUbicacionProvider =
    FutureProvider<List<VentaCompleta>>((ref) async {
  final repository = ref.watch(ventasRepositoryProvider);
  final todasVentas = await repository.obtenerVentas();

  // Filtrar solo ventas que tienen ubicación
  return todasVentas
      .where((venta) => venta.latitud != null && venta.longitud != null)
      .toList();
});

final puntosVentaProvider = FutureProvider<List<PuntoVenta>>((ref) async {
  final ventasConUbicacion = await ref.watch(ventasConUbicacionProvider.future);

  // Agrupar ventas por ubicación aproximada (radio de 100m)
  final Map<String, List<VentaCompleta>> gruposUbicacion = {};

  for (final venta in ventasConUbicacion) {
    // Crear clave basada en coordenadas aproximadas
    final lat = (venta.latitud! * 1000).round() / 1000;
    final lng = (venta.longitud! * 1000).round() / 1000;
    final clave = '$lat,$lng';

    gruposUbicacion.putIfAbsent(clave, () => []).add(venta);
  }

  // Convertir grupos en PuntoVenta
  return gruposUbicacion.entries.map((entry) {
    final ventas = entry.value;
    final ubicacion = LatLng(ventas.first.latitud!, ventas.first.longitud!);
    final totalVentas = ventas.fold(0.0, (sum, v) => sum + v.totalVenta);
    final fechaUltima =
        ventas.map((v) => v.fechaVenta).reduce((a, b) => a.isAfter(b) ? a : b);

    return PuntoVenta(
      ubicacion: ubicacion,
      totalVentas: totalVentas,
      numeroVentas: ventas.length,
      fechaUltimaVenta: fechaUltima,
      zona: ventas.first.zonaGeografica ?? 'Sin zona',
      ventas: ventas,
    );
  }).toList();
});

final zonasGeograficasProvider =
    FutureProvider<List<ZonaGeografica>>((ref) async {
  // Simular zonas geográficas para La Paz, Bolivia
  return [
    ZonaGeografica(
      nombre: 'Zona Sur',
      centro: const LatLng(-16.5320, -68.1193),
      radio: 2000,
      totalVentas: 15420.50,
      numeroVentas: 45,
      color: Colors.blue,
    ),
    ZonaGeografica(
      nombre: 'Centro',
      centro: const LatLng(-16.4955, -68.1336),
      radio: 1500,
      totalVentas: 22150.75,
      numeroVentas: 67,
      color: Colors.green,
    ),
    ZonaGeografica(
      nombre: 'El Alto',
      centro: const LatLng(-16.5039, -68.1697),
      radio: 3000,
      totalVentas: 8950.25,
      numeroVentas: 28,
      color: Colors.orange,
    ),
    ZonaGeografica(
      nombre: 'Zona Norte',
      centro: const LatLng(-16.4820, -68.1500),
      radio: 2500,
      totalVentas: 12340.00,
      numeroVentas: 34,
      color: Colors.purple,
    ),
  ];
});

// ===== PANTALLA PRINCIPAL DE MAPAS =====

class MapasGelocalizacionScreen extends ConsumerStatefulWidget {
  const MapasGelocalizacionScreen({super.key});

  @override
  ConsumerState<MapasGelocalizacionScreen> createState() =>
      _MapasGelocalizacionScreenState();
}

class _MapasGelocalizacionScreenState
    extends ConsumerState<MapasGelocalizacionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MapController _mapController = MapController();

  // Configuración del mapa
  static const LatLng _laPazCenter = LatLng(-16.5000, -68.1500);
  bool _mostrarZonas = true;
  bool _mostrarPuntosVenta = true;
  bool _mostrarCalor = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapas y Geolocalización'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.map), text: 'Mapa'),
            Tab(icon: Icon(Icons.analytics), text: 'Análisis'),
            Tab(icon: Icon(Icons.location_on), text: 'Zonas'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _centrarEnUbicacionActual,
            tooltip: 'Mi ubicación',
          ),
          PopupMenuButton<String>(
            onSelected: _onMenuSelected,
            icon: const Icon(Icons.layers),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'zonas',
                child: Row(
                  children: [
                    Icon(
                      _mostrarZonas ? Icons.visibility : Icons.visibility_off,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('Zonas geográficas'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'puntos',
                child: Row(
                  children: [
                    Icon(
                      _mostrarPuntosVenta
                          ? Icons.visibility
                          : Icons.visibility_off,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('Puntos de venta'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'calor',
                child: Row(
                  children: [
                    Icon(
                      _mostrarCalor ? Icons.visibility : Icons.visibility_off,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('Mapa de calor'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMapaTab(),
          _buildAnalisisTab(),
          _buildZonasTab(),
        ],
      ),
    );
  }

  // ===== TAB 1: MAPA PRINCIPAL =====

  Widget _buildMapaTab() {
    final puntosVenta = ref.watch(puntosVentaProvider);
    final zonas = ref.watch(zonasGeograficasProvider);
    final ubicacionActual = ref.watch(ubicacionActualProvider);

    return Stack(
      children: [
        // Mapa
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _laPazCenter,
            initialZoom: 13.0,
            minZoom: 10.0,
            maxZoom: 18.0,
            onTap: (tapPosition, point) => _onMapTap(point),
          ),
          children: [
            // Capa base del mapa
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.inventario.multitienda',
            ),

            // Zonas geográficas
            if (_mostrarZonas)
              zonas.when(
                data: (listaZonas) => CircleLayer(
                  circles: listaZonas
                      .map((zona) => CircleMarker(
                            point: zona.centro,
                            radius: zona.radio,
                            useRadiusInMeter: true,
                            color: zona.color.withOpacity(0.3),
                            borderColor: zona.color,
                            borderStrokeWidth: 2,
                          ))
                      .toList(),
                ),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),

            // Puntos de venta
            if (_mostrarPuntosVenta)
              puntosVenta.when(
                data: (listaPuntos) => MarkerLayer(
                  markers: listaPuntos
                      .map((punto) => Marker(
                            point: punto.ubicacion,
                            width: _getMarkerSize(punto.totalVentas),
                            height: _getMarkerSize(punto.totalVentas),
                            child: GestureDetector(
                              onTap: () => _mostrarInfoPunto(punto),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _getMarkerColor(punto.totalVentas),
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    punto.numeroVentas.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),

            // Ubicación actual
            ubicacionActual.when(
              data: (position) => position != null
                  ? MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(position.latitude, position.longitude),
                          width: 40,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
          ],
        ),

        // Panel de información
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: _buildInfoPanel(),
        ),

        // Controles del mapa
        Positioned(
          bottom: 16,
          right: 16,
          child: _buildMapControls(),
        ),
      ],
    );
  }

  Widget _buildInfoPanel() {
    final puntosVenta = ref.watch(puntosVentaProvider);

    return puntosVenta.when(
      data: (puntos) {
        final totalVentas = puntos.fold(0.0, (sum, p) => sum + p.totalVentas);
        final totalTransacciones =
            puntos.fold(0, (sum, p) => sum + p.numeroVentas);

        return Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Resumen de Ventas Geográficas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoMetric(
                        'Total Ventas',
                        'Bs. ${totalVentas.toStringAsFixed(2)}',
                        Icons.attach_money,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoMetric(
                        'Transacciones',
                        totalTransacciones.toString(),
                        Icons.receipt,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoMetric(
                        'Puntos Activos',
                        puntos.length.toString(),
                        Icons.location_on,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Cargando datos del mapa...'),
            ],
          ),
        ),
      ),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildInfoMetric(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildMapControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Zoom in
        FloatingActionButton(
          mini: true,
          heroTag: 'zoom_in',
          onPressed: () {
            final zoom = _mapController.camera.zoom;
            _mapController.move(_mapController.camera.center, zoom + 1);
          },
          backgroundColor: Colors.white,
          child: const Icon(Icons.add, color: Colors.black),
        ),
        const SizedBox(height: 8),
        // Zoom out
        FloatingActionButton(
          mini: true,
          heroTag: 'zoom_out',
          onPressed: () {
            final zoom = _mapController.camera.zoom;
            _mapController.move(_mapController.camera.center, zoom - 1);
          },
          backgroundColor: Colors.white,
          child: const Icon(Icons.remove, color: Colors.black),
        ),
        const SizedBox(height: 8),
        // Reset zoom
        FloatingActionButton(
          mini: true,
          heroTag: 'reset',
          onPressed: () {
            _mapController.move(_laPazCenter, 13.0);
          },
          backgroundColor: Colors.white,
          child: const Icon(Icons.center_focus_strong, color: Colors.black),
        ),
      ],
    );
  }

  // ===== TAB 2: ANÁLISIS GEOGRÁFICO =====

  Widget _buildAnalisisTab() {
    final zonas = ref.watch(zonasGeograficasProvider);
    final puntosVenta = ref.watch(puntosVentaProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          const Text(
            'Análisis Geográfico de Ventas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Resumen por zonas
          zonas.when(
            data: (listaZonas) => _buildResumenZonas(listaZonas),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('Error al cargar zonas'),
          ),

          const SizedBox(height: 24),

          // Análisis de densidad
          puntosVenta.when(
            data: (puntos) => _buildAnalisisDensidad(puntos),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('Error al cargar puntos de venta'),
          ),

          const SizedBox(height: 24),

          // Recomendaciones
          _buildRecomendaciones(),
        ],
      ),
    );
  }

  Widget _buildResumenZonas(List<ZonaGeografica> zonas) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rendimiento por Zona',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...zonas.map((zona) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: zona.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              zona.nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${zona.numeroVentas} ventas • Bs. ${zona.totalVentas.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Bs. ${(zona.totalVentas / zona.numeroVentas).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const Text(
                            'promedio',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalisisDensidad(List<PuntoVenta> puntos) {
    if (puntos.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No hay puntos de venta para analizar'),
        ),
      );
    }

    final densidadPromedio = puntos.length / 100; // puntos por km²
    final ventaPromedio =
        puntos.fold(0.0, (sum, p) => sum + p.totalVentas) / puntos.length;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Análisis de Densidad',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDensidadMetric(
                    'Densidad',
                    '${densidadPromedio.toStringAsFixed(1)}/km²',
                    Icons.location_on,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildDensidadMetric(
                    'Venta Promedio',
                    'Bs. ${ventaPromedio.toStringAsFixed(2)}',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Puntos con mejor rendimiento
            const Text(
              'Puntos de Mayor Rendimiento',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...puntos.take(3).map((punto) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getMarkerColor(punto.totalVentas),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        punto.numeroVentas.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    punto.zona,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    '${punto.numeroVentas} ventas',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Text(
                    'Bs. ${punto.totalVentas.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildDensidadMetric(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecomendaciones() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.orange[600]),
                const SizedBox(width: 8),
                const Text(
                  'Recomendaciones',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRecomendacion(
              '📍 Expandir en Zona Centro',
              'Alta concentración de ventas. Considerar más puntos de distribución.',
              Colors.green,
            ),
            _buildRecomendacion(
              '🚀 Oportunidad en El Alto',
              'Zona con potencial de crecimiento. Evaluar estrategias de marketing.',
              Colors.blue,
            ),
            _buildRecomendacion(
              '⚡ Optimizar rutas',
              'Crear rutas eficientes entre los puntos de mayor rendimiento.',
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecomendacion(String titulo, String descripcion, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  descripcion,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== TAB 3: GESTIÓN DE ZONAS =====

  Widget _buildZonasTab() {
    final zonas = ref.watch(zonasGeograficasProvider);

    return zonas.when(
      data: (listaZonas) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Zonas Geográficas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _agregarNuevaZona,
                  icon: const Icon(Icons.add_location, size: 16),
                  label: const Text('Nueva Zona'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...listaZonas.map((zona) => _buildZonaCard(zona)),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Error al cargar zonas')),
    );
  }

  Widget _buildZonaCard(ZonaGeografica zona) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: zona.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    zona.nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _onZonaMenuSelected(value, zona),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'editar',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'ver_mapa',
                      child: Row(
                        children: [
                          Icon(Icons.map, size: 18),
                          SizedBox(width: 8),
                          Text('Ver en mapa'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'eliminar',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 18),
                          SizedBox(width: 8),
                          Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildZonaMetric(
                    'Ventas Totales',
                    'Bs. ${zona.totalVentas.toStringAsFixed(2)}',
                    Icons.attach_money,
                  ),
                ),
                Expanded(
                  child: _buildZonaMetric(
                    'Transacciones',
                    zona.numeroVentas.toString(),
                    Icons.receipt,
                  ),
                ),
                Expanded(
                  child: _buildZonaMetric(
                    'Radio',
                    '${(zona.radio / 1000).toStringAsFixed(1)} km',
                    Icons.radio_button_unchecked,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Centro: ${zona.centro.latitude.toStringAsFixed(4)}, ${zona.centro.longitude.toStringAsFixed(4)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZonaMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ===== MÉTODOS AUXILIARES =====

  void _centrarEnUbicacionActual() async {
    final ubicacion = await ref.read(ubicacionActualProvider.future);
    if (ubicacion != null) {
      _mapController.move(
        LatLng(ubicacion.latitude, ubicacion.longitude),
        15.0,
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo obtener la ubicación actual'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _onMenuSelected(String value) {
    setState(() {
      switch (value) {
        case 'zonas':
          _mostrarZonas = !_mostrarZonas;
          break;
        case 'puntos':
          _mostrarPuntosVenta = !_mostrarPuntosVenta;
          break;
        case 'calor':
          _mostrarCalor = !_mostrarCalor;
          break;
      }
    });
  }

  void _onMapTap(LatLng point) {
    // Mostrar información del punto tocado
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Información del Punto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Latitud: ${point.latitude.toStringAsFixed(6)}'),
            Text('Longitud: ${point.longitude.toStringAsFixed(6)}'),
            const SizedBox(height: 8),
            const Text('¿Deseas crear un punto de venta aquí?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _crearPuntoVenta(point);
            },
            child: const Text('Crear Punto'),
          ),
        ],
      ),
    );
  }

  void _mostrarInfoPunto(PuntoVenta punto) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Punto de Venta - ${punto.zona}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ventas totales: Bs. ${punto.totalVentas.toStringAsFixed(2)}'),
            Text('Número de transacciones: ${punto.numeroVentas}'),
            Text(
                'Promedio por venta: Bs. ${(punto.totalVentas / punto.numeroVentas).toStringAsFixed(2)}'),
            Text('Última venta: ${_formatearFecha(punto.fechaUltimaVenta)}'),
            const SizedBox(height: 8),
            Text(
                'Ubicación: ${punto.ubicacion.latitude.toStringAsFixed(4)}, ${punto.ubicacion.longitude.toStringAsFixed(4)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _mapController.move(punto.ubicacion, 16.0);
            },
            child: const Text('Ver en Mapa'),
          ),
        ],
      ),
    );
  }

  void _crearPuntoVenta(LatLng punto) {
    // Implementar creación de punto de venta
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Punto de venta creado en: ${punto.latitude.toStringAsFixed(4)}, ${punto.longitude.toStringAsFixed(4)}',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _agregarNuevaZona() {
    // Implementar creación de nueva zona
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Zona'),
        content:
            const Text('Funcionalidad para crear una nueva zona geográfica'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _onZonaMenuSelected(String value, ZonaGeografica zona) {
    switch (value) {
      case 'editar':
        // Implementar edición de zona
        break;
      case 'ver_mapa':
        _tabController.animateTo(0);
        _mapController.move(zona.centro, 14.0);
        break;
      case 'eliminar':
        // Implementar eliminación de zona
        break;
    }
  }

  double _getMarkerSize(double totalVentas) {
    if (totalVentas < 1000) return 30;
    if (totalVentas < 5000) return 40;
    if (totalVentas < 10000) return 50;
    return 60;
  }

  Color _getMarkerColor(double totalVentas) {
    if (totalVentas < 1000) return Colors.yellow[700]!;
    if (totalVentas < 5000) return Colors.orange[700]!;
    if (totalVentas < 10000) return Colors.red[700]!;
    return Colors.purple[700]!;
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }
}

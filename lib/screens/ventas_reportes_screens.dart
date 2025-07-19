import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../models/database_models.dart';
import '../repositories/database_repositories.dart';

// ===== MODELOS PARA REPORTES =====

class DatosReporte {
  final double ventasHoy;
  final double ventasAyer;
  final double ventasSemana;
  final double ventasMes;
  final int numeroVentasHoy;
  final int numeroVentasSemana;
  final int numeroVentasMes;
  final double promedioVentaDiaria;
  final List<VentaPorDia> ventasPorDia;
  final List<VentaPorMetodo> ventasPorMetodo;
  final List<ProductoMasVendido> topProductos;
  final List<VentaPorHora> ventasPorHora;

  DatosReporte({
    required this.ventasHoy,
    required this.ventasAyer,
    required this.ventasSemana,
    required this.ventasMes,
    required this.numeroVentasHoy,
    required this.numeroVentasSemana,
    required this.numeroVentasMes,
    required this.promedioVentaDiaria,
    required this.ventasPorDia,
    required this.ventasPorMetodo,
    required this.topProductos,
    required this.ventasPorHora,
  });
}

class VentaPorDia {
  final DateTime fecha;
  final double total;
  final int numeroVentas;

  VentaPorDia(
      {required this.fecha, required this.total, required this.numeroVentas});
}

class VentaPorMetodo {
  final String metodo;
  final double total;
  final int cantidad;
  final double porcentaje;

  VentaPorMetodo({
    required this.metodo,
    required this.total,
    required this.cantidad,
    required this.porcentaje,
  });
}

class VentaPorHora {
  final int hora;
  final double total;
  final int cantidad;

  VentaPorHora(
      {required this.hora, required this.total, required this.cantidad});
}

// ===== PROVIDERS PARA REPORTES =====

final filtroVentasProvider =
    StateProvider<FiltroVentas>((ref) => FiltroVentas());

final fechaInicioReporteProvider = StateProvider<DateTime>((ref) {
  return DateTime.now().subtract(const Duration(days: 30));
});

final fechaFinReporteProvider =
    StateProvider<DateTime>((ref) => DateTime.now());

final ventasFiltadasProvider = FutureProvider<List<VentaCompleta>>((ref) async {
  final repository = ref.watch(ventasRepositoryProvider);
  final filtro = ref.watch(filtroVentasProvider);
  return await repository.obtenerVentas(filtro: filtro);
});

final datosReporteProvider = FutureProvider<DatosReporte>((ref) async {
  final repository = ref.watch(ventasRepositoryProvider);
  final fechaInicio = ref.watch(fechaInicioReporteProvider);
  final fechaFin = ref.watch(fechaFinReporteProvider);

  return await _calcularDatosReporte(repository, fechaInicio, fechaFin);
});

// ===== FUNCIÓN PARA CALCULAR REPORTES =====

Future<DatosReporte> _calcularDatosReporte(VentasRepository repository,
    DateTime fechaInicio, DateTime fechaFin) async {
  final hoy = DateTime.now();
  final inicioHoy = DateTime(hoy.year, hoy.month, hoy.day);
  final inicioAyer = inicioHoy.subtract(const Duration(days: 1));
  final inicioSemana = inicioHoy.subtract(Duration(days: hoy.weekday - 1));
  final inicioMes = DateTime(hoy.year, hoy.month, 1);

  // Obtener ventas por períodos
  final ventasHoy = await repository.obtenerVentas(
      filtro: FiltroVentas(
    fechaInicio: inicioHoy,
    fechaFin: hoy,
  ));

  final ventasAyer = await repository.obtenerVentas(
      filtro: FiltroVentas(
    fechaInicio: inicioAyer,
    fechaFin: inicioHoy,
  ));

  final ventasSemana = await repository.obtenerVentas(
      filtro: FiltroVentas(
    fechaInicio: inicioSemana,
    fechaFin: hoy,
  ));

  final ventasMes = await repository.obtenerVentas(
      filtro: FiltroVentas(
    fechaInicio: inicioMes,
    fechaFin: hoy,
  ));

  final todasLasVentas = await repository.obtenerVentas(
      filtro: FiltroVentas(
    fechaInicio: fechaInicio,
    fechaFin: fechaFin,
  ));

  // Calcular totales
  final totalHoy = ventasHoy.fold(0.0, (sum, v) => sum + v.totalVenta);
  final totalAyer = ventasAyer.fold(0.0, (sum, v) => sum + v.totalVenta);
  final totalSemana = ventasSemana.fold(0.0, (sum, v) => sum + v.totalVenta);
  final totalMes = ventasMes.fold(0.0, (sum, v) => sum + v.totalVenta);

  // Ventas por día (últimos 30 días)
  final ventasPorDia = <VentaPorDia>[];
  for (int i = 29; i >= 0; i--) {
    final fecha = inicioHoy.subtract(Duration(days: i));
    final ventasDelDia = todasLasVentas
        .where((v) =>
            v.fechaVenta.year == fecha.year &&
            v.fechaVenta.month == fecha.month &&
            v.fechaVenta.day == fecha.day)
        .toList();

    final totalDia = ventasDelDia.fold(0.0, (sum, v) => sum + v.totalVenta);
    ventasPorDia.add(VentaPorDia(
      fecha: fecha,
      total: totalDia,
      numeroVentas: ventasDelDia.length,
    ));
  }

  // Ventas por método de pago
  final ventasPorMetodoMap = <String, List<VentaCompleta>>{};
  for (final venta in todasLasVentas) {
    ventasPorMetodoMap.putIfAbsent(venta.metodoPago, () => []).add(venta);
  }

  final totalGeneral = todasLasVentas.fold(0.0, (sum, v) => sum + v.totalVenta);
  final ventasPorMetodo = ventasPorMetodoMap.entries.map((entry) {
    final total = entry.value.fold(0.0, (sum, v) => sum + v.totalVenta);
    return VentaPorMetodo(
      metodo: entry.key,
      total: total,
      cantidad: entry.value.length,
      porcentaje: totalGeneral > 0 ? (total / totalGeneral) * 100 : 0,
    );
  }).toList()
    ..sort((a, b) => b.total.compareTo(a.total));

  // Top productos más vendidos
  final productosVendidos = <int, List<DetalleVentaCompleto>>{};
  for (final venta in todasLasVentas) {
    for (final detalle in venta.detalles) {
      productosVendidos.putIfAbsent(detalle.productoId, () => []).add(detalle);
    }
  }

  final topProductos = productosVendidos.entries.map((entry) {
    final detalles = entry.value;
    final cantidadTotal = detalles.fold(0, (sum, d) => sum + d.cantidad);
    final ingresoTotal = detalles.fold(0.0, (sum, d) => sum + d.subtotal);

    return ProductoMasVendido(
      productoId: entry.key,
      nombreProducto: detalles.first.nombreProducto,
      categoria: detalles.first.categoria,
      cantidadVendida: cantidadTotal,
      ingresoTotal: ingresoTotal,
      participacionPorcentaje:
          totalGeneral > 0 ? (ingresoTotal / totalGeneral) * 100 : 0,
    );
  }).toList()
    ..sort((a, b) => b.ingresoTotal.compareTo(a.ingresoTotal));

  // Ventas por hora del día
  final ventasPorHoraMap = <int, List<VentaCompleta>>{};
  for (final venta in todasLasVentas) {
    final hora = venta.fechaVenta.hour;
    ventasPorHoraMap.putIfAbsent(hora, () => []).add(venta);
  }

  final ventasPorHora = List.generate(24, (hora) {
    final ventasHora = ventasPorHoraMap[hora] ?? [];
    return VentaPorHora(
      hora: hora,
      total: ventasHora.fold(0.0, (sum, v) => sum + v.totalVenta),
      cantidad: ventasHora.length,
    );
  });

  return DatosReporte(
    ventasHoy: totalHoy,
    ventasAyer: totalAyer,
    ventasSemana: totalSemana,
    ventasMes: totalMes,
    numeroVentasHoy: ventasHoy.length,
    numeroVentasSemana: ventasSemana.length,
    numeroVentasMes: ventasMes.length,
    promedioVentaDiaria: ventasPorDia.isNotEmpty
        ? ventasPorDia.fold(0.0, (sum, v) => sum + v.total) /
            ventasPorDia.length
        : 0,
    ventasPorDia: ventasPorDia,
    ventasPorMetodo: ventasPorMetodo,
    topProductos: topProductos.take(10).toList(),
    ventasPorHora: ventasPorHora,
  );
}

// ===== 1. PANTALLA PRINCIPAL DE VENTAS =====

class VentasScreen extends ConsumerWidget {
  const VentasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ventas = ref.watch(ventasFiltadasProvider);
    final filtro = ref.watch(filtroVentasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Ventas'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ReportesScreen()),
              );
            },
            tooltip: 'Ver reportes',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _mostrarFiltros(context, ref),
            tooltip: 'Filtros',
          ),
        ],
      ),
      body: Column(
        children: [
          // Resumen rápido
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: ventas.when(
              data: (listaVentas) => _buildResumenRapido(listaVentas),
              loading: () => const SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const SizedBox(height: 80),
            ),
          ),

          // Lista de ventas
          Expanded(
            child: ventas.when(
              data: (listaVentas) {
                if (listaVentas.isEmpty) {
                  return _buildEstadoVacio(filtro);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.refresh(ventasFiltadasProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: listaVentas.length,
                    itemBuilder: (context, index) {
                      final venta = listaVentas[index];
                      return _buildVentaCard(context, ref, venta);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _buildEstadoError(error, ref),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ReportesScreen()),
          );
        },
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.analytics),
        label: const Text('Reportes'),
      ),
    );
  }

  Widget _buildResumenRapido(List<VentaCompleta> ventas) {
    final total = ventas.fold(0.0, (sum, v) => sum + v.totalVenta);
    final hoy = DateTime.now();
    final ventasHoy = ventas
        .where((v) =>
            v.fechaVenta.year == hoy.year &&
            v.fechaVenta.month == hoy.month &&
            v.fechaVenta.day == hoy.day)
        .length;

    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: _buildResumenItem(
              'Total Ventas',
              'Bs. ${total.toStringAsFixed(2)}',
              Icons.attach_money,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildResumenItem(
              'Número Ventas',
              ventas.length.toString(),
              Icons.receipt,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildResumenItem(
              'Ventas Hoy',
              ventasHoy.toString(),
              Icons.today,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenItem(
      String label, String valor, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            valor,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoVacio(FiltroVentas filtro) {
    final hayFiltros = filtro.fechaInicio != null ||
        filtro.fechaFin != null ||
        filtro.usuarioId != null ||
        filtro.metodoPago != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              hayFiltros
                  ? 'No se encontraron ventas'
                  : 'No hay ventas registradas',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hayFiltros
                  ? 'Intenta ajustar los filtros de búsqueda'
                  : 'Las ventas aparecerán aquí cuando uses el POS',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (hayFiltros) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Limpiar filtros - implementar según necesidad
                },
                child: const Text('Limpiar Filtros'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVentaCard(
      BuildContext context, WidgetRef ref, VentaCompleta venta) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DetalleVentaScreen(venta: venta),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header de la venta
              Row(
                children: [
                  // Chip de ID de venta
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Venta #${venta.id.toString().padLeft(6, '0')}',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Total de la venta
                  Text(
                    'Bs. ${venta.totalVenta.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Información básica
              Row(
                children: [
                  // Fecha y hora
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _formatearFechaHora(venta.fechaVenta),
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Método de pago
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.payment, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _getMetodoPagoDisplay(venta.metodoPago),
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Información adicional
              Row(
                children: [
                  // Número de productos
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shopping_cart,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${venta.totalItems} ${venta.totalItems == 1 ? 'producto' : 'productos'}',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Descuento (si existe)
                  if (venta.descuentoAplicado > 0) ...[
                    const SizedBox(width: 16),
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_offer,
                              size: 16, color: Colors.red[600]),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Desc: Bs. ${venta.descuentoAplicado.toStringAsFixed(2)}',
                              style: TextStyle(
                                  color: Colors.red[600], fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const Spacer(),

                  // Estado de sincronización
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: venta.sincronizadoNube
                          ? Colors.green[100]
                          : Colors.orange[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          venta.sincronizadoNube
                              ? Icons.cloud_done
                              : Icons.cloud_off,
                          size: 12,
                          color: venta.sincronizadoNube
                              ? Colors.green[700]
                              : Colors.orange[700],
                        ),
                        const SizedBox(width: 2),
                        Text(
                          venta.sincronizadoNube ? 'Sync' : 'Local',
                          style: TextStyle(
                            color: venta.sincronizadoNube
                                ? Colors.green[700]
                                : Colors.orange[700],
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatearFechaHora(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  String _getMetodoPagoDisplay(String metodoPago) {
    switch (metodoPago) {
      case 'efectivo':
        return 'Efectivo';
      case 'tarjeta':
        return 'Tarjeta';
      case 'transferencia':
        return 'Transferencia';
      case 'qr':
        return 'QR';
      case 'mixto':
        return 'Mixto';
      default:
        return metodoPago;
    }
  }

  void _mostrarFiltros(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FiltrosVentasBottomSheet(),
    );
  }

  Widget _buildEstadoError(Object error, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar ventas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.refresh(ventasFiltadasProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== 2. PANTALLA DE REPORTES =====

class ReportesScreen extends ConsumerWidget {
  const ReportesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datosReporte = ref.watch(datosReporteProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes y Analytics'),
        backgroundColor: Colors.purple.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _mostrarSelectorFechas(context, ref),
            tooltip: 'Cambiar período',
          ),
        ],
      ),
      body: datosReporte.when(
        data: (datos) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Métricas principales
              _buildSeccionMetricas(context, datos),
              const SizedBox(height: 24),

              // Gráfico de ventas por día
              _buildSeccionVentasPorDia(context, datos),
              const SizedBox(height: 24),

              // Métodos de pago
              _buildSeccionMetodosPago(context, datos),
              const SizedBox(height: 24),

              // Top productos
              _buildSeccionTopProductos(context, datos),
              const SizedBox(height: 24),

              // Ventas por hora
              _buildSeccionVentasPorHora(context, datos),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildEstadoError(error, ref),
      ),
    );
  }

  Widget _buildSeccionMetricas(BuildContext context, DatosReporte datos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Métricas Principales',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        // Grid para métricas
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildMetricaCard(
                  'Ventas Hoy',
                  'Bs. ${datos.ventasHoy.toStringAsFixed(2)}',
                  '${datos.numeroVentasHoy} ventas',
                  Icons.today,
                  Colors.green,
                  datos.ventasHoy > datos.ventasAyer
                      ? Icons.trending_up
                      : Icons.trending_down,
                  datos.ventasHoy > datos.ventasAyer
                      ? Colors.green
                      : Colors.red,
                ),
                _buildMetricaCard(
                  'Esta Semana',
                  'Bs. ${datos.ventasSemana.toStringAsFixed(2)}',
                  '${datos.numeroVentasSemana} ventas',
                  Icons.date_range,
                  Colors.blue,
                  null,
                  null,
                ),
                _buildMetricaCard(
                  'Este Mes',
                  'Bs. ${datos.ventasMes.toStringAsFixed(2)}',
                  '${datos.numeroVentasMes} ventas',
                  Icons.calendar_month,
                  Colors.purple,
                  null,
                  null,
                ),
                _buildMetricaCard(
                  'Promedio Diario',
                  'Bs. ${datos.promedioVentaDiaria.toStringAsFixed(2)}',
                  'Últimos 30 días',
                  Icons.analytics,
                  Colors.orange,
                  null,
                  null,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildMetricaCard(
    String titulo,
    String valor,
    String descripcion,
    IconData icono,
    Color color,
    IconData? tendenciaIcono,
    Color? tendenciaColor,
  ) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icono, color: color, size: 24),
                if (tendenciaIcono != null)
                  Icon(tendenciaIcono, color: tendenciaColor, size: 16),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              titulo,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              valor,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              descripcion,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionVentasPorDia(BuildContext context, DatosReporte datos) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ventas por Día (Últimos 30 días)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 200,
              child: _buildGraficoBarras(datos.ventasPorDia),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraficoBarras(List<VentaPorDia> datos) {
    if (datos.isEmpty) {
      return const Center(child: Text('Sin datos disponibles'));
    }

    final maxTotal = datos.map((d) => d.total).reduce(math.max);
    if (maxTotal == 0) {
      return const Center(child: Text('Sin ventas en el período'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: math.max(constraints.maxWidth, datos.length * 18.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: datos.map((venta) {
                final altura =
                    maxTotal > 0 ? (venta.total / maxTotal) * 160 : 0.0;
                final esHoy = venta.fecha.day == DateTime.now().day &&
                    venta.fecha.month == DateTime.now().month;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (venta.total > 0)
                          Container(
                            constraints: const BoxConstraints(minHeight: 20),
                            child: Text(
                              venta.total.toStringAsFixed(0),
                              style: const TextStyle(fontSize: 8),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Container(
                          height: altura,
                          decoration: BoxDecoration(
                            color: esHoy
                                ? Colors.green
                                : Colors.blue.withOpacity(0.7),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(2),
                              topRight: Radius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${venta.fecha.day}',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight:
                                esHoy ? FontWeight.bold : FontWeight.normal,
                            color: esHoy ? Colors.green : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSeccionMetodosPago(BuildContext context, DatosReporte datos) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Métodos de Pago',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (datos.ventasPorMetodo.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Sin datos de métodos de pago'),
                ),
              )
            else
              ...datos.ventasPorMetodo.map((metodo) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(_getIconoMetodoPago(metodo.metodo)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _getMetodoPagoDisplay(metodo.metodo),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              'Bs. ${metodo.total.toStringAsFixed(2)}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${metodo.porcentaje.toStringAsFixed(1)}%)',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: metodo.porcentaje / 100,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation(
                              _getColorMetodoPago(metodo.metodo)),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionTopProductos(BuildContext context, DatosReporte datos) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Productos Más Vendidos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (datos.topProductos.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Sin datos de productos'),
                ),
              )
            else
              ...datos.topProductos.take(5).map((producto) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: Text(
                        producto.cantidadVendida.toString(),
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    title: Text(
                      producto.nombreProducto,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      producto.categoria,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Bs. ${producto.ingresoTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${producto.participacionPorcentaje.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionVentasPorHora(BuildContext context, DatosReporte datos) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ventas por Hora del Día',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: _buildGraficoVentasPorHora(datos.ventasPorHora),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraficoVentasPorHora(List<VentaPorHora> datos) {
    final maxTotal = datos.map((d) => d.total).reduce(math.max);
    if (maxTotal == 0) {
      return const Center(child: Text('Sin ventas registradas por hora'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: math.max(400, datos.length * 14.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: datos.map((ventaHora) {
            final altura =
                maxTotal > 0 ? (ventaHora.total / maxTotal) * 110 : 0.0;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (ventaHora.total > 0)
                      Text(
                        ventaHora.total.toStringAsFixed(0),
                        style: const TextStyle(fontSize: 8),
                      ),
                    const SizedBox(height: 4),
                    Container(
                      height: altura,
                      decoration: BoxDecoration(
                        color: Colors.purple.withAlpha((0.7 * 255).toInt()),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(2),
                          topRight: Radius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${ventaHora.hora}h',
                      style: const TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  IconData _getIconoMetodoPago(String metodo) {
    switch (metodo) {
      case 'efectivo':
        return Icons.money;
      case 'tarjeta':
        return Icons.credit_card;
      case 'transferencia':
        return Icons.account_balance;
      case 'qr':
        return Icons.qr_code;
      case 'mixto':
        return Icons.payments;
      default:
        return Icons.payment;
    }
  }

  Color _getColorMetodoPago(String metodo) {
    switch (metodo) {
      case 'efectivo':
        return Colors.green;
      case 'tarjeta':
        return Colors.blue;
      case 'transferencia':
        return Colors.purple;
      case 'qr':
        return Colors.orange;
      case 'mixto':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getMetodoPagoDisplay(String metodoPago) {
    switch (metodoPago) {
      case 'efectivo':
        return 'Efectivo';
      case 'tarjeta':
        return 'Tarjeta';
      case 'transferencia':
        return 'Transferencia';
      case 'qr':
        return 'QR';
      case 'mixto':
        return 'Mixto';
      default:
        return metodoPago;
    }
  }

  void _mostrarSelectorFechas(BuildContext context, WidgetRef ref) {
    showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: ref.read(fechaInicioReporteProvider),
        end: ref.read(fechaFinReporteProvider),
      ),
    ).then((range) {
      if (range != null) {
        ref.read(fechaInicioReporteProvider.notifier).state = range.start;
        ref.read(fechaFinReporteProvider.notifier).state = range.end;
      }
    });
  }

  Widget _buildEstadoError(Object error, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar reportes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.refresh(datosReporteProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== 3. PANTALLA DETALLE DE VENTA =====

class DetalleVentaScreen extends ConsumerWidget {
  final VentaCompleta venta;

  const DetalleVentaScreen({super.key, required this.venta});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Venta #${venta.id.toString().padLeft(6, '0')}'),
        backgroundColor: Colors.indigo.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información general
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información General',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('ID de Venta:', venta.id.toString()),
                    _buildInfoRow(
                        'Fecha y Hora:', _formatearFechaHora(venta.fechaVenta)),
                    _buildInfoRow('Método de Pago:',
                        _getMetodoPagoDisplay(venta.metodoPago)),
                    _buildInfoRow('Usuario:', 'Usuario #${venta.usuarioId}'),
                    _buildInfoRow('Estado Sync:',
                        venta.sincronizadoNube ? 'Sincronizado' : 'Pendiente'),
                    if (venta.latitud != null && venta.longitud != null)
                      _buildInfoRow('Ubicación:',
                          '${venta.latitud!.toStringAsFixed(4)}, ${venta.longitud!.toStringAsFixed(4)}'),
                    if (venta.direccionAproximada != null)
                      _buildInfoRow('Dirección:', venta.direccionAproximada!),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Productos vendidos
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Productos Vendidos',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ...venta.detalles.map((detalle) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.inventory_2,
                                  color: Colors.grey[500],
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      detalle.nombreProducto,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      detalle.categoria,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    if (detalle.codigoBarras != null)
                                      Text(
                                        'Código: ${detalle.codigoBarras}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
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
                                    '${detalle.cantidad} x Bs. ${detalle.precioUnitario.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    'Bs. ${detalle.subtotal.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (detalle.descuentoItem > 0)
                                    Text(
                                      'Desc: -Bs. ${detalle.descuentoItem.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Colors.red[600],
                                        fontSize: 12,
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
            ),

            const SizedBox(height: 16),

            // Resumen de totales
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen de Totales',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildTotalRow('Subtotal:',
                        'Bs. ${venta.subtotal.toStringAsFixed(2)}'),
                    if (venta.totalDescuento > 0)
                      _buildTotalRow(
                        'Descuentos:',
                        '-Bs. ${venta.totalDescuento.toStringAsFixed(2)}',
                        color: Colors.red[600],
                      ),
                    const Divider(),
                    _buildTotalRow(
                      'TOTAL PAGADO:',
                      'Bs. ${venta.totalVenta.toStringAsFixed(2)}',
                      isTotal: true,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.receipt, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          '${venta.totalItems} productos • ${_getMetodoPagoDisplay(venta.metodoPago)}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String valor,
      {Color? color, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isTotal ? 16 : 14,
              color: color,
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isTotal ? 18 : 14,
              color: color ?? (isTotal ? Colors.green[700] : null),
            ),
          ),
        ],
      ),
    );
  }

  String _formatearFechaHora(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  String _getMetodoPagoDisplay(String metodoPago) {
    switch (metodoPago) {
      case 'efectivo':
        return 'Efectivo';
      case 'tarjeta':
        return 'Tarjeta';
      case 'transferencia':
        return 'Transferencia';
      case 'qr':
        return 'QR';
      case 'mixto':
        return 'Mixto';
      default:
        return metodoPago;
    }
  }
}

// ===== 4. BOTTOM SHEET DE FILTROS =====

class FiltrosVentasBottomSheet extends ConsumerStatefulWidget {
  const FiltrosVentasBottomSheet({super.key});

  @override
  ConsumerState<FiltrosVentasBottomSheet> createState() =>
      _FiltrosVentasBottomSheetState();
}

class _FiltrosVentasBottomSheetState
    extends ConsumerState<FiltrosVentasBottomSheet> {
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  String? _metodoPago;
  bool? _soloSincronizadas;

  @override
  void initState() {
    super.initState();
    final filtroActual = ref.read(filtroVentasProvider);
    _fechaInicio = filtroActual.fechaInicio;
    _fechaFin = filtroActual.fechaFin;
    _metodoPago = filtroActual.metodoPago;
    _soloSincronizadas = filtroActual.soloSincronizadas;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Handle del modal
        Container(
          margin: const EdgeInsets.only(top: 8),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.filter_list),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Filtros de Ventas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Filtros
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rango de fechas
                Text(
                  'Período',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _seleccionarFecha(context, true),
                        icon: const Icon(Icons.date_range, size: 16),
                        label: Text(
                          _fechaInicio != null
                              ? '${_fechaInicio!.day}/${_fechaInicio!.month}/${_fechaInicio!.year}'
                              : 'Fecha inicio',
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _seleccionarFecha(context, false),
                        icon: const Icon(Icons.date_range, size: 16),
                        label: Text(
                          _fechaFin != null
                              ? '${_fechaFin!.day}/${_fechaFin!.month}/${_fechaFin!.year}'
                              : 'Fecha fin',
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Método de pago
                Text(
                  'Método de Pago',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _metodoPago,
                  decoration: const InputDecoration(
                    labelText: 'Seleccionar método',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Todos los métodos'),
                    ),
                    ...MetodoPago.values.map((metodo) => DropdownMenuItem(
                          value: metodo.name,
                          child: Text(metodo.displayName),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _metodoPago = value;
                    });
                  },
                ),

                const SizedBox(height: 24),

                // Estado de sincronización
                Text(
                  'Estado de Sincronización',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),

                Column(
                  children: [
                    RadioListTile<bool?>(
                      title: const Text('Todas las ventas'),
                      value: null,
                      groupValue: _soloSincronizadas,
                      onChanged: (value) {
                        setState(() {
                          _soloSincronizadas = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                    RadioListTile<bool?>(
                      title: const Text('Solo sincronizadas'),
                      value: true,
                      groupValue: _soloSincronizadas,
                      onChanged: (value) {
                        setState(() {
                          _soloSincronizadas = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                    RadioListTile<bool?>(
                      title: const Text('Solo pendientes'),
                      value: false,
                      groupValue: _soloSincronizadas,
                      onChanged: (value) {
                        setState(() {
                          _soloSincronizadas = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Botones
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(top: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _limpiarFiltros,
                  child: const Text('Limpiar'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _aplicarFiltros,
                  child: const Text('Aplicar'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _seleccionarFecha(
      BuildContext context, bool esFechaInicio) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: esFechaInicio
          ? (_fechaInicio ?? DateTime.now())
          : (_fechaFin ?? DateTime.now()),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (fecha != null) {
      setState(() {
        if (esFechaInicio) {
          _fechaInicio = fecha;
        } else {
          _fechaFin = fecha;
        }
      });
    }
  }

  void _limpiarFiltros() {
    setState(() {
      _fechaInicio = null;
      _fechaFin = null;
      _metodoPago = null;
      _soloSincronizadas = null;
    });
  }

  void _aplicarFiltros() {
    final filtro = FiltroVentas(
      fechaInicio: _fechaInicio,
      fechaFin: _fechaFin,
      metodoPago: _metodoPago,
      soloSincronizadas: _soloSincronizadas,
    );

    ref.read(filtroVentasProvider.notifier).state = filtro;
    Navigator.of(context).pop();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:inventario_multitienda/screens/ventas_reportes_screens.dart';
import 'dart:math' as math;
import '../database/database.dart';
import '../models/database_models.dart';
import '../repositories/database_repositories.dart';

// ===== PANTALLA PRINCIPAL DE GRÁFICOS =====

class GraficosAvanzadosScreen extends ConsumerStatefulWidget {
  const GraficosAvanzadosScreen({super.key});

  @override
  ConsumerState<GraficosAvanzadosScreen> createState() =>
      _GraficosAvanzadosScreenState();
}

class _GraficosAvanzadosScreenState
    extends ConsumerState<GraficosAvanzadosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text('Gráficos y Analytics'),
        backgroundColor: Colors.indigo.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.trending_up), text: 'Ventas'),
            Tab(icon: Icon(Icons.pie_chart), text: 'Productos'),
            Tab(icon: Icon(Icons.schedule), text: 'Tiempo'),
            Tab(icon: Icon(Icons.compare_arrows), text: 'Comparativa'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(datosReporteProvider);
              ref.refresh(estadisticasProvider);
            },
            tooltip: 'Actualizar datos',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          VentasChartsTab(),
          ProductosChartsTab(),
          TiempoChartsTab(),
          ComparativaChartsTab(),
        ],
      ),
    );
  }
}

// ===== TAB 1: GRÁFICOS DE VENTAS =====

class VentasChartsTab extends ConsumerWidget {
  const VentasChartsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datosReporte = ref.watch(datosReporteProvider);

    return datosReporte.when(
      data: (datos) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Gráfico de línea - Ventas por día
            _buildChartCard(
              title: 'Tendencia de Ventas (30 días)',
              subtitle: 'Ventas diarias en Bolivianos',
              chart: VentasPorDiaLineChart(datos: datos.ventasPorDia),
              height: 300,
            ),

            const SizedBox(height: 20),

            // Gráfico de barras - Ventas por método de pago
            _buildChartCard(
              title: 'Ventas por Método de Pago',
              subtitle: 'Distribución de métodos de pago',
              chart: MetodosPagoBarChart(datos: datos.ventasPorMetodo),
              height: 250,
            ),

            const SizedBox(height: 20),

            // Métricas rápidas
            _buildMetricasRapidas(datos),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _buildErrorWidget(error),
    );
  }

  Widget _buildChartCard({
    required String title,
    required String subtitle,
    required Widget chart,
    required double height,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: height,
              child: chart,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricasRapidas(DatosReporte datos) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Métricas Clave',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricaItem(
                    'Crecimiento vs Ayer',
                    _calcularCrecimiento(datos.ventasHoy, datos.ventasAyer),
                    datos.ventasHoy > datos.ventasAyer
                        ? Colors.green
                        : Colors.red,
                    datos.ventasHoy > datos.ventasAyer
                        ? Icons.trending_up
                        : Icons.trending_down,
                  ),
                ),
                Expanded(
                  child: _buildMetricaItem(
                    'Promedio Diario',
                    'Bs. ${datos.promedioVentaDiaria.toStringAsFixed(2)}',
                    Colors.blue,
                    Icons.analytics,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricaItem(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _calcularCrecimiento(double ventasHoy, double ventasAyer) {
    if (ventasAyer == 0) return ventasHoy > 0 ? '+100%' : '0%';
    final crecimiento = ((ventasHoy - ventasAyer) / ventasAyer) * 100;
    return '${crecimiento >= 0 ? '+' : ''}${crecimiento.toStringAsFixed(1)}%';
  }

  Widget _buildErrorWidget(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text('Error al cargar gráficos: $error'),
        ],
      ),
    );
  }
}

// ===== TAB 2: GRÁFICOS DE PRODUCTOS =====

class ProductosChartsTab extends ConsumerWidget {
  const ProductosChartsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datosReporte = ref.watch(datosReporteProvider);
    final estadisticas = ref.watch(estadisticasProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Gráfico de dona - Stock por categoría
          estadisticas.when(
            data: (stats) => _buildChartCard(
              title: 'Distribución de Inventario',
              subtitle: 'Valor por categoría',
              chart: InventarioPorCategoriaChart(),
              height: 300,
            ),
            loading: () => const SizedBox(
                height: 300, child: Center(child: CircularProgressIndicator())),
            error: (_, __) => const SizedBox(),
          ),

          const SizedBox(height: 20),

          // Top productos más vendidos
          datosReporte.when(
            data: (datos) => _buildChartCard(
              title: 'Productos Más Vendidos',
              subtitle: 'Top 10 productos por ingresos',
              chart: TopProductosChart(
                  productos: datos.topProductos.take(10).toList()),
              height: 400,
            ),
            loading: () => const SizedBox(
                height: 400, child: Center(child: CircularProgressIndicator())),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required String subtitle,
    required Widget chart,
    required double height,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 20),
            SizedBox(height: height, child: chart),
          ],
        ),
      ),
    );
  }
}

// ===== TAB 3: GRÁFICOS DE TIEMPO =====

class TiempoChartsTab extends ConsumerWidget {
  const TiempoChartsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datosReporte = ref.watch(datosReporteProvider);

    return datosReporte.when(
      data: (datos) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Gráfico de ventas por hora
            _buildChartCard(
              title: 'Ventas por Hora del Día',
              subtitle: 'Patrón de ventas durante el día',
              chart: VentasPorHoraChart(datos: datos.ventasPorHora),
              height: 300,
            ),

            const SizedBox(height: 20),

            // Gráfico de radar - Días de la semana
            _buildChartCard(
              title: 'Actividad Semanal',
              subtitle: 'Distribución de ventas por día',
              chart: ActividadSemanalChart(datos: datos.ventasPorDia),
              height: 300,
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildChartCard({
    required String title,
    required String subtitle,
    required Widget chart,
    required double height,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 20),
            SizedBox(height: height, child: chart),
          ],
        ),
      ),
    );
  }
}

// ===== TAB 4: GRÁFICOS COMPARATIVOS =====

class ComparativaChartsTab extends ConsumerWidget {
  const ComparativaChartsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datosReporte = ref.watch(datosReporteProvider);

    return datosReporte.when(
      data: (datos) {
        // Verifica si todos los totales de ventas son cero
        final allSalesAreZero = datos.ventasPorDia.every((v) => v.total == 0.0);
        // Verifica si todos los números de ventas son cero
        final allTransactionCountsAreZero =
            datos.ventasPorDia.every((v) => v.numeroVentas == 0);

        // Si todas las ventas y transacciones son cero, o si la lista está vacía (aunque tu loop la llena con 30 días)
        // muestra un mensaje o un widget alternativo en lugar del gráfico.
        final bool shouldShowChart =
            !(allSalesAreZero && allTransactionCountsAreZero);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Comparativa de métricas clave
              _buildComparativaMetricas(datos),

              const SizedBox(height: 20),

              // Gráfico combinado
              _buildChartCard(
                title: 'Análisis Combinado',
                subtitle: 'Ventas y número de transacciones',
                // Condición para mostrar el gráfico o un mensaje
                chart: shouldShowChart
                    ? AnalisisCombinadoChart(datos: datos.ventasPorDia)
                    : const SizedBox(
                        // Puedes ajustar el tamaño o el tipo de widget aquí
                        height: 200, // Altura similar a la del gráfico
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.bar_chart_outlined,
                                  size: 50, color: Colors.grey),
                              SizedBox(height: 10),
                              Text(
                                'No hay datos de ventas para mostrar.',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                height: 350,
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildComparativaMetricas(DatosReporte datos) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comparativa de Períodos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildComparativaItem(
                    'Hoy vs Ayer',
                    'Bs. ${datos.ventasHoy.toStringAsFixed(2)}',
                    'Bs. ${datos.ventasAyer.toStringAsFixed(2)}',
                    datos.ventasHoy > datos.ventasAyer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildComparativaItem(
                    'Esta Semana',
                    'Bs. ${datos.ventasSemana.toStringAsFixed(2)}',
                    '${datos.numeroVentasSemana} ventas',
                    true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparativaItem(
      String title, String value1, String value2, bool isPositive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isPositive ? Colors.green : Colors.red).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isPositive ? Colors.green : Colors.red).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            value1,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isPositive ? Colors.green[700] : Colors.red[700],
            ),
          ),
          Text(
            value2,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required String subtitle,
    required Widget chart,
    required double height,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 20),
            SizedBox(height: height, child: chart),
          ],
        ),
      ),
    );
  }
}

// ===== GRÁFICO: VENTAS POR DÍA (LÍNEA) =====

class VentasPorDiaLineChart extends StatelessWidget {
  final List<VentaPorDia> datos;

  const VentasPorDiaLineChart({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    if (datos.isEmpty) {
      return const Center(child: Text('Sin datos disponibles'));
    }

    final maxY = datos.map((d) => d.total).reduce(math.max);
    if (maxY == 0) {
      return const Center(child: Text('Sin ventas en el período'));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 5,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.3),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 5,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < datos.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      '${datos[index].fecha.day}',
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    'Bs.${(value / 1000).toStringAsFixed(0)}K',
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (datos.length - 1).toDouble(),
        minY: 0,
        maxY: maxY * 1.1,
        lineBarsData: [
          LineChartBarData(
            spots: datos.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.total);
            }).toList(),
            isCurved: true,
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.blue.shade600],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                radius: 4,
                color: Colors.blue.shade600,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade200.withOpacity(0.3),
                  Colors.blue.shade100.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===== GRÁFICO: MÉTODOS DE PAGO (BARRAS) =====

class MetodosPagoBarChart extends StatelessWidget {
  final List<VentaPorMetodo> datos;

  const MetodosPagoBarChart({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    if (datos.isEmpty) {
      return const Center(child: Text('Sin datos disponibles'));
    }

    final maxY = datos.map((d) => d.total).reduce(math.max);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.1,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final metodo = datos[group.x];
              return BarTooltipItem(
                '${_getMetodoPagoDisplay(metodo.metodo)}\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: 'Bs. ${metodo.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < datos.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      _getMetodoPagoDisplay(datos[index].metodo),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    'Bs.${(value / 1000).toStringAsFixed(0)}K',
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: datos.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.total,
                gradient: LinearGradient(
                  colors: [
                    _getColorMetodoPago(entry.value.metodo).withOpacity(0.7),
                    _getColorMetodoPago(entry.value.metodo),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _getMetodoPagoDisplay(String metodoPago) {
    switch (metodoPago) {
      case 'efectivo':
        return 'Efectivo';
      case 'tarjeta':
        return 'Tarjeta';
      case 'transferencia':
        return 'Transfer';
      case 'qr':
        return 'QR';
      case 'mixto':
        return 'Mixto';
      default:
        return metodoPago;
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
}

// ===== GRÁFICO: TOP PRODUCTOS (BARRAS HORIZONTALES) =====

class TopProductosChart extends StatelessWidget {
  final List<ProductoMasVendido> productos;

  const TopProductosChart({super.key, required this.productos});

  @override
  Widget build(BuildContext context) {
    if (productos.isEmpty) {
      return const Center(child: Text('Sin datos de productos'));
    }

    final maxIngreso = productos.map((p) => p.ingresoTotal).reduce(math.max);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxIngreso * 1.1,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final producto = productos[group.x];
              return BarTooltipItem(
                '${producto.nombreProducto}\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                children: [
                  TextSpan(
                    text: 'Bs. ${producto.ingresoTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 11,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < productos.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        productos[index].nombreProducto.length > 10
                            ? '${productos[index].nombreProducto.substring(0, 10)}...'
                            : productos[index].nombreProducto,
                        style: const TextStyle(fontSize: 9),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    'Bs.${(value / 1000).toStringAsFixed(0)}K',
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: productos.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.ingresoTotal,
                gradient: LinearGradient(
                  colors: [
                    Colors.teal.withOpacity(0.7),
                    Colors.teal,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ===== GRÁFICO: INVENTARIO POR CATEGORÍA (DONA) =====

class InventarioPorCategoriaChart extends ConsumerWidget {
  const InventarioPorCategoriaChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categorias = ref.watch(categoriasProvider);

    return categorias.when(
      data: (listaCategorias) {
        if (listaCategorias.isEmpty) {
          return const Center(child: Text('Sin categorías disponibles'));
        }

        // Simulamos datos por categoría (en producción obtendrías esto de la DB)
        final datosCategoria = listaCategorias.asMap().entries.map((entry) {
          final random = math.Random(entry.key);
          return PieChartSectionData(
            color: _getColorForIndex(entry.key),
            value: (random.nextDouble() * 100) + 20,
            title:
                '${entry.value}\n${((random.nextDouble() * 30) + 10).toStringAsFixed(1)}%',
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList();

        return PieChart(
          PieChartData(
            sections: datosCategoria,
            centerSpaceRadius: 40,
            sectionsSpace: 2,
            startDegreeOffset: -90,
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Error al cargar categorías')),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[index % colors.length];
  }
}

// ===== GRÁFICO: VENTAS POR HORA =====

class VentasPorHoraChart extends StatelessWidget {
  final List<VentaPorHora> datos;

  const VentasPorHoraChart({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    if (datos.isEmpty) {
      return const Center(child: Text('Sin datos disponibles'));
    }

    final maxY = datos.map((d) => d.total).reduce(math.max);
    if (maxY == 0) {
      return const Center(child: Text('Sin ventas registradas'));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.1,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final hora = datos[group.x];
              return BarTooltipItem(
                '${hora.hora}:00\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: 'Bs. ${hora.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < datos.length && index % 2 == 0) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      '${datos[index].hora}h',
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    'Bs.${(value / 100).toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: datos.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.total,
                gradient: LinearGradient(
                  colors: [
                    Colors.indigo.withOpacity(0.7),
                    Colors.indigo,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 12,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ===== GRÁFICO: ACTIVIDAD SEMANAL (RADAR) =====

class ActividadSemanalChart extends StatelessWidget {
  final List<VentaPorDia> datos;

  const ActividadSemanalChart({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    // Agrupar datos por día de la semana
    final ventasPorDiaSemana = List.filled(7, 0.0);

    for (final venta in datos) {
      final dayIndex = (venta.fecha.weekday - 1) % 7;
      ventasPorDiaSemana[dayIndex] += venta.total;
    }

    final maxValue = ventasPorDiaSemana.reduce(math.max);
    if (maxValue == 0) {
      return const Center(child: Text('Sin datos para mostrar'));
    }

    return RadarChart(
      RadarChartData(
        dataSets: [
          RadarDataSet(
            fillColor: Colors.blue.withOpacity(0.2),
            borderColor: Colors.blue,
            borderWidth: 2,
            entryRadius: 3,
            dataEntries: ventasPorDiaSemana.asMap().entries.map((entry) {
              return RadarEntry(value: entry.value / maxValue * 100);
            }).toList(),
          ),
        ],
        radarBorderData: const BorderSide(color: Colors.transparent),
        titlePositionPercentageOffset: 0.2,
        titleTextStyle: const TextStyle(fontSize: 12),
        getTitle: (index, angle) {
          const dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
          return RadarChartTitle(text: dias[index % dias.length]);
        },
        tickCount: 4,
        ticksTextStyle: const TextStyle(fontSize: 10, color: Colors.grey),
        tickBorderData: const BorderSide(color: Colors.grey, width: 1),
        gridBorderData: const BorderSide(color: Colors.grey, width: 1),
      ),
    );
  }
}

// ===== GRÁFICO: ANÁLISIS COMBINADO =====

class AnalisisCombinadoChart extends StatelessWidget {
  final List<VentaPorDia> datos;

  const AnalisisCombinadoChart({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    if (datos.isEmpty) {
      return const Center(child: Text('Sin datos disponibles'));
    }

    final maxVentas = datos.map((d) => d.total).reduce(math.max);
    final maxTransacciones =
        datos.map((d) => d.numeroVentas.toDouble()).reduce(math.max);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxVentas / 5,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.3),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    '${(value * maxTransacciones / maxVentas).toInt()}',
                    style: const TextStyle(fontSize: 10, color: Colors.red),
                  ),
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 5,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < datos.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      '${datos[index].fecha.day}',
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    'Bs.${(value / 1000).toStringAsFixed(0)}K',
                    style: const TextStyle(fontSize: 10, color: Colors.blue),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (datos.length - 1).toDouble(),
        minY: 0,
        maxY: maxVentas * 1.1,
        lineBarsData: [
          // Línea de ventas (en Bolivianos)
          LineChartBarData(
            spots: datos.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.total);
            }).toList(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.1),
            ),
          ),
          // Línea de número de transacciones (escalada)
          LineChartBarData(
            spots: datos.asMap().entries.map((entry) {
              final scaledValue =
                  (entry.value.numeroVentas.toDouble() / maxTransacciones) *
                      maxVentas;
              return FlSpot(entry.key.toDouble(), scaledValue);
            }).toList(),
            isCurved: true,
            color: Colors.red,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            dashArray: [5, 5],
          ),
        ],
      ),
    );
  }
}

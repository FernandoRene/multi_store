import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/database_models.dart';
import 'repositories/database_repositories.dart';
import 'screens/productos_screens.dart';
import 'screens/punto_venta_screens.dart';
import 'screens/ventas_reportes_screens.dart';
import 'services/supabase_sync_system.dart';

void main() async {
  // Asegurar que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializar Supabase
    print('🚀 Inicializando Supabase...');
    await SupabaseConfig.initialize();
    print('✅ Supabase inicializado correctamente');
  } catch (e) {
    print('❌ Error inicializando Supabase: $e');
    // Continuar con la app aunque Supabase falle
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi-tienda',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estadisticas = ref.watch(estadisticasProvider);
    final alertas = ref.watch(alertasStockProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard - Multi-tienda'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: estadisticas.when(
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título de bienvenida
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sistema Multi-tienda',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Configurado: ${SupabaseConfig.modoDemo ? "Modo Demo" : "Modo Real"} activo.',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Título de Acciones Rápidas
              Text(
                'Acciones Rápidas',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Botones de navegación principales
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const ProductosScreen()),
                        );
                      },
                      icon: const Icon(Icons.inventory_2, size: 18),
                      label: const Text('Productos',
                          style: TextStyle(fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(14),
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const PuntoVentaScreen()),
                        );
                      },
                      icon: const Icon(Icons.point_of_sale, size: 18),
                      label: const Text('Punto Venta',
                          style: TextStyle(fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(14),
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // botones de ventas y reportes
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const VentasScreen()),
                        );
                      },
                      icon: const Icon(Icons.receipt_long, size: 18),
                      label:
                          const Text('Ventas', style: TextStyle(fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(14),
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const ReportesScreen()),
                        );
                      },
                      icon: const Icon(Icons.analytics, size: 18),
                      label: const Text('Reportes',
                          style: TextStyle(fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(14),
                        backgroundColor: Colors.purple.shade600,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Botón de sincronización
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const SincronizacionScreen()),
                    );
                  },
                  icon: const Icon(Icons.sync),
                  label: Text(SupabaseConfig.modoDemo
                      ? 'Sincronización (Demo)'
                      : 'Sincronización (Real)'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.teal.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Título de KPIs
              Text(
                'Estadísticas Generales',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // KPIs en Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _buildKPICard(
                    'Productos',
                    stats.totalProductos.toString(),
                    Icons.inventory_2,
                    Colors.blue,
                    context,
                  ),
                  _buildKPICard(
                    'Activos',
                    stats.productosActivos.toString(),
                    Icons.check_circle,
                    Colors.green,
                    context,
                  ),
                  _buildKPICard(
                    'Stock Bajo',
                    stats.productosStockBajo.toString(),
                    Icons.warning_amber,
                    Colors.orange,
                    context,
                  ),
                  _buildKPICard(
                    'Ventas Hoy',
                    'Bs. ${stats.ventasHoy.toStringAsFixed(1)}',
                    Icons.trending_up,
                    Colors.purple,
                    context,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Valor del inventario
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        size: 40,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Valor Total del Inventario',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Bs. ${stats.valorTotalInventario.toStringAsFixed(2)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Alertas de Stock
              Text(
                'Alertas de Stock',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              alertas.when(
                data: (listaAlertas) =>
                    _buildAlertasSection(listaAlertas, context),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Error al cargar alertas: $error'),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Información técnica
              Card(
                color: Colors.grey.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información Técnica',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      _buildTechInfo('Base de Datos', 'SQLite ORM'),
                      _buildTechInfo('Sincronización',
                          SupabaseConfig.modoDemo ? 'Demo Mode' : 'Supabase'),
                      _buildTechInfo(
                          'Geolocalización', 'Implementada en ventas'),
                      _buildTechInfo('Última actualización',
                          '${stats.fechaUltimaActualizacion.day}/${stats.fechaUltimaActualizacion.month}/${stats.fechaUltimaActualizacion.year} ${stats.fechaUltimaActualizacion.hour}:${stats.fechaUltimaActualizacion.minute.toString().padLeft(2, '0')}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando base de datos...'),
            ],
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Card(
            color: Colors.red.shade50,
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error, size: 48, color: Colors.red.shade700),
                  const SizedBox(height: 16),
                  Text(
                    'Error al inicializar la base de datos',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text('$error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(estadisticasProvider),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Refrescar datos
          // Ignorar explícitamente el valor retornado por refresh
          // ignore: unused_result
          ref.refresh(estadisticasProvider);
          // ignore: unused_result
          ref.refresh(alertasStockProvider);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Datos actualizados'),
              backgroundColor: Colors.green,
            ),
          );
        },
        tooltip: 'Actualizar datos',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color color,
      BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withAlpha((0.1 * 255).toInt()),
              color.withAlpha((0.05 * 255).toInt()),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertasSection(List<AlertaStock> alertas, BuildContext context) {
    if (alertas.isEmpty) {
      return Card(
        color: Colors.green.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade700),
              const SizedBox(width: 16),
              const Expanded(
                child: Text('¡Excelente! No hay alertas de stock crítico'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Text(
                  'Productos con Stock Bajo (${alertas.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...alertas.take(5).map((alerta) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor:
                          _getColorForNivel(alerta.nivel).withOpacity(0.2),
                      child: Icon(
                        _getIconForNivel(alerta.nivel),
                        color: _getColorForNivel(alerta.nivel),
                      ),
                    ),
                    title: Text(
                      alerta.nombreProducto,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                        'Stock actual: ${alerta.stockActual} | Mínimo: ${alerta.stockMinimo}'),
                    trailing: Chip(
                      label: Text(
                        alerta.nivel.displayName,
                        style: TextStyle(
                          color: _getColorForNivel(alerta.nivel),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor:
                          _getColorForNivel(alerta.nivel).withOpacity(0.1),
                      side: BorderSide(
                          color:
                              _getColorForNivel(alerta.nivel).withOpacity(0.3)),
                    ),
                  ),
                )),
            if (alertas.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Y ${alertas.length - 5} productos más...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Color _getColorForNivel(NivelAlerta nivel) {
    switch (nivel) {
      case NivelAlerta.critico:
        return Colors.red;
      case NivelAlerta.bajo:
        return Colors.orange;
      case NivelAlerta.medio:
        return Colors.yellow.shade700;
      case NivelAlerta.normal:
        return Colors.green;
    }
  }

  IconData _getIconForNivel(NivelAlerta nivel) {
    switch (nivel) {
      case NivelAlerta.critico:
        return Icons.error;
      case NivelAlerta.bajo:
        return Icons.warning;
      case NivelAlerta.medio:
        return Icons.info;
      case NivelAlerta.normal:
        return Icons.check;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../database/database.dart';
import '../models/database_models.dart';
import '../repositories/database_repositories.dart';

// ===== PROVIDERS PARA GESTIÓN DE PRODUCTOS =====

final filtroProductosProvider =
    StateProvider<FiltroProductos>((ref) => FiltroProductos());

final busquedaProductosProvider = StateProvider<String>((ref) => '');

final categoriaSeleccionadaProvider = StateProvider<String?>((ref) => null);

final productoSeleccionadoProvider = StateProvider<Producto?>((ref) => null);

// Provider para productos filtrados
final productosFilteredProvider = FutureProvider<List<Producto>>((ref) async {
  final repository = ref.watch(productosRepositoryProvider);
  final filtro = ref.watch(filtroProductosProvider);
  final busqueda = ref.watch(busquedaProductosProvider);
  final categoria = ref.watch(categoriaSeleccionadaProvider);

  final filtroCompleto = FiltroProductos(
    categoria: categoria,
    busqueda: busqueda.isEmpty ? null : busqueda,
    soloActivos: filtro.soloActivos,
    soloStockBajo: filtro.soloStockBajo,
    precioMinimo: filtro.precioMinimo,
    precioMaximo: filtro.precioMaximo,
  );

  return await repository.obtenerTodos(filtro: filtroCompleto);
});

// ===== 1. PANTALLA PRINCIPAL - LISTA DE PRODUCTOS =====

class ProductosScreen extends ConsumerWidget {
  const ProductosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productos = ref.watch(productosFilteredProvider);
    final categorias = ref.watch(categoriasProvider);
    final busqueda = ref.watch(busquedaProductosProvider);
    final categoriaSeleccionada = ref.watch(categoriaSeleccionadaProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Productos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _mostrarFiltros(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(productosFilteredProvider);
              ref.refresh(categoriasProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda - CORREGIDA
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                // Campo de búsqueda mejorado
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar productos...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: busqueda.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => ref
                                .read(busquedaProductosProvider.notifier)
                                .state = '',
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    ref.read(busquedaProductosProvider.notifier).state = value;
                  },
                ),
                const SizedBox(height: 12),
                // Filtro de categorías - CORREGIDO
                categorias.when(
                  data: (listaCategorias) => _buildFiltroCategoria(
                      listaCategorias, categoriaSeleccionada, ref),
                  loading: () => const SizedBox(height: 40),
                  error: (_, __) => const SizedBox(height: 40),
                ),
              ],
            ),
          ),

          // Lista de productos
          Expanded(
            child: productos.when(
              data: (listaProductos) {
                if (listaProductos.isEmpty) {
                  return _buildEstadoVacio(busqueda, categoriaSeleccionada);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.refresh(productosFilteredProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: listaProductos.length,
                    itemBuilder: (context, index) {
                      final producto = listaProductos[index];
                      return _buildProductoCard(context, ref, producto);
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
            MaterialPageRoute(
                builder: (context) => const AgregarProductoScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
    );
  }

  Widget _buildFiltroCategoria(
      List<String> categorias, String? categoriaSeleccionada, WidgetRef ref) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Chip "Todas" - siempre presente
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('Todas'),
              selected: categoriaSeleccionada == null,
              onSelected: (selected) {
                ref.read(categoriaSeleccionadaProvider.notifier).state = null;
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          // Chips de categorías
          ...categorias.map((categoria) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(
                    categoria,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  selected: categoriaSeleccionada == categoria,
                  onSelected: (selected) {
                    ref.read(categoriaSeleccionadaProvider.notifier).state =
                        selected ? categoria : null;
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildProductoCard(
      BuildContext context, WidgetRef ref, Producto producto) {
    final stockBajo = producto.stockActual <= producto.stockMinimo;
    final sinStock = producto.stockActual <= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DetalleProductoScreen(producto: producto),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ROW PRINCIPAL
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información del producto - USA EXPANDED
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nombre del producto
                        Text(
                          producto.nombre,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Descripción (si existe)
                        if (producto.descripcion?.isNotEmpty == true) ...[
                          const SizedBox(height: 4),
                          Text(
                            producto.descripcion!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Precio y menú - DIMENSIONES FIJAS
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Precio
                      Container(
                        constraints: const BoxConstraints(minWidth: 80),
                        child: Text(
                          'Bs. ${producto.precioVenta.toStringAsFixed(2)}',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: sinStock
                                        ? Colors.grey
                                        : Theme.of(context).colorScheme.primary,
                                  ),
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Menú de opciones
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: PopupMenuButton<String>(
                          onSelected: (value) => _onMenuItemSelected(
                              context, ref, value, producto),
                          icon: const Icon(Icons.more_vert, size: 20),
                          padding: EdgeInsets.zero,
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'ver',
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.visibility, size: 16),
                                  SizedBox(width: 8),
                                  Text('Ver', style: TextStyle(fontSize: 14)),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'editar',
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.edit, size: 16),
                                  SizedBox(width: 8),
                                  Text('Editar',
                                      style: TextStyle(fontSize: 14)),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'eliminar',
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.delete,
                                      color: Colors.red, size: 16),
                                  SizedBox(width: 8),
                                  Text('Eliminar',
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 14)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // CHIPS Y ESTADO CORREGIDOS
              Row(
                children: [
                  // Categoría - TAMAÑO FLEXIBLE
                  Flexible(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 120),
                      child: Chip(
                        label: Text(
                          producto.categoria,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),

                  // Código de barras (si existe)
                  if (producto.codigoBarras?.isNotEmpty == true) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 100),
                        child: Chip(
                          label: Text(
                            producto.codigoBarras!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10),
                          ),
                          backgroundColor: Colors.grey[200],
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                  ],

                  const Spacer(),

                  // Indicador de stock - TAMAÑO FIJO
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: sinStock
                          ? Colors.red[100]
                          : stockBajo
                              ? Colors.orange[100]
                              : Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          sinStock
                              ? Icons.error
                              : stockBajo
                                  ? Icons.warning
                                  : Icons.check_circle,
                          size: 14,
                          color: sinStock
                              ? Colors.red[700]
                              : stockBajo
                                  ? Colors.orange[700]
                                  : Colors.green[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          sinStock
                              ? 'Sin Stock'
                              : 'Stock: ${producto.stockActual}',
                          style: TextStyle(
                            color: sinStock
                                ? Colors.red[700]
                                : stockBajo
                                    ? Colors.orange[700]
                                    : Colors.green[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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

  void _onMenuItemSelected(
      BuildContext context, WidgetRef ref, String value, Producto producto) {
    switch (value) {
      case 'ver':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DetalleProductoScreen(producto: producto),
          ),
        );
        break;
      case 'editar':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EditarProductoScreen(producto: producto),
          ),
        );
        break;
      case 'eliminar':
        _mostrarDialogoEliminar(context, ref, producto);
        break;
    }
  }

  void _mostrarDialogoEliminar(
      BuildContext context, WidgetRef ref, Producto producto) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content:
            Text('¿Estás seguro de que deseas eliminar "${producto.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(context).pop();
              final repository = ref.read(productosRepositoryProvider);
              final success = await repository.eliminar(producto.id);

              if (context.mounted) {
                if (success) {
                  ref.refresh(productosFilteredProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Producto eliminado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error al eliminar el producto'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _mostrarFiltros(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: const FiltrosProductosBottomSheet(),
      ),
    );
  }
}

// ESTADO VACÍO MEJORADO
Widget _buildEstadoVacio(String busqueda, String? categoriaSeleccionada) {
  final hayFiltros = busqueda.isNotEmpty || categoriaSeleccionada != null;

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hayFiltros ? Icons.search_off : Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            hayFiltros
                ? 'No se encontraron productos'
                : 'No hay productos registrados',
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
                ? 'Intenta cambiar los filtros de búsqueda'
                : 'Agrega tu primer producto para comenzar',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

// ESTADO DE ERROR MEJORADO
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
            'Error al cargar productos',
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
            onPressed: () => ref.refresh(productosFilteredProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    ),
  );
}

// ===== 2. PANTALLA AGREGAR PRODUCTO =====

class AgregarProductoScreen extends ConsumerStatefulWidget {
  const AgregarProductoScreen({super.key});

  @override
  ConsumerState<AgregarProductoScreen> createState() =>
      _AgregarProductoScreenState();
}

class _AgregarProductoScreenState extends ConsumerState<AgregarProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codigoBarrasController = TextEditingController();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _precioVentaController = TextEditingController();
  final _precioCompraController = TextEditingController();
  final _stockActualController = TextEditingController();
  final _stockMinimoController = TextEditingController();

  String _unidadMedida = 'unidad';
  bool _guardando = false;

  @override
  void dispose() {
    _codigoBarrasController.dispose();
    _nombreController.dispose();
    _descripcionController.dispose();
    _categoriaController.dispose();
    _precioVentaController.dispose();
    _precioCompraController.dispose();
    _stockActualController.dispose();
    _stockMinimoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categorias = ref.watch(categoriasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Producto'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información básica
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información Básica',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _codigoBarrasController,
                        decoration: const InputDecoration(
                          labelText: 'Código de Barras',
                          hintText: '1234567890123',
                          prefixIcon: Icon(Icons.qr_code),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              value.length < 8) {
                            return 'El código debe tener al menos 8 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del Producto *',
                          prefixIcon: Icon(Icons.shopping_bag),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El nombre es requerido';
                          }
                          if (value.length < 2) {
                            return 'El nombre debe tener al menos 2 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descripcionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                          prefixIcon: Icon(Icons.description),
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      categorias.when(
                        data: (listaCategorias) =>
                            _buildCategoriaField(listaCategorias),
                        loading: () => TextFormField(
                          controller: _categoriaController,
                          decoration: const InputDecoration(
                            labelText: 'Categoría *',
                            prefixIcon: Icon(Icons.category),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'La categoría es requerida';
                            }
                            return null;
                          },
                        ),
                        error: (_, __) => TextFormField(
                          controller: _categoriaController,
                          decoration: const InputDecoration(
                            labelText: 'Categoría *',
                            prefixIcon: Icon(Icons.category),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'La categoría es requerida';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Precios
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Precios',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _precioCompraController,
                              decoration: const InputDecoration(
                                labelText: 'Precio de Compra',
                                prefixText: 'Bs. ',
                                prefixIcon: Icon(Icons.money_off),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}'))
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Requerido';
                                }
                                final precio = double.tryParse(value);
                                if (precio == null || precio <= 0) {
                                  return 'Precio inválido';
                                }
                                return null;
                              },
                              onChanged: (_) => _calcularMargen(),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextFormField(
                              controller: _precioVentaController,
                              decoration: const InputDecoration(
                                labelText: 'Precio de Venta',
                                prefixText: 'Bs. ',
                                prefixIcon: Icon(Icons.attach_money),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}'))
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Requerido';
                                }
                                final precio = double.tryParse(value);
                                if (precio == null || precio <= 0) {
                                  return 'Precio inválido';
                                }
                                final precioCompra = double.tryParse(
                                    _precioCompraController.text);
                                if (precioCompra != null &&
                                    precio < precioCompra) {
                                  return 'Menor que compra';
                                }
                                return null;
                              },
                              onChanged: (_) => _calcularMargen(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Margen de ganancia: ${_calcularMargenTexto()}',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Inventario
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inventario',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _stockActualController,
                              decoration: const InputDecoration(
                                labelText: 'Stock Actual *',
                                prefixIcon: Icon(Icons.inventory),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Requerido';
                                }
                                final stock = int.tryParse(value);
                                if (stock == null || stock < 0) {
                                  return 'Stock inválido';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _stockMinimoController,
                              decoration: const InputDecoration(
                                labelText: 'Stock Mínimo *',
                                prefixIcon: Icon(Icons.warning),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Requerido';
                                }
                                final stock = int.tryParse(value);
                                if (stock == null || stock < 0) {
                                  return 'Stock inválido';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _unidadMedida,
                        decoration: const InputDecoration(
                          labelText: 'Unidad de Medida',
                          prefixIcon: Icon(Icons.straighten),
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'unidad', child: Text('Unidad')),
                          DropdownMenuItem(
                              value: 'kg', child: Text('Kilogramo')),
                          DropdownMenuItem(value: 'g', child: Text('Gramo')),
                          DropdownMenuItem(value: 'l', child: Text('Litro')),
                          DropdownMenuItem(
                              value: 'ml', child: Text('Mililitro')),
                          DropdownMenuItem(value: 'm', child: Text('Metro')),
                          DropdownMenuItem(
                              value: 'cm', child: Text('Centímetro')),
                          DropdownMenuItem(value: 'caja', child: Text('Caja')),
                          DropdownMenuItem(
                              value: 'paquete', child: Text('Paquete')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _unidadMedida = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _guardando ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _guardando ? null : _guardarProducto,
                      child: _guardando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Guardar Producto'),
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

  Widget _buildCategoriaField(List<String> categorias) {
    return DropdownButtonFormField<String>(
      value: categorias.contains(_categoriaController.text)
          ? _categoriaController.text
          : null,
      decoration: const InputDecoration(
        labelText: 'Categoría *',
        prefixIcon: Icon(Icons.category),
        border: OutlineInputBorder(),
      ),
      items: [
        ...categorias.map((categoria) => DropdownMenuItem(
              value: categoria,
              child: Text(categoria),
            )),
        const DropdownMenuItem(
          value: 'nueva',
          child: Text('+ Nueva categoría'),
        ),
      ],
      onChanged: (value) {
        if (value == 'nueva') {
          _mostrarDialogoNuevaCategoria();
        } else {
          _categoriaController.text = value ?? '';
        }
      },
      validator: (value) {
        if (_categoriaController.text.isEmpty) {
          return 'La categoría es requerida';
        }
        return null;
      },
    );
  }

  void _mostrarDialogoNuevaCategoria() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Categoría'),
        content: TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nombre de la categoría',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _categoriaController.text = controller.text;
                });
                Navigator.of(context).pop();
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _calcularMargen() {
    setState(() {});
  }

  String _calcularMargenTexto() {
    final precioCompra = double.tryParse(_precioCompraController.text);
    final precioVenta = double.tryParse(_precioVentaController.text);

    if (precioCompra != null && precioVenta != null && precioCompra > 0) {
      final margen = precioVenta - precioCompra;
      final porcentaje = (margen / precioCompra) * 100;
      return 'Bs. ${margen.toStringAsFixed(2)} (${porcentaje.toStringAsFixed(1)}%)';
    }

    return 'Bs. 0.00 (0.0%)';
  }

  Future<void> _guardarProducto() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _guardando = true;
    });

    try {
      final repository = ref.read(productosRepositoryProvider);

      final precioCompra = double.parse(_precioCompraController.text);
      final precioVenta = double.parse(_precioVentaController.text);
      final margenGanancia = precioVenta - precioCompra;

      final producto = ProductosCompanion(
        codigoBarras: drift.Value(_codigoBarrasController.text.isEmpty
            ? null
            : _codigoBarrasController.text),
        nombre: drift.Value(_nombreController.text),
        descripcion: drift.Value(_descripcionController.text.isEmpty
            ? null
            : _descripcionController.text),
        categoria: drift.Value(_categoriaController.text),
        precioVenta: drift.Value(precioVenta),
        precioCompra: drift.Value(precioCompra),
        margenGanancia: drift.Value(margenGanancia),
        stockActual: drift.Value(int.parse(_stockActualController.text)),
        stockMinimo: drift.Value(int.parse(_stockMinimoController.text)),
        unidadMedida: drift.Value(_unidadMedida),
        tiendaId: const drift.Value('tienda_001'),
      );

      await repository.insertar(producto);

      if (mounted) {
        ref.refresh(productosFilteredProvider);
        ref.refresh(categoriasProvider);

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto guardado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }
}

// ===== 3. PANTALLA EDITAR PRODUCTO =====

class EditarProductoScreen extends ConsumerStatefulWidget {
  final Producto producto;

  const EditarProductoScreen({super.key, required this.producto});

  @override
  ConsumerState<EditarProductoScreen> createState() =>
      _EditarProductoScreenState();
}

class _EditarProductoScreenState extends ConsumerState<EditarProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codigoBarrasController;
  late final TextEditingController _nombreController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _categoriaController;
  late final TextEditingController _precioVentaController;
  late final TextEditingController _precioCompraController;
  late final TextEditingController _stockActualController;
  late final TextEditingController _stockMinimoController;

  late String _unidadMedida;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _codigoBarrasController =
        TextEditingController(text: widget.producto.codigoBarras ?? '');
    _nombreController = TextEditingController(text: widget.producto.nombre);
    _descripcionController =
        TextEditingController(text: widget.producto.descripcion ?? '');
    _categoriaController =
        TextEditingController(text: widget.producto.categoria);
    _precioVentaController =
        TextEditingController(text: widget.producto.precioVenta.toString());
    _precioCompraController =
        TextEditingController(text: widget.producto.precioCompra.toString());
    _stockActualController =
        TextEditingController(text: widget.producto.stockActual.toString());
    _stockMinimoController =
        TextEditingController(text: widget.producto.stockMinimo.toString());
    _unidadMedida = widget.producto.unidadMedida;
  }

  @override
  void dispose() {
    _codigoBarrasController.dispose();
    _nombreController.dispose();
    _descripcionController.dispose();
    _categoriaController.dispose();
    _precioVentaController.dispose();
    _precioCompraController.dispose();
    _stockActualController.dispose();
    _stockMinimoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categorias = ref.watch(categoriasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Producto'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () =>
                _mostrarDialogoEliminar(context, ref, widget.producto),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner de información
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Editando: ${widget.producto.nombre}',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Información básica
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información Básica',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _codigoBarrasController,
                        decoration: const InputDecoration(
                          labelText: 'Código de Barras',
                          prefixIcon: Icon(Icons.qr_code),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              value.length < 8) {
                            return 'El código debe tener al menos 8 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del Producto *',
                          prefixIcon: Icon(Icons.shopping_bag),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El nombre es requerido';
                          }
                          if (value.length < 2) {
                            return 'El nombre debe tener al menos 2 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descripcionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                          prefixIcon: Icon(Icons.description),
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      categorias.when(
                        data: (listaCategorias) =>
                            _buildCategoriaField(listaCategorias),
                        loading: () => TextFormField(
                          controller: _categoriaController,
                          decoration: const InputDecoration(
                            labelText: 'Categoría *',
                            prefixIcon: Icon(Icons.category),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'La categoría es requerida';
                            }
                            return null;
                          },
                        ),
                        error: (_, __) => TextFormField(
                          controller: _categoriaController,
                          decoration: const InputDecoration(
                            labelText: 'Categoría *',
                            prefixIcon: Icon(Icons.category),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'La categoría es requerida';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Precios
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Precios',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _precioCompraController,
                              decoration: const InputDecoration(
                                labelText: 'Precio de Compra *',
                                prefixText: 'Bs. ',
                                prefixIcon: Icon(Icons.money_off),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}'))
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Requerido';
                                }
                                final precio = double.tryParse(value);
                                if (precio == null || precio <= 0) {
                                  return 'Precio inválido';
                                }
                                return null;
                              },
                              onChanged: (_) => _calcularMargen(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _precioVentaController,
                              decoration: const InputDecoration(
                                labelText: 'Precio de Venta *',
                                prefixText: 'Bs. ',
                                prefixIcon: Icon(Icons.attach_money),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}'))
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Requerido';
                                }
                                final precio = double.tryParse(value);
                                if (precio == null || precio <= 0) {
                                  return 'Precio inválido';
                                }
                                final precioCompra = double.tryParse(
                                    _precioCompraController.text);
                                if (precioCompra != null &&
                                    precio < precioCompra) {
                                  return 'Menor que compra';
                                }
                                return null;
                              },
                              onChanged: (_) => _calcularMargen(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Margen de ganancia: ${_calcularMargenTexto()}',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Inventario
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inventario',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _stockActualController,
                              decoration: const InputDecoration(
                                labelText: 'Stock Actual *',
                                prefixIcon: Icon(Icons.inventory),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Requerido';
                                }
                                final stock = int.tryParse(value);
                                if (stock == null || stock < 0) {
                                  return 'Stock inválido';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _stockMinimoController,
                              decoration: const InputDecoration(
                                labelText: 'Stock Mínimo *',
                                prefixIcon: Icon(Icons.warning),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Requerido';
                                }
                                final stock = int.tryParse(value);
                                if (stock == null || stock < 0) {
                                  return 'Stock inválido';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _unidadMedida,
                        decoration: const InputDecoration(
                          labelText: 'Unidad de Medida',
                          prefixIcon: Icon(Icons.straighten),
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'unidad', child: Text('Unidad')),
                          DropdownMenuItem(
                              value: 'kg', child: Text('Kilogramo')),
                          DropdownMenuItem(value: 'g', child: Text('Gramo')),
                          DropdownMenuItem(value: 'l', child: Text('Litro')),
                          DropdownMenuItem(
                              value: 'ml', child: Text('Mililitro')),
                          DropdownMenuItem(value: 'm', child: Text('Metro')),
                          DropdownMenuItem(
                              value: 'cm', child: Text('Centímetro')),
                          DropdownMenuItem(value: 'caja', child: Text('Caja')),
                          DropdownMenuItem(
                              value: 'paquete', child: Text('Paquete')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _unidadMedida = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _guardando ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _guardando ? null : _actualizarProducto,
                      child: _guardando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Actualizar Producto'),
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

  Widget _buildCategoriaField(List<String> categorias) {
    return DropdownButtonFormField<String>(
      value: categorias.contains(_categoriaController.text)
          ? _categoriaController.text
          : null,
      decoration: const InputDecoration(
        labelText: 'Categoría *',
        prefixIcon: Icon(Icons.category),
        border: OutlineInputBorder(),
      ),
      items: [
        ...categorias.map((categoria) => DropdownMenuItem(
              value: categoria,
              child: Text(categoria),
            )),
        const DropdownMenuItem(
          value: 'nueva',
          child: Text('+ Nueva categoría'),
        ),
      ],
      onChanged: (value) {
        if (value == 'nueva') {
          _mostrarDialogoNuevaCategoria();
        } else {
          _categoriaController.text = value ?? '';
        }
      },
      validator: (value) {
        if (_categoriaController.text.isEmpty) {
          return 'La categoría es requerida';
        }
        return null;
      },
    );
  }

  void _mostrarDialogoNuevaCategoria() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Categoría'),
        content: TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nombre de la categoría',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _categoriaController.text = controller.text;
                });
                Navigator.of(context).pop();
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _calcularMargen() {
    setState(() {});
  }

  String _calcularMargenTexto() {
    final precioCompra = double.tryParse(_precioCompraController.text);
    final precioVenta = double.tryParse(_precioVentaController.text);

    if (precioCompra != null && precioVenta != null && precioCompra > 0) {
      final margen = precioVenta - precioCompra;
      final porcentaje = (margen / precioCompra) * 100;
      return 'Bs. ${margen.toStringAsFixed(2)} (${porcentaje.toStringAsFixed(1)}%)';
    }

    return 'Bs. 0.00 (0.0%)';
  }

  void _mostrarDialogoEliminar(
      BuildContext context, WidgetRef ref, Producto producto) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${producto.nombre}"?',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(context).pop();
              final repository = ref.read(productosRepositoryProvider);
              final success = await repository.eliminar(producto.id);

              if (context.mounted) {
                if (success) {
                  ref.refresh(productosFilteredProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Producto eliminado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error al eliminar el producto'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _actualizarProducto() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _guardando = true;
    });

    try {
      final repository = ref.read(productosRepositoryProvider);

      final precioCompra = double.parse(_precioCompraController.text);
      final precioVenta = double.parse(_precioVentaController.text);
      final margenGanancia = precioVenta - precioCompra;

      final productoActualizado = ProductosCompanion(
        codigoBarras: drift.Value(_codigoBarrasController.text.isEmpty
            ? null
            : _codigoBarrasController.text),
        nombre: drift.Value(_nombreController.text),
        descripcion: drift.Value(_descripcionController.text.isEmpty
            ? null
            : _descripcionController.text),
        categoria: drift.Value(_categoriaController.text),
        precioVenta: drift.Value(precioVenta),
        precioCompra: drift.Value(precioCompra),
        margenGanancia: drift.Value(margenGanancia),
        stockActual: drift.Value(int.parse(_stockActualController.text)),
        stockMinimo: drift.Value(int.parse(_stockMinimoController.text)),
        unidadMedida: drift.Value(_unidadMedida),
      );

      await repository.actualizar(widget.producto.id, productoActualizado);

      if (mounted) {
        ref.refresh(productosFilteredProvider);
        ref.refresh(categoriasProvider);

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }
}

// ===== 4. PANTALLA DETALLE PRODUCTO =====

class DetalleProductoScreen extends ConsumerWidget {
  final Producto producto;

  const DetalleProductoScreen({super.key, required this.producto});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stockBajo = producto.stockActual <= producto.stockMinimo;
    final margenReal = producto.precioVenta - producto.precioCompra;
    final porcentajeMargen = producto.precioCompra > 0
        ? (margenReal / producto.precioCompra) * 100
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(producto.nombre),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      EditarProductoScreen(producto: producto),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) =>
                _onMenuItemSelected(context, ref, value, producto),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'editar',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'eliminar',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Eliminar', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con información principal
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          radius: 30,
                          child: Icon(
                            Icons.inventory_2,
                            size: 30,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                producto.nombre,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              if (producto.descripcion != null)
                                Text(
                                  producto.descripcion!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Chip(
                          label: Text(producto.categoria),
                          backgroundColor:
                              Theme.of(context).colorScheme.secondaryContainer,
                        ),
                        const SizedBox(width: 8),
                        if (producto.codigoBarras != null)
                          Chip(
                            label: Text(producto.codigoBarras!),
                            backgroundColor: Colors.grey[200],
                          ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: producto.activo
                                ? Colors.green[100]
                                : Colors.red[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            producto.activo ? 'ACTIVO' : 'INACTIVO',
                            style: TextStyle(
                              color: producto.activo
                                  ? Colors.green[700]
                                  : Colors.red[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Precios
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información de Precios',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            'Precio de Compra',
                            'Bs. ${producto.precioCompra.toStringAsFixed(2)}',
                            Icons.money_off,
                            Colors.orange,
                            context,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildInfoCard(
                            'Precio de Venta',
                            'Bs. ${producto.precioVenta.toStringAsFixed(2)}',
                            Icons.attach_money,
                            Colors.green,
                            context,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.trending_up, color: Colors.blue[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Margen de Ganancia',
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Bs. ${margenReal.toStringAsFixed(2)} (${porcentajeMargen.toStringAsFixed(1)}%)',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Inventario
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información de Inventario',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            'Stock Actual',
                            '${producto.stockActual} ${producto.unidadMedida}',
                            Icons.inventory,
                            stockBajo ? Colors.red : Colors.green,
                            context,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildInfoCard(
                            'Stock Mínimo',
                            '${producto.stockMinimo} ${producto.unidadMedida}',
                            Icons.warning,
                            Colors.orange,
                            context,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (stockBajo)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.red[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '¡Stock Bajo!',
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Este producto necesita reposición',
                                    style: TextStyle(color: Colors.red[600]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 14),
                    _buildInfoRow('Valor en Inventario',
                        'Bs. ${(producto.stockActual * producto.precioCompra).toStringAsFixed(2)}'),
                    _buildInfoRow('Unidad de Medida', producto.unidadMedida),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Información adicional
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información Adicional',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('ID del Producto', producto.id.toString()),
                    if (producto.codigoBarras != null)
                      _buildInfoRow('Código de Barras', producto.codigoBarras!),
                    _buildInfoRow('Tienda ID', producto.tiendaId),
                    _buildInfoRow('Fecha de Creación',
                        '${producto.fechaCreacion.day}/${producto.fechaCreacion.month}/${producto.fechaCreacion.year}'),
                    _buildInfoRow(
                        'Estado', producto.activo ? 'Activo' : 'Inactivo'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EditarProductoScreen(producto: producto),
            ),
          );
        },
        icon: const Icon(Icons.edit),
        label: const Text('Editar'),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color,
      BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _onMenuItemSelected(
      BuildContext context, WidgetRef ref, String value, Producto producto) {
    switch (value) {
      case 'ver':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DetalleProductoScreen(producto: producto),
          ),
        );
        break;
      case 'editar':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EditarProductoScreen(producto: producto),
          ),
        );
        break;
      case 'eliminar':
        _mostrarDialogoEliminar(context, ref, producto);
        break;
    }
  }

  void _mostrarDialogoEliminar(
      BuildContext context, WidgetRef ref, Producto producto) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${producto.nombre}"?',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(context).pop();
              final repository = ref.read(productosRepositoryProvider);
              final success = await repository.eliminar(producto.id);

              if (context.mounted) {
                if (success) {
                  ref.refresh(productosFilteredProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Producto eliminado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error al eliminar el producto'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

// ===== BOTTOM SHEET DE FILTROS =====

class FiltrosProductosBottomSheet extends ConsumerWidget {
  const FiltrosProductosBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtro = ref.watch(filtroProductosProvider);

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
              const Text(
                'Filtros de Productos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Contenido
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  title: const Text('Solo productos activos'),
                  subtitle: const Text('Ocultar productos desactivados'),
                  value: filtro.soloActivos ?? true,
                  onChanged: (value) {
                    ref.read(filtroProductosProvider.notifier).state =
                        FiltroProductos(
                      categoria: filtro.categoria,
                      soloActivos: value,
                      soloStockBajo: filtro.soloStockBajo,
                      busqueda: filtro.busqueda,
                      precioMinimo: filtro.precioMinimo,
                      precioMaximo: filtro.precioMaximo,
                    );
                  },
                ),
                SwitchListTile(
                  title: const Text('Solo productos con stock bajo'),
                  subtitle: const Text(
                      'Mostrar solo productos que necesitan reposición'),
                  value: filtro.soloStockBajo ?? false,
                  onChanged: (value) {
                    ref.read(filtroProductosProvider.notifier).state =
                        FiltroProductos(
                      categoria: filtro.categoria,
                      soloActivos: filtro.soloActivos,
                      soloStockBajo: value,
                      busqueda: filtro.busqueda,
                      precioMinimo: filtro.precioMinimo,
                      precioMaximo: filtro.precioMaximo,
                    );
                  },
                ),
                const Spacer(),
                // Botones
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ref.read(filtroProductosProvider.notifier).state =
                              FiltroProductos();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Limpiar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Aplicar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../database/database.dart';
import '../models/database_models.dart';
import '../repositories/database_repositories.dart';

// ===== PROVIDERS PARA GESTIÓN DE PRODUCTOS =====

final filtroProductosProvider = StateProvider<FiltroProductos>((ref) => FiltroProductos());

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
          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar productos...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: busqueda.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => ref.read(busquedaProductosProvider.notifier).state = '',
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.background,
                  ),
                  onChanged: (value) {
                    ref.read(busquedaProductosProvider.notifier).state = value;
                  },
                ),
                const SizedBox(height: 12),
                // Filtro de categorías
                categorias.when(
                  data: (listaCategorias) => _buildFiltroCategoria(listaCategorias, categoriaSeleccionada, ref),
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
              ],
            ),
          ),
          
          // Lista de productos
          Expanded(
            child: productos.when(
              data: (listaProductos) {
                if (listaProductos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          busqueda.isNotEmpty || categoriaSeleccionada != null
                              ? 'No se encontraron productos'
                              : 'No hay productos registrados',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (busqueda.isEmpty && categoriaSeleccionada == null)
                          const Text(
                            'Agrega tu primer producto',
                            style: TextStyle(color: Colors.grey),
                          ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: listaProductos.length,
                  itemBuilder: (context, index) {
                    final producto = listaProductos[index];
                    return _buildProductoCard(context, ref, producto);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 48, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(productosFilteredProvider),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AgregarProductoScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Agregar Producto'),
      ),
    );
  }

  Widget _buildFiltroCategoria(List<String> categorias, String? categoriaSeleccionada, WidgetRef ref) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          FilterChip(
            label: const Text('Todas'),
            selected: categoriaSeleccionada == null,
            onSelected: (selected) {
              ref.read(categoriaSeleccionadaProvider.notifier).state = null;
            },
          ),
          const SizedBox(width: 8),
          ...categorias.map((categoria) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(categoria),
              selected: categoriaSeleccionada == categoria,
              onSelected: (selected) {
                ref.read(categoriaSeleccionadaProvider.notifier).state = 
                    selected ? categoria : null;
              },
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildProductoCard(BuildContext context, WidgetRef ref, Producto producto) {
    final stockBajo = producto.stockActual <= producto.stockMinimo;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          producto.nombre,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (producto.descripcion != null)
                          Text(
                            producto.descripcion!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Bs. ${producto.precioVenta.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) => _onMenuItemSelected(context, ref, value, producto),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'ver',
                            child: Row(
                              children: [
                                Icon(Icons.visibility),
                                SizedBox(width: 8),
                                Text('Ver detalles'),
                              ],
                            ),
                          ),
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
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Chip(
                    label: Text(producto.categoria),
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                  ),
                  const SizedBox(width: 8),
                  if (producto.codigoBarras != null)
                    Chip(
                      label: Text(producto.codigoBarras!),
                      backgroundColor: Colors.grey[200],
                    ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: stockBajo ? Colors.red[100] : Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          stockBajo ? Icons.warning : Icons.check_circle,
                          size: 16,
                          color: stockBajo ? Colors.red[700] : Colors.green[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Stock: ${producto.stockActual}',
                          style: TextStyle(
                            color: stockBajo ? Colors.red[700] : Colors.green[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
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

  void _onMenuItemSelected(BuildContext context, WidgetRef ref, String value, Producto producto) {
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

  void _mostrarDialogoEliminar(BuildContext context, WidgetRef ref, Producto producto) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text('¿Estás seguro de que deseas eliminar "${producto.nombre}"?'),
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
      builder: (context) => FiltrosProductosBottomSheet(),
    );
  }
}

// ===== 2. PANTALLA AGREGAR PRODUCTO =====

class AgregarProductoScreen extends ConsumerStatefulWidget {
  const AgregarProductoScreen({super.key});

  @override
  ConsumerState<AgregarProductoScreen> createState() => _AgregarProductoScreenState();
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                          if (value != null && value.isNotEmpty && value.length < 8) {
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
                        data: (listaCategorias) => _buildCategoriaField(listaCategorias),
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
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
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Requerido';
                                }
                                final precio = double.tryParse(value);
                                if (precio == null || precio <= 0) {
                                  return 'Precio inválido';
                                }
                                final precioCompra = double.tryParse(_precioCompraController.text);
                                if (precioCompra != null && precio < precioCompra) {
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                          DropdownMenuItem(value: 'unidad', child: Text('Unidad')),
                          DropdownMenuItem(value: 'kg', child: Text('Kilogramo')),
                          DropdownMenuItem(value: 'g', child: Text('Gramo')),
                          DropdownMenuItem(value: 'l', child: Text('Litro')),
                          DropdownMenuItem(value: 'ml', child: Text('Mililitro')),
                          DropdownMenuItem(value: 'm', child: Text('Metro')),
                          DropdownMenuItem(value: 'cm', child: Text('Centímetro')),
                          DropdownMenuItem(value: 'caja', child: Text('Caja')),
                          DropdownMenuItem(value: 'paquete', child: Text('Paquete')),
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
                      onPressed: _guardando ? null : () => Navigator.of(context).pop(),
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
      value: categorias.contains(_categoriaController.text) ? _categoriaController.text : null,
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
        codigoBarras: drift.Value(_codigoBarrasController.text.isEmpty ? null : _codigoBarrasController.text),
        nombre: drift.Value(_nombreController.text),
        descripcion: drift.Value(_descripcionController.text.isEmpty ? null : _descripcionController.text),
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
  ConsumerState<EditarProductoScreen> createState() => _EditarProductoScreenState();
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
    _codigoBarrasController = TextEditingController(text: widget.producto.codigoBarras ?? '');
    _nombreController = TextEditingController(text: widget.producto.nombre);
    _descripcionController = TextEditingController(text: widget.producto.descripcion ?? '');
    _categoriaController = TextEditingController(text: widget.producto.categoria);
    _precioVentaController = TextEditingController(text: widget.producto.precioVenta.toString());
    _precioCompraController = TextEditingController(text: widget.producto.precioCompra.toString());
    _stockActualController = TextEditingController(text: widget.producto.stockActual.toString());
    _stockMinimoController = TextEditingController(text: widget.producto.stockMinimo.toString());
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
            onPressed: () => _mostrarDialogoEliminar(),
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                          if (value != null && value.isNotEmpty && value.length < 8) {
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
                        data: (listaCategorias) => _buildCategoriaField(listaCategorias),
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
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
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Requerido';
                                }
                                final precio = double.tryParse(value);
                                if (precio == null || precio <= 0) {
                                  return 'Precio inválido';
                                }
                                final precioCompra = double.tryParse(_precioCompraController.text);
                                if (precioCompra != null && precio < precioCompra) {
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                          DropdownMenuItem(value: 'unidad', child: Text('Unidad')),
                          DropdownMenuItem(value: 'kg', child: Text('Kilogramo')),
                          DropdownMenuItem(value: 'g', child: Text('Gramo')),
                          DropdownMenuItem(value: 'l', child: Text('Litro')),
                          DropdownMenuItem(value: 'ml', child: Text('Mililitro')),
                          DropdownMenuItem(value: 'm', child: Text('Metro')),
                          DropdownMenuItem(value: 'cm', child: Text('Centímetro')),
                          DropdownMenuItem(value: 'caja', child: Text('Caja')),
                          DropdownMenuItem(value: 'paquete', child: Text('Paquete')),
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
                      onPressed: _guardando ? null : () => Navigator.of(context).pop(),
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
      value: categorias.contains(_categoriaController.text) ? _categoriaController.text : null,
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

  void _mostrarDialogoEliminar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text('¿Estás seguro de que deseas eliminar "${widget.producto.nombre}"?'),
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
              final success = await repository.eliminar(widget.producto.id);
              
              if (mounted) {
                if (success) {
                  ref.refresh(productosFilteredProvider);
                  Navigator.of(context).pop();
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
        codigoBarras: drift.Value(_codigoBarrasController.text.isEmpty ? null : _codigoBarrasController.text),
        nombre: drift.Value(_nombreController.text),
        descripcion: drift.Value(_descripcionController.text.isEmpty ? null : _descripcionController.text),
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
                  builder: (context) => EditarProductoScreen(producto: producto),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _onMenuItemSelected(context, ref, value),
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
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          radius: 30,
                          child: Icon(
                            Icons.inventory_2,
                            size: 30,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                producto.nombre,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (producto.descripcion != null)
                                Text(
                                  producto.descripcion!,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                        ),
                        const SizedBox(width: 8),
                        if (producto.codigoBarras != null)
                          Chip(
                            label: Text(producto.codigoBarras!),
                            backgroundColor: Colors.grey[200],
                          ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: producto.activo ? Colors.green[100] : Colors.red[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            producto.activo ? 'ACTIVO' : 'INACTIVO',
                            style: TextStyle(
                              color: producto.activo ? Colors.green[700] : Colors.red[700],
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información de Precios',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
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
                        const SizedBox(width: 16),
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
                    const SizedBox(height: 16),
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
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información de Inventario',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
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
                        const SizedBox(width: 16),
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
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 16),
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
                    _buildInfoRow('Estado', producto.activo ? 'Activo' : 'Inactivo'),
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

  Widget _buildInfoCard(String title, String value, IconData icon, Color color, BuildContext context) {
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

  void _onMenuItemSelected(BuildContext context, WidgetRef ref, String value) {
    switch (value) {
      case 'editar':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EditarProductoScreen(producto: producto),
          ),
        );
        break;
      case 'eliminar':
        _mostrarDialogoEliminar(context, ref);
        break;
    }
  }

  void _mostrarDialogoEliminar(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text('¿Estás seguro de que deseas eliminar "${producto.nombre}"?'),
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
                  Navigator.of(context).pop();
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
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtro = ref.watch(filtroProductosProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtros de Productos',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Solo productos activos'),
            value: filtro.soloActivos ?? true,
            onChanged: (value) {
              ref.read(filtroProductosProvider.notifier).state = FiltroProductos(
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
            value: filtro.soloStockBajo ?? false,
            onChanged: (value) {
              ref.read(filtroProductosProvider.notifier).state = FiltroProductos(
                categoria: filtro.categoria,
                soloActivos: filtro.soloActivos,
                soloStockBajo: value,
                busqueda: filtro.busqueda,
                precioMinimo: filtro.precioMinimo,
                precioMaximo: filtro.precioMaximo,
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(filtroProductosProvider.notifier).state = FiltroProductos();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Limpiar Filtros'),
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
    );
  }
}
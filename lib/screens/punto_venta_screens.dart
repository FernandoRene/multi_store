import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'dart:math' as math;
import '../database/database.dart';
import '../models/database_models.dart';
import '../repositories/database_repositories.dart';
import 'productos_screens.dart'; // Import para acceder a productosFilteredProvider

// ===== MODELOS PARA EL CARRITO =====

class ItemCarrito {
  final Producto producto;
  int cantidad;
  double descuentoItem;

  ItemCarrito({
    required this.producto,
    this.cantidad = 1,
    this.descuentoItem = 0.0,
  });

  double get subtotal => (producto.precioVenta * cantidad) - descuentoItem;
  double get precioUnitario => producto.precioVenta;
}

class EstadoCarrito {
  final List<ItemCarrito> items;
  final double descuentoGeneral;
  final String? clienteId;

  EstadoCarrito({
    this.items = const [],
    this.descuentoGeneral = 0.0,
    this.clienteId,
  });

  double get subtotalSinDescuento => items.fold(
      0.0, (sum, item) => sum + (item.producto.precioVenta * item.cantidad));
  double get totalDescuentosItems =>
      items.fold(0.0, (sum, item) => sum + item.descuentoItem);
  double get subtotalConDescuentosItems =>
      subtotalSinDescuento - totalDescuentosItems;
  double get totalFinal => subtotalConDescuentosItems - descuentoGeneral;
  int get totalItems => items.fold(0, (sum, item) => sum + item.cantidad);
  bool get isEmpty => items.isEmpty;

  EstadoCarrito copyWith({
    List<ItemCarrito>? items,
    double? descuentoGeneral,
    String? clienteId,
  }) {
    return EstadoCarrito(
      items: items ?? this.items,
      descuentoGeneral: descuentoGeneral ?? this.descuentoGeneral,
      clienteId: clienteId ?? this.clienteId,
    );
  }
}

// ===== PROVIDERS PARA EL POS =====

final carritoProvider =
    StateNotifierProvider<CarritoNotifier, EstadoCarrito>((ref) {
  return CarritoNotifier();
});

final busquedaProductoPOSProvider = StateProvider<String>((ref) => '');

final metodoPagoSeleccionadoProvider =
    StateProvider<MetodoPago>((ref) => MetodoPago.efectivo);

final productosParaPOSProvider = FutureProvider<List<Producto>>((ref) async {
  final repository = ref.watch(productosRepositoryProvider);
  final busqueda = ref.watch(busquedaProductoPOSProvider);

  final filtro = FiltroProductos(
    busqueda: busqueda.trim().isEmpty ? null : busqueda.trim(),
    soloActivos: true,
  );

  return await repository.obtenerTodos(filtro: filtro);
});

// ===== NOTIFIER DEL CARRITO =====

class CarritoNotifier extends StateNotifier<EstadoCarrito> {
  CarritoNotifier() : super(EstadoCarrito());

  void agregarProducto(Producto producto, {int cantidad = 1}) {
    final items = List<ItemCarrito>.from(state.items);

    // Buscar si el producto ya está en el carrito
    final indexExistente =
        items.indexWhere((item) => item.producto.id == producto.id);

    if (indexExistente != -1) {
      // Si existe, aumentar cantidad
      items[indexExistente].cantidad += cantidad;
    } else {
      // Si no existe, agregar nuevo item
      items.add(ItemCarrito(producto: producto, cantidad: cantidad));
    }

    state = state.copyWith(items: items);
  }

  void quitarProducto(int productoId) {
    final items =
        state.items.where((item) => item.producto.id != productoId).toList();
    state = state.copyWith(items: items);
  }

  void actualizarCantidad(int productoId, int nuevaCantidad) {
    if (nuevaCantidad <= 0) {
      quitarProducto(productoId);
      return;
    }

    final items = state.items.map((item) {
      if (item.producto.id == productoId) {
        item.cantidad = nuevaCantidad;
      }
      return item;
    }).toList();

    state = state.copyWith(items: items);
  }

  void aplicarDescuentoItem(int productoId, double descuento) {
    final items = state.items.map((item) {
      if (item.producto.id == productoId) {
        item.descuentoItem = descuento;
      }
      return item;
    }).toList();

    state = state.copyWith(items: items);
  }

  void aplicarDescuentoGeneral(double descuento) {
    state = state.copyWith(descuentoGeneral: descuento);
  }

  void limpiarCarrito() {
    state = EstadoCarrito();
  }
}

// ===== 1. PANTALLA PRINCIPAL DEL POS =====

class PuntoVentaScreen extends ConsumerWidget {
  const PuntoVentaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carrito = ref.watch(carritoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Punto de Venta'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shopping_cart, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${carrito.totalItems}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          if (!carrito.isEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () => _mostrarDialogoLimpiarCarrito(context, ref),
              tooltip: 'Limpiar carrito',
            ),
        ],
      ),
      body: Column(
        children: [
          // Panel de productos
          Expanded(
            child: _buildPanelProductos(context, ref),
          ),
          // Espacio reducido para el bottom sheet
          if (!carrito.isEmpty)
            const SizedBox(height: 100), // Reducido de 120 a 100
        ],
      ),
      // Bottom sheet persistente
      bottomSheet: carrito.isEmpty
          ? null
          : _buildCarritoBottomSheet(context, ref, carrito),
    );
  }

  // PANEL DE PRODUCTOS
  Widget _buildPanelProductos(BuildContext context, WidgetRef ref) {
    final productos = ref.watch(productosParaPOSProvider);
    final busqueda = ref.watch(busquedaProductoPOSProvider);

    return Column(
      children: [
        // Barra de búsqueda CORREGIDA
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar productos...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (busqueda.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  ref
                                      .read(
                                          busquedaProductoPOSProvider.notifier)
                                      .state = '';
                                },
                              ),
                            IconButton(
                              icon: const Icon(Icons.qr_code_scanner),
                              onPressed: () => _simularEscaneoCodigoBarras(ref),
                              tooltip: 'Escanear código',
                            ),
                          ],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        ref.read(busquedaProductoPOSProvider.notifier).state =
                            value;
                      },
                      autofocus: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Tip informativo mejorado
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: busqueda.isEmpty ? Colors.green[50] : Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: busqueda.isEmpty
                          ? Colors.green[200]!
                          : Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      busqueda.isEmpty ? Icons.shopping_cart : Icons.search,
                      color: busqueda.isEmpty
                          ? Colors.green[600]
                          : Colors.blue[600],
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        busqueda.isEmpty
                            ? 'Mostrando todos los productos disponibles'
                            : 'Filtrando por: "$busqueda"',
                        style: TextStyle(
                          color: busqueda.isEmpty
                              ? Colors.green[600]
                              : Colors.blue[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Lista de productos con contador
        Expanded(
          child: productos.when(
            data: (listaProductos) {
              if (listaProductos.isEmpty) {
                return _buildEstadoVacio(busqueda);
              }

              return Column(
                children: [
                  // Contador de productos
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.inventory_2,
                            color: Colors.grey[600], size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '${listaProductos.length} productos ${busqueda.isEmpty ? 'disponibles' : 'encontrados'}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (busqueda.isNotEmpty) ...[
                          const Spacer(),
                          GestureDetector(
                            onTap: () => ref
                                .read(busquedaProductoPOSProvider.notifier)
                                .state = '',
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Ver todos',
                                style: TextStyle(
                                  color: Colors.orange[700],
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: listaProductos.length,
                      itemBuilder: (context, index) {
                        final producto = listaProductos[index];
                        return _buildProductoCard(context, ref, producto);
                      },
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando productos...'),
                ],
              ),
            ),
            error: (error, _) => _buildEstadoError(error),
          ),
        ),
      ],
    );
  }

  // PRODUCTO CARD
  Widget _buildProductoCard(
      BuildContext context, WidgetRef ref, Producto producto) {
    final stockBajo = producto.stockActual <= producto.stockMinimo;
    final sinStock = producto.stockActual <= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: sinStock ? null : () => _agregarAlCarrito(ref, producto),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Imagen placeholder
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: sinStock ? Colors.grey[300] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.inventory_2,
                  color: sinStock ? Colors.grey[500] : Colors.grey[600],
                  size: 30,
                ),
              ),

              const SizedBox(width: 16),

              // Información del producto
              Expanded(
                flex: 2, // Más espacio para el contenido
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre del producto
                    Text(
                      producto.nombre,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: sinStock ? Colors.grey : null,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Descripción (si existe)
                    if (producto.descripcion?.isNotEmpty == true) ...[
                      const SizedBox(height: 2),
                      Text(
                        producto.descripcion!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Chips de información - MEJORADO
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        // Categoría
                        Container(
                          constraints: const BoxConstraints(maxWidth: 100),
                          child: Chip(
                            label: Text(
                              producto.categoria,
                              style: const TextStyle(fontSize: 10),
                            ),
                            backgroundColor: Colors.blue[100],
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                          ),
                        ),

                        // Estado de stock
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: sinStock
                                ? Colors.red[100]
                                : stockBajo
                                    ? Colors.orange[100]
                                    : Colors.green[100],
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: sinStock
                                  ? Colors.red[300]!
                                  : stockBajo
                                      ? Colors.orange[300]!
                                      : Colors.green[300]!,
                            ),
                          ),
                          child: Text(
                            sinStock
                                ? 'SIN STOCK'
                                : 'Stock: ${producto.stockActual}',
                            style: TextStyle(
                              color: sinStock
                                  ? Colors.red[700]
                                  : stockBajo
                                      ? Colors.orange[700]
                                      : Colors.green[700],
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Precio y botón
              Container(
                width: 120, // Ancho fijo generoso
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Precio
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: sinStock ? Colors.grey[100] : Colors.green[50],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color:
                              sinStock ? Colors.grey[300]! : Colors.green[200]!,
                        ),
                      ),
                      child: Text(
                        'Bs. ${producto.precioVenta.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              sinStock ? Colors.grey[600] : Colors.green[700],
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Botón agregar - MEJORADO
                    SizedBox(
                      width: double.infinity,
                      height: 32, // Altura fija más pequeña
                      child: ElevatedButton.icon(
                        onPressed: sinStock
                            ? null
                            : () => _agregarAlCarrito(ref, producto),
                        icon: const Icon(Icons.add_shopping_cart, size: 14),
                        label: const Text(
                          'Agregar',
                          style: TextStyle(fontSize: 11),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              sinStock ? Colors.grey[300] : Colors.green[600],
                          foregroundColor:
                              sinStock ? Colors.grey[600] : Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: sinStock ? 0 : 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // BOTTOM SHEET
  Widget _buildCarritoBottomSheet(
      BuildContext context, WidgetRef ref, EstadoCarrito carrito) {
    return Container(
      height: 80, // Muy compacto
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Info compacta
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.shopping_cart,
              color: Colors.green[700],
              size: 16,
            ),
          ),
          const SizedBox(width: 8),

          // Información
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${carrito.totalItems} item${carrito.totalItems == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Bs. ${carrito.totalFinal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),

          // Botones apilados verticalmente
          Column(
            children: [
              SizedBox(
                width: 100,
                height: 28,
                child: OutlinedButton(
                  onPressed: () => _mostrarCarritoCompleto(context, ref),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green[600],
                    side: BorderSide(color: Colors.green[600]!),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('Ver', style: TextStyle(fontSize: 10)),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 100,
                height: 28,
                child: ElevatedButton(
                  onPressed: () => _irAProcesarPago(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('Procesar', style: TextStyle(fontSize: 10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ESTADOS VACÍO Y ERROR MEJORADOS
  Widget _buildEstadoVacio(String busqueda) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              busqueda.isNotEmpty
                  ? Icons.search_off
                  : Icons.shopping_cart_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              busqueda.isNotEmpty
                  ? 'No se encontraron productos'
                  : 'Busca productos para agregar',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              busqueda.isNotEmpty
                  ? 'Intenta con otro término de búsqueda'
                  : 'Usa la barra de búsqueda o el escáner',
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

  Widget _buildEstadoError(Object error) {
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
                fontSize: 16,
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
          ],
        ),
      ),
    );
  }

  // MODAL DEL CARRITO
  void _mostrarCarritoCompleto(BuildContext context, WidgetRef ref) {
    final carrito = ref.watch(carritoProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
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
                  const Icon(Icons.shopping_cart),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Carrito (${carrito.totalItems} items)',
                      style: const TextStyle(
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

            // Lista de items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: carrito.items.length,
                itemBuilder: (context, index) {
                  final item = carrito.items[index];
                  return _buildItemCarrito(context, ref, item);
                },
              ),
            ),

            // Totales y botones
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Column(
                children: [
                  _buildFilaTotales('Subtotal:',
                      'Bs. ${carrito.subtotalSinDescuento.toStringAsFixed(2)}'),
                  if (carrito.totalDescuentosItems > 0)
                    _buildFilaTotales(
                      'Desc. items:',
                      '-Bs. ${carrito.totalDescuentosItems.toStringAsFixed(2)}',
                      color: Colors.red[600],
                    ),
                  if (carrito.descuentoGeneral > 0)
                    _buildFilaTotales(
                      'Desc. general:',
                      '-Bs. ${carrito.descuentoGeneral.toStringAsFixed(2)}',
                      color: Colors.red[600],
                    ),
                  const Divider(),
                  _buildFilaTotales(
                    'TOTAL:',
                    'Bs. ${carrito.totalFinal.toStringAsFixed(2)}',
                    isTotal: true,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _mostrarDialogoDescuento(context, ref),
                          icon: const Icon(Icons.percent, size: 16),
                          label: const Text('Descuento'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _irAProcesarPago(context, ref);
                          },
                          icon: const Icon(Icons.payment),
                          label: const Text('PROCESAR VENTA'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ITEM DEL CARRITO
  Widget _buildItemCarrito(
      BuildContext context, WidgetRef ref, ItemCarrito item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del item
            Row(
              children: [
                // Información del producto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.producto.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Bs. ${item.precioUnitario.toStringAsFixed(2)} c/u',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Botón eliminar
                SizedBox(
                  width: 32,
                  height: 32,
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => ref
                        .read(carritoProvider.notifier)
                        .quitarProducto(item.producto.id),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Controles de cantidad y subtotal
            Row(
              children: [
                // Controles de cantidad
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botón menos
                      InkWell(
                        onTap: () => ref
                            .read(carritoProvider.notifier)
                            .actualizarCantidad(
                                item.producto.id, item.cantidad - 1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.remove, size: 16),
                        ),
                      ),
                      // Cantidad
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.symmetric(
                            vertical: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: Text(
                          item.cantidad.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      // Botón más
                      InkWell(
                        onTap: item.cantidad < item.producto.stockActual
                            ? () => ref
                                .read(carritoProvider.notifier)
                                .actualizarCantidad(
                                    item.producto.id, item.cantidad + 1)
                            : null,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.add,
                            size: 16,
                            color: item.cantidad < item.producto.stockActual
                                ? null
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Subtotal
                Text(
                  'Bs. ${item.subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            // Descuento por item (si existe)
            if (item.descuentoItem > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Descuento: -Bs. ${item.descuentoItem.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.red[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // HELPER PARA FILAS DE TOTALES
  Widget _buildFilaTotales(String label, String valor,
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

  // MÉTODOS DE ACCIÓN (SIN CAMBIOS FUNCIONALES)
  void _agregarAlCarrito(WidgetRef ref, Producto producto) {
    ref.read(carritoProvider.notifier).agregarProducto(producto);
    HapticFeedback.lightImpact();
  }

  void _simularEscaneoCodigoBarras(WidgetRef ref) {
    final codigosDemo = ['7501234567890', '7501234567891'];
    final codigoRandom = codigosDemo[math.Random().nextInt(codigosDemo.length)];

    ref.read(busquedaProductoPOSProvider.notifier).state = codigoRandom;
    HapticFeedback.mediumImpact();
  }

  void _mostrarDialogoDescuento(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aplicar Descuento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Descuento en Bs.',
                prefixText: 'Bs. ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final descuento = double.tryParse(controller.text) ?? 0.0;
              if (descuento >= 0) {
                ref
                    .read(carritoProvider.notifier)
                    .aplicarDescuentoGeneral(descuento);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoLimpiarCarrito(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar Carrito'),
        content: const Text('¿Estás seguro de que deseas limpiar el carrito?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(carritoProvider.notifier).limpiarCarrito();
              Navigator.of(context).pop();
            },
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }

  void _irAProcesarPago(BuildContext context, WidgetRef ref) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProcesarPagoScreen(),
      ),
    );
  }
}

// ===== 2. PANTALLA PROCESAR PAGO =====

class ProcesarPagoScreen extends ConsumerStatefulWidget {
  const ProcesarPagoScreen({super.key});

  @override
  ConsumerState<ProcesarPagoScreen> createState() => _ProcesarPagoScreenState();
}

class _ProcesarPagoScreenState extends ConsumerState<ProcesarPagoScreen> {
  bool _procesando = false;
  double? _latitud;
  double? _longitud;

  @override
  void initState() {
    super.initState();
    _obtenerUbicacion();
  }

  Future<void> _obtenerUbicacion() async {
    // Simulación de geolocalización - en producción usarías geolocator
    setState(() {
      _latitud = -16.5000 +
          (math.Random().nextDouble() - 0.5) * 0.01; // La Paz, Bolivia
      _longitud = -68.1500 + (math.Random().nextDouble() - 0.5) * 0.01;
    });
  }

  @override
  Widget build(BuildContext context) {
    final carrito = ref.watch(carritoProvider);
    final metodoPago = ref.watch(metodoPagoSeleccionadoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Procesar Pago'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resumen de la venta - RESPONSIVE
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.receipt_long, color: Colors.green[600]),
                          const SizedBox(width: 8),
                          Text(
                            'Resumen de la Venta',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Items de la venta - MEJORADO
                      Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: SingleChildScrollView(
                          child: Column(
                            children: carrito.items
                                .map((item) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: Colors.blue[100],
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${item.cantidad}x',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue[700],
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.producto.nombre,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  'Bs. ${item.precioUnitario.toStringAsFixed(2)} c/u',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                'Bs. ${item.subtotal.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (item.descuentoItem > 0)
                                                Text(
                                                  '-Bs. ${item.descuentoItem.toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.red[600],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),

                      const Divider(),
                      _buildFilaResumen('Subtotal:',
                          'Bs. ${carrito.subtotalSinDescuento.toStringAsFixed(2)}'),
                      if (carrito.totalDescuentosItems > 0)
                        _buildFilaResumen(
                          'Descuentos items:',
                          '-Bs. ${carrito.totalDescuentosItems.toStringAsFixed(2)}',
                          color: Colors.red[600],
                        ),
                      if (carrito.descuentoGeneral > 0)
                        _buildFilaResumen(
                          'Descuento general:',
                          '-Bs. ${carrito.descuentoGeneral.toStringAsFixed(2)}',
                          color: Colors.red[600],
                        ),
                      const Divider(thickness: 2),
                      _buildFilaResumen(
                        'TOTAL A PAGAR:',
                        'Bs. ${carrito.totalFinal.toStringAsFixed(2)}',
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Método de pago - MEJORADO
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.payment, color: Colors.blue[600]),
                          const SizedBox(width: 8),
                          Text(
                            'Método de Pago',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // RESPONSIVE PARA MÉTODOS DE PAGO
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 400) {
                            // Layout vertical para pantallas pequeñas
                            return Column(
                              children: MetodoPago.values
                                  .map((metodo) => Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: metodoPago == metodo
                                                ? Colors.green[300]!
                                                : Colors.grey[300]!,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: metodoPago == metodo
                                              ? Colors.green[50]
                                              : null,
                                        ),
                                        child: RadioListTile<MetodoPago>(
                                          title: Row(
                                            children: [
                                              Icon(
                                                _getIconoMetodoPago(metodo),
                                                color: metodoPago == metodo
                                                    ? Colors.green[600]
                                                    : Colors.grey[600],
                                              ),
                                              const SizedBox(width: 8),
                                              Text(metodo.displayName),
                                            ],
                                          ),
                                          value: metodo,
                                          groupValue: metodoPago,
                                          onChanged: (value) {
                                            ref
                                                .read(
                                                    metodoPagoSeleccionadoProvider
                                                        .notifier)
                                                .state = value!;
                                          },
                                          activeColor: Colors.green[600],
                                        ),
                                      ))
                                  .toList(),
                            );
                          } else {
                            // Layout en grid para pantallas grandes
                            return GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              childAspectRatio: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              children: MetodoPago.values
                                  .map((metodo) => Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: metodoPago == metodo
                                                ? Colors.green[300]!
                                                : Colors.grey[300]!,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: metodoPago == metodo
                                              ? Colors.green[50]
                                              : null,
                                        ),
                                        child: RadioListTile<MetodoPago>(
                                          title: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                _getIconoMetodoPago(metodo),
                                                size: 16,
                                                color: metodoPago == metodo
                                                    ? Colors.green[600]
                                                    : Colors.grey[600],
                                              ),
                                              const SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  metodo.displayName,
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          value: metodo,
                                          groupValue: metodoPago,
                                          onChanged: (value) {
                                            ref
                                                .read(
                                                    metodoPagoSeleccionadoProvider
                                                        .notifier)
                                                .state = value!;
                                          },
                                          activeColor: Colors.green[600],
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8),
                                        ),
                                      ))
                                  .toList(),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Información de ubicación - COMPACTA
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: Colors.blue[600],
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ubicación de la Venta',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            if (_latitud != null && _longitud != null)
                              Text(
                                'La Paz, Bolivia',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              )
                            else
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Obteniendo ubicación...',
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
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Botón de finalizar venta - RESPONSIVE
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _procesando ? null : _finalizarVenta,
                  icon: _procesando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_circle, size: 24),
                  label:
                      Text(_procesando ? 'PROCESANDO...' : 'FINALIZAR VENTA'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              // Espacio extra para navegación
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilaResumen(String label, String valor,
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

  IconData _getIconoMetodoPago(MetodoPago metodo) {
    switch (metodo) {
      case MetodoPago.efectivo:
        return Icons.money;
      case MetodoPago.tarjeta:
        return Icons.credit_card;
      case MetodoPago.transferencia:
        return Icons.account_balance;
      case MetodoPago.qr:
        return Icons.qr_code;
      case MetodoPago.mixto:
        return Icons.payments;
    }
  }

  Future<void> _finalizarVenta() async {
    setState(() {
      _procesando = true;
    });

    try {
      final carrito = ref.read(carritoProvider);
      final metodoPago = ref.read(metodoPagoSeleccionadoProvider);
      final ventasRepository = ref.read(ventasRepositoryProvider);

      // Crear la venta completa
      final detalles = carrito.items
          .map((item) => DetalleVentaCompleto(
                id: 0, // Se asignará en la base de datos
                ventaId: 0, // Se asignará en la base de datos
                productoId: item.producto.id,
                cantidad: item.cantidad,
                precioUnitario: item.precioUnitario,
                subtotal: item.subtotal,
                descuentoItem: item.descuentoItem,
                nombreProducto: item.producto.nombre,
                codigoBarras: item.producto.codigoBarras,
                categoria: item.producto.categoria,
                unidadMedida: item.producto.unidadMedida,
              ))
          .toList();

      final ventaCompleta = VentaCompleta(
        id: 0, // Se asignará en la base de datos
        fechaVenta: DateTime.now(),
        totalVenta: carrito.totalFinal,
        metodoPago: metodoPago.name,
        clienteId: null,
        usuarioId: '1', // Usuario demo
        descuentoAplicado: carrito.descuentoGeneral,
        latitud: _latitud,
        longitud: _longitud,
        direccionAproximada: 'La Paz, Bolivia',
        zonaGeografica: 'Zona Sur',
        sincronizadoNube: false,
        fechaSincronizacion: null,
        tiendaId: 'tienda_001',
        detalles: detalles,
      );

      // Insertar la venta
      final ventaId =
          await ventasRepository.insertarVentaCompleta(ventaCompleta);

      if (mounted) {
        // Limpiar carrito
        ref.read(carritoProvider.notifier).limpiarCarrito();

        // Actualizar datos
        ref.refresh(productosFilteredProvider);
        ref.refresh(estadisticasProvider);

        // Crear nueva instancia con ID actualizado
        final ventaFinalizada = VentaCompleta(
          id: ventaId,
          fechaVenta: ventaCompleta.fechaVenta,
          totalVenta: ventaCompleta.totalVenta,
          metodoPago: ventaCompleta.metodoPago,
          clienteId: ventaCompleta.clienteId,
          usuarioId: ventaCompleta.usuarioId,
          descuentoAplicado: ventaCompleta.descuentoAplicado,
          latitud: ventaCompleta.latitud,
          longitud: ventaCompleta.longitud,
          direccionAproximada: ventaCompleta.direccionAproximada,
          zonaGeografica: ventaCompleta.zonaGeografica,
          sincronizadoNube: ventaCompleta.sincronizadoNube,
          fechaSincronizacion: ventaCompleta.fechaSincronizacion,
          tiendaId: ventaCompleta.tiendaId,
          detalles: ventaCompleta.detalles,
        );

        // Ir a pantalla de recibo
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ReciboScreen(
              ventaId: ventaId,
              ventaCompleta: ventaFinalizada,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar la venta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _procesando = false;
        });
      }
    }
  }
}

// ===== 3. PANTALLA DE RECIBO =====

class ReciboScreen extends ConsumerWidget {
  final int ventaId;
  final VentaCompleta ventaCompleta;

  const ReciboScreen({
    super.key,
    required this.ventaId,
    required this.ventaCompleta,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recibo de Venta'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _cerrarRecibo(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Recibo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header de la tienda
                  Icon(
                    Icons.store,
                    size: 48,
                    color: Colors.green[600],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'TIENDA PRINCIPAL',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Sistema de Inventario Multi-tienda',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '✅ VENTA EXITOSA',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Información de la venta
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                            'Venta #:', ventaId.toString().padLeft(6, '0')),
                        _buildInfoRow('Fecha:',
                            _formatearFecha(ventaCompleta.fechaVenta)),
                        _buildInfoRow(
                            'Hora:', _formatearHora(ventaCompleta.fechaVenta)),
                        _buildInfoRow('Método de Pago:',
                            _getMetodoPagoDisplay(ventaCompleta.metodoPago)),
                        if (ventaCompleta.latitud != null &&
                            ventaCompleta.longitud != null)
                          _buildInfoRow('Ubicación:',
                              '${ventaCompleta.latitud!.toStringAsFixed(4)}, ${ventaCompleta.longitud!.toStringAsFixed(4)}'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Detalles de productos
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'PRODUCTOS',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  ...ventaCompleta.detalles.map((detalle) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 30,
                              child: Text(
                                '${detalle.cantidad}x',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
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
                                    'Bs. ${detalle.precioUnitario.toStringAsFixed(2)} c/u',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'Bs. ${detalle.subtotal.toStringAsFixed(2)}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      )),

                  const Divider(thickness: 2),

                  // Totales
                  _buildTotalRow('Subtotal:',
                      'Bs. ${ventaCompleta.subtotal.toStringAsFixed(2)}'),

                  if (ventaCompleta.totalDescuento > 0)
                    _buildTotalRow(
                      'Descuentos:',
                      '-Bs. ${ventaCompleta.totalDescuento.toStringAsFixed(2)}',
                      color: Colors.red[600],
                    ),

                  const SizedBox(height: 8),

                  _buildTotalRow(
                    'TOTAL PAGADO:',
                    'Bs. ${ventaCompleta.totalVenta.toStringAsFixed(2)}',
                    isTotal: true,
                  ),

                  const SizedBox(height: 24),

                  // Footer
                  Text(
                    '¡Gracias por su compra!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Conserve este recibo como comprobante',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Código QR simulado
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.qr_code,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Código de verificación',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _compartirRecibo(context),
                    icon: const Icon(Icons.share),
                    label: const Text('Compartir'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _nuevaVenta(context),
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Nueva Venta'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
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

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  String _formatearHora(DateTime fecha) {
    return '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
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

  void _compartirRecibo(BuildContext context) {
    // En producción, aquí implementarías compartir el recibo
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de compartir próximamente'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _nuevaVenta(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const PuntoVentaScreen()),
      (route) => route.isFirst,
    );
  }

  void _cerrarRecibo(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

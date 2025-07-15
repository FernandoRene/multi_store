import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../database/database.dart';
import '../models/database_models.dart';

// ===== PROVIDER PRINCIPAL DE LA BASE DE DATOS =====

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

// ===== REPOSITORIO DE PRODUCTOS =====

class ProductosRepository {
  final AppDatabase _database;
  
  ProductosRepository(this._database);

  // Obtener todos los productos
  Future<List<Producto>> obtenerTodos({FiltroProductos? filtro}) async {
    final query = _database.select(_database.productos);
    
    if (filtro != null) {
      query.where((p) {
        Expression<bool>? condicion;
        
        if (filtro.categoria != null) {
          condicion = p.categoria.equals(filtro.categoria!);
        }
        
        if (filtro.soloActivos == true) {
          condicion = condicion == null 
              ? p.activo.equals(true)
              : condicion & p.activo.equals(true);
        }
        
        if (filtro.soloStockBajo == true) {
          condicion = condicion == null 
              ? p.stockActual.isSmallerOrEqual(p.stockMinimo)
              : condicion & p.stockActual.isSmallerOrEqual(p.stockMinimo);
        }
        
        if (filtro.busqueda != null && filtro.busqueda!.isNotEmpty) {
          final busqueda = '%${filtro.busqueda!}%';
          final busquedaCondicion = p.nombre.like(busqueda) | 
              p.descripcion.like(busqueda) |
              p.codigoBarras.like(busqueda);
          condicion = condicion == null 
              ? busquedaCondicion
              : condicion & busquedaCondicion;
        }
        
        if (filtro.precioMinimo != null) {
          condicion = condicion == null 
              ? p.precioVenta.isBiggerOrEqualValue(filtro.precioMinimo!)
              : condicion & p.precioVenta.isBiggerOrEqualValue(filtro.precioMinimo!);
        }
        
        if (filtro.precioMaximo != null) {
          condicion = condicion == null 
              ? p.precioVenta.isSmallerOrEqualValue(filtro.precioMaximo!)
              : condicion & p.precioVenta.isSmallerOrEqualValue(filtro.precioMaximo!);
        }
        
        return condicion ?? const Constant(true);
      });
    }
    
    query.orderBy([(p) => OrderingTerm.asc(p.nombre)]);
    return await query.get();
  }

  // Obtener producto por ID
  Future<Producto?> obtenerPorId(int id) async {
    final query = _database.select(_database.productos)..where((p) => p.id.equals(id));
    return await query.getSingleOrNull();
  }

  // Buscar producto por código de barras
  Future<Producto?> obtenerPorCodigoBarras(String codigoBarras) async {
    final query = _database.select(_database.productos)
        ..where((p) => p.codigoBarras.equals(codigoBarras));
    return await query.getSingleOrNull();
  }

  // Obtener productos con stock bajo
  Future<List<AlertaStock>> obtenerProductosStockBajo() async {
    final query = _database.select(_database.productos)
        ..where((p) => p.stockActual.isSmallerOrEqual(p.stockMinimo) & p.activo.equals(true));
    
    final productos = await query.get();
    
    return productos.map((p) {
      final diasParaAgotarse = p.stockActual > 0 ? p.stockActual / 1.0 : 0.0;
      NivelAlerta nivel;
      
      if (p.stockActual == 0) {
        nivel = NivelAlerta.critico;
      } else if (p.stockActual < p.stockMinimo * 0.5) {
        nivel = NivelAlerta.bajo;
      } else {
        nivel = NivelAlerta.medio;
      }
      
      return AlertaStock(
        productoId: p.id,
        nombreProducto: p.nombre,
        categoria: p.categoria,
        stockActual: p.stockActual,
        stockMinimo: p.stockMinimo,
        diasParaAgotarse: diasParaAgotarse,
        nivel: nivel,
        fechaCalculada: DateTime.now(),
      );
    }).toList();
  }

  // Insertar producto
  Future<int> insertar(ProductosCompanion producto) async {
    return await _database.into(_database.productos).insert(producto);
  }

  // Actualizar producto
  Future<bool> actualizar(int id, ProductosCompanion producto) async {
    return await (_database.update(_database.productos)..where((p) => p.id.equals(id)))
        .write(producto) > 0;
  }

  // Eliminar producto (marcar como inactivo)
  Future<bool> eliminar(int id) async {
    return await (_database.update(_database.productos)..where((p) => p.id.equals(id)))
        .write(const ProductosCompanion(activo: Value(false))) > 0;
  }

  // Actualizar stock
  Future<bool> actualizarStock(int productoId, int nuevoStock) async {
    return await (_database.update(_database.productos)..where((p) => p.id.equals(productoId)))
        .write(ProductosCompanion(stockActual: Value(nuevoStock))) > 0;
  }

  // Obtener categorías únicas
  Future<List<String>> obtenerCategorias() async {
    final query = _database.selectOnly(_database.productos)
        ..addColumns([_database.productos.categoria])
        ..groupBy([_database.productos.categoria])
        ..where(_database.productos.activo.equals(true));
    
    final result = await query.get();
    return result.map((row) => row.read(_database.productos.categoria)!).toList();
  }

  // ESTADÍSTICAS CORREGIDAS - SIN AGREGACIONES COMPLEJAS
  Future<EstadisticasGenerales> obtenerEstadisticas() async {
    try {
      print('📊 Obteniendo estadísticas...');
      
      // Obtener todos los productos para calcular estadísticas manualmente
      final todosProductos = await _database.select(_database.productos).get();
      final productosActivos = todosProductos.where((p) => p.activo).toList();
      final productosStockBajo = productosActivos.where((p) => p.stockActual <= p.stockMinimo).toList();
      
      // Calcular valor del inventario manualmente
      double valorInventario = 0.0;
      for (final producto in productosActivos) {
        valorInventario += producto.stockActual * producto.precioCompra;
      }
      
      // Obtener ventas de hoy
      final hoy = DateTime.now();
      final inicioHoy = DateTime(hoy.year, hoy.month, hoy.day);
      final ventasHoy = await (_database.select(_database.ventas)
            ..where((v) => v.fechaVenta.isBiggerOrEqualValue(inicioHoy)))
          .get();
      
      double totalVentasHoy = 0.0;
      for (final venta in ventasHoy) {
        totalVentasHoy += venta.totalVenta;
      }

      // Ventas del mes
      final inicioMes = DateTime(hoy.year, hoy.month, 1);
      final ventasMes = await (_database.select(_database.ventas)
            ..where((v) => v.fechaVenta.isBiggerOrEqualValue(inicioMes)))
          .get();
      
      double totalVentasMes = 0.0;
      for (final venta in ventasMes) {
        totalVentasMes += venta.totalVenta;
      }

      // Ventas pendientes de sincronización
      final ventasPendientes = await (_database.select(_database.ventas)
            ..where((v) => v.sincronizadoNube.equals(false)))
          .get();

      print('✅ Estadísticas calculadas correctamente');
      
      return EstadisticasGenerales(
        totalProductos: todosProductos.length,
        productosActivos: productosActivos.length,
        productosStockBajo: productosStockBajo.length,
        valorTotalInventario: valorInventario,
        ventasHoy: totalVentasHoy,
        ventasEsteMes: totalVentasMes,
        ventasPendientesSincronizacion: ventasPendientes.length,
        fechaUltimaActualizacion: DateTime.now(),
      );
    } catch (e, stack) {
      print('🚨 Error al obtener estadísticas: $e');
      print('📍 Stack trace: $stack');
      
      // Retornar estadísticas por defecto en caso de error
      return EstadisticasGenerales(
        totalProductos: 0,
        productosActivos: 0,
        productosStockBajo: 0,
        valorTotalInventario: 0.0,
        ventasHoy: 0.0,
        ventasEsteMes: 0.0,
        ventasPendientesSincronizacion: 0,
        fechaUltimaActualizacion: DateTime.now(),
      );
    }
  }
}

// ===== REPOSITORIO DE VENTAS =====

class VentasRepository {
  final AppDatabase _database;
  
  VentasRepository(this._database);

  // Insertar venta completa
  Future<int> insertarVentaCompleta(VentaCompleta ventaCompleta) async {
    return await _database.transaction(() async {
      // Insertar la venta
      final ventaId = await _database.into(_database.ventas).insert(VentasCompanion(
        fechaVenta: Value(ventaCompleta.fechaVenta),
        totalVenta: Value(ventaCompleta.totalVenta),
        metodoPago: Value(ventaCompleta.metodoPago),
        clienteId: Value(ventaCompleta.clienteId),
        usuarioId: Value(ventaCompleta.usuarioId),
        descuentoAplicado: Value(ventaCompleta.descuentoAplicado),
        latitud: Value(ventaCompleta.latitud),
        longitud: Value(ventaCompleta.longitud),
        direccionAproximada: Value(ventaCompleta.direccionAproximada),
        zonaGeografica: Value(ventaCompleta.zonaGeografica),
        tiendaId: Value(ventaCompleta.tiendaId),
      ));

      // Insertar los detalles
      for (final detalle in ventaCompleta.detalles) {
        await _database.into(_database.detalleVentas).insert(DetalleVentasCompanion(
          ventaId: Value(ventaId),
          productoId: Value(detalle.productoId),
          cantidad: Value(detalle.cantidad),
          precioUnitario: Value(detalle.precioUnitario),
          subtotal: Value(detalle.subtotal),
          descuentoItem: Value(detalle.descuentoItem),
        ));

        // Actualizar stock del producto
        final productoActual = await (_database.select(_database.productos)
            ..where((p) => p.id.equals(detalle.productoId))).getSingle();
        
        await (_database.update(_database.productos)..where((p) => p.id.equals(detalle.productoId)))
            .write(ProductosCompanion(
          stockActual: Value(productoActual.stockActual - detalle.cantidad),
        ));
      }

      return ventaId;
    });
  }

  // Obtener ventas con filtros
  Future<List<VentaCompleta>> obtenerVentas({FiltroVentas? filtro}) async {
    try {
      final query = _database.select(_database.ventas);
      
      if (filtro != null) {
        query.where((v) {
          Expression<bool>? condicion;
          
          if (filtro.fechaInicio != null) {
            condicion = v.fechaVenta.isBiggerOrEqualValue(filtro.fechaInicio!);
          }
          
          if (filtro.fechaFin != null) {
            condicion = condicion == null 
                ? v.fechaVenta.isSmallerOrEqualValue(filtro.fechaFin!)
                : condicion & v.fechaVenta.isSmallerOrEqualValue(filtro.fechaFin!);
          }
          
          if (filtro.usuarioId != null) {
            condicion = condicion == null 
                ? v.usuarioId.equals(filtro.usuarioId!)
                : condicion & v.usuarioId.equals(filtro.usuarioId!);
          }
          
          if (filtro.metodoPago != null) {
            condicion = condicion == null 
                ? v.metodoPago.equals(filtro.metodoPago!)
                : condicion & v.metodoPago.equals(filtro.metodoPago!);
          }
          
          if (filtro.soloSincronizadas != null) {
            condicion = condicion == null 
                ? v.sincronizadoNube.equals(filtro.soloSincronizadas!)
                : condicion & v.sincronizadoNube.equals(filtro.soloSincronizadas!);
          }
          
          return condicion ?? const Constant(true);
        });
      }
      
      query.orderBy([(v) => OrderingTerm.desc(v.fechaVenta)]);
      final ventas = await query.get();
      
      // Cargar detalles para cada venta
      final ventasCompletas = <VentaCompleta>[];
      for (final venta in ventas) {
        final detalles = await obtenerDetallesVenta(venta.id);
        ventasCompletas.add(VentaCompleta(
          id: venta.id,
          fechaVenta: venta.fechaVenta,
          totalVenta: venta.totalVenta,
          metodoPago: venta.metodoPago,
          clienteId: venta.clienteId,
          usuarioId: venta.usuarioId,
          descuentoAplicado: venta.descuentoAplicado,
          latitud: venta.latitud,
          longitud: venta.longitud,
          direccionAproximada: venta.direccionAproximada,
          zonaGeografica: venta.zonaGeografica,
          sincronizadoNube: venta.sincronizadoNube,
          fechaSincronizacion: venta.fechaSincronizacion,
          tiendaId: venta.tiendaId,
          detalles: detalles,
        ));
      }
      
      return ventasCompletas;
    } catch (e) {
      print('Error al obtener ventas: $e');
      return [];
    }
  }

  // Obtener detalles de una venta
  Future<List<DetalleVentaCompleto>> obtenerDetallesVenta(int ventaId) async {
    try {
      final query = _database.select(_database.detalleVentas).join([
        leftOuterJoin(_database.productos, _database.productos.id.equalsExp(_database.detalleVentas.productoId))
      ])..where(_database.detalleVentas.ventaId.equals(ventaId));
      
      final result = await query.get();
      
      return result.map((row) {
        final detalle = row.readTable(_database.detalleVentas);
        final producto = row.readTable(_database.productos);
        
        return DetalleVentaCompleto(
          id: detalle.id,
          ventaId: detalle.ventaId,
          productoId: detalle.productoId,
          cantidad: detalle.cantidad,
          precioUnitario: detalle.precioUnitario,
          subtotal: detalle.subtotal,
          descuentoItem: detalle.descuentoItem,
          nombreProducto: producto.nombre,
          codigoBarras: producto.codigoBarras,
          categoria: producto.categoria,
          unidadMedida: producto.unidadMedida,
        );
      }).toList();
    } catch (e) {
      print('Error al obtener detalles de venta: $e');
      return [];
    }
  }

  // Marcar venta como sincronizada
  Future<bool> marcarComoSincronizada(int ventaId) async {
    return await (_database.update(_database.ventas)..where((v) => v.id.equals(ventaId)))
        .write(VentasCompanion(
          sincronizadoNube: const Value(true),
          fechaSincronizacion: Value(DateTime.now()),
        )) > 0;
  }

  // Obtener ventas pendientes de sincronización
  Future<List<VentaCompleta>> obtenerVentasPendientesSincronizacion() async {
    return await obtenerVentas(
      filtro: FiltroVentas(soloSincronizadas: false),
    );
  }
}

// ===== PROVIDERS DE REPOSITORIOS =====

final productosRepositoryProvider = Provider<ProductosRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return ProductosRepository(database);
});

final ventasRepositoryProvider = Provider<VentasRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return VentasRepository(database);
});

// ===== PROVIDERS DE ESTADO =====

final productosProvider = FutureProvider.family<List<Producto>, FiltroProductos?>((ref, filtro) async {
  final repository = ref.watch(productosRepositoryProvider);
  return await repository.obtenerTodos(filtro: filtro);
});

final ventasProvider = FutureProvider.family<List<VentaCompleta>, FiltroVentas?>((ref, filtro) async {
  final repository = ref.watch(ventasRepositoryProvider);
  return await repository.obtenerVentas(filtro: filtro);
});

final estadisticasProvider = FutureProvider<EstadisticasGenerales>((ref) async {
  final repository = ref.watch(productosRepositoryProvider);
  return await repository.obtenerEstadisticas();
});

final alertasStockProvider = FutureProvider<List<AlertaStock>>((ref) async {
  final repository = ref.watch(productosRepositoryProvider);
  return await repository.obtenerProductosStockBajo();
});

final categoriasProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(productosRepositoryProvider);
  return await repository.obtenerCategorias();
});
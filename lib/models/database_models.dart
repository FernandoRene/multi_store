// ===== ENUMS =====

enum TipoMovimiento {
  entrada,
  salida,
  ajuste,
  devolucion;

  String get displayName {
    switch (this) {
      case TipoMovimiento.entrada:
        return 'Entrada';
      case TipoMovimiento.salida:
        return 'Salida';
      case TipoMovimiento.ajuste:
        return 'Ajuste';
      case TipoMovimiento.devolucion:
        return 'Devolución';
    }
  }
}

enum MetodoPago {
  efectivo,
  tarjeta,
  transferencia,
  qr,
  mixto;

  String get displayName {
    switch (this) {
      case MetodoPago.efectivo:
        return 'Efectivo';
      case MetodoPago.tarjeta:
        return 'Tarjeta';
      case MetodoPago.transferencia:
        return 'Transferencia';
      case MetodoPago.qr:
        return 'QR';
      case MetodoPago.mixto:
        return 'Mixto';
    }
  }
}

enum RolUsuario {
  vendedor,
  gerente,
  admin;

  String get displayName {
    switch (this) {
      case RolUsuario.vendedor:
        return 'Vendedor';
      case RolUsuario.gerente:
        return 'Gerente';
      case RolUsuario.admin:
        return 'Administrador';
    }
  }
}

enum EstadoSincronizacion {
  pendiente,
  sincronizado,
  error;

  String get displayName {
    switch (this) {
      case EstadoSincronizacion.pendiente:
        return 'Pendiente';
      case EstadoSincronizacion.sincronizado:
        return 'Sincronizado';
      case EstadoSincronizacion.error:
        return 'Error';
    }
  }
}

enum NivelAlerta {
  critico,
  bajo,
  medio,
  normal;

  String get displayName {
    switch (this) {
      case NivelAlerta.critico:
        return 'Crítico';
      case NivelAlerta.bajo:
        return 'Bajo';
      case NivelAlerta.medio:
        return 'Medio';
      case NivelAlerta.normal:
        return 'Normal';
    }
  }
}

// ===== MODELOS AUXILIARES =====

class ProductoConStock {
  final int id;
  final String? codigoBarras;
  final String nombre;
  final String? descripcion;
  final String categoria;
  final double precioVenta;
  final double precioCompra;
  final double? margenGanancia;
  final int stockActual;
  final int stockMinimo;
  final String unidadMedida;
  final DateTime fechaCreacion;
  final bool activo;
  final String tiendaId;
  
  // Campos calculados
  final bool stockBajo;
  final double valorInventario;
  final double margenReal;

  ProductoConStock({
    required this.id,
    this.codigoBarras,
    required this.nombre,
    this.descripcion,
    required this.categoria,
    required this.precioVenta,
    required this.precioCompra,
    this.margenGanancia,
    required this.stockActual,
    required this.stockMinimo,
    required this.unidadMedida,
    required this.fechaCreacion,
    required this.activo,
    required this.tiendaId,
  })  : stockBajo = stockActual <= stockMinimo,
        valorInventario = stockActual * precioCompra,
        margenReal = precioVenta - precioCompra;
}

class VentaCompleta {
  final int id;
  final DateTime fechaVenta;
  final double totalVenta;
  final String metodoPago;
  final String? clienteId;
  final String usuarioId;
  final double descuentoAplicado;
  final double? latitud;
  final double? longitud;
  final String? direccionAproximada;
  final String? zonaGeografica;
  final bool sincronizadoNube;
  final DateTime? fechaSincronizacion;
  final String tiendaId;
  
  // Detalles de la venta
  final List<DetalleVentaCompleto> detalles;
  
  // Campos calculados
  final double subtotal;
  final double totalDescuento;
  final int totalItems;

  VentaCompleta({
    required this.id,
    required this.fechaVenta,
    required this.totalVenta,
    required this.metodoPago,
    this.clienteId,
    required this.usuarioId,
    required this.descuentoAplicado,
    this.latitud,
    this.longitud,
    this.direccionAproximada,
    this.zonaGeografica,
    required this.sincronizadoNube,
    this.fechaSincronizacion,
    required this.tiendaId,
    required this.detalles,
  })  : subtotal = totalVenta + descuentoAplicado,
        totalDescuento = descuentoAplicado + 
            detalles.fold(0.0, (sum, item) => sum + item.descuentoItem),
        totalItems = detalles.fold(0, (sum, item) => sum + item.cantidad);
}

class DetalleVentaCompleto {
  final int id;
  final int ventaId;
  final int productoId;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;
  final double descuentoItem;
  
  // Información del producto
  final String nombreProducto;
  final String? codigoBarras;
  final String categoria;
  final String unidadMedida;

  DetalleVentaCompleto({
    required this.id,
    required this.ventaId,
    required this.productoId,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    required this.descuentoItem,
    required this.nombreProducto,
    this.codigoBarras,
    required this.categoria,
    required this.unidadMedida,
  });
}

class ResumenVentas {
  final DateTime fecha;
  final double totalVentas;
  final int numeroVentas;
  final double promedioVenta;
  final double totalDescuentos;
  final Map<String, double> ventasPorMetodoPago;
  final Map<String, int> ventasPorCategoria;
  final List<ProductoMasVendido> productosMasVendidos;

  ResumenVentas({
    required this.fecha,
    required this.totalVentas,
    required this.numeroVentas,
    required this.promedioVenta,
    required this.totalDescuentos,
    required this.ventasPorMetodoPago,
    required this.ventasPorCategoria,
    required this.productosMasVendidos,
  });
}

class ProductoMasVendido {
  final int productoId;
  final String nombreProducto;
  final String categoria;
  final int cantidadVendida;
  final double ingresoTotal;
  final double participacionPorcentaje;

  ProductoMasVendido({
    required this.productoId,
    required this.nombreProducto,
    required this.categoria,
    required this.cantidadVendida,
    required this.ingresoTotal,
    required this.participacionPorcentaje,
  });
}

class PuntoGeoVenta {
  final double latitud;
  final double longitud;
  final double totalVentas;
  final int numeroVentas;
  final DateTime fechaUltimaVenta;
  final String? direccionAproximada;
  final String? zonaGeografica;

  PuntoGeoVenta({
    required this.latitud,
    required this.longitud,
    required this.totalVentas,
    required this.numeroVentas,
    required this.fechaUltimaVenta,
    this.direccionAproximada,
    this.zonaGeografica,
  });
}

class AlertaStock {
  final int productoId;
  final String nombreProducto;
  final String categoria;
  final int stockActual;
  final int stockMinimo;
  final double diasParaAgotarse;
  final NivelAlerta nivel;
  final DateTime fechaCalculada;

  AlertaStock({
    required this.productoId,
    required this.nombreProducto,
    required this.categoria,
    required this.stockActual,
    required this.stockMinimo,
    required this.diasParaAgotarse,
    required this.nivel,
    required this.fechaCalculada,
  });
}

// ===== FILTROS Y PARÁMETROS =====

class FiltroVentas {
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final String? usuarioId;
  final String? metodoPago;
  final double? montoMinimo;
  final double? montoMaximo;
  final bool? soloSincronizadas;
  final String? zonaGeografica;

  FiltroVentas({
    this.fechaInicio,
    this.fechaFin,
    this.usuarioId,
    this.metodoPago,
    this.montoMinimo,
    this.montoMaximo,
    this.soloSincronizadas,
    this.zonaGeografica,
  });
}

class FiltroProductos {
  final String? categoria;
  final bool? soloActivos;
  final bool? soloStockBajo;
  final String? busqueda;
  final double? precioMinimo;
  final double? precioMaximo;

  FiltroProductos({
    this.categoria,
    this.soloActivos,
    this.soloStockBajo,
    this.busqueda,
    this.precioMinimo,
    this.precioMaximo,
  });
}

// ===== ESTADÍSTICAS =====

class EstadisticasGenerales {
  final int totalProductos;
  final int productosActivos;
  final int productosStockBajo;
  final double valorTotalInventario;
  final double ventasHoy;
  final double ventasEsteMes;
  final int ventasPendientesSincronizacion;
  final DateTime fechaUltimaActualizacion;

  EstadisticasGenerales({
    required this.totalProductos,
    required this.productosActivos,
    required this.productosStockBajo,
    required this.valorTotalInventario,
    required this.ventasHoy,
    required this.ventasEsteMes,
    required this.ventasPendientesSincronizacion,
    required this.fechaUltimaActualizacion,
  });
}
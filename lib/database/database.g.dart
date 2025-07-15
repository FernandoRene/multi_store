// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProductosTable extends Productos
    with TableInfo<$ProductosTable, Producto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _codigoBarrasMeta =
      const VerificationMeta('codigoBarras');
  @override
  late final GeneratedColumn<String> codigoBarras = GeneratedColumn<String>(
      'codigo_barras', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
      'nombre', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descripcionMeta =
      const VerificationMeta('descripcion');
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
      'descripcion', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoriaMeta =
      const VerificationMeta('categoria');
  @override
  late final GeneratedColumn<String> categoria = GeneratedColumn<String>(
      'categoria', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _precioVentaMeta =
      const VerificationMeta('precioVenta');
  @override
  late final GeneratedColumn<double> precioVenta = GeneratedColumn<double>(
      'precio_venta', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _precioCompraMeta =
      const VerificationMeta('precioCompra');
  @override
  late final GeneratedColumn<double> precioCompra = GeneratedColumn<double>(
      'precio_compra', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _margenGananciaMeta =
      const VerificationMeta('margenGanancia');
  @override
  late final GeneratedColumn<double> margenGanancia = GeneratedColumn<double>(
      'margen_ganancia', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _stockActualMeta =
      const VerificationMeta('stockActual');
  @override
  late final GeneratedColumn<int> stockActual = GeneratedColumn<int>(
      'stock_actual', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _stockMinimoMeta =
      const VerificationMeta('stockMinimo');
  @override
  late final GeneratedColumn<int> stockMinimo = GeneratedColumn<int>(
      'stock_minimo', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _unidadMedidaMeta =
      const VerificationMeta('unidadMedida');
  @override
  late final GeneratedColumn<String> unidadMedida = GeneratedColumn<String>(
      'unidad_medida', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('unidad'));
  static const VerificationMeta _fechaCreacionMeta =
      const VerificationMeta('fechaCreacion');
  @override
  late final GeneratedColumn<DateTime> fechaCreacion =
      GeneratedColumn<DateTime>('fecha_creacion', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<bool> activo = GeneratedColumn<bool>(
      'activo', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("activo" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _tiendaIdMeta =
      const VerificationMeta('tiendaId');
  @override
  late final GeneratedColumn<String> tiendaId = GeneratedColumn<String>(
      'tienda_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        codigoBarras,
        nombre,
        descripcion,
        categoria,
        precioVenta,
        precioCompra,
        margenGanancia,
        stockActual,
        stockMinimo,
        unidadMedida,
        fechaCreacion,
        activo,
        tiendaId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'productos';
  @override
  VerificationContext validateIntegrity(Insertable<Producto> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('codigo_barras')) {
      context.handle(
          _codigoBarrasMeta,
          codigoBarras.isAcceptableOrUnknown(
              data['codigo_barras']!, _codigoBarrasMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(_nombreMeta,
          nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta));
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('descripcion')) {
      context.handle(
          _descripcionMeta,
          descripcion.isAcceptableOrUnknown(
              data['descripcion']!, _descripcionMeta));
    }
    if (data.containsKey('categoria')) {
      context.handle(_categoriaMeta,
          categoria.isAcceptableOrUnknown(data['categoria']!, _categoriaMeta));
    } else if (isInserting) {
      context.missing(_categoriaMeta);
    }
    if (data.containsKey('precio_venta')) {
      context.handle(
          _precioVentaMeta,
          precioVenta.isAcceptableOrUnknown(
              data['precio_venta']!, _precioVentaMeta));
    } else if (isInserting) {
      context.missing(_precioVentaMeta);
    }
    if (data.containsKey('precio_compra')) {
      context.handle(
          _precioCompraMeta,
          precioCompra.isAcceptableOrUnknown(
              data['precio_compra']!, _precioCompraMeta));
    } else if (isInserting) {
      context.missing(_precioCompraMeta);
    }
    if (data.containsKey('margen_ganancia')) {
      context.handle(
          _margenGananciaMeta,
          margenGanancia.isAcceptableOrUnknown(
              data['margen_ganancia']!, _margenGananciaMeta));
    }
    if (data.containsKey('stock_actual')) {
      context.handle(
          _stockActualMeta,
          stockActual.isAcceptableOrUnknown(
              data['stock_actual']!, _stockActualMeta));
    } else if (isInserting) {
      context.missing(_stockActualMeta);
    }
    if (data.containsKey('stock_minimo')) {
      context.handle(
          _stockMinimoMeta,
          stockMinimo.isAcceptableOrUnknown(
              data['stock_minimo']!, _stockMinimoMeta));
    } else if (isInserting) {
      context.missing(_stockMinimoMeta);
    }
    if (data.containsKey('unidad_medida')) {
      context.handle(
          _unidadMedidaMeta,
          unidadMedida.isAcceptableOrUnknown(
              data['unidad_medida']!, _unidadMedidaMeta));
    }
    if (data.containsKey('fecha_creacion')) {
      context.handle(
          _fechaCreacionMeta,
          fechaCreacion.isAcceptableOrUnknown(
              data['fecha_creacion']!, _fechaCreacionMeta));
    }
    if (data.containsKey('activo')) {
      context.handle(_activoMeta,
          activo.isAcceptableOrUnknown(data['activo']!, _activoMeta));
    }
    if (data.containsKey('tienda_id')) {
      context.handle(_tiendaIdMeta,
          tiendaId.isAcceptableOrUnknown(data['tienda_id']!, _tiendaIdMeta));
    } else if (isInserting) {
      context.missing(_tiendaIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Producto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Producto(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      codigoBarras: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}codigo_barras']),
      nombre: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nombre'])!,
      descripcion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}descripcion']),
      categoria: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}categoria'])!,
      precioVenta: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}precio_venta'])!,
      precioCompra: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}precio_compra'])!,
      margenGanancia: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}margen_ganancia']),
      stockActual: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stock_actual'])!,
      stockMinimo: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stock_minimo'])!,
      unidadMedida: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unidad_medida'])!,
      fechaCreacion: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_creacion'])!,
      activo: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}activo'])!,
      tiendaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tienda_id'])!,
    );
  }

  @override
  $ProductosTable createAlias(String alias) {
    return $ProductosTable(attachedDatabase, alias);
  }
}

class Producto extends DataClass implements Insertable<Producto> {
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
  const Producto(
      {required this.id,
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
      required this.tiendaId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || codigoBarras != null) {
      map['codigo_barras'] = Variable<String>(codigoBarras);
    }
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || descripcion != null) {
      map['descripcion'] = Variable<String>(descripcion);
    }
    map['categoria'] = Variable<String>(categoria);
    map['precio_venta'] = Variable<double>(precioVenta);
    map['precio_compra'] = Variable<double>(precioCompra);
    if (!nullToAbsent || margenGanancia != null) {
      map['margen_ganancia'] = Variable<double>(margenGanancia);
    }
    map['stock_actual'] = Variable<int>(stockActual);
    map['stock_minimo'] = Variable<int>(stockMinimo);
    map['unidad_medida'] = Variable<String>(unidadMedida);
    map['fecha_creacion'] = Variable<DateTime>(fechaCreacion);
    map['activo'] = Variable<bool>(activo);
    map['tienda_id'] = Variable<String>(tiendaId);
    return map;
  }

  ProductosCompanion toCompanion(bool nullToAbsent) {
    return ProductosCompanion(
      id: Value(id),
      codigoBarras: codigoBarras == null && nullToAbsent
          ? const Value.absent()
          : Value(codigoBarras),
      nombre: Value(nombre),
      descripcion: descripcion == null && nullToAbsent
          ? const Value.absent()
          : Value(descripcion),
      categoria: Value(categoria),
      precioVenta: Value(precioVenta),
      precioCompra: Value(precioCompra),
      margenGanancia: margenGanancia == null && nullToAbsent
          ? const Value.absent()
          : Value(margenGanancia),
      stockActual: Value(stockActual),
      stockMinimo: Value(stockMinimo),
      unidadMedida: Value(unidadMedida),
      fechaCreacion: Value(fechaCreacion),
      activo: Value(activo),
      tiendaId: Value(tiendaId),
    );
  }

  factory Producto.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Producto(
      id: serializer.fromJson<int>(json['id']),
      codigoBarras: serializer.fromJson<String?>(json['codigoBarras']),
      nombre: serializer.fromJson<String>(json['nombre']),
      descripcion: serializer.fromJson<String?>(json['descripcion']),
      categoria: serializer.fromJson<String>(json['categoria']),
      precioVenta: serializer.fromJson<double>(json['precioVenta']),
      precioCompra: serializer.fromJson<double>(json['precioCompra']),
      margenGanancia: serializer.fromJson<double?>(json['margenGanancia']),
      stockActual: serializer.fromJson<int>(json['stockActual']),
      stockMinimo: serializer.fromJson<int>(json['stockMinimo']),
      unidadMedida: serializer.fromJson<String>(json['unidadMedida']),
      fechaCreacion: serializer.fromJson<DateTime>(json['fechaCreacion']),
      activo: serializer.fromJson<bool>(json['activo']),
      tiendaId: serializer.fromJson<String>(json['tiendaId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'codigoBarras': serializer.toJson<String?>(codigoBarras),
      'nombre': serializer.toJson<String>(nombre),
      'descripcion': serializer.toJson<String?>(descripcion),
      'categoria': serializer.toJson<String>(categoria),
      'precioVenta': serializer.toJson<double>(precioVenta),
      'precioCompra': serializer.toJson<double>(precioCompra),
      'margenGanancia': serializer.toJson<double?>(margenGanancia),
      'stockActual': serializer.toJson<int>(stockActual),
      'stockMinimo': serializer.toJson<int>(stockMinimo),
      'unidadMedida': serializer.toJson<String>(unidadMedida),
      'fechaCreacion': serializer.toJson<DateTime>(fechaCreacion),
      'activo': serializer.toJson<bool>(activo),
      'tiendaId': serializer.toJson<String>(tiendaId),
    };
  }

  Producto copyWith(
          {int? id,
          Value<String?> codigoBarras = const Value.absent(),
          String? nombre,
          Value<String?> descripcion = const Value.absent(),
          String? categoria,
          double? precioVenta,
          double? precioCompra,
          Value<double?> margenGanancia = const Value.absent(),
          int? stockActual,
          int? stockMinimo,
          String? unidadMedida,
          DateTime? fechaCreacion,
          bool? activo,
          String? tiendaId}) =>
      Producto(
        id: id ?? this.id,
        codigoBarras:
            codigoBarras.present ? codigoBarras.value : this.codigoBarras,
        nombre: nombre ?? this.nombre,
        descripcion: descripcion.present ? descripcion.value : this.descripcion,
        categoria: categoria ?? this.categoria,
        precioVenta: precioVenta ?? this.precioVenta,
        precioCompra: precioCompra ?? this.precioCompra,
        margenGanancia:
            margenGanancia.present ? margenGanancia.value : this.margenGanancia,
        stockActual: stockActual ?? this.stockActual,
        stockMinimo: stockMinimo ?? this.stockMinimo,
        unidadMedida: unidadMedida ?? this.unidadMedida,
        fechaCreacion: fechaCreacion ?? this.fechaCreacion,
        activo: activo ?? this.activo,
        tiendaId: tiendaId ?? this.tiendaId,
      );
  Producto copyWithCompanion(ProductosCompanion data) {
    return Producto(
      id: data.id.present ? data.id.value : this.id,
      codigoBarras: data.codigoBarras.present
          ? data.codigoBarras.value
          : this.codigoBarras,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      descripcion:
          data.descripcion.present ? data.descripcion.value : this.descripcion,
      categoria: data.categoria.present ? data.categoria.value : this.categoria,
      precioVenta:
          data.precioVenta.present ? data.precioVenta.value : this.precioVenta,
      precioCompra: data.precioCompra.present
          ? data.precioCompra.value
          : this.precioCompra,
      margenGanancia: data.margenGanancia.present
          ? data.margenGanancia.value
          : this.margenGanancia,
      stockActual:
          data.stockActual.present ? data.stockActual.value : this.stockActual,
      stockMinimo:
          data.stockMinimo.present ? data.stockMinimo.value : this.stockMinimo,
      unidadMedida: data.unidadMedida.present
          ? data.unidadMedida.value
          : this.unidadMedida,
      fechaCreacion: data.fechaCreacion.present
          ? data.fechaCreacion.value
          : this.fechaCreacion,
      activo: data.activo.present ? data.activo.value : this.activo,
      tiendaId: data.tiendaId.present ? data.tiendaId.value : this.tiendaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Producto(')
          ..write('id: $id, ')
          ..write('codigoBarras: $codigoBarras, ')
          ..write('nombre: $nombre, ')
          ..write('descripcion: $descripcion, ')
          ..write('categoria: $categoria, ')
          ..write('precioVenta: $precioVenta, ')
          ..write('precioCompra: $precioCompra, ')
          ..write('margenGanancia: $margenGanancia, ')
          ..write('stockActual: $stockActual, ')
          ..write('stockMinimo: $stockMinimo, ')
          ..write('unidadMedida: $unidadMedida, ')
          ..write('fechaCreacion: $fechaCreacion, ')
          ..write('activo: $activo, ')
          ..write('tiendaId: $tiendaId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      codigoBarras,
      nombre,
      descripcion,
      categoria,
      precioVenta,
      precioCompra,
      margenGanancia,
      stockActual,
      stockMinimo,
      unidadMedida,
      fechaCreacion,
      activo,
      tiendaId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Producto &&
          other.id == this.id &&
          other.codigoBarras == this.codigoBarras &&
          other.nombre == this.nombre &&
          other.descripcion == this.descripcion &&
          other.categoria == this.categoria &&
          other.precioVenta == this.precioVenta &&
          other.precioCompra == this.precioCompra &&
          other.margenGanancia == this.margenGanancia &&
          other.stockActual == this.stockActual &&
          other.stockMinimo == this.stockMinimo &&
          other.unidadMedida == this.unidadMedida &&
          other.fechaCreacion == this.fechaCreacion &&
          other.activo == this.activo &&
          other.tiendaId == this.tiendaId);
}

class ProductosCompanion extends UpdateCompanion<Producto> {
  final Value<int> id;
  final Value<String?> codigoBarras;
  final Value<String> nombre;
  final Value<String?> descripcion;
  final Value<String> categoria;
  final Value<double> precioVenta;
  final Value<double> precioCompra;
  final Value<double?> margenGanancia;
  final Value<int> stockActual;
  final Value<int> stockMinimo;
  final Value<String> unidadMedida;
  final Value<DateTime> fechaCreacion;
  final Value<bool> activo;
  final Value<String> tiendaId;
  const ProductosCompanion({
    this.id = const Value.absent(),
    this.codigoBarras = const Value.absent(),
    this.nombre = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.categoria = const Value.absent(),
    this.precioVenta = const Value.absent(),
    this.precioCompra = const Value.absent(),
    this.margenGanancia = const Value.absent(),
    this.stockActual = const Value.absent(),
    this.stockMinimo = const Value.absent(),
    this.unidadMedida = const Value.absent(),
    this.fechaCreacion = const Value.absent(),
    this.activo = const Value.absent(),
    this.tiendaId = const Value.absent(),
  });
  ProductosCompanion.insert({
    this.id = const Value.absent(),
    this.codigoBarras = const Value.absent(),
    required String nombre,
    this.descripcion = const Value.absent(),
    required String categoria,
    required double precioVenta,
    required double precioCompra,
    this.margenGanancia = const Value.absent(),
    required int stockActual,
    required int stockMinimo,
    this.unidadMedida = const Value.absent(),
    this.fechaCreacion = const Value.absent(),
    this.activo = const Value.absent(),
    required String tiendaId,
  })  : nombre = Value(nombre),
        categoria = Value(categoria),
        precioVenta = Value(precioVenta),
        precioCompra = Value(precioCompra),
        stockActual = Value(stockActual),
        stockMinimo = Value(stockMinimo),
        tiendaId = Value(tiendaId);
  static Insertable<Producto> custom({
    Expression<int>? id,
    Expression<String>? codigoBarras,
    Expression<String>? nombre,
    Expression<String>? descripcion,
    Expression<String>? categoria,
    Expression<double>? precioVenta,
    Expression<double>? precioCompra,
    Expression<double>? margenGanancia,
    Expression<int>? stockActual,
    Expression<int>? stockMinimo,
    Expression<String>? unidadMedida,
    Expression<DateTime>? fechaCreacion,
    Expression<bool>? activo,
    Expression<String>? tiendaId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (codigoBarras != null) 'codigo_barras': codigoBarras,
      if (nombre != null) 'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      if (categoria != null) 'categoria': categoria,
      if (precioVenta != null) 'precio_venta': precioVenta,
      if (precioCompra != null) 'precio_compra': precioCompra,
      if (margenGanancia != null) 'margen_ganancia': margenGanancia,
      if (stockActual != null) 'stock_actual': stockActual,
      if (stockMinimo != null) 'stock_minimo': stockMinimo,
      if (unidadMedida != null) 'unidad_medida': unidadMedida,
      if (fechaCreacion != null) 'fecha_creacion': fechaCreacion,
      if (activo != null) 'activo': activo,
      if (tiendaId != null) 'tienda_id': tiendaId,
    });
  }

  ProductosCompanion copyWith(
      {Value<int>? id,
      Value<String?>? codigoBarras,
      Value<String>? nombre,
      Value<String?>? descripcion,
      Value<String>? categoria,
      Value<double>? precioVenta,
      Value<double>? precioCompra,
      Value<double?>? margenGanancia,
      Value<int>? stockActual,
      Value<int>? stockMinimo,
      Value<String>? unidadMedida,
      Value<DateTime>? fechaCreacion,
      Value<bool>? activo,
      Value<String>? tiendaId}) {
    return ProductosCompanion(
      id: id ?? this.id,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      categoria: categoria ?? this.categoria,
      precioVenta: precioVenta ?? this.precioVenta,
      precioCompra: precioCompra ?? this.precioCompra,
      margenGanancia: margenGanancia ?? this.margenGanancia,
      stockActual: stockActual ?? this.stockActual,
      stockMinimo: stockMinimo ?? this.stockMinimo,
      unidadMedida: unidadMedida ?? this.unidadMedida,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      activo: activo ?? this.activo,
      tiendaId: tiendaId ?? this.tiendaId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (codigoBarras.present) {
      map['codigo_barras'] = Variable<String>(codigoBarras.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(categoria.value);
    }
    if (precioVenta.present) {
      map['precio_venta'] = Variable<double>(precioVenta.value);
    }
    if (precioCompra.present) {
      map['precio_compra'] = Variable<double>(precioCompra.value);
    }
    if (margenGanancia.present) {
      map['margen_ganancia'] = Variable<double>(margenGanancia.value);
    }
    if (stockActual.present) {
      map['stock_actual'] = Variable<int>(stockActual.value);
    }
    if (stockMinimo.present) {
      map['stock_minimo'] = Variable<int>(stockMinimo.value);
    }
    if (unidadMedida.present) {
      map['unidad_medida'] = Variable<String>(unidadMedida.value);
    }
    if (fechaCreacion.present) {
      map['fecha_creacion'] = Variable<DateTime>(fechaCreacion.value);
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    if (tiendaId.present) {
      map['tienda_id'] = Variable<String>(tiendaId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductosCompanion(')
          ..write('id: $id, ')
          ..write('codigoBarras: $codigoBarras, ')
          ..write('nombre: $nombre, ')
          ..write('descripcion: $descripcion, ')
          ..write('categoria: $categoria, ')
          ..write('precioVenta: $precioVenta, ')
          ..write('precioCompra: $precioCompra, ')
          ..write('margenGanancia: $margenGanancia, ')
          ..write('stockActual: $stockActual, ')
          ..write('stockMinimo: $stockMinimo, ')
          ..write('unidadMedida: $unidadMedida, ')
          ..write('fechaCreacion: $fechaCreacion, ')
          ..write('activo: $activo, ')
          ..write('tiendaId: $tiendaId')
          ..write(')'))
        .toString();
  }
}

class $VentasTable extends Ventas with TableInfo<$VentasTable, Venta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VentasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _fechaVentaMeta =
      const VerificationMeta('fechaVenta');
  @override
  late final GeneratedColumn<DateTime> fechaVenta = GeneratedColumn<DateTime>(
      'fecha_venta', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _totalVentaMeta =
      const VerificationMeta('totalVenta');
  @override
  late final GeneratedColumn<double> totalVenta = GeneratedColumn<double>(
      'total_venta', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _metodoPagoMeta =
      const VerificationMeta('metodoPago');
  @override
  late final GeneratedColumn<String> metodoPago = GeneratedColumn<String>(
      'metodo_pago', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _clienteIdMeta =
      const VerificationMeta('clienteId');
  @override
  late final GeneratedColumn<String> clienteId = GeneratedColumn<String>(
      'cliente_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _usuarioIdMeta =
      const VerificationMeta('usuarioId');
  @override
  late final GeneratedColumn<String> usuarioId = GeneratedColumn<String>(
      'usuario_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descuentoAplicadoMeta =
      const VerificationMeta('descuentoAplicado');
  @override
  late final GeneratedColumn<double> descuentoAplicado =
      GeneratedColumn<double>('descuento_aplicado', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0));
  static const VerificationMeta _latitudMeta =
      const VerificationMeta('latitud');
  @override
  late final GeneratedColumn<double> latitud = GeneratedColumn<double>(
      'latitud', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _longitudMeta =
      const VerificationMeta('longitud');
  @override
  late final GeneratedColumn<double> longitud = GeneratedColumn<double>(
      'longitud', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _direccionAproximadaMeta =
      const VerificationMeta('direccionAproximada');
  @override
  late final GeneratedColumn<String> direccionAproximada =
      GeneratedColumn<String>('direccion_aproximada', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _zonaGeograficaMeta =
      const VerificationMeta('zonaGeografica');
  @override
  late final GeneratedColumn<String> zonaGeografica = GeneratedColumn<String>(
      'zona_geografica', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sincronizadoNubeMeta =
      const VerificationMeta('sincronizadoNube');
  @override
  late final GeneratedColumn<bool> sincronizadoNube = GeneratedColumn<bool>(
      'sincronizado_nube', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("sincronizado_nube" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _fechaSincronizacionMeta =
      const VerificationMeta('fechaSincronizacion');
  @override
  late final GeneratedColumn<DateTime> fechaSincronizacion =
      GeneratedColumn<DateTime>('fecha_sincronizacion', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _tiendaIdMeta =
      const VerificationMeta('tiendaId');
  @override
  late final GeneratedColumn<String> tiendaId = GeneratedColumn<String>(
      'tienda_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        fechaVenta,
        totalVenta,
        metodoPago,
        clienteId,
        usuarioId,
        descuentoAplicado,
        latitud,
        longitud,
        direccionAproximada,
        zonaGeografica,
        sincronizadoNube,
        fechaSincronizacion,
        tiendaId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ventas';
  @override
  VerificationContext validateIntegrity(Insertable<Venta> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('fecha_venta')) {
      context.handle(
          _fechaVentaMeta,
          fechaVenta.isAcceptableOrUnknown(
              data['fecha_venta']!, _fechaVentaMeta));
    } else if (isInserting) {
      context.missing(_fechaVentaMeta);
    }
    if (data.containsKey('total_venta')) {
      context.handle(
          _totalVentaMeta,
          totalVenta.isAcceptableOrUnknown(
              data['total_venta']!, _totalVentaMeta));
    } else if (isInserting) {
      context.missing(_totalVentaMeta);
    }
    if (data.containsKey('metodo_pago')) {
      context.handle(
          _metodoPagoMeta,
          metodoPago.isAcceptableOrUnknown(
              data['metodo_pago']!, _metodoPagoMeta));
    } else if (isInserting) {
      context.missing(_metodoPagoMeta);
    }
    if (data.containsKey('cliente_id')) {
      context.handle(_clienteIdMeta,
          clienteId.isAcceptableOrUnknown(data['cliente_id']!, _clienteIdMeta));
    }
    if (data.containsKey('usuario_id')) {
      context.handle(_usuarioIdMeta,
          usuarioId.isAcceptableOrUnknown(data['usuario_id']!, _usuarioIdMeta));
    } else if (isInserting) {
      context.missing(_usuarioIdMeta);
    }
    if (data.containsKey('descuento_aplicado')) {
      context.handle(
          _descuentoAplicadoMeta,
          descuentoAplicado.isAcceptableOrUnknown(
              data['descuento_aplicado']!, _descuentoAplicadoMeta));
    }
    if (data.containsKey('latitud')) {
      context.handle(_latitudMeta,
          latitud.isAcceptableOrUnknown(data['latitud']!, _latitudMeta));
    }
    if (data.containsKey('longitud')) {
      context.handle(_longitudMeta,
          longitud.isAcceptableOrUnknown(data['longitud']!, _longitudMeta));
    }
    if (data.containsKey('direccion_aproximada')) {
      context.handle(
          _direccionAproximadaMeta,
          direccionAproximada.isAcceptableOrUnknown(
              data['direccion_aproximada']!, _direccionAproximadaMeta));
    }
    if (data.containsKey('zona_geografica')) {
      context.handle(
          _zonaGeograficaMeta,
          zonaGeografica.isAcceptableOrUnknown(
              data['zona_geografica']!, _zonaGeograficaMeta));
    }
    if (data.containsKey('sincronizado_nube')) {
      context.handle(
          _sincronizadoNubeMeta,
          sincronizadoNube.isAcceptableOrUnknown(
              data['sincronizado_nube']!, _sincronizadoNubeMeta));
    }
    if (data.containsKey('fecha_sincronizacion')) {
      context.handle(
          _fechaSincronizacionMeta,
          fechaSincronizacion.isAcceptableOrUnknown(
              data['fecha_sincronizacion']!, _fechaSincronizacionMeta));
    }
    if (data.containsKey('tienda_id')) {
      context.handle(_tiendaIdMeta,
          tiendaId.isAcceptableOrUnknown(data['tienda_id']!, _tiendaIdMeta));
    } else if (isInserting) {
      context.missing(_tiendaIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Venta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Venta(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      fechaVenta: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fecha_venta'])!,
      totalVenta: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_venta'])!,
      metodoPago: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metodo_pago'])!,
      clienteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cliente_id']),
      usuarioId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}usuario_id'])!,
      descuentoAplicado: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}descuento_aplicado'])!,
      latitud: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitud']),
      longitud: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitud']),
      direccionAproximada: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}direccion_aproximada']),
      zonaGeografica: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}zona_geografica']),
      sincronizadoNube: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}sincronizado_nube'])!,
      fechaSincronizacion: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}fecha_sincronizacion']),
      tiendaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tienda_id'])!,
    );
  }

  @override
  $VentasTable createAlias(String alias) {
    return $VentasTable(attachedDatabase, alias);
  }
}

class Venta extends DataClass implements Insertable<Venta> {
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
  const Venta(
      {required this.id,
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
      required this.tiendaId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['fecha_venta'] = Variable<DateTime>(fechaVenta);
    map['total_venta'] = Variable<double>(totalVenta);
    map['metodo_pago'] = Variable<String>(metodoPago);
    if (!nullToAbsent || clienteId != null) {
      map['cliente_id'] = Variable<String>(clienteId);
    }
    map['usuario_id'] = Variable<String>(usuarioId);
    map['descuento_aplicado'] = Variable<double>(descuentoAplicado);
    if (!nullToAbsent || latitud != null) {
      map['latitud'] = Variable<double>(latitud);
    }
    if (!nullToAbsent || longitud != null) {
      map['longitud'] = Variable<double>(longitud);
    }
    if (!nullToAbsent || direccionAproximada != null) {
      map['direccion_aproximada'] = Variable<String>(direccionAproximada);
    }
    if (!nullToAbsent || zonaGeografica != null) {
      map['zona_geografica'] = Variable<String>(zonaGeografica);
    }
    map['sincronizado_nube'] = Variable<bool>(sincronizadoNube);
    if (!nullToAbsent || fechaSincronizacion != null) {
      map['fecha_sincronizacion'] = Variable<DateTime>(fechaSincronizacion);
    }
    map['tienda_id'] = Variable<String>(tiendaId);
    return map;
  }

  VentasCompanion toCompanion(bool nullToAbsent) {
    return VentasCompanion(
      id: Value(id),
      fechaVenta: Value(fechaVenta),
      totalVenta: Value(totalVenta),
      metodoPago: Value(metodoPago),
      clienteId: clienteId == null && nullToAbsent
          ? const Value.absent()
          : Value(clienteId),
      usuarioId: Value(usuarioId),
      descuentoAplicado: Value(descuentoAplicado),
      latitud: latitud == null && nullToAbsent
          ? const Value.absent()
          : Value(latitud),
      longitud: longitud == null && nullToAbsent
          ? const Value.absent()
          : Value(longitud),
      direccionAproximada: direccionAproximada == null && nullToAbsent
          ? const Value.absent()
          : Value(direccionAproximada),
      zonaGeografica: zonaGeografica == null && nullToAbsent
          ? const Value.absent()
          : Value(zonaGeografica),
      sincronizadoNube: Value(sincronizadoNube),
      fechaSincronizacion: fechaSincronizacion == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaSincronizacion),
      tiendaId: Value(tiendaId),
    );
  }

  factory Venta.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Venta(
      id: serializer.fromJson<int>(json['id']),
      fechaVenta: serializer.fromJson<DateTime>(json['fechaVenta']),
      totalVenta: serializer.fromJson<double>(json['totalVenta']),
      metodoPago: serializer.fromJson<String>(json['metodoPago']),
      clienteId: serializer.fromJson<String?>(json['clienteId']),
      usuarioId: serializer.fromJson<String>(json['usuarioId']),
      descuentoAplicado: serializer.fromJson<double>(json['descuentoAplicado']),
      latitud: serializer.fromJson<double?>(json['latitud']),
      longitud: serializer.fromJson<double?>(json['longitud']),
      direccionAproximada:
          serializer.fromJson<String?>(json['direccionAproximada']),
      zonaGeografica: serializer.fromJson<String?>(json['zonaGeografica']),
      sincronizadoNube: serializer.fromJson<bool>(json['sincronizadoNube']),
      fechaSincronizacion:
          serializer.fromJson<DateTime?>(json['fechaSincronizacion']),
      tiendaId: serializer.fromJson<String>(json['tiendaId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fechaVenta': serializer.toJson<DateTime>(fechaVenta),
      'totalVenta': serializer.toJson<double>(totalVenta),
      'metodoPago': serializer.toJson<String>(metodoPago),
      'clienteId': serializer.toJson<String?>(clienteId),
      'usuarioId': serializer.toJson<String>(usuarioId),
      'descuentoAplicado': serializer.toJson<double>(descuentoAplicado),
      'latitud': serializer.toJson<double?>(latitud),
      'longitud': serializer.toJson<double?>(longitud),
      'direccionAproximada': serializer.toJson<String?>(direccionAproximada),
      'zonaGeografica': serializer.toJson<String?>(zonaGeografica),
      'sincronizadoNube': serializer.toJson<bool>(sincronizadoNube),
      'fechaSincronizacion': serializer.toJson<DateTime?>(fechaSincronizacion),
      'tiendaId': serializer.toJson<String>(tiendaId),
    };
  }

  Venta copyWith(
          {int? id,
          DateTime? fechaVenta,
          double? totalVenta,
          String? metodoPago,
          Value<String?> clienteId = const Value.absent(),
          String? usuarioId,
          double? descuentoAplicado,
          Value<double?> latitud = const Value.absent(),
          Value<double?> longitud = const Value.absent(),
          Value<String?> direccionAproximada = const Value.absent(),
          Value<String?> zonaGeografica = const Value.absent(),
          bool? sincronizadoNube,
          Value<DateTime?> fechaSincronizacion = const Value.absent(),
          String? tiendaId}) =>
      Venta(
        id: id ?? this.id,
        fechaVenta: fechaVenta ?? this.fechaVenta,
        totalVenta: totalVenta ?? this.totalVenta,
        metodoPago: metodoPago ?? this.metodoPago,
        clienteId: clienteId.present ? clienteId.value : this.clienteId,
        usuarioId: usuarioId ?? this.usuarioId,
        descuentoAplicado: descuentoAplicado ?? this.descuentoAplicado,
        latitud: latitud.present ? latitud.value : this.latitud,
        longitud: longitud.present ? longitud.value : this.longitud,
        direccionAproximada: direccionAproximada.present
            ? direccionAproximada.value
            : this.direccionAproximada,
        zonaGeografica:
            zonaGeografica.present ? zonaGeografica.value : this.zonaGeografica,
        sincronizadoNube: sincronizadoNube ?? this.sincronizadoNube,
        fechaSincronizacion: fechaSincronizacion.present
            ? fechaSincronizacion.value
            : this.fechaSincronizacion,
        tiendaId: tiendaId ?? this.tiendaId,
      );
  Venta copyWithCompanion(VentasCompanion data) {
    return Venta(
      id: data.id.present ? data.id.value : this.id,
      fechaVenta:
          data.fechaVenta.present ? data.fechaVenta.value : this.fechaVenta,
      totalVenta:
          data.totalVenta.present ? data.totalVenta.value : this.totalVenta,
      metodoPago:
          data.metodoPago.present ? data.metodoPago.value : this.metodoPago,
      clienteId: data.clienteId.present ? data.clienteId.value : this.clienteId,
      usuarioId: data.usuarioId.present ? data.usuarioId.value : this.usuarioId,
      descuentoAplicado: data.descuentoAplicado.present
          ? data.descuentoAplicado.value
          : this.descuentoAplicado,
      latitud: data.latitud.present ? data.latitud.value : this.latitud,
      longitud: data.longitud.present ? data.longitud.value : this.longitud,
      direccionAproximada: data.direccionAproximada.present
          ? data.direccionAproximada.value
          : this.direccionAproximada,
      zonaGeografica: data.zonaGeografica.present
          ? data.zonaGeografica.value
          : this.zonaGeografica,
      sincronizadoNube: data.sincronizadoNube.present
          ? data.sincronizadoNube.value
          : this.sincronizadoNube,
      fechaSincronizacion: data.fechaSincronizacion.present
          ? data.fechaSincronizacion.value
          : this.fechaSincronizacion,
      tiendaId: data.tiendaId.present ? data.tiendaId.value : this.tiendaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Venta(')
          ..write('id: $id, ')
          ..write('fechaVenta: $fechaVenta, ')
          ..write('totalVenta: $totalVenta, ')
          ..write('metodoPago: $metodoPago, ')
          ..write('clienteId: $clienteId, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('descuentoAplicado: $descuentoAplicado, ')
          ..write('latitud: $latitud, ')
          ..write('longitud: $longitud, ')
          ..write('direccionAproximada: $direccionAproximada, ')
          ..write('zonaGeografica: $zonaGeografica, ')
          ..write('sincronizadoNube: $sincronizadoNube, ')
          ..write('fechaSincronizacion: $fechaSincronizacion, ')
          ..write('tiendaId: $tiendaId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      fechaVenta,
      totalVenta,
      metodoPago,
      clienteId,
      usuarioId,
      descuentoAplicado,
      latitud,
      longitud,
      direccionAproximada,
      zonaGeografica,
      sincronizadoNube,
      fechaSincronizacion,
      tiendaId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Venta &&
          other.id == this.id &&
          other.fechaVenta == this.fechaVenta &&
          other.totalVenta == this.totalVenta &&
          other.metodoPago == this.metodoPago &&
          other.clienteId == this.clienteId &&
          other.usuarioId == this.usuarioId &&
          other.descuentoAplicado == this.descuentoAplicado &&
          other.latitud == this.latitud &&
          other.longitud == this.longitud &&
          other.direccionAproximada == this.direccionAproximada &&
          other.zonaGeografica == this.zonaGeografica &&
          other.sincronizadoNube == this.sincronizadoNube &&
          other.fechaSincronizacion == this.fechaSincronizacion &&
          other.tiendaId == this.tiendaId);
}

class VentasCompanion extends UpdateCompanion<Venta> {
  final Value<int> id;
  final Value<DateTime> fechaVenta;
  final Value<double> totalVenta;
  final Value<String> metodoPago;
  final Value<String?> clienteId;
  final Value<String> usuarioId;
  final Value<double> descuentoAplicado;
  final Value<double?> latitud;
  final Value<double?> longitud;
  final Value<String?> direccionAproximada;
  final Value<String?> zonaGeografica;
  final Value<bool> sincronizadoNube;
  final Value<DateTime?> fechaSincronizacion;
  final Value<String> tiendaId;
  const VentasCompanion({
    this.id = const Value.absent(),
    this.fechaVenta = const Value.absent(),
    this.totalVenta = const Value.absent(),
    this.metodoPago = const Value.absent(),
    this.clienteId = const Value.absent(),
    this.usuarioId = const Value.absent(),
    this.descuentoAplicado = const Value.absent(),
    this.latitud = const Value.absent(),
    this.longitud = const Value.absent(),
    this.direccionAproximada = const Value.absent(),
    this.zonaGeografica = const Value.absent(),
    this.sincronizadoNube = const Value.absent(),
    this.fechaSincronizacion = const Value.absent(),
    this.tiendaId = const Value.absent(),
  });
  VentasCompanion.insert({
    this.id = const Value.absent(),
    required DateTime fechaVenta,
    required double totalVenta,
    required String metodoPago,
    this.clienteId = const Value.absent(),
    required String usuarioId,
    this.descuentoAplicado = const Value.absent(),
    this.latitud = const Value.absent(),
    this.longitud = const Value.absent(),
    this.direccionAproximada = const Value.absent(),
    this.zonaGeografica = const Value.absent(),
    this.sincronizadoNube = const Value.absent(),
    this.fechaSincronizacion = const Value.absent(),
    required String tiendaId,
  })  : fechaVenta = Value(fechaVenta),
        totalVenta = Value(totalVenta),
        metodoPago = Value(metodoPago),
        usuarioId = Value(usuarioId),
        tiendaId = Value(tiendaId);
  static Insertable<Venta> custom({
    Expression<int>? id,
    Expression<DateTime>? fechaVenta,
    Expression<double>? totalVenta,
    Expression<String>? metodoPago,
    Expression<String>? clienteId,
    Expression<String>? usuarioId,
    Expression<double>? descuentoAplicado,
    Expression<double>? latitud,
    Expression<double>? longitud,
    Expression<String>? direccionAproximada,
    Expression<String>? zonaGeografica,
    Expression<bool>? sincronizadoNube,
    Expression<DateTime>? fechaSincronizacion,
    Expression<String>? tiendaId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fechaVenta != null) 'fecha_venta': fechaVenta,
      if (totalVenta != null) 'total_venta': totalVenta,
      if (metodoPago != null) 'metodo_pago': metodoPago,
      if (clienteId != null) 'cliente_id': clienteId,
      if (usuarioId != null) 'usuario_id': usuarioId,
      if (descuentoAplicado != null) 'descuento_aplicado': descuentoAplicado,
      if (latitud != null) 'latitud': latitud,
      if (longitud != null) 'longitud': longitud,
      if (direccionAproximada != null)
        'direccion_aproximada': direccionAproximada,
      if (zonaGeografica != null) 'zona_geografica': zonaGeografica,
      if (sincronizadoNube != null) 'sincronizado_nube': sincronizadoNube,
      if (fechaSincronizacion != null)
        'fecha_sincronizacion': fechaSincronizacion,
      if (tiendaId != null) 'tienda_id': tiendaId,
    });
  }

  VentasCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? fechaVenta,
      Value<double>? totalVenta,
      Value<String>? metodoPago,
      Value<String?>? clienteId,
      Value<String>? usuarioId,
      Value<double>? descuentoAplicado,
      Value<double?>? latitud,
      Value<double?>? longitud,
      Value<String?>? direccionAproximada,
      Value<String?>? zonaGeografica,
      Value<bool>? sincronizadoNube,
      Value<DateTime?>? fechaSincronizacion,
      Value<String>? tiendaId}) {
    return VentasCompanion(
      id: id ?? this.id,
      fechaVenta: fechaVenta ?? this.fechaVenta,
      totalVenta: totalVenta ?? this.totalVenta,
      metodoPago: metodoPago ?? this.metodoPago,
      clienteId: clienteId ?? this.clienteId,
      usuarioId: usuarioId ?? this.usuarioId,
      descuentoAplicado: descuentoAplicado ?? this.descuentoAplicado,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      direccionAproximada: direccionAproximada ?? this.direccionAproximada,
      zonaGeografica: zonaGeografica ?? this.zonaGeografica,
      sincronizadoNube: sincronizadoNube ?? this.sincronizadoNube,
      fechaSincronizacion: fechaSincronizacion ?? this.fechaSincronizacion,
      tiendaId: tiendaId ?? this.tiendaId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fechaVenta.present) {
      map['fecha_venta'] = Variable<DateTime>(fechaVenta.value);
    }
    if (totalVenta.present) {
      map['total_venta'] = Variable<double>(totalVenta.value);
    }
    if (metodoPago.present) {
      map['metodo_pago'] = Variable<String>(metodoPago.value);
    }
    if (clienteId.present) {
      map['cliente_id'] = Variable<String>(clienteId.value);
    }
    if (usuarioId.present) {
      map['usuario_id'] = Variable<String>(usuarioId.value);
    }
    if (descuentoAplicado.present) {
      map['descuento_aplicado'] = Variable<double>(descuentoAplicado.value);
    }
    if (latitud.present) {
      map['latitud'] = Variable<double>(latitud.value);
    }
    if (longitud.present) {
      map['longitud'] = Variable<double>(longitud.value);
    }
    if (direccionAproximada.present) {
      map['direccion_aproximada'] = Variable<String>(direccionAproximada.value);
    }
    if (zonaGeografica.present) {
      map['zona_geografica'] = Variable<String>(zonaGeografica.value);
    }
    if (sincronizadoNube.present) {
      map['sincronizado_nube'] = Variable<bool>(sincronizadoNube.value);
    }
    if (fechaSincronizacion.present) {
      map['fecha_sincronizacion'] =
          Variable<DateTime>(fechaSincronizacion.value);
    }
    if (tiendaId.present) {
      map['tienda_id'] = Variable<String>(tiendaId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VentasCompanion(')
          ..write('id: $id, ')
          ..write('fechaVenta: $fechaVenta, ')
          ..write('totalVenta: $totalVenta, ')
          ..write('metodoPago: $metodoPago, ')
          ..write('clienteId: $clienteId, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('descuentoAplicado: $descuentoAplicado, ')
          ..write('latitud: $latitud, ')
          ..write('longitud: $longitud, ')
          ..write('direccionAproximada: $direccionAproximada, ')
          ..write('zonaGeografica: $zonaGeografica, ')
          ..write('sincronizadoNube: $sincronizadoNube, ')
          ..write('fechaSincronizacion: $fechaSincronizacion, ')
          ..write('tiendaId: $tiendaId')
          ..write(')'))
        .toString();
  }
}

class $DetalleVentasTable extends DetalleVentas
    with TableInfo<$DetalleVentasTable, DetalleVenta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DetalleVentasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _ventaIdMeta =
      const VerificationMeta('ventaId');
  @override
  late final GeneratedColumn<int> ventaId = GeneratedColumn<int>(
      'venta_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _productoIdMeta =
      const VerificationMeta('productoId');
  @override
  late final GeneratedColumn<int> productoId = GeneratedColumn<int>(
      'producto_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _cantidadMeta =
      const VerificationMeta('cantidad');
  @override
  late final GeneratedColumn<int> cantidad = GeneratedColumn<int>(
      'cantidad', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _precioUnitarioMeta =
      const VerificationMeta('precioUnitario');
  @override
  late final GeneratedColumn<double> precioUnitario = GeneratedColumn<double>(
      'precio_unitario', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _subtotalMeta =
      const VerificationMeta('subtotal');
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
      'subtotal', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _descuentoItemMeta =
      const VerificationMeta('descuentoItem');
  @override
  late final GeneratedColumn<double> descuentoItem = GeneratedColumn<double>(
      'descuento_item', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        ventaId,
        productoId,
        cantidad,
        precioUnitario,
        subtotal,
        descuentoItem
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'detalle_ventas';
  @override
  VerificationContext validateIntegrity(Insertable<DetalleVenta> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('venta_id')) {
      context.handle(_ventaIdMeta,
          ventaId.isAcceptableOrUnknown(data['venta_id']!, _ventaIdMeta));
    } else if (isInserting) {
      context.missing(_ventaIdMeta);
    }
    if (data.containsKey('producto_id')) {
      context.handle(
          _productoIdMeta,
          productoId.isAcceptableOrUnknown(
              data['producto_id']!, _productoIdMeta));
    } else if (isInserting) {
      context.missing(_productoIdMeta);
    }
    if (data.containsKey('cantidad')) {
      context.handle(_cantidadMeta,
          cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta));
    } else if (isInserting) {
      context.missing(_cantidadMeta);
    }
    if (data.containsKey('precio_unitario')) {
      context.handle(
          _precioUnitarioMeta,
          precioUnitario.isAcceptableOrUnknown(
              data['precio_unitario']!, _precioUnitarioMeta));
    } else if (isInserting) {
      context.missing(_precioUnitarioMeta);
    }
    if (data.containsKey('subtotal')) {
      context.handle(_subtotalMeta,
          subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta));
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    if (data.containsKey('descuento_item')) {
      context.handle(
          _descuentoItemMeta,
          descuentoItem.isAcceptableOrUnknown(
              data['descuento_item']!, _descuentoItemMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {ventaId, productoId},
      ];
  @override
  DetalleVenta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DetalleVenta(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      ventaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}venta_id'])!,
      productoId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}producto_id'])!,
      cantidad: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cantidad'])!,
      precioUnitario: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}precio_unitario'])!,
      subtotal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}subtotal'])!,
      descuentoItem: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}descuento_item'])!,
    );
  }

  @override
  $DetalleVentasTable createAlias(String alias) {
    return $DetalleVentasTable(attachedDatabase, alias);
  }
}

class DetalleVenta extends DataClass implements Insertable<DetalleVenta> {
  final int id;
  final int ventaId;
  final int productoId;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;
  final double descuentoItem;
  const DetalleVenta(
      {required this.id,
      required this.ventaId,
      required this.productoId,
      required this.cantidad,
      required this.precioUnitario,
      required this.subtotal,
      required this.descuentoItem});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['venta_id'] = Variable<int>(ventaId);
    map['producto_id'] = Variable<int>(productoId);
    map['cantidad'] = Variable<int>(cantidad);
    map['precio_unitario'] = Variable<double>(precioUnitario);
    map['subtotal'] = Variable<double>(subtotal);
    map['descuento_item'] = Variable<double>(descuentoItem);
    return map;
  }

  DetalleVentasCompanion toCompanion(bool nullToAbsent) {
    return DetalleVentasCompanion(
      id: Value(id),
      ventaId: Value(ventaId),
      productoId: Value(productoId),
      cantidad: Value(cantidad),
      precioUnitario: Value(precioUnitario),
      subtotal: Value(subtotal),
      descuentoItem: Value(descuentoItem),
    );
  }

  factory DetalleVenta.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DetalleVenta(
      id: serializer.fromJson<int>(json['id']),
      ventaId: serializer.fromJson<int>(json['ventaId']),
      productoId: serializer.fromJson<int>(json['productoId']),
      cantidad: serializer.fromJson<int>(json['cantidad']),
      precioUnitario: serializer.fromJson<double>(json['precioUnitario']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      descuentoItem: serializer.fromJson<double>(json['descuentoItem']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ventaId': serializer.toJson<int>(ventaId),
      'productoId': serializer.toJson<int>(productoId),
      'cantidad': serializer.toJson<int>(cantidad),
      'precioUnitario': serializer.toJson<double>(precioUnitario),
      'subtotal': serializer.toJson<double>(subtotal),
      'descuentoItem': serializer.toJson<double>(descuentoItem),
    };
  }

  DetalleVenta copyWith(
          {int? id,
          int? ventaId,
          int? productoId,
          int? cantidad,
          double? precioUnitario,
          double? subtotal,
          double? descuentoItem}) =>
      DetalleVenta(
        id: id ?? this.id,
        ventaId: ventaId ?? this.ventaId,
        productoId: productoId ?? this.productoId,
        cantidad: cantidad ?? this.cantidad,
        precioUnitario: precioUnitario ?? this.precioUnitario,
        subtotal: subtotal ?? this.subtotal,
        descuentoItem: descuentoItem ?? this.descuentoItem,
      );
  DetalleVenta copyWithCompanion(DetalleVentasCompanion data) {
    return DetalleVenta(
      id: data.id.present ? data.id.value : this.id,
      ventaId: data.ventaId.present ? data.ventaId.value : this.ventaId,
      productoId:
          data.productoId.present ? data.productoId.value : this.productoId,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
      precioUnitario: data.precioUnitario.present
          ? data.precioUnitario.value
          : this.precioUnitario,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      descuentoItem: data.descuentoItem.present
          ? data.descuentoItem.value
          : this.descuentoItem,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DetalleVenta(')
          ..write('id: $id, ')
          ..write('ventaId: $ventaId, ')
          ..write('productoId: $productoId, ')
          ..write('cantidad: $cantidad, ')
          ..write('precioUnitario: $precioUnitario, ')
          ..write('subtotal: $subtotal, ')
          ..write('descuentoItem: $descuentoItem')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ventaId, productoId, cantidad,
      precioUnitario, subtotal, descuentoItem);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DetalleVenta &&
          other.id == this.id &&
          other.ventaId == this.ventaId &&
          other.productoId == this.productoId &&
          other.cantidad == this.cantidad &&
          other.precioUnitario == this.precioUnitario &&
          other.subtotal == this.subtotal &&
          other.descuentoItem == this.descuentoItem);
}

class DetalleVentasCompanion extends UpdateCompanion<DetalleVenta> {
  final Value<int> id;
  final Value<int> ventaId;
  final Value<int> productoId;
  final Value<int> cantidad;
  final Value<double> precioUnitario;
  final Value<double> subtotal;
  final Value<double> descuentoItem;
  const DetalleVentasCompanion({
    this.id = const Value.absent(),
    this.ventaId = const Value.absent(),
    this.productoId = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.precioUnitario = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.descuentoItem = const Value.absent(),
  });
  DetalleVentasCompanion.insert({
    this.id = const Value.absent(),
    required int ventaId,
    required int productoId,
    required int cantidad,
    required double precioUnitario,
    required double subtotal,
    this.descuentoItem = const Value.absent(),
  })  : ventaId = Value(ventaId),
        productoId = Value(productoId),
        cantidad = Value(cantidad),
        precioUnitario = Value(precioUnitario),
        subtotal = Value(subtotal);
  static Insertable<DetalleVenta> custom({
    Expression<int>? id,
    Expression<int>? ventaId,
    Expression<int>? productoId,
    Expression<int>? cantidad,
    Expression<double>? precioUnitario,
    Expression<double>? subtotal,
    Expression<double>? descuentoItem,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ventaId != null) 'venta_id': ventaId,
      if (productoId != null) 'producto_id': productoId,
      if (cantidad != null) 'cantidad': cantidad,
      if (precioUnitario != null) 'precio_unitario': precioUnitario,
      if (subtotal != null) 'subtotal': subtotal,
      if (descuentoItem != null) 'descuento_item': descuentoItem,
    });
  }

  DetalleVentasCompanion copyWith(
      {Value<int>? id,
      Value<int>? ventaId,
      Value<int>? productoId,
      Value<int>? cantidad,
      Value<double>? precioUnitario,
      Value<double>? subtotal,
      Value<double>? descuentoItem}) {
    return DetalleVentasCompanion(
      id: id ?? this.id,
      ventaId: ventaId ?? this.ventaId,
      productoId: productoId ?? this.productoId,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      subtotal: subtotal ?? this.subtotal,
      descuentoItem: descuentoItem ?? this.descuentoItem,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ventaId.present) {
      map['venta_id'] = Variable<int>(ventaId.value);
    }
    if (productoId.present) {
      map['producto_id'] = Variable<int>(productoId.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<int>(cantidad.value);
    }
    if (precioUnitario.present) {
      map['precio_unitario'] = Variable<double>(precioUnitario.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (descuentoItem.present) {
      map['descuento_item'] = Variable<double>(descuentoItem.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DetalleVentasCompanion(')
          ..write('id: $id, ')
          ..write('ventaId: $ventaId, ')
          ..write('productoId: $productoId, ')
          ..write('cantidad: $cantidad, ')
          ..write('precioUnitario: $precioUnitario, ')
          ..write('subtotal: $subtotal, ')
          ..write('descuentoItem: $descuentoItem')
          ..write(')'))
        .toString();
  }
}

class $UsuariosTiendaTable extends UsuariosTienda
    with TableInfo<$UsuariosTiendaTable, UsuarioTienda> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsuariosTiendaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
      'nombre', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _telefonoMeta =
      const VerificationMeta('telefono');
  @override
  late final GeneratedColumn<String> telefono = GeneratedColumn<String>(
      'telefono', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _rolMeta = const VerificationMeta('rol');
  @override
  late final GeneratedColumn<String> rol = GeneratedColumn<String>(
      'rol', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tiendaIdMeta =
      const VerificationMeta('tiendaId');
  @override
  late final GeneratedColumn<String> tiendaId = GeneratedColumn<String>(
      'tienda_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<bool> activo = GeneratedColumn<bool>(
      'activo', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("activo" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _fechaCreacionMeta =
      const VerificationMeta('fechaCreacion');
  @override
  late final GeneratedColumn<DateTime> fechaCreacion =
      GeneratedColumn<DateTime>('fecha_creacion', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  static const VerificationMeta _fechaUltimoAccesoMeta =
      const VerificationMeta('fechaUltimoAcceso');
  @override
  late final GeneratedColumn<DateTime> fechaUltimoAcceso =
      GeneratedColumn<DateTime>('fecha_ultimo_acceso', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        nombre,
        email,
        telefono,
        rol,
        tiendaId,
        activo,
        fechaCreacion,
        fechaUltimoAcceso
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'usuarios_tienda';
  @override
  VerificationContext validateIntegrity(Insertable<UsuarioTienda> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(_nombreMeta,
          nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta));
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('telefono')) {
      context.handle(_telefonoMeta,
          telefono.isAcceptableOrUnknown(data['telefono']!, _telefonoMeta));
    }
    if (data.containsKey('rol')) {
      context.handle(
          _rolMeta, rol.isAcceptableOrUnknown(data['rol']!, _rolMeta));
    } else if (isInserting) {
      context.missing(_rolMeta);
    }
    if (data.containsKey('tienda_id')) {
      context.handle(_tiendaIdMeta,
          tiendaId.isAcceptableOrUnknown(data['tienda_id']!, _tiendaIdMeta));
    } else if (isInserting) {
      context.missing(_tiendaIdMeta);
    }
    if (data.containsKey('activo')) {
      context.handle(_activoMeta,
          activo.isAcceptableOrUnknown(data['activo']!, _activoMeta));
    }
    if (data.containsKey('fecha_creacion')) {
      context.handle(
          _fechaCreacionMeta,
          fechaCreacion.isAcceptableOrUnknown(
              data['fecha_creacion']!, _fechaCreacionMeta));
    }
    if (data.containsKey('fecha_ultimo_acceso')) {
      context.handle(
          _fechaUltimoAccesoMeta,
          fechaUltimoAcceso.isAcceptableOrUnknown(
              data['fecha_ultimo_acceso']!, _fechaUltimoAccesoMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {email},
      ];
  @override
  UsuarioTienda map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UsuarioTienda(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nombre: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nombre'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      telefono: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}telefono']),
      rol: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rol'])!,
      tiendaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tienda_id'])!,
      activo: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}activo'])!,
      fechaCreacion: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_creacion'])!,
      fechaUltimoAcceso: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_ultimo_acceso']),
    );
  }

  @override
  $UsuariosTiendaTable createAlias(String alias) {
    return $UsuariosTiendaTable(attachedDatabase, alias);
  }
}

class UsuarioTienda extends DataClass implements Insertable<UsuarioTienda> {
  final int id;
  final String nombre;
  final String email;
  final String? telefono;
  final String rol;
  final String tiendaId;
  final bool activo;
  final DateTime fechaCreacion;
  final DateTime? fechaUltimoAcceso;
  const UsuarioTienda(
      {required this.id,
      required this.nombre,
      required this.email,
      this.telefono,
      required this.rol,
      required this.tiendaId,
      required this.activo,
      required this.fechaCreacion,
      this.fechaUltimoAcceso});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    map['email'] = Variable<String>(email);
    if (!nullToAbsent || telefono != null) {
      map['telefono'] = Variable<String>(telefono);
    }
    map['rol'] = Variable<String>(rol);
    map['tienda_id'] = Variable<String>(tiendaId);
    map['activo'] = Variable<bool>(activo);
    map['fecha_creacion'] = Variable<DateTime>(fechaCreacion);
    if (!nullToAbsent || fechaUltimoAcceso != null) {
      map['fecha_ultimo_acceso'] = Variable<DateTime>(fechaUltimoAcceso);
    }
    return map;
  }

  UsuariosTiendaCompanion toCompanion(bool nullToAbsent) {
    return UsuariosTiendaCompanion(
      id: Value(id),
      nombre: Value(nombre),
      email: Value(email),
      telefono: telefono == null && nullToAbsent
          ? const Value.absent()
          : Value(telefono),
      rol: Value(rol),
      tiendaId: Value(tiendaId),
      activo: Value(activo),
      fechaCreacion: Value(fechaCreacion),
      fechaUltimoAcceso: fechaUltimoAcceso == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaUltimoAcceso),
    );
  }

  factory UsuarioTienda.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UsuarioTienda(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      email: serializer.fromJson<String>(json['email']),
      telefono: serializer.fromJson<String?>(json['telefono']),
      rol: serializer.fromJson<String>(json['rol']),
      tiendaId: serializer.fromJson<String>(json['tiendaId']),
      activo: serializer.fromJson<bool>(json['activo']),
      fechaCreacion: serializer.fromJson<DateTime>(json['fechaCreacion']),
      fechaUltimoAcceso:
          serializer.fromJson<DateTime?>(json['fechaUltimoAcceso']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombre': serializer.toJson<String>(nombre),
      'email': serializer.toJson<String>(email),
      'telefono': serializer.toJson<String?>(telefono),
      'rol': serializer.toJson<String>(rol),
      'tiendaId': serializer.toJson<String>(tiendaId),
      'activo': serializer.toJson<bool>(activo),
      'fechaCreacion': serializer.toJson<DateTime>(fechaCreacion),
      'fechaUltimoAcceso': serializer.toJson<DateTime?>(fechaUltimoAcceso),
    };
  }

  UsuarioTienda copyWith(
          {int? id,
          String? nombre,
          String? email,
          Value<String?> telefono = const Value.absent(),
          String? rol,
          String? tiendaId,
          bool? activo,
          DateTime? fechaCreacion,
          Value<DateTime?> fechaUltimoAcceso = const Value.absent()}) =>
      UsuarioTienda(
        id: id ?? this.id,
        nombre: nombre ?? this.nombre,
        email: email ?? this.email,
        telefono: telefono.present ? telefono.value : this.telefono,
        rol: rol ?? this.rol,
        tiendaId: tiendaId ?? this.tiendaId,
        activo: activo ?? this.activo,
        fechaCreacion: fechaCreacion ?? this.fechaCreacion,
        fechaUltimoAcceso: fechaUltimoAcceso.present
            ? fechaUltimoAcceso.value
            : this.fechaUltimoAcceso,
      );
  UsuarioTienda copyWithCompanion(UsuariosTiendaCompanion data) {
    return UsuarioTienda(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      email: data.email.present ? data.email.value : this.email,
      telefono: data.telefono.present ? data.telefono.value : this.telefono,
      rol: data.rol.present ? data.rol.value : this.rol,
      tiendaId: data.tiendaId.present ? data.tiendaId.value : this.tiendaId,
      activo: data.activo.present ? data.activo.value : this.activo,
      fechaCreacion: data.fechaCreacion.present
          ? data.fechaCreacion.value
          : this.fechaCreacion,
      fechaUltimoAcceso: data.fechaUltimoAcceso.present
          ? data.fechaUltimoAcceso.value
          : this.fechaUltimoAcceso,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UsuarioTienda(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('email: $email, ')
          ..write('telefono: $telefono, ')
          ..write('rol: $rol, ')
          ..write('tiendaId: $tiendaId, ')
          ..write('activo: $activo, ')
          ..write('fechaCreacion: $fechaCreacion, ')
          ..write('fechaUltimoAcceso: $fechaUltimoAcceso')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nombre, email, telefono, rol, tiendaId,
      activo, fechaCreacion, fechaUltimoAcceso);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsuarioTienda &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.email == this.email &&
          other.telefono == this.telefono &&
          other.rol == this.rol &&
          other.tiendaId == this.tiendaId &&
          other.activo == this.activo &&
          other.fechaCreacion == this.fechaCreacion &&
          other.fechaUltimoAcceso == this.fechaUltimoAcceso);
}

class UsuariosTiendaCompanion extends UpdateCompanion<UsuarioTienda> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<String> email;
  final Value<String?> telefono;
  final Value<String> rol;
  final Value<String> tiendaId;
  final Value<bool> activo;
  final Value<DateTime> fechaCreacion;
  final Value<DateTime?> fechaUltimoAcceso;
  const UsuariosTiendaCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.email = const Value.absent(),
    this.telefono = const Value.absent(),
    this.rol = const Value.absent(),
    this.tiendaId = const Value.absent(),
    this.activo = const Value.absent(),
    this.fechaCreacion = const Value.absent(),
    this.fechaUltimoAcceso = const Value.absent(),
  });
  UsuariosTiendaCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    required String email,
    this.telefono = const Value.absent(),
    required String rol,
    required String tiendaId,
    this.activo = const Value.absent(),
    this.fechaCreacion = const Value.absent(),
    this.fechaUltimoAcceso = const Value.absent(),
  })  : nombre = Value(nombre),
        email = Value(email),
        rol = Value(rol),
        tiendaId = Value(tiendaId);
  static Insertable<UsuarioTienda> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<String>? email,
    Expression<String>? telefono,
    Expression<String>? rol,
    Expression<String>? tiendaId,
    Expression<bool>? activo,
    Expression<DateTime>? fechaCreacion,
    Expression<DateTime>? fechaUltimoAcceso,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (email != null) 'email': email,
      if (telefono != null) 'telefono': telefono,
      if (rol != null) 'rol': rol,
      if (tiendaId != null) 'tienda_id': tiendaId,
      if (activo != null) 'activo': activo,
      if (fechaCreacion != null) 'fecha_creacion': fechaCreacion,
      if (fechaUltimoAcceso != null) 'fecha_ultimo_acceso': fechaUltimoAcceso,
    });
  }

  UsuariosTiendaCompanion copyWith(
      {Value<int>? id,
      Value<String>? nombre,
      Value<String>? email,
      Value<String?>? telefono,
      Value<String>? rol,
      Value<String>? tiendaId,
      Value<bool>? activo,
      Value<DateTime>? fechaCreacion,
      Value<DateTime?>? fechaUltimoAcceso}) {
    return UsuariosTiendaCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      rol: rol ?? this.rol,
      tiendaId: tiendaId ?? this.tiendaId,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaUltimoAcceso: fechaUltimoAcceso ?? this.fechaUltimoAcceso,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (telefono.present) {
      map['telefono'] = Variable<String>(telefono.value);
    }
    if (rol.present) {
      map['rol'] = Variable<String>(rol.value);
    }
    if (tiendaId.present) {
      map['tienda_id'] = Variable<String>(tiendaId.value);
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    if (fechaCreacion.present) {
      map['fecha_creacion'] = Variable<DateTime>(fechaCreacion.value);
    }
    if (fechaUltimoAcceso.present) {
      map['fecha_ultimo_acceso'] = Variable<DateTime>(fechaUltimoAcceso.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsuariosTiendaCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('email: $email, ')
          ..write('telefono: $telefono, ')
          ..write('rol: $rol, ')
          ..write('tiendaId: $tiendaId, ')
          ..write('activo: $activo, ')
          ..write('fechaCreacion: $fechaCreacion, ')
          ..write('fechaUltimoAcceso: $fechaUltimoAcceso')
          ..write(')'))
        .toString();
  }
}

class $MovimientosInventarioTable extends MovimientosInventario
    with TableInfo<$MovimientosInventarioTable, MovimientoInventario> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MovimientosInventarioTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _productoIdMeta =
      const VerificationMeta('productoId');
  @override
  late final GeneratedColumn<int> productoId = GeneratedColumn<int>(
      'producto_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _tipoMovimientoMeta =
      const VerificationMeta('tipoMovimiento');
  @override
  late final GeneratedColumn<String> tipoMovimiento = GeneratedColumn<String>(
      'tipo_movimiento', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cantidadMeta =
      const VerificationMeta('cantidad');
  @override
  late final GeneratedColumn<int> cantidad = GeneratedColumn<int>(
      'cantidad', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _precioUnitarioMeta =
      const VerificationMeta('precioUnitario');
  @override
  late final GeneratedColumn<double> precioUnitario = GeneratedColumn<double>(
      'precio_unitario', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _motivoMeta = const VerificationMeta('motivo');
  @override
  late final GeneratedColumn<String> motivo = GeneratedColumn<String>(
      'motivo', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _referenciaDocumentoMeta =
      const VerificationMeta('referenciaDocumento');
  @override
  late final GeneratedColumn<String> referenciaDocumento =
      GeneratedColumn<String>('referencia_documento', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fechaMovimientoMeta =
      const VerificationMeta('fechaMovimiento');
  @override
  late final GeneratedColumn<DateTime> fechaMovimiento =
      GeneratedColumn<DateTime>('fecha_movimiento', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  static const VerificationMeta _usuarioIdMeta =
      const VerificationMeta('usuarioId');
  @override
  late final GeneratedColumn<String> usuarioId = GeneratedColumn<String>(
      'usuario_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sincronizadoNubeMeta =
      const VerificationMeta('sincronizadoNube');
  @override
  late final GeneratedColumn<bool> sincronizadoNube = GeneratedColumn<bool>(
      'sincronizado_nube', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("sincronizado_nube" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        productoId,
        tipoMovimiento,
        cantidad,
        precioUnitario,
        motivo,
        referenciaDocumento,
        fechaMovimiento,
        usuarioId,
        sincronizadoNube
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'movimientos_inventario';
  @override
  VerificationContext validateIntegrity(
      Insertable<MovimientoInventario> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('producto_id')) {
      context.handle(
          _productoIdMeta,
          productoId.isAcceptableOrUnknown(
              data['producto_id']!, _productoIdMeta));
    } else if (isInserting) {
      context.missing(_productoIdMeta);
    }
    if (data.containsKey('tipo_movimiento')) {
      context.handle(
          _tipoMovimientoMeta,
          tipoMovimiento.isAcceptableOrUnknown(
              data['tipo_movimiento']!, _tipoMovimientoMeta));
    } else if (isInserting) {
      context.missing(_tipoMovimientoMeta);
    }
    if (data.containsKey('cantidad')) {
      context.handle(_cantidadMeta,
          cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta));
    } else if (isInserting) {
      context.missing(_cantidadMeta);
    }
    if (data.containsKey('precio_unitario')) {
      context.handle(
          _precioUnitarioMeta,
          precioUnitario.isAcceptableOrUnknown(
              data['precio_unitario']!, _precioUnitarioMeta));
    }
    if (data.containsKey('motivo')) {
      context.handle(_motivoMeta,
          motivo.isAcceptableOrUnknown(data['motivo']!, _motivoMeta));
    }
    if (data.containsKey('referencia_documento')) {
      context.handle(
          _referenciaDocumentoMeta,
          referenciaDocumento.isAcceptableOrUnknown(
              data['referencia_documento']!, _referenciaDocumentoMeta));
    }
    if (data.containsKey('fecha_movimiento')) {
      context.handle(
          _fechaMovimientoMeta,
          fechaMovimiento.isAcceptableOrUnknown(
              data['fecha_movimiento']!, _fechaMovimientoMeta));
    }
    if (data.containsKey('usuario_id')) {
      context.handle(_usuarioIdMeta,
          usuarioId.isAcceptableOrUnknown(data['usuario_id']!, _usuarioIdMeta));
    } else if (isInserting) {
      context.missing(_usuarioIdMeta);
    }
    if (data.containsKey('sincronizado_nube')) {
      context.handle(
          _sincronizadoNubeMeta,
          sincronizadoNube.isAcceptableOrUnknown(
              data['sincronizado_nube']!, _sincronizadoNubeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MovimientoInventario map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MovimientoInventario(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      productoId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}producto_id'])!,
      tipoMovimiento: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}tipo_movimiento'])!,
      cantidad: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cantidad'])!,
      precioUnitario: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}precio_unitario']),
      motivo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}motivo']),
      referenciaDocumento: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}referencia_documento']),
      fechaMovimiento: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_movimiento'])!,
      usuarioId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}usuario_id'])!,
      sincronizadoNube: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}sincronizado_nube'])!,
    );
  }

  @override
  $MovimientosInventarioTable createAlias(String alias) {
    return $MovimientosInventarioTable(attachedDatabase, alias);
  }
}

class MovimientoInventario extends DataClass
    implements Insertable<MovimientoInventario> {
  final int id;
  final int productoId;
  final String tipoMovimiento;
  final int cantidad;
  final double? precioUnitario;
  final String? motivo;
  final String? referenciaDocumento;
  final DateTime fechaMovimiento;
  final String usuarioId;
  final bool sincronizadoNube;
  const MovimientoInventario(
      {required this.id,
      required this.productoId,
      required this.tipoMovimiento,
      required this.cantidad,
      this.precioUnitario,
      this.motivo,
      this.referenciaDocumento,
      required this.fechaMovimiento,
      required this.usuarioId,
      required this.sincronizadoNube});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['producto_id'] = Variable<int>(productoId);
    map['tipo_movimiento'] = Variable<String>(tipoMovimiento);
    map['cantidad'] = Variable<int>(cantidad);
    if (!nullToAbsent || precioUnitario != null) {
      map['precio_unitario'] = Variable<double>(precioUnitario);
    }
    if (!nullToAbsent || motivo != null) {
      map['motivo'] = Variable<String>(motivo);
    }
    if (!nullToAbsent || referenciaDocumento != null) {
      map['referencia_documento'] = Variable<String>(referenciaDocumento);
    }
    map['fecha_movimiento'] = Variable<DateTime>(fechaMovimiento);
    map['usuario_id'] = Variable<String>(usuarioId);
    map['sincronizado_nube'] = Variable<bool>(sincronizadoNube);
    return map;
  }

  MovimientosInventarioCompanion toCompanion(bool nullToAbsent) {
    return MovimientosInventarioCompanion(
      id: Value(id),
      productoId: Value(productoId),
      tipoMovimiento: Value(tipoMovimiento),
      cantidad: Value(cantidad),
      precioUnitario: precioUnitario == null && nullToAbsent
          ? const Value.absent()
          : Value(precioUnitario),
      motivo:
          motivo == null && nullToAbsent ? const Value.absent() : Value(motivo),
      referenciaDocumento: referenciaDocumento == null && nullToAbsent
          ? const Value.absent()
          : Value(referenciaDocumento),
      fechaMovimiento: Value(fechaMovimiento),
      usuarioId: Value(usuarioId),
      sincronizadoNube: Value(sincronizadoNube),
    );
  }

  factory MovimientoInventario.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MovimientoInventario(
      id: serializer.fromJson<int>(json['id']),
      productoId: serializer.fromJson<int>(json['productoId']),
      tipoMovimiento: serializer.fromJson<String>(json['tipoMovimiento']),
      cantidad: serializer.fromJson<int>(json['cantidad']),
      precioUnitario: serializer.fromJson<double?>(json['precioUnitario']),
      motivo: serializer.fromJson<String?>(json['motivo']),
      referenciaDocumento:
          serializer.fromJson<String?>(json['referenciaDocumento']),
      fechaMovimiento: serializer.fromJson<DateTime>(json['fechaMovimiento']),
      usuarioId: serializer.fromJson<String>(json['usuarioId']),
      sincronizadoNube: serializer.fromJson<bool>(json['sincronizadoNube']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'productoId': serializer.toJson<int>(productoId),
      'tipoMovimiento': serializer.toJson<String>(tipoMovimiento),
      'cantidad': serializer.toJson<int>(cantidad),
      'precioUnitario': serializer.toJson<double?>(precioUnitario),
      'motivo': serializer.toJson<String?>(motivo),
      'referenciaDocumento': serializer.toJson<String?>(referenciaDocumento),
      'fechaMovimiento': serializer.toJson<DateTime>(fechaMovimiento),
      'usuarioId': serializer.toJson<String>(usuarioId),
      'sincronizadoNube': serializer.toJson<bool>(sincronizadoNube),
    };
  }

  MovimientoInventario copyWith(
          {int? id,
          int? productoId,
          String? tipoMovimiento,
          int? cantidad,
          Value<double?> precioUnitario = const Value.absent(),
          Value<String?> motivo = const Value.absent(),
          Value<String?> referenciaDocumento = const Value.absent(),
          DateTime? fechaMovimiento,
          String? usuarioId,
          bool? sincronizadoNube}) =>
      MovimientoInventario(
        id: id ?? this.id,
        productoId: productoId ?? this.productoId,
        tipoMovimiento: tipoMovimiento ?? this.tipoMovimiento,
        cantidad: cantidad ?? this.cantidad,
        precioUnitario:
            precioUnitario.present ? precioUnitario.value : this.precioUnitario,
        motivo: motivo.present ? motivo.value : this.motivo,
        referenciaDocumento: referenciaDocumento.present
            ? referenciaDocumento.value
            : this.referenciaDocumento,
        fechaMovimiento: fechaMovimiento ?? this.fechaMovimiento,
        usuarioId: usuarioId ?? this.usuarioId,
        sincronizadoNube: sincronizadoNube ?? this.sincronizadoNube,
      );
  MovimientoInventario copyWithCompanion(MovimientosInventarioCompanion data) {
    return MovimientoInventario(
      id: data.id.present ? data.id.value : this.id,
      productoId:
          data.productoId.present ? data.productoId.value : this.productoId,
      tipoMovimiento: data.tipoMovimiento.present
          ? data.tipoMovimiento.value
          : this.tipoMovimiento,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
      precioUnitario: data.precioUnitario.present
          ? data.precioUnitario.value
          : this.precioUnitario,
      motivo: data.motivo.present ? data.motivo.value : this.motivo,
      referenciaDocumento: data.referenciaDocumento.present
          ? data.referenciaDocumento.value
          : this.referenciaDocumento,
      fechaMovimiento: data.fechaMovimiento.present
          ? data.fechaMovimiento.value
          : this.fechaMovimiento,
      usuarioId: data.usuarioId.present ? data.usuarioId.value : this.usuarioId,
      sincronizadoNube: data.sincronizadoNube.present
          ? data.sincronizadoNube.value
          : this.sincronizadoNube,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MovimientoInventario(')
          ..write('id: $id, ')
          ..write('productoId: $productoId, ')
          ..write('tipoMovimiento: $tipoMovimiento, ')
          ..write('cantidad: $cantidad, ')
          ..write('precioUnitario: $precioUnitario, ')
          ..write('motivo: $motivo, ')
          ..write('referenciaDocumento: $referenciaDocumento, ')
          ..write('fechaMovimiento: $fechaMovimiento, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('sincronizadoNube: $sincronizadoNube')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      productoId,
      tipoMovimiento,
      cantidad,
      precioUnitario,
      motivo,
      referenciaDocumento,
      fechaMovimiento,
      usuarioId,
      sincronizadoNube);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MovimientoInventario &&
          other.id == this.id &&
          other.productoId == this.productoId &&
          other.tipoMovimiento == this.tipoMovimiento &&
          other.cantidad == this.cantidad &&
          other.precioUnitario == this.precioUnitario &&
          other.motivo == this.motivo &&
          other.referenciaDocumento == this.referenciaDocumento &&
          other.fechaMovimiento == this.fechaMovimiento &&
          other.usuarioId == this.usuarioId &&
          other.sincronizadoNube == this.sincronizadoNube);
}

class MovimientosInventarioCompanion
    extends UpdateCompanion<MovimientoInventario> {
  final Value<int> id;
  final Value<int> productoId;
  final Value<String> tipoMovimiento;
  final Value<int> cantidad;
  final Value<double?> precioUnitario;
  final Value<String?> motivo;
  final Value<String?> referenciaDocumento;
  final Value<DateTime> fechaMovimiento;
  final Value<String> usuarioId;
  final Value<bool> sincronizadoNube;
  const MovimientosInventarioCompanion({
    this.id = const Value.absent(),
    this.productoId = const Value.absent(),
    this.tipoMovimiento = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.precioUnitario = const Value.absent(),
    this.motivo = const Value.absent(),
    this.referenciaDocumento = const Value.absent(),
    this.fechaMovimiento = const Value.absent(),
    this.usuarioId = const Value.absent(),
    this.sincronizadoNube = const Value.absent(),
  });
  MovimientosInventarioCompanion.insert({
    this.id = const Value.absent(),
    required int productoId,
    required String tipoMovimiento,
    required int cantidad,
    this.precioUnitario = const Value.absent(),
    this.motivo = const Value.absent(),
    this.referenciaDocumento = const Value.absent(),
    this.fechaMovimiento = const Value.absent(),
    required String usuarioId,
    this.sincronizadoNube = const Value.absent(),
  })  : productoId = Value(productoId),
        tipoMovimiento = Value(tipoMovimiento),
        cantidad = Value(cantidad),
        usuarioId = Value(usuarioId);
  static Insertable<MovimientoInventario> custom({
    Expression<int>? id,
    Expression<int>? productoId,
    Expression<String>? tipoMovimiento,
    Expression<int>? cantidad,
    Expression<double>? precioUnitario,
    Expression<String>? motivo,
    Expression<String>? referenciaDocumento,
    Expression<DateTime>? fechaMovimiento,
    Expression<String>? usuarioId,
    Expression<bool>? sincronizadoNube,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productoId != null) 'producto_id': productoId,
      if (tipoMovimiento != null) 'tipo_movimiento': tipoMovimiento,
      if (cantidad != null) 'cantidad': cantidad,
      if (precioUnitario != null) 'precio_unitario': precioUnitario,
      if (motivo != null) 'motivo': motivo,
      if (referenciaDocumento != null)
        'referencia_documento': referenciaDocumento,
      if (fechaMovimiento != null) 'fecha_movimiento': fechaMovimiento,
      if (usuarioId != null) 'usuario_id': usuarioId,
      if (sincronizadoNube != null) 'sincronizado_nube': sincronizadoNube,
    });
  }

  MovimientosInventarioCompanion copyWith(
      {Value<int>? id,
      Value<int>? productoId,
      Value<String>? tipoMovimiento,
      Value<int>? cantidad,
      Value<double?>? precioUnitario,
      Value<String?>? motivo,
      Value<String?>? referenciaDocumento,
      Value<DateTime>? fechaMovimiento,
      Value<String>? usuarioId,
      Value<bool>? sincronizadoNube}) {
    return MovimientosInventarioCompanion(
      id: id ?? this.id,
      productoId: productoId ?? this.productoId,
      tipoMovimiento: tipoMovimiento ?? this.tipoMovimiento,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      motivo: motivo ?? this.motivo,
      referenciaDocumento: referenciaDocumento ?? this.referenciaDocumento,
      fechaMovimiento: fechaMovimiento ?? this.fechaMovimiento,
      usuarioId: usuarioId ?? this.usuarioId,
      sincronizadoNube: sincronizadoNube ?? this.sincronizadoNube,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (productoId.present) {
      map['producto_id'] = Variable<int>(productoId.value);
    }
    if (tipoMovimiento.present) {
      map['tipo_movimiento'] = Variable<String>(tipoMovimiento.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<int>(cantidad.value);
    }
    if (precioUnitario.present) {
      map['precio_unitario'] = Variable<double>(precioUnitario.value);
    }
    if (motivo.present) {
      map['motivo'] = Variable<String>(motivo.value);
    }
    if (referenciaDocumento.present) {
      map['referencia_documento'] = Variable<String>(referenciaDocumento.value);
    }
    if (fechaMovimiento.present) {
      map['fecha_movimiento'] = Variable<DateTime>(fechaMovimiento.value);
    }
    if (usuarioId.present) {
      map['usuario_id'] = Variable<String>(usuarioId.value);
    }
    if (sincronizadoNube.present) {
      map['sincronizado_nube'] = Variable<bool>(sincronizadoNube.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MovimientosInventarioCompanion(')
          ..write('id: $id, ')
          ..write('productoId: $productoId, ')
          ..write('tipoMovimiento: $tipoMovimiento, ')
          ..write('cantidad: $cantidad, ')
          ..write('precioUnitario: $precioUnitario, ')
          ..write('motivo: $motivo, ')
          ..write('referenciaDocumento: $referenciaDocumento, ')
          ..write('fechaMovimiento: $fechaMovimiento, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('sincronizadoNube: $sincronizadoNube')
          ..write(')'))
        .toString();
  }
}

class $ConfiguracionesLocalesTable extends ConfiguracionesLocales
    with TableInfo<$ConfiguracionesLocalesTable, ConfiguracionLocal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConfiguracionesLocalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _claveMeta = const VerificationMeta('clave');
  @override
  late final GeneratedColumn<String> clave = GeneratedColumn<String>(
      'clave', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<String> valor = GeneratedColumn<String>(
      'valor', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descripcionMeta =
      const VerificationMeta('descripcion');
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
      'descripcion', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fechaActualizacionMeta =
      const VerificationMeta('fechaActualizacion');
  @override
  late final GeneratedColumn<DateTime> fechaActualizacion =
      GeneratedColumn<DateTime>('fecha_actualizacion', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, clave, valor, descripcion, fechaActualizacion];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'configuraciones_locales';
  @override
  VerificationContext validateIntegrity(Insertable<ConfiguracionLocal> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('clave')) {
      context.handle(
          _claveMeta, clave.isAcceptableOrUnknown(data['clave']!, _claveMeta));
    } else if (isInserting) {
      context.missing(_claveMeta);
    }
    if (data.containsKey('valor')) {
      context.handle(
          _valorMeta, valor.isAcceptableOrUnknown(data['valor']!, _valorMeta));
    } else if (isInserting) {
      context.missing(_valorMeta);
    }
    if (data.containsKey('descripcion')) {
      context.handle(
          _descripcionMeta,
          descripcion.isAcceptableOrUnknown(
              data['descripcion']!, _descripcionMeta));
    }
    if (data.containsKey('fecha_actualizacion')) {
      context.handle(
          _fechaActualizacionMeta,
          fechaActualizacion.isAcceptableOrUnknown(
              data['fecha_actualizacion']!, _fechaActualizacionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {clave},
      ];
  @override
  ConfiguracionLocal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConfiguracionLocal(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      clave: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}clave'])!,
      valor: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}valor'])!,
      descripcion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}descripcion']),
      fechaActualizacion: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}fecha_actualizacion'])!,
    );
  }

  @override
  $ConfiguracionesLocalesTable createAlias(String alias) {
    return $ConfiguracionesLocalesTable(attachedDatabase, alias);
  }
}

class ConfiguracionLocal extends DataClass
    implements Insertable<ConfiguracionLocal> {
  final int id;
  final String clave;
  final String valor;
  final String? descripcion;
  final DateTime fechaActualizacion;
  const ConfiguracionLocal(
      {required this.id,
      required this.clave,
      required this.valor,
      this.descripcion,
      required this.fechaActualizacion});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['clave'] = Variable<String>(clave);
    map['valor'] = Variable<String>(valor);
    if (!nullToAbsent || descripcion != null) {
      map['descripcion'] = Variable<String>(descripcion);
    }
    map['fecha_actualizacion'] = Variable<DateTime>(fechaActualizacion);
    return map;
  }

  ConfiguracionesLocalesCompanion toCompanion(bool nullToAbsent) {
    return ConfiguracionesLocalesCompanion(
      id: Value(id),
      clave: Value(clave),
      valor: Value(valor),
      descripcion: descripcion == null && nullToAbsent
          ? const Value.absent()
          : Value(descripcion),
      fechaActualizacion: Value(fechaActualizacion),
    );
  }

  factory ConfiguracionLocal.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConfiguracionLocal(
      id: serializer.fromJson<int>(json['id']),
      clave: serializer.fromJson<String>(json['clave']),
      valor: serializer.fromJson<String>(json['valor']),
      descripcion: serializer.fromJson<String?>(json['descripcion']),
      fechaActualizacion:
          serializer.fromJson<DateTime>(json['fechaActualizacion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'clave': serializer.toJson<String>(clave),
      'valor': serializer.toJson<String>(valor),
      'descripcion': serializer.toJson<String?>(descripcion),
      'fechaActualizacion': serializer.toJson<DateTime>(fechaActualizacion),
    };
  }

  ConfiguracionLocal copyWith(
          {int? id,
          String? clave,
          String? valor,
          Value<String?> descripcion = const Value.absent(),
          DateTime? fechaActualizacion}) =>
      ConfiguracionLocal(
        id: id ?? this.id,
        clave: clave ?? this.clave,
        valor: valor ?? this.valor,
        descripcion: descripcion.present ? descripcion.value : this.descripcion,
        fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      );
  ConfiguracionLocal copyWithCompanion(ConfiguracionesLocalesCompanion data) {
    return ConfiguracionLocal(
      id: data.id.present ? data.id.value : this.id,
      clave: data.clave.present ? data.clave.value : this.clave,
      valor: data.valor.present ? data.valor.value : this.valor,
      descripcion:
          data.descripcion.present ? data.descripcion.value : this.descripcion,
      fechaActualizacion: data.fechaActualizacion.present
          ? data.fechaActualizacion.value
          : this.fechaActualizacion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConfiguracionLocal(')
          ..write('id: $id, ')
          ..write('clave: $clave, ')
          ..write('valor: $valor, ')
          ..write('descripcion: $descripcion, ')
          ..write('fechaActualizacion: $fechaActualizacion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, clave, valor, descripcion, fechaActualizacion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConfiguracionLocal &&
          other.id == this.id &&
          other.clave == this.clave &&
          other.valor == this.valor &&
          other.descripcion == this.descripcion &&
          other.fechaActualizacion == this.fechaActualizacion);
}

class ConfiguracionesLocalesCompanion
    extends UpdateCompanion<ConfiguracionLocal> {
  final Value<int> id;
  final Value<String> clave;
  final Value<String> valor;
  final Value<String?> descripcion;
  final Value<DateTime> fechaActualizacion;
  const ConfiguracionesLocalesCompanion({
    this.id = const Value.absent(),
    this.clave = const Value.absent(),
    this.valor = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.fechaActualizacion = const Value.absent(),
  });
  ConfiguracionesLocalesCompanion.insert({
    this.id = const Value.absent(),
    required String clave,
    required String valor,
    this.descripcion = const Value.absent(),
    this.fechaActualizacion = const Value.absent(),
  })  : clave = Value(clave),
        valor = Value(valor);
  static Insertable<ConfiguracionLocal> custom({
    Expression<int>? id,
    Expression<String>? clave,
    Expression<String>? valor,
    Expression<String>? descripcion,
    Expression<DateTime>? fechaActualizacion,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clave != null) 'clave': clave,
      if (valor != null) 'valor': valor,
      if (descripcion != null) 'descripcion': descripcion,
      if (fechaActualizacion != null) 'fecha_actualizacion': fechaActualizacion,
    });
  }

  ConfiguracionesLocalesCompanion copyWith(
      {Value<int>? id,
      Value<String>? clave,
      Value<String>? valor,
      Value<String?>? descripcion,
      Value<DateTime>? fechaActualizacion}) {
    return ConfiguracionesLocalesCompanion(
      id: id ?? this.id,
      clave: clave ?? this.clave,
      valor: valor ?? this.valor,
      descripcion: descripcion ?? this.descripcion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (clave.present) {
      map['clave'] = Variable<String>(clave.value);
    }
    if (valor.present) {
      map['valor'] = Variable<String>(valor.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (fechaActualizacion.present) {
      map['fecha_actualizacion'] = Variable<DateTime>(fechaActualizacion.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConfiguracionesLocalesCompanion(')
          ..write('id: $id, ')
          ..write('clave: $clave, ')
          ..write('valor: $valor, ')
          ..write('descripcion: $descripcion, ')
          ..write('fechaActualizacion: $fechaActualizacion')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProductosTable productos = $ProductosTable(this);
  late final $VentasTable ventas = $VentasTable(this);
  late final $DetalleVentasTable detalleVentas = $DetalleVentasTable(this);
  late final $UsuariosTiendaTable usuariosTienda = $UsuariosTiendaTable(this);
  late final $MovimientosInventarioTable movimientosInventario =
      $MovimientosInventarioTable(this);
  late final $ConfiguracionesLocalesTable configuracionesLocales =
      $ConfiguracionesLocalesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        productos,
        ventas,
        detalleVentas,
        usuariosTienda,
        movimientosInventario,
        configuracionesLocales
      ];
}

typedef $$ProductosTableCreateCompanionBuilder = ProductosCompanion Function({
  Value<int> id,
  Value<String?> codigoBarras,
  required String nombre,
  Value<String?> descripcion,
  required String categoria,
  required double precioVenta,
  required double precioCompra,
  Value<double?> margenGanancia,
  required int stockActual,
  required int stockMinimo,
  Value<String> unidadMedida,
  Value<DateTime> fechaCreacion,
  Value<bool> activo,
  required String tiendaId,
});
typedef $$ProductosTableUpdateCompanionBuilder = ProductosCompanion Function({
  Value<int> id,
  Value<String?> codigoBarras,
  Value<String> nombre,
  Value<String?> descripcion,
  Value<String> categoria,
  Value<double> precioVenta,
  Value<double> precioCompra,
  Value<double?> margenGanancia,
  Value<int> stockActual,
  Value<int> stockMinimo,
  Value<String> unidadMedida,
  Value<DateTime> fechaCreacion,
  Value<bool> activo,
  Value<String> tiendaId,
});

class $$ProductosTableFilterComposer
    extends Composer<_$AppDatabase, $ProductosTable> {
  $$ProductosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get codigoBarras => $composableBuilder(
      column: $table.codigoBarras, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoria => $composableBuilder(
      column: $table.categoria, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get precioVenta => $composableBuilder(
      column: $table.precioVenta, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get precioCompra => $composableBuilder(
      column: $table.precioCompra, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get margenGanancia => $composableBuilder(
      column: $table.margenGanancia,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stockActual => $composableBuilder(
      column: $table.stockActual, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stockMinimo => $composableBuilder(
      column: $table.stockMinimo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unidadMedida => $composableBuilder(
      column: $table.unidadMedida, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaCreacion => $composableBuilder(
      column: $table.fechaCreacion, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get activo => $composableBuilder(
      column: $table.activo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tiendaId => $composableBuilder(
      column: $table.tiendaId, builder: (column) => ColumnFilters(column));
}

class $$ProductosTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductosTable> {
  $$ProductosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get codigoBarras => $composableBuilder(
      column: $table.codigoBarras,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoria => $composableBuilder(
      column: $table.categoria, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get precioVenta => $composableBuilder(
      column: $table.precioVenta, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get precioCompra => $composableBuilder(
      column: $table.precioCompra,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get margenGanancia => $composableBuilder(
      column: $table.margenGanancia,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stockActual => $composableBuilder(
      column: $table.stockActual, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stockMinimo => $composableBuilder(
      column: $table.stockMinimo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unidadMedida => $composableBuilder(
      column: $table.unidadMedida,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaCreacion => $composableBuilder(
      column: $table.fechaCreacion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get activo => $composableBuilder(
      column: $table.activo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tiendaId => $composableBuilder(
      column: $table.tiendaId, builder: (column) => ColumnOrderings(column));
}

class $$ProductosTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductosTable> {
  $$ProductosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get codigoBarras => $composableBuilder(
      column: $table.codigoBarras, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => column);

  GeneratedColumn<String> get categoria =>
      $composableBuilder(column: $table.categoria, builder: (column) => column);

  GeneratedColumn<double> get precioVenta => $composableBuilder(
      column: $table.precioVenta, builder: (column) => column);

  GeneratedColumn<double> get precioCompra => $composableBuilder(
      column: $table.precioCompra, builder: (column) => column);

  GeneratedColumn<double> get margenGanancia => $composableBuilder(
      column: $table.margenGanancia, builder: (column) => column);

  GeneratedColumn<int> get stockActual => $composableBuilder(
      column: $table.stockActual, builder: (column) => column);

  GeneratedColumn<int> get stockMinimo => $composableBuilder(
      column: $table.stockMinimo, builder: (column) => column);

  GeneratedColumn<String> get unidadMedida => $composableBuilder(
      column: $table.unidadMedida, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaCreacion => $composableBuilder(
      column: $table.fechaCreacion, builder: (column) => column);

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  GeneratedColumn<String> get tiendaId =>
      $composableBuilder(column: $table.tiendaId, builder: (column) => column);
}

class $$ProductosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProductosTable,
    Producto,
    $$ProductosTableFilterComposer,
    $$ProductosTableOrderingComposer,
    $$ProductosTableAnnotationComposer,
    $$ProductosTableCreateCompanionBuilder,
    $$ProductosTableUpdateCompanionBuilder,
    (Producto, BaseReferences<_$AppDatabase, $ProductosTable, Producto>),
    Producto,
    PrefetchHooks Function()> {
  $$ProductosTableTableManager(_$AppDatabase db, $ProductosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> codigoBarras = const Value.absent(),
            Value<String> nombre = const Value.absent(),
            Value<String?> descripcion = const Value.absent(),
            Value<String> categoria = const Value.absent(),
            Value<double> precioVenta = const Value.absent(),
            Value<double> precioCompra = const Value.absent(),
            Value<double?> margenGanancia = const Value.absent(),
            Value<int> stockActual = const Value.absent(),
            Value<int> stockMinimo = const Value.absent(),
            Value<String> unidadMedida = const Value.absent(),
            Value<DateTime> fechaCreacion = const Value.absent(),
            Value<bool> activo = const Value.absent(),
            Value<String> tiendaId = const Value.absent(),
          }) =>
              ProductosCompanion(
            id: id,
            codigoBarras: codigoBarras,
            nombre: nombre,
            descripcion: descripcion,
            categoria: categoria,
            precioVenta: precioVenta,
            precioCompra: precioCompra,
            margenGanancia: margenGanancia,
            stockActual: stockActual,
            stockMinimo: stockMinimo,
            unidadMedida: unidadMedida,
            fechaCreacion: fechaCreacion,
            activo: activo,
            tiendaId: tiendaId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> codigoBarras = const Value.absent(),
            required String nombre,
            Value<String?> descripcion = const Value.absent(),
            required String categoria,
            required double precioVenta,
            required double precioCompra,
            Value<double?> margenGanancia = const Value.absent(),
            required int stockActual,
            required int stockMinimo,
            Value<String> unidadMedida = const Value.absent(),
            Value<DateTime> fechaCreacion = const Value.absent(),
            Value<bool> activo = const Value.absent(),
            required String tiendaId,
          }) =>
              ProductosCompanion.insert(
            id: id,
            codigoBarras: codigoBarras,
            nombre: nombre,
            descripcion: descripcion,
            categoria: categoria,
            precioVenta: precioVenta,
            precioCompra: precioCompra,
            margenGanancia: margenGanancia,
            stockActual: stockActual,
            stockMinimo: stockMinimo,
            unidadMedida: unidadMedida,
            fechaCreacion: fechaCreacion,
            activo: activo,
            tiendaId: tiendaId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProductosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProductosTable,
    Producto,
    $$ProductosTableFilterComposer,
    $$ProductosTableOrderingComposer,
    $$ProductosTableAnnotationComposer,
    $$ProductosTableCreateCompanionBuilder,
    $$ProductosTableUpdateCompanionBuilder,
    (Producto, BaseReferences<_$AppDatabase, $ProductosTable, Producto>),
    Producto,
    PrefetchHooks Function()>;
typedef $$VentasTableCreateCompanionBuilder = VentasCompanion Function({
  Value<int> id,
  required DateTime fechaVenta,
  required double totalVenta,
  required String metodoPago,
  Value<String?> clienteId,
  required String usuarioId,
  Value<double> descuentoAplicado,
  Value<double?> latitud,
  Value<double?> longitud,
  Value<String?> direccionAproximada,
  Value<String?> zonaGeografica,
  Value<bool> sincronizadoNube,
  Value<DateTime?> fechaSincronizacion,
  required String tiendaId,
});
typedef $$VentasTableUpdateCompanionBuilder = VentasCompanion Function({
  Value<int> id,
  Value<DateTime> fechaVenta,
  Value<double> totalVenta,
  Value<String> metodoPago,
  Value<String?> clienteId,
  Value<String> usuarioId,
  Value<double> descuentoAplicado,
  Value<double?> latitud,
  Value<double?> longitud,
  Value<String?> direccionAproximada,
  Value<String?> zonaGeografica,
  Value<bool> sincronizadoNube,
  Value<DateTime?> fechaSincronizacion,
  Value<String> tiendaId,
});

class $$VentasTableFilterComposer
    extends Composer<_$AppDatabase, $VentasTable> {
  $$VentasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaVenta => $composableBuilder(
      column: $table.fechaVenta, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalVenta => $composableBuilder(
      column: $table.totalVenta, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metodoPago => $composableBuilder(
      column: $table.metodoPago, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clienteId => $composableBuilder(
      column: $table.clienteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get usuarioId => $composableBuilder(
      column: $table.usuarioId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get descuentoAplicado => $composableBuilder(
      column: $table.descuentoAplicado,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitud => $composableBuilder(
      column: $table.latitud, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitud => $composableBuilder(
      column: $table.longitud, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get direccionAproximada => $composableBuilder(
      column: $table.direccionAproximada,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get zonaGeografica => $composableBuilder(
      column: $table.zonaGeografica,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get sincronizadoNube => $composableBuilder(
      column: $table.sincronizadoNube,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaSincronizacion => $composableBuilder(
      column: $table.fechaSincronizacion,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tiendaId => $composableBuilder(
      column: $table.tiendaId, builder: (column) => ColumnFilters(column));
}

class $$VentasTableOrderingComposer
    extends Composer<_$AppDatabase, $VentasTable> {
  $$VentasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaVenta => $composableBuilder(
      column: $table.fechaVenta, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalVenta => $composableBuilder(
      column: $table.totalVenta, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metodoPago => $composableBuilder(
      column: $table.metodoPago, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clienteId => $composableBuilder(
      column: $table.clienteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get usuarioId => $composableBuilder(
      column: $table.usuarioId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get descuentoAplicado => $composableBuilder(
      column: $table.descuentoAplicado,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitud => $composableBuilder(
      column: $table.latitud, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitud => $composableBuilder(
      column: $table.longitud, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get direccionAproximada => $composableBuilder(
      column: $table.direccionAproximada,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get zonaGeografica => $composableBuilder(
      column: $table.zonaGeografica,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get sincronizadoNube => $composableBuilder(
      column: $table.sincronizadoNube,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaSincronizacion => $composableBuilder(
      column: $table.fechaSincronizacion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tiendaId => $composableBuilder(
      column: $table.tiendaId, builder: (column) => ColumnOrderings(column));
}

class $$VentasTableAnnotationComposer
    extends Composer<_$AppDatabase, $VentasTable> {
  $$VentasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaVenta => $composableBuilder(
      column: $table.fechaVenta, builder: (column) => column);

  GeneratedColumn<double> get totalVenta => $composableBuilder(
      column: $table.totalVenta, builder: (column) => column);

  GeneratedColumn<String> get metodoPago => $composableBuilder(
      column: $table.metodoPago, builder: (column) => column);

  GeneratedColumn<String> get clienteId =>
      $composableBuilder(column: $table.clienteId, builder: (column) => column);

  GeneratedColumn<String> get usuarioId =>
      $composableBuilder(column: $table.usuarioId, builder: (column) => column);

  GeneratedColumn<double> get descuentoAplicado => $composableBuilder(
      column: $table.descuentoAplicado, builder: (column) => column);

  GeneratedColumn<double> get latitud =>
      $composableBuilder(column: $table.latitud, builder: (column) => column);

  GeneratedColumn<double> get longitud =>
      $composableBuilder(column: $table.longitud, builder: (column) => column);

  GeneratedColumn<String> get direccionAproximada => $composableBuilder(
      column: $table.direccionAproximada, builder: (column) => column);

  GeneratedColumn<String> get zonaGeografica => $composableBuilder(
      column: $table.zonaGeografica, builder: (column) => column);

  GeneratedColumn<bool> get sincronizadoNube => $composableBuilder(
      column: $table.sincronizadoNube, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaSincronizacion => $composableBuilder(
      column: $table.fechaSincronizacion, builder: (column) => column);

  GeneratedColumn<String> get tiendaId =>
      $composableBuilder(column: $table.tiendaId, builder: (column) => column);
}

class $$VentasTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VentasTable,
    Venta,
    $$VentasTableFilterComposer,
    $$VentasTableOrderingComposer,
    $$VentasTableAnnotationComposer,
    $$VentasTableCreateCompanionBuilder,
    $$VentasTableUpdateCompanionBuilder,
    (Venta, BaseReferences<_$AppDatabase, $VentasTable, Venta>),
    Venta,
    PrefetchHooks Function()> {
  $$VentasTableTableManager(_$AppDatabase db, $VentasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VentasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VentasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VentasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> fechaVenta = const Value.absent(),
            Value<double> totalVenta = const Value.absent(),
            Value<String> metodoPago = const Value.absent(),
            Value<String?> clienteId = const Value.absent(),
            Value<String> usuarioId = const Value.absent(),
            Value<double> descuentoAplicado = const Value.absent(),
            Value<double?> latitud = const Value.absent(),
            Value<double?> longitud = const Value.absent(),
            Value<String?> direccionAproximada = const Value.absent(),
            Value<String?> zonaGeografica = const Value.absent(),
            Value<bool> sincronizadoNube = const Value.absent(),
            Value<DateTime?> fechaSincronizacion = const Value.absent(),
            Value<String> tiendaId = const Value.absent(),
          }) =>
              VentasCompanion(
            id: id,
            fechaVenta: fechaVenta,
            totalVenta: totalVenta,
            metodoPago: metodoPago,
            clienteId: clienteId,
            usuarioId: usuarioId,
            descuentoAplicado: descuentoAplicado,
            latitud: latitud,
            longitud: longitud,
            direccionAproximada: direccionAproximada,
            zonaGeografica: zonaGeografica,
            sincronizadoNube: sincronizadoNube,
            fechaSincronizacion: fechaSincronizacion,
            tiendaId: tiendaId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime fechaVenta,
            required double totalVenta,
            required String metodoPago,
            Value<String?> clienteId = const Value.absent(),
            required String usuarioId,
            Value<double> descuentoAplicado = const Value.absent(),
            Value<double?> latitud = const Value.absent(),
            Value<double?> longitud = const Value.absent(),
            Value<String?> direccionAproximada = const Value.absent(),
            Value<String?> zonaGeografica = const Value.absent(),
            Value<bool> sincronizadoNube = const Value.absent(),
            Value<DateTime?> fechaSincronizacion = const Value.absent(),
            required String tiendaId,
          }) =>
              VentasCompanion.insert(
            id: id,
            fechaVenta: fechaVenta,
            totalVenta: totalVenta,
            metodoPago: metodoPago,
            clienteId: clienteId,
            usuarioId: usuarioId,
            descuentoAplicado: descuentoAplicado,
            latitud: latitud,
            longitud: longitud,
            direccionAproximada: direccionAproximada,
            zonaGeografica: zonaGeografica,
            sincronizadoNube: sincronizadoNube,
            fechaSincronizacion: fechaSincronizacion,
            tiendaId: tiendaId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$VentasTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VentasTable,
    Venta,
    $$VentasTableFilterComposer,
    $$VentasTableOrderingComposer,
    $$VentasTableAnnotationComposer,
    $$VentasTableCreateCompanionBuilder,
    $$VentasTableUpdateCompanionBuilder,
    (Venta, BaseReferences<_$AppDatabase, $VentasTable, Venta>),
    Venta,
    PrefetchHooks Function()>;
typedef $$DetalleVentasTableCreateCompanionBuilder = DetalleVentasCompanion
    Function({
  Value<int> id,
  required int ventaId,
  required int productoId,
  required int cantidad,
  required double precioUnitario,
  required double subtotal,
  Value<double> descuentoItem,
});
typedef $$DetalleVentasTableUpdateCompanionBuilder = DetalleVentasCompanion
    Function({
  Value<int> id,
  Value<int> ventaId,
  Value<int> productoId,
  Value<int> cantidad,
  Value<double> precioUnitario,
  Value<double> subtotal,
  Value<double> descuentoItem,
});

class $$DetalleVentasTableFilterComposer
    extends Composer<_$AppDatabase, $DetalleVentasTable> {
  $$DetalleVentasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ventaId => $composableBuilder(
      column: $table.ventaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get productoId => $composableBuilder(
      column: $table.productoId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cantidad => $composableBuilder(
      column: $table.cantidad, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get precioUnitario => $composableBuilder(
      column: $table.precioUnitario,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get descuentoItem => $composableBuilder(
      column: $table.descuentoItem, builder: (column) => ColumnFilters(column));
}

class $$DetalleVentasTableOrderingComposer
    extends Composer<_$AppDatabase, $DetalleVentasTable> {
  $$DetalleVentasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ventaId => $composableBuilder(
      column: $table.ventaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get productoId => $composableBuilder(
      column: $table.productoId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cantidad => $composableBuilder(
      column: $table.cantidad, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get precioUnitario => $composableBuilder(
      column: $table.precioUnitario,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get descuentoItem => $composableBuilder(
      column: $table.descuentoItem,
      builder: (column) => ColumnOrderings(column));
}

class $$DetalleVentasTableAnnotationComposer
    extends Composer<_$AppDatabase, $DetalleVentasTable> {
  $$DetalleVentasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ventaId =>
      $composableBuilder(column: $table.ventaId, builder: (column) => column);

  GeneratedColumn<int> get productoId => $composableBuilder(
      column: $table.productoId, builder: (column) => column);

  GeneratedColumn<int> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  GeneratedColumn<double> get precioUnitario => $composableBuilder(
      column: $table.precioUnitario, builder: (column) => column);

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<double> get descuentoItem => $composableBuilder(
      column: $table.descuentoItem, builder: (column) => column);
}

class $$DetalleVentasTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DetalleVentasTable,
    DetalleVenta,
    $$DetalleVentasTableFilterComposer,
    $$DetalleVentasTableOrderingComposer,
    $$DetalleVentasTableAnnotationComposer,
    $$DetalleVentasTableCreateCompanionBuilder,
    $$DetalleVentasTableUpdateCompanionBuilder,
    (
      DetalleVenta,
      BaseReferences<_$AppDatabase, $DetalleVentasTable, DetalleVenta>
    ),
    DetalleVenta,
    PrefetchHooks Function()> {
  $$DetalleVentasTableTableManager(_$AppDatabase db, $DetalleVentasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DetalleVentasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DetalleVentasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DetalleVentasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> ventaId = const Value.absent(),
            Value<int> productoId = const Value.absent(),
            Value<int> cantidad = const Value.absent(),
            Value<double> precioUnitario = const Value.absent(),
            Value<double> subtotal = const Value.absent(),
            Value<double> descuentoItem = const Value.absent(),
          }) =>
              DetalleVentasCompanion(
            id: id,
            ventaId: ventaId,
            productoId: productoId,
            cantidad: cantidad,
            precioUnitario: precioUnitario,
            subtotal: subtotal,
            descuentoItem: descuentoItem,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int ventaId,
            required int productoId,
            required int cantidad,
            required double precioUnitario,
            required double subtotal,
            Value<double> descuentoItem = const Value.absent(),
          }) =>
              DetalleVentasCompanion.insert(
            id: id,
            ventaId: ventaId,
            productoId: productoId,
            cantidad: cantidad,
            precioUnitario: precioUnitario,
            subtotal: subtotal,
            descuentoItem: descuentoItem,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DetalleVentasTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DetalleVentasTable,
    DetalleVenta,
    $$DetalleVentasTableFilterComposer,
    $$DetalleVentasTableOrderingComposer,
    $$DetalleVentasTableAnnotationComposer,
    $$DetalleVentasTableCreateCompanionBuilder,
    $$DetalleVentasTableUpdateCompanionBuilder,
    (
      DetalleVenta,
      BaseReferences<_$AppDatabase, $DetalleVentasTable, DetalleVenta>
    ),
    DetalleVenta,
    PrefetchHooks Function()>;
typedef $$UsuariosTiendaTableCreateCompanionBuilder = UsuariosTiendaCompanion
    Function({
  Value<int> id,
  required String nombre,
  required String email,
  Value<String?> telefono,
  required String rol,
  required String tiendaId,
  Value<bool> activo,
  Value<DateTime> fechaCreacion,
  Value<DateTime?> fechaUltimoAcceso,
});
typedef $$UsuariosTiendaTableUpdateCompanionBuilder = UsuariosTiendaCompanion
    Function({
  Value<int> id,
  Value<String> nombre,
  Value<String> email,
  Value<String?> telefono,
  Value<String> rol,
  Value<String> tiendaId,
  Value<bool> activo,
  Value<DateTime> fechaCreacion,
  Value<DateTime?> fechaUltimoAcceso,
});

class $$UsuariosTiendaTableFilterComposer
    extends Composer<_$AppDatabase, $UsuariosTiendaTable> {
  $$UsuariosTiendaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get telefono => $composableBuilder(
      column: $table.telefono, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rol => $composableBuilder(
      column: $table.rol, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tiendaId => $composableBuilder(
      column: $table.tiendaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get activo => $composableBuilder(
      column: $table.activo, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaCreacion => $composableBuilder(
      column: $table.fechaCreacion, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaUltimoAcceso => $composableBuilder(
      column: $table.fechaUltimoAcceso,
      builder: (column) => ColumnFilters(column));
}

class $$UsuariosTiendaTableOrderingComposer
    extends Composer<_$AppDatabase, $UsuariosTiendaTable> {
  $$UsuariosTiendaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get telefono => $composableBuilder(
      column: $table.telefono, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rol => $composableBuilder(
      column: $table.rol, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tiendaId => $composableBuilder(
      column: $table.tiendaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get activo => $composableBuilder(
      column: $table.activo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaCreacion => $composableBuilder(
      column: $table.fechaCreacion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaUltimoAcceso => $composableBuilder(
      column: $table.fechaUltimoAcceso,
      builder: (column) => ColumnOrderings(column));
}

class $$UsuariosTiendaTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsuariosTiendaTable> {
  $$UsuariosTiendaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get telefono =>
      $composableBuilder(column: $table.telefono, builder: (column) => column);

  GeneratedColumn<String> get rol =>
      $composableBuilder(column: $table.rol, builder: (column) => column);

  GeneratedColumn<String> get tiendaId =>
      $composableBuilder(column: $table.tiendaId, builder: (column) => column);

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaCreacion => $composableBuilder(
      column: $table.fechaCreacion, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaUltimoAcceso => $composableBuilder(
      column: $table.fechaUltimoAcceso, builder: (column) => column);
}

class $$UsuariosTiendaTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsuariosTiendaTable,
    UsuarioTienda,
    $$UsuariosTiendaTableFilterComposer,
    $$UsuariosTiendaTableOrderingComposer,
    $$UsuariosTiendaTableAnnotationComposer,
    $$UsuariosTiendaTableCreateCompanionBuilder,
    $$UsuariosTiendaTableUpdateCompanionBuilder,
    (
      UsuarioTienda,
      BaseReferences<_$AppDatabase, $UsuariosTiendaTable, UsuarioTienda>
    ),
    UsuarioTienda,
    PrefetchHooks Function()> {
  $$UsuariosTiendaTableTableManager(
      _$AppDatabase db, $UsuariosTiendaTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsuariosTiendaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsuariosTiendaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsuariosTiendaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nombre = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String?> telefono = const Value.absent(),
            Value<String> rol = const Value.absent(),
            Value<String> tiendaId = const Value.absent(),
            Value<bool> activo = const Value.absent(),
            Value<DateTime> fechaCreacion = const Value.absent(),
            Value<DateTime?> fechaUltimoAcceso = const Value.absent(),
          }) =>
              UsuariosTiendaCompanion(
            id: id,
            nombre: nombre,
            email: email,
            telefono: telefono,
            rol: rol,
            tiendaId: tiendaId,
            activo: activo,
            fechaCreacion: fechaCreacion,
            fechaUltimoAcceso: fechaUltimoAcceso,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String nombre,
            required String email,
            Value<String?> telefono = const Value.absent(),
            required String rol,
            required String tiendaId,
            Value<bool> activo = const Value.absent(),
            Value<DateTime> fechaCreacion = const Value.absent(),
            Value<DateTime?> fechaUltimoAcceso = const Value.absent(),
          }) =>
              UsuariosTiendaCompanion.insert(
            id: id,
            nombre: nombre,
            email: email,
            telefono: telefono,
            rol: rol,
            tiendaId: tiendaId,
            activo: activo,
            fechaCreacion: fechaCreacion,
            fechaUltimoAcceso: fechaUltimoAcceso,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UsuariosTiendaTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsuariosTiendaTable,
    UsuarioTienda,
    $$UsuariosTiendaTableFilterComposer,
    $$UsuariosTiendaTableOrderingComposer,
    $$UsuariosTiendaTableAnnotationComposer,
    $$UsuariosTiendaTableCreateCompanionBuilder,
    $$UsuariosTiendaTableUpdateCompanionBuilder,
    (
      UsuarioTienda,
      BaseReferences<_$AppDatabase, $UsuariosTiendaTable, UsuarioTienda>
    ),
    UsuarioTienda,
    PrefetchHooks Function()>;
typedef $$MovimientosInventarioTableCreateCompanionBuilder
    = MovimientosInventarioCompanion Function({
  Value<int> id,
  required int productoId,
  required String tipoMovimiento,
  required int cantidad,
  Value<double?> precioUnitario,
  Value<String?> motivo,
  Value<String?> referenciaDocumento,
  Value<DateTime> fechaMovimiento,
  required String usuarioId,
  Value<bool> sincronizadoNube,
});
typedef $$MovimientosInventarioTableUpdateCompanionBuilder
    = MovimientosInventarioCompanion Function({
  Value<int> id,
  Value<int> productoId,
  Value<String> tipoMovimiento,
  Value<int> cantidad,
  Value<double?> precioUnitario,
  Value<String?> motivo,
  Value<String?> referenciaDocumento,
  Value<DateTime> fechaMovimiento,
  Value<String> usuarioId,
  Value<bool> sincronizadoNube,
});

class $$MovimientosInventarioTableFilterComposer
    extends Composer<_$AppDatabase, $MovimientosInventarioTable> {
  $$MovimientosInventarioTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get productoId => $composableBuilder(
      column: $table.productoId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tipoMovimiento => $composableBuilder(
      column: $table.tipoMovimiento,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cantidad => $composableBuilder(
      column: $table.cantidad, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get precioUnitario => $composableBuilder(
      column: $table.precioUnitario,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get motivo => $composableBuilder(
      column: $table.motivo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenciaDocumento => $composableBuilder(
      column: $table.referenciaDocumento,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaMovimiento => $composableBuilder(
      column: $table.fechaMovimiento,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get usuarioId => $composableBuilder(
      column: $table.usuarioId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get sincronizadoNube => $composableBuilder(
      column: $table.sincronizadoNube,
      builder: (column) => ColumnFilters(column));
}

class $$MovimientosInventarioTableOrderingComposer
    extends Composer<_$AppDatabase, $MovimientosInventarioTable> {
  $$MovimientosInventarioTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get productoId => $composableBuilder(
      column: $table.productoId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tipoMovimiento => $composableBuilder(
      column: $table.tipoMovimiento,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cantidad => $composableBuilder(
      column: $table.cantidad, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get precioUnitario => $composableBuilder(
      column: $table.precioUnitario,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get motivo => $composableBuilder(
      column: $table.motivo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenciaDocumento => $composableBuilder(
      column: $table.referenciaDocumento,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaMovimiento => $composableBuilder(
      column: $table.fechaMovimiento,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get usuarioId => $composableBuilder(
      column: $table.usuarioId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get sincronizadoNube => $composableBuilder(
      column: $table.sincronizadoNube,
      builder: (column) => ColumnOrderings(column));
}

class $$MovimientosInventarioTableAnnotationComposer
    extends Composer<_$AppDatabase, $MovimientosInventarioTable> {
  $$MovimientosInventarioTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get productoId => $composableBuilder(
      column: $table.productoId, builder: (column) => column);

  GeneratedColumn<String> get tipoMovimiento => $composableBuilder(
      column: $table.tipoMovimiento, builder: (column) => column);

  GeneratedColumn<int> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  GeneratedColumn<double> get precioUnitario => $composableBuilder(
      column: $table.precioUnitario, builder: (column) => column);

  GeneratedColumn<String> get motivo =>
      $composableBuilder(column: $table.motivo, builder: (column) => column);

  GeneratedColumn<String> get referenciaDocumento => $composableBuilder(
      column: $table.referenciaDocumento, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaMovimiento => $composableBuilder(
      column: $table.fechaMovimiento, builder: (column) => column);

  GeneratedColumn<String> get usuarioId =>
      $composableBuilder(column: $table.usuarioId, builder: (column) => column);

  GeneratedColumn<bool> get sincronizadoNube => $composableBuilder(
      column: $table.sincronizadoNube, builder: (column) => column);
}

class $$MovimientosInventarioTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MovimientosInventarioTable,
    MovimientoInventario,
    $$MovimientosInventarioTableFilterComposer,
    $$MovimientosInventarioTableOrderingComposer,
    $$MovimientosInventarioTableAnnotationComposer,
    $$MovimientosInventarioTableCreateCompanionBuilder,
    $$MovimientosInventarioTableUpdateCompanionBuilder,
    (
      MovimientoInventario,
      BaseReferences<_$AppDatabase, $MovimientosInventarioTable,
          MovimientoInventario>
    ),
    MovimientoInventario,
    PrefetchHooks Function()> {
  $$MovimientosInventarioTableTableManager(
      _$AppDatabase db, $MovimientosInventarioTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MovimientosInventarioTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$MovimientosInventarioTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MovimientosInventarioTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> productoId = const Value.absent(),
            Value<String> tipoMovimiento = const Value.absent(),
            Value<int> cantidad = const Value.absent(),
            Value<double?> precioUnitario = const Value.absent(),
            Value<String?> motivo = const Value.absent(),
            Value<String?> referenciaDocumento = const Value.absent(),
            Value<DateTime> fechaMovimiento = const Value.absent(),
            Value<String> usuarioId = const Value.absent(),
            Value<bool> sincronizadoNube = const Value.absent(),
          }) =>
              MovimientosInventarioCompanion(
            id: id,
            productoId: productoId,
            tipoMovimiento: tipoMovimiento,
            cantidad: cantidad,
            precioUnitario: precioUnitario,
            motivo: motivo,
            referenciaDocumento: referenciaDocumento,
            fechaMovimiento: fechaMovimiento,
            usuarioId: usuarioId,
            sincronizadoNube: sincronizadoNube,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int productoId,
            required String tipoMovimiento,
            required int cantidad,
            Value<double?> precioUnitario = const Value.absent(),
            Value<String?> motivo = const Value.absent(),
            Value<String?> referenciaDocumento = const Value.absent(),
            Value<DateTime> fechaMovimiento = const Value.absent(),
            required String usuarioId,
            Value<bool> sincronizadoNube = const Value.absent(),
          }) =>
              MovimientosInventarioCompanion.insert(
            id: id,
            productoId: productoId,
            tipoMovimiento: tipoMovimiento,
            cantidad: cantidad,
            precioUnitario: precioUnitario,
            motivo: motivo,
            referenciaDocumento: referenciaDocumento,
            fechaMovimiento: fechaMovimiento,
            usuarioId: usuarioId,
            sincronizadoNube: sincronizadoNube,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MovimientosInventarioTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $MovimientosInventarioTable,
        MovimientoInventario,
        $$MovimientosInventarioTableFilterComposer,
        $$MovimientosInventarioTableOrderingComposer,
        $$MovimientosInventarioTableAnnotationComposer,
        $$MovimientosInventarioTableCreateCompanionBuilder,
        $$MovimientosInventarioTableUpdateCompanionBuilder,
        (
          MovimientoInventario,
          BaseReferences<_$AppDatabase, $MovimientosInventarioTable,
              MovimientoInventario>
        ),
        MovimientoInventario,
        PrefetchHooks Function()>;
typedef $$ConfiguracionesLocalesTableCreateCompanionBuilder
    = ConfiguracionesLocalesCompanion Function({
  Value<int> id,
  required String clave,
  required String valor,
  Value<String?> descripcion,
  Value<DateTime> fechaActualizacion,
});
typedef $$ConfiguracionesLocalesTableUpdateCompanionBuilder
    = ConfiguracionesLocalesCompanion Function({
  Value<int> id,
  Value<String> clave,
  Value<String> valor,
  Value<String?> descripcion,
  Value<DateTime> fechaActualizacion,
});

class $$ConfiguracionesLocalesTableFilterComposer
    extends Composer<_$AppDatabase, $ConfiguracionesLocalesTable> {
  $$ConfiguracionesLocalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clave => $composableBuilder(
      column: $table.clave, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get valor => $composableBuilder(
      column: $table.valor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaActualizacion => $composableBuilder(
      column: $table.fechaActualizacion,
      builder: (column) => ColumnFilters(column));
}

class $$ConfiguracionesLocalesTableOrderingComposer
    extends Composer<_$AppDatabase, $ConfiguracionesLocalesTable> {
  $$ConfiguracionesLocalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clave => $composableBuilder(
      column: $table.clave, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get valor => $composableBuilder(
      column: $table.valor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaActualizacion => $composableBuilder(
      column: $table.fechaActualizacion,
      builder: (column) => ColumnOrderings(column));
}

class $$ConfiguracionesLocalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConfiguracionesLocalesTable> {
  $$ConfiguracionesLocalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clave =>
      $composableBuilder(column: $table.clave, builder: (column) => column);

  GeneratedColumn<String> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaActualizacion => $composableBuilder(
      column: $table.fechaActualizacion, builder: (column) => column);
}

class $$ConfiguracionesLocalesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ConfiguracionesLocalesTable,
    ConfiguracionLocal,
    $$ConfiguracionesLocalesTableFilterComposer,
    $$ConfiguracionesLocalesTableOrderingComposer,
    $$ConfiguracionesLocalesTableAnnotationComposer,
    $$ConfiguracionesLocalesTableCreateCompanionBuilder,
    $$ConfiguracionesLocalesTableUpdateCompanionBuilder,
    (
      ConfiguracionLocal,
      BaseReferences<_$AppDatabase, $ConfiguracionesLocalesTable,
          ConfiguracionLocal>
    ),
    ConfiguracionLocal,
    PrefetchHooks Function()> {
  $$ConfiguracionesLocalesTableTableManager(
      _$AppDatabase db, $ConfiguracionesLocalesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConfiguracionesLocalesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$ConfiguracionesLocalesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConfiguracionesLocalesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> clave = const Value.absent(),
            Value<String> valor = const Value.absent(),
            Value<String?> descripcion = const Value.absent(),
            Value<DateTime> fechaActualizacion = const Value.absent(),
          }) =>
              ConfiguracionesLocalesCompanion(
            id: id,
            clave: clave,
            valor: valor,
            descripcion: descripcion,
            fechaActualizacion: fechaActualizacion,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String clave,
            required String valor,
            Value<String?> descripcion = const Value.absent(),
            Value<DateTime> fechaActualizacion = const Value.absent(),
          }) =>
              ConfiguracionesLocalesCompanion.insert(
            id: id,
            clave: clave,
            valor: valor,
            descripcion: descripcion,
            fechaActualizacion: fechaActualizacion,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ConfiguracionesLocalesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $ConfiguracionesLocalesTable,
        ConfiguracionLocal,
        $$ConfiguracionesLocalesTableFilterComposer,
        $$ConfiguracionesLocalesTableOrderingComposer,
        $$ConfiguracionesLocalesTableAnnotationComposer,
        $$ConfiguracionesLocalesTableCreateCompanionBuilder,
        $$ConfiguracionesLocalesTableUpdateCompanionBuilder,
        (
          ConfiguracionLocal,
          BaseReferences<_$AppDatabase, $ConfiguracionesLocalesTable,
              ConfiguracionLocal>
        ),
        ConfiguracionLocal,
        PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProductosTableTableManager get productos =>
      $$ProductosTableTableManager(_db, _db.productos);
  $$VentasTableTableManager get ventas =>
      $$VentasTableTableManager(_db, _db.ventas);
  $$DetalleVentasTableTableManager get detalleVentas =>
      $$DetalleVentasTableTableManager(_db, _db.detalleVentas);
  $$UsuariosTiendaTableTableManager get usuariosTienda =>
      $$UsuariosTiendaTableTableManager(_db, _db.usuariosTienda);
  $$MovimientosInventarioTableTableManager get movimientosInventario =>
      $$MovimientosInventarioTableTableManager(_db, _db.movimientosInventario);
  $$ConfiguracionesLocalesTableTableManager get configuracionesLocales =>
      $$ConfiguracionesLocalesTableTableManager(
          _db, _db.configuracionesLocales);
}

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'database.g.dart';

// ===== TABLAS SIMPLIFICADAS PARA DEBUGGING =====

@DataClassName('Producto')
class Productos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get codigoBarras => text().nullable()();
  TextColumn get nombre => text()();
  TextColumn get descripcion => text().nullable()();
  TextColumn get categoria => text()();
  RealColumn get precioVenta => real()();
  RealColumn get precioCompra => real()();
  RealColumn get margenGanancia => real().nullable()();
  IntColumn get stockActual => integer()();
  IntColumn get stockMinimo => integer()();
  TextColumn get unidadMedida => text().withDefault(const Constant('unidad'))();
  DateTimeColumn get fechaCreacion => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
  TextColumn get tiendaId => text()();
}

@DataClassName('Venta')
class Ventas extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get fechaVenta => dateTime()();
  RealColumn get totalVenta => real()();
  TextColumn get metodoPago => text()();
  TextColumn get clienteId => text().nullable()();
  TextColumn get usuarioId => text()();
  RealColumn get descuentoAplicado => real().withDefault(const Constant(0))();
  RealColumn get latitud => real().nullable()();
  RealColumn get longitud => real().nullable()();
  TextColumn get direccionAproximada => text().nullable()();
  TextColumn get zonaGeografica => text().nullable()();
  BoolColumn get sincronizadoNube => boolean().withDefault(const Constant(false))();
  DateTimeColumn get fechaSincronizacion => dateTime().nullable()();
  TextColumn get tiendaId => text()();
}

@DataClassName('DetalleVenta')
class DetalleVentas extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get ventaId => integer()();
  IntColumn get productoId => integer()();
  IntColumn get cantidad => integer()();
  RealColumn get precioUnitario => real()();
  RealColumn get subtotal => real()();
  RealColumn get descuentoItem => real().withDefault(const Constant(0))();
  
  @override
  List<Set<Column>> get uniqueKeys => [
    {ventaId, productoId},
  ];
}

@DataClassName('UsuarioTienda')
class UsuariosTienda extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text()();
  TextColumn get email => text()();
  TextColumn get telefono => text().nullable()();
  TextColumn get rol => text()();
  TextColumn get tiendaId => text()();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
  DateTimeColumn get fechaCreacion => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get fechaUltimoAcceso => dateTime().nullable()();
  
  @override
  List<Set<Column>> get uniqueKeys => [
    {email},
  ];
}

@DataClassName('MovimientoInventario')
class MovimientosInventario extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productoId => integer()();
  TextColumn get tipoMovimiento => text()();
  IntColumn get cantidad => integer()();
  RealColumn get precioUnitario => real().nullable()();
  TextColumn get motivo => text().nullable()();
  TextColumn get referenciaDocumento => text().nullable()();
  DateTimeColumn get fechaMovimiento => dateTime().withDefault(currentDateAndTime)();
  TextColumn get usuarioId => text()();
  BoolColumn get sincronizadoNube => boolean().withDefault(const Constant(false))();
}

@DataClassName('ConfiguracionLocal')
class ConfiguracionesLocales extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get clave => text()();
  TextColumn get valor => text()();
  TextColumn get descripcion => text().nullable()();
  DateTimeColumn get fechaActualizacion => dateTime().withDefault(currentDateAndTime)();
  
  @override
  List<Set<Column>> get uniqueKeys => [
    {clave},
  ];
}

// ===== BASE DE DATOS CON MEJOR MANEJO DE ERRORES =====

@DriftDatabase(tables: [
  Productos,
  Ventas,
  DetalleVentas,
  UsuariosTienda,
  MovimientosInventario,
  ConfiguracionesLocales,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        print('📊 Creando tablas de la base de datos...');
        await m.createAll();
        print('✅ Tablas creadas exitosamente');
        
        print('📝 Insertando datos iniciales...');
        await _insertInitialData();
        print('✅ Datos iniciales insertados');
      },
      onUpgrade: (Migrator m, int from, int to) async {
        print('🔄 Migrando base de datos de versión $from a $to');
      },
    );
  }

  // INSERCIÓN DE DATOS INICIALES SIMPLIFICADA
  Future<void> _insertInitialData() async {
    try {
      // Verificar si ya hay datos
      final existingConfigs = await select(configuracionesLocales).get();
      if (existingConfigs.isNotEmpty) {
        print('📋 Datos iniciales ya existen, omitiendo inserción');
        return;
      }

      print('📝 Insertando configuraciones...');
      final configuraciones = [
        ConfiguracionesLocalesCompanion.insert(
          clave: 'tienda_id',
          valor: 'tienda_001',
          descripcion: const Value('Identificador único de la tienda'),
        ),
        ConfiguracionesLocalesCompanion.insert(
          clave: 'nombre_tienda',
          valor: 'Tienda Principal',
          descripcion: const Value('Nombre de la tienda'),
        ),
        ConfiguracionesLocalesCompanion.insert(
          clave: 'moneda',
          valor: 'BOB',
          descripcion: const Value('Moneda local'),
        ),
      ];
      
      for (final config in configuraciones) {
        await into(configuracionesLocales).insert(config);
      }
      print('✅ Configuraciones insertadas');

      print('👤 Insertando usuario administrador...');
      await into(usuariosTienda).insert(
        UsuariosTiendaCompanion.insert(
          nombre: 'Administrador',
          email: 'admin@tienda.com',
          rol: 'admin',
          tiendaId: 'tienda_001',
        ),
      );
      print('✅ Usuario administrador creado');

      print('📦 Insertando productos de ejemplo...');
      final productosDemo = [
        ProductosCompanion.insert(
          codigoBarras: const Value('7501234567890'),
          nombre: 'Producto Demo 1',
          descripcion: const Value('Producto de demostración'),
          categoria: 'Electrónicos',
          precioVenta: 150.0,
          precioCompra: 100.0,
          margenGanancia: const Value(50.0),
          stockActual: 50,
          stockMinimo: 10,
          tiendaId: 'tienda_001',
        ),
        ProductosCompanion.insert(
          codigoBarras: const Value('7501234567891'),
          nombre: 'Producto Demo 2',
          descripcion: const Value('Otro producto de demostración'),
          categoria: 'Hogar',
          precioVenta: 75.0,
          precioCompra: 50.0,
          margenGanancia: const Value(25.0),
          stockActual: 30,
          stockMinimo: 5,
          tiendaId: 'tienda_001',
        ),
      ];
      
      for (final producto in productosDemo) {
        await into(productos).insert(producto);
      }
      print('✅ Productos de ejemplo insertados');
      
    } catch (e, stack) {
      print('🚨 Error al insertar datos iniciales: $e');
      print('📍 Stack trace: $stack');
      rethrow;
    }
  }
}

// ===== CONFIGURACIÓN DE CONEXIÓN ROBUSTA =====

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    try {
      print('🚀 Inicializando conexión a la base de datos...');
      
      // Inicializar SQLite3 para móviles
      print('🔧 Configurando SQLite3 para Android...');
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
      print('✅ SQLite3 configurado');

      // Obtener directorio de la aplicación
      print('📂 Obteniendo directorio de la aplicación...');
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'inventario_multitienda.db'));
      
      print('📄 Archivo de base de datos: ${file.path}');
      print('📊 ¿Base de datos existe?: ${file.existsSync()}');

      // Crear conexión
      print('🔌 Creando conexión a la base de datos...');
      final database = NativeDatabase.createInBackground(
        file,
        setup: (database) {
          print('⚙️  Configurando SQLite...');
          
          try {
            // Configuraciones básicas y seguras
            database.execute('PRAGMA foreign_keys = ON');
            database.execute('PRAGMA journal_mode = WAL');
            database.execute('PRAGMA synchronous = NORMAL');
            print('✅ SQLite configurado correctamente');
          } catch (e) {
            print('⚠️  Error en configuración SQLite: $e');
            // Continuar sin las optimizaciones si hay error
          }
        },
      );
      
      print('✅ Base de datos inicializada exitosamente');
      return database;
      
    } catch (e, stack) {
      print('🚨 Error fatal al inicializar base de datos: $e');
      print('📍 Stack trace: $stack');
      rethrow;
    }
  });
}
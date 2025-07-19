import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/database_models.dart';
import 'repositories/database_repositories.dart';
import 'screens/productos_screens.dart';
import 'screens/punto_venta_screens.dart';
import 'screens/ventas_reportes_screens.dart';
import 'screens/graficos_avanzados_screen.dart';
import 'screens/mapas_geolocalizacion_screen.dart';
import 'services/supabase_sync_system.dart';

// ===== CONFIGURACIÓN INICIAL =====

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar orientación
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configurar barra de estado
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Inicializar Supabase
  try {
    await SupabaseConfig.initialize();
    print('✅ Supabase inicializado correctamente');
  } catch (e) {
    print('⚠️ Error inicializando Supabase: $e');
    // Continuar sin Supabase si hay error
  }

  runApp(const ProviderScope(child: InventarioMultitiendaApp()));
}

// ===== APLICACIÓN PRINCIPAL =====

class InventarioMultitiendaApp extends StatelessWidget {
  const InventarioMultitiendaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventario Multi-tienda',
      debugShowCheckedModeBanner: false,
      theme: _buildAppTheme(),
      home: const SplashScreen(),
      // Rutas nombradas para navegación
      routes: {
        '/main': (context) => const MainNavigationScreen(),
        '/productos': (context) => const ProductosScreen(),
        '/pos': (context) => const PuntoVentaScreen(),
        '/ventas': (context) => const VentasScreen(),
        '/graficos': (context) => const GraficosAvanzadosScreen(),
        '/mapas': (context) => const MapasGelocalizacionScreen(),
        '/sincronizacion': (context) => const SincronizacionScreen(),
      },
    );
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 4,
        surfaceTintColor: Colors.transparent,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Input Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
        shape: CircleBorder(),
      ),
    );
  }
}

// ===== SPLASH SCREEN =====

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    // Simular inicialización de la app
    await Future.delayed(const Duration(seconds: 3));

    // Navegar a la pantalla principal
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/main');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[600],
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.inventory_2,
                        size: 60,
                        color: Colors.blue,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Título
                    const Text(
                      'Inventario\nMulti-tienda',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Subtítulo
                    Text(
                      'Sistema integral de gestión',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Indicador de carga
                    SizedBox(
                      width: 200,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Inicializando...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ===== SISTEMA DE NAVEGACIÓN PRINCIPAL =====

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  // Lista de pantallas principales
  final List<Widget> _screens = [
    const DashboardScreen(),
    const ProductosScreen(),
    const PuntoVentaScreen(),
    const VentasScreen(),
    const MenuScreen(),
  ];

  // Información de las pestañas
  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.dashboard,
      label: 'Dashboard',
      color: Colors.blue,
    ),
    NavigationItem(
      icon: Icons.inventory_2,
      label: 'Productos',
      color: Colors.green,
    ),
    NavigationItem(
      icon: Icons.point_of_sale,
      label: 'POS',
      color: Colors.orange,
    ),
    NavigationItem(
      icon: Icons.analytics,
      label: 'Ventas',
      color: Colors.purple,
    ),
    NavigationItem(
      icon: Icons.menu,
      label: 'Más',
      color: Colors.teal,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navigationItems.length,
              (index) => _buildNavItem(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navigationItems[index];
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono con animación
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? item.color.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  size: 24,
                  color: isSelected ? item.color : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              // Texto con animación
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? item.color : Colors.grey[600],
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}

// ===== MODELO PARA NAVEGACIÓN =====

class NavigationItem {
  final IconData icon;
  final String label;
  final Color color;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.color,
  });
}

// ===== PANTALLA DE MENÚ =====

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Más Opciones'),
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con información de la app
            Card(
              color: Colors.teal[50],
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.teal[600],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.inventory_2,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Inventario Multi-tienda',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Versión 1.0.0',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
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

            // Sección de Análisis
            _buildSeccionMenu(
              'Análisis y Reportes',
              [
                _buildMenuItem(
                  'Gráficos Avanzados',
                  'Visualización avanzada de datos',
                  Icons.insert_chart,
                  Colors.purple,
                  () => Navigator.of(context).pushNamed('/graficos'),
                ),
                _buildMenuItem(
                  'Mapas y Ubicaciones',
                  'Por implemetar(hardcodeado por ahora)',
                  Icons.map,
                  Colors.green,
                  () => Navigator.of(context).pushNamed('/mapas'),
                ),
                _buildMenuItem(
                  'Reportes Detallados',
                  'Informes completos de rendimiento',
                  Icons.assessment,
                  Colors.blue,
                  () => Navigator.of(context).pushNamed('/ventas'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Sección de Configuración
            _buildSeccionMenu(
              'Configuración',
              [
                _buildMenuItem(
                  'Sincronización',
                  'Configurar sync con la nube',
                  Icons.cloud_sync,
                  Colors.teal,
                  () => Navigator.of(context).pushNamed('/sincronizacion'),
                ),
                _buildMenuItem(
                  'Configuraciones',
                  'Ajustes de la aplicación',
                  Icons.settings,
                  Colors.grey,
                  () => _mostrarConfiguraciones(context),
                ),
                _buildMenuItem(
                  'Backup de Datos',
                  'Respaldar información',
                  Icons.backup,
                  Colors.orange,
                  () => _crearBackup(context, ref),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Sección de Ayuda
            _buildSeccionMenu(
              'Ayuda y Soporte',
              [
                _buildMenuItem(
                  'Tutorial',
                  'Aprende a usar la aplicación',
                  Icons.school,
                  Colors.indigo,
                  () => _mostrarTutorial(context),
                ),
                _buildMenuItem(
                  'Soporte Técnico',
                  'Contactar soporte',
                  Icons.support_agent,
                  Colors.red,
                  () => _contactarSoporte(context),
                ),
                _buildMenuItem(
                  'Acerca de',
                  'Información de la aplicación',
                  Icons.info,
                  Colors.cyan,
                  () => _mostrarAcercaDe(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionMenu(String titulo, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...items,
      ],
    );
  }

  Widget _buildMenuItem(
    String titulo,
    String subtitulo,
    IconData icono,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icono, color: color),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitulo,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  // Métodos de acciones del menú
  void _mostrarConfiguraciones(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configuraciones'),
        content: const Text('Panel de configuraciones próximamente'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _crearBackup(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Backup'),
        content: const Text('¿Deseas crear un respaldo de todos los datos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Backup creado exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _mostrarTutorial(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TutorialScreen(),
      ),
    );
  }

  void _contactarSoporte(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Soporte Técnico'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📧 Email: lluscofernando1@gmail.com'),
            SizedBox(height: 8),
            Text('📱 WhatsApp: +591 70135940'),
            SizedBox(height: 8),
            Text('🌐 Web: '),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _mostrarAcercaDe(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Inventario Multi-tienda',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.inventory_2,
          color: Colors.white,
          size: 30,
        ),
      ),
      children: const [
        Text(
            'Sistema integral de gestión de inventario para múltiples tiendas.'),
        SizedBox(height: 8),
        Text('Incluye POS, reportes, mapas y sincronización en la nube.'),
      ],
    );
  }
}

// ===== PANTALLA DE TUTORIAL =====

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<TutorialPage> _pages = [
    TutorialPage(
      title: '¡Bienvenido!',
      description:
          'Gestiona tu inventario de manera eficiente con nuestra aplicación integral.',
      icon: Icons.inventory_2,
      color: Colors.blue,
    ),
    TutorialPage(
      title: 'Productos',
      description:
          'Agrega, edita y controla el stock de todos tus productos fácilmente.',
      icon: Icons.add_box,
      color: Colors.green,
    ),
    TutorialPage(
      title: 'Punto de Venta',
      description:
          'Procesa ventas rápidamente con nuestro sistema POS integrado.',
      icon: Icons.point_of_sale,
      color: Colors.orange,
    ),
    TutorialPage(
      title: 'Reportes',
      description:
          'Analiza tus ventas con gráficos detallados y reportes avanzados.',
      icon: Icons.analytics,
      color: Colors.purple,
    ),
    TutorialPage(
      title: 'Sincronización',
      description:
          'Mantén tus datos seguros y sincronizados en la nube automáticamente.',
      icon: Icons.cloud_sync,
      color: Colors.teal,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Saltar'),
                  ),
                  Text(
                    '${_currentPage + 1} de ${_pages.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Contenido
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: page.color.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            page.icon,
                            size: 60,
                            color: page.color,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          page.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indicadores y navegación
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  // Indicadores de página
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.blue
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Botón de navegación
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _currentPage < _pages.length - 1
                            ? 'Siguiente'
                            : 'Comenzar',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== MODELO PARA TUTORIAL =====

class TutorialPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  TutorialPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

// ===== DASHBOARD MEJORADO =====

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estadisticas = ref.watch(estadisticasProvider);
    final alertas = ref.watch(alertasStockProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(estadisticasProvider);
              ref.refresh(alertasStockProvider);
            },
            tooltip: 'Actualizar datos',
          ),
        ],
      ),
      body: estadisticas.when(
        data: (stats) => RefreshIndicator(
          onRefresh: () async {
            ref.refresh(estadisticasProvider);
            ref.refresh(alertasStockProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Saludo personalizado
                _buildHeader(context),
                const SizedBox(height: 24),

                // KPIs principales
                _buildKPIsSection(context, stats),
                const SizedBox(height: 24),

                // Acciones rápidas
                _buildAccionesRapidas(context),
                const SizedBox(height: 24),

                // Alertas de stock
                alertas.when(
                  data: (listaAlertas) =>
                      _buildAlertasSection(context, listaAlertas),
                  loading: () => _buildLoadingCard('Cargando alertas...'),
                  error: (error, _) =>
                      _buildErrorCard('Error al cargar alertas'),
                ),

                const SizedBox(height: 24),

                // Resumen del inventario
                _buildResumenInventario(context, stats),

                const SizedBox(height: 100), // Espacio para navegación
              ],
            ),
          ),
        ),
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando dashboard...'),
            ],
          ),
        ),
        error: (error, _) => _buildErrorState(context, ref, error),
      ),
    );
  }

  // Métodos auxiliares del Dashboard (igual que antes pero mejorados)
  Widget _buildHeader(BuildContext context) {
    final now = DateTime.now();
    final greeting = _getGreeting();
    final dateText =
        '${_getDayName(now.weekday)}, ${now.day} de ${_getMonthName(now.month)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
        ),
        const SizedBox(height: 4),
        Text(
          dateText,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildKPIsSection(BuildContext context, EstadisticasGenerales stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen General',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
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
                _buildKPICard(
                  'Productos',
                  stats.totalProductos.toString(),
                  '${stats.productosActivos} activos',
                  Icons.inventory_2,
                  Colors.blue,
                  context,
                ),
                _buildKPICard(
                  'Ventas Hoy',
                  'Bs. ${stats.ventasHoy.toStringAsFixed(2)}',
                  'Ventas de hoy',
                  Icons.today,
                  Colors.green,
                  context,
                ),
                _buildKPICard(
                  'Stock Bajo',
                  stats.productosStockBajo.toString(),
                  'Necesitan reposición',
                  Icons.warning_amber,
                  stats.productosStockBajo > 0 ? Colors.orange : Colors.green,
                  context,
                ),
                _buildKPICard(
                  'Ventas Mes',
                  'Bs. ${stats.ventasEsteMes.toStringAsFixed(2)}',
                  'Total del mes',
                  Icons.calendar_month,
                  Colors.purple,
                  context,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildKPICard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
    BuildContext context,
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
                Icon(icon, color: color, size: 24),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(Icons.trending_up, size: 12, color: color),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
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

  Widget _buildAccionesRapidas(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones Rápidas',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Nueva Venta',
                Icons.point_of_sale,
                Colors.green,
                () => _navigateToScreen(context, 2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Agregar Producto',
                Icons.add_box,
                Colors.blue,
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AgregarProductoScreen(),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Ver Gráficos',
                Icons.analytics,
                Colors.purple,
                () => Navigator.of(context).pushNamed('/graficos'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Ver Mapas',
                Icons.map,
                Colors.teal,
                () => Navigator.of(context).pushNamed('/mapas'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildAlertasSection(BuildContext context, List<AlertaStock> alertas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Alertas de Stock',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (alertas.isNotEmpty)
              TextButton(
                onPressed: () => _navigateToScreen(context, 1),
                child: const Text('Ver todos'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (alertas.isEmpty)
          Card(
            color: Colors.green[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700]),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text('¡Excelente! No hay alertas de stock'),
                  ),
                ],
              ),
            ),
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: alertas
                    .take(3)
                    .map((alerta) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: _getColorForNivel(alerta.nivel)
                                  .withOpacity(0.2),
                              child: Icon(
                                _getIconForNivel(alerta.nivel),
                                color: _getColorForNivel(alerta.nivel),
                                size: 20,
                              ),
                            ),
                            title: Text(
                              alerta.nombreProducto,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              'Stock: ${alerta.stockActual} | Mínimo: ${alerta.stockMinimo}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getColorForNivel(alerta.nivel)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _getColorForNivel(alerta.nivel)
                                      .withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                alerta.nivel.displayName,
                                style: TextStyle(
                                  color: _getColorForNivel(alerta.nivel),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildResumenInventario(
      BuildContext context, EstadisticasGenerales stats) {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.summarize, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'Resumen del Inventario',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildResumenItem(
                    'Valor Total',
                    'Bs. ${stats.valorTotalInventario.toStringAsFixed(2)}',
                    Icons.account_balance_wallet,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildResumenItem(
                    'Pendientes Sync',
                    stats.ventasPendientesSincronizacion.toString(),
                    Icons.cloud_off,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blue[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingCard(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red[700]),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error al cargar el dashboard',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.refresh(estadisticasProvider);
                ref.refresh(alertasStockProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Métodos auxiliares
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '¡Buenos días!';
    if (hour < 18) return '¡Buenas tardes!';
    return '¡Buenas noches!';
  }

  String _getDayName(int weekday) {
    const days = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo'
    ];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ];
    return months[month - 1];
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

  void _navigateToScreen(BuildContext context, int index) {
    final mainState =
        context.findAncestorStateOfType<_MainNavigationScreenState>();
    if (mainState != null) {
      mainState._onItemTapped(index);
    }
  }
}

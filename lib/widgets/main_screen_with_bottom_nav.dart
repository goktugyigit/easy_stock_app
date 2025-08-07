import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import '../screens/home_page_with_search.dart';
import '../screens/list_page.dart';
import '../screens/warehouses_shops_page.dart';
import '../screens/wallet_page.dart';
import '../screens/home_settings_page.dart';
import '../utils/app_theme.dart';

// Projenizin linter kurallarına uyum sağlamak için bu Color extension'ının
// projenizde tanımlı olduğu varsayılıyor.
extension ColorValues on Color {
  Color withValues({double? alpha}) {
    if (alpha != null) {
      return withAlpha((alpha * 255).round().clamp(0, 255));
    }
    return this;
  }
}

// Her bir sekme için Navigator anahtarları
final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _listNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _warehousesNavigatorKey =
    GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _walletNavigatorKey =
    GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _settingsNavigatorKey =
    GlobalKey<NavigatorState>();

class MainScreenWithBottomNav extends StatefulWidget {
  final int initialSelectedIndex;

  // DÜZELTME: Sabitler buraya, yani widget'ın kendisine taşındı.
  // Bu sayede projenin diğer dosyalarından erişilebilir hale geldiler.
  static const double navBarHeight = 70.0;
  static const double navBarBottomMargin = 25.0;

  const MainScreenWithBottomNav({super.key, this.initialSelectedIndex = 0});

  @override
  State<MainScreenWithBottomNav> createState() =>
      _MainScreenWithBottomNavState();
}

class _MainScreenWithBottomNavState extends State<MainScreenWithBottomNav>
    with TickerProviderStateMixin {
  late int _selectedIndex;
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _pulseAnimations;

  // Modern navbar data - o beğendiğin iconlar
  final List<NavItem> _navItems = [
    NavItem(icon: Icons.home_rounded, label: 'Ana Sayfa'),
    NavItem(icon: Icons.dashboard_rounded, label: 'İşlemler'),
    NavItem(icon: Icons.store_rounded, label: 'Yerler'),
    NavItem(icon: Icons.point_of_sale_rounded, label: 'Satışlar'),
    NavItem(icon: Icons.settings_rounded, label: 'Ayarlar'),
  ];

  static final List<Widget> _widgetOptions = <Widget>[
    _buildOffstageNavigator(_homeNavigatorKey, const HomePageWithSearch()),
    _buildOffstageNavigator(_listNavigatorKey, const ListPage()),
    _buildOffstageNavigator(
        _warehousesNavigatorKey, const WarehousesShopsPage()),
    _buildOffstageNavigator(_walletNavigatorKey, const WalletPage()),
    _buildOffstageNavigator(_settingsNavigatorKey, const HomeSettingsPage()),
  ];

  static Widget _buildOffstageNavigator(
      GlobalKey<NavigatorState> key, Widget initialPage) {
    return Navigator(
      key: key,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) => initialPage,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    // Başlangıç index'ini widget'tan al
    _selectedIndex = widget.initialSelectedIndex;

    // Her buton için animasyon controller'ları oluştur
    _animationControllers = List.generate(
      _navItems.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      ),
    );

    // Scale animasyonları - o havalı büyüme efekti
    _scaleAnimations = _animationControllers
        .map(
          (controller) => Tween<double>(begin: 1.0, end: 1.2).animate(
            CurvedAnimation(parent: controller, curve: Curves.elasticOut),
          ),
        )
        .toList();

    // Pulse animasyonları - o dairesel dalga efekti
    _pulseAnimations = _animationControllers
        .map(
          (controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          ),
        )
        .toList();

    // İlk seçili buton animasyonunu başlat
    _animationControllers[widget.initialSelectedIndex].forward();
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      _navigateAndPopToRoot(index);
    } else {
      // Eski seçili buton animasyonunu durdur
      _animationControllers[_selectedIndex].reverse();

      setState(() {
        _selectedIndex = index;
      });

      // Yeni seçili buton animasyonunu başlat
      _animationControllers[index].forward();
    }
  }

  void _navigateAndPopToRoot(int index) {
    final List<GlobalKey<NavigatorState>> navigatorKeys = [
      _homeNavigatorKey,
      _listNavigatorKey,
      _warehousesNavigatorKey,
      _walletNavigatorKey,
      _settingsNavigatorKey,
    ];

    if (navigatorKeys[index].currentState != null &&
        navigatorKeys[index].currentState!.canPop()) {
      navigatorKeys[index].currentState!.popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    const double navBarHorizontalMargin = 20.0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;

        final List<GlobalKey<NavigatorState>> navigatorKeys = [
          _homeNavigatorKey,
          _listNavigatorKey,
          _warehousesNavigatorKey,
          _walletNavigatorKey,
          _settingsNavigatorKey,
        ];
        final NavigatorState? currentNavigator =
            navigatorKeys[_selectedIndex].currentState;

        if (currentNavigator != null && currentNavigator.canPop()) {
          currentNavigator.pop();
        } else {
          if (mounted) {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.appBackgroundColor,
        extendBody: true,
        body: IndexedStack(
          index: _selectedIndex,
          children: _widgetOptions,
        ),
        bottomNavigationBar: Container(
          margin: EdgeInsets.only(
            left: navBarHorizontalMargin,
            right: navBarHorizontalMargin,
            bottom: MainScreenWithBottomNav.navBarBottomMargin + bottomPadding,
            top: 8.0,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(35.0),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
              child: Container(
                height: MainScreenWithBottomNav.navBarHeight,
                decoration: BoxDecoration(
                  // O beğendiğin modern koyu gradient!
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.grey[900]!.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(35.0),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 25,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    _navItems.length,
                    (index) => _buildModernNavButton(index),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernNavButton(int index) {
    final bool isSelected = _selectedIndex == index;
    final NavItem item = _navItems[index];

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        onTapDown: (_) {
          // O havalı basma efekti
          if (!isSelected) {
            _animationControllers[index].forward().then((_) {
              _animationControllers[index].reverse();
            });
          }
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _scaleAnimations[index],
            _pulseAnimations[index],
          ]),
          builder: (context, child) {
            return SizedBox(
              height: MainScreenWithBottomNav.navBarHeight,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Seçili durum için pulse efekti - o beğendiğin dalga!
                    if (isSelected)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 45 + (_pulseAnimations[index].value * 10),
                        height: 45 + (_pulseAnimations[index].value * 10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                      ),

                    // Ana icon container - o şık tasarım
                    Transform.scale(
                      scale: _scaleAnimations[index].value,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryColor.withValues(alpha: 0.2)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: AppTheme.primaryColor
                                      .withValues(alpha: 0.3),
                                  width: 1.5,
                                )
                              : null,
                        ),
                        child: item.assetPath != null
                            ? Image.asset(
                                item.assetPath!,
                                // 40x40px PNG için Flutter icon boyutuna uyumlu scale
                                width: isSelected
                                    ? 16
                                    : 15, // Daha küçük - Flutter icon'lar ile uyumlu
                                height: isSelected ? 16 : 15,
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : Colors.white.withValues(alpha: 0.7),
                                filterQuality: FilterQuality.high,
                              )
                            : Icon(
                                item.icon!,
                                size: isSelected ? 26 : 24,
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : Colors.white.withValues(alpha: 0.7),
                              ),
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

// Navbar item data class - hem icon hem asset desteği
class NavItem {
  final IconData? icon;
  final String? assetPath;
  final String label;

  NavItem({this.icon, this.assetPath, required this.label})
      : assert(icon != null || assetPath != null,
            'Either icon or assetPath must be provided');
}

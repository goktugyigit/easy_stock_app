// lib/widgets/main_screen_with_bottom_nav.dart
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart'; // SystemNavigator.pop için eklendi
import '../screens/home_page_with_search.dart';
import '../screens/list_page.dart';
import '../screens/warehouses_shops_page.dart';
import '../screens/wallet_page.dart';
import '../screens/home_settings_page.dart';
import '../utils/app_theme.dart';

// Her bir sekme için Navigator anahtarları
final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _listNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _warehousesNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _walletNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _settingsNavigatorKey = GlobalKey<NavigatorState>();

class MainScreenWithBottomNav extends StatefulWidget {
  const MainScreenWithBottomNav({super.key});

  @override
  State<MainScreenWithBottomNav> createState() => _MainScreenWithBottomNavState();
}

class _MainScreenWithBottomNavState extends State<MainScreenWithBottomNav> {
  int _selectedIndex = 0;

  // OffstageNavigator, her sekmenin kendi navigasyon geçmişini korumasını sağlar.
  // IndexedStack ile kullanıldığında, görünür olmayan sekmeler state'lerini kaybetmez.
  static final List<Widget> _widgetOptions = <Widget>[
    _buildOffstageNavigator(_homeNavigatorKey, const HomePageWithSearch()),
    _buildOffstageNavigator(_listNavigatorKey, const ListPage()),
    _buildOffstageNavigator(_warehousesNavigatorKey, const WarehousesShopsPage()),
    _buildOffstageNavigator(_walletNavigatorKey, const WalletPage()),
    _buildOffstageNavigator(_settingsNavigatorKey, const HomeSettingsPage()),
  ];

  static Widget _buildOffstageNavigator(GlobalKey<NavigatorState> key, Widget initialPage) {
    return Navigator(
      key: key,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            // Her zaman başlangıç sayfasını döndürür, çünkü her sekme kendi içinde
            // push/pop işlemlerini yönetir.
            return initialPage;
          },
        );
      },
    );
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      // Eğer kullanıcı zaten bulunduğu sekmenin ikonuna tekrar basarsa,
      // o sekmenin navigasyon yığınını en başa döndür.
      _navigateAndPopToRoot(index);
    } else {
      // Farklı bir sekmeye geçiş yap.
      setState(() {
        _selectedIndex = index;
      });
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
    // İlgili sekmenin navigator'ı pop yapabiliyorsa (yani kök sayfada değilse),
    // ilk sayfaya kadar tüm sayfaları yığından çıkar.
    if (navigatorKeys[index].currentState != null && navigatorKeys[index].currentState!.canPop()) {
      navigatorKeys[index].currentState!.popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavBarEffectiveColor = AppTheme.glassNavBarBackgroundColor;
    final bottomNavBarBorderColor = AppTheme.glassNavBarBorderColor;

    const double navBarHeight = 60.0;
    const double navBarHorizontalMargin = 20.0;
    const double navBarBottomMargin = 22.0;
    final double navBarCornerRadius = navBarHeight / 2;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return PopScope(
      canPop: false,
      // --- DÜZELTME: 'deprecated_member_use' uyarısını gidermek için ---
      // Sizin Flutter sürümünüzün beklediği 'onPopInvokedWithResult' kullanıldı.
      // Bu parametre modern Flutter'da tekrar 'onPopInvoked' olarak değiştirilmiştir.
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) {
          return;
        }

        final List<GlobalKey<NavigatorState>> navigatorKeys = [
          _homeNavigatorKey,
          _listNavigatorKey,
          _warehousesNavigatorKey,
          _walletNavigatorKey,
          _settingsNavigatorKey,
        ];
        final NavigatorState? currentNavigator = navigatorKeys[_selectedIndex].currentState;

        if (currentNavigator != null && currentNavigator.canPop()) {
          currentNavigator.pop();
        } else {
          // Eğer hiçbir sekme geri gidemiyorsa, uygulamayı kapat.
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
            bottom: navBarBottomMargin + bottomPadding,
            top: 8.0,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(navBarCornerRadius),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
              child: Container(
                height: navBarHeight,
                decoration: BoxDecoration(
                  color: bottomNavBarEffectiveColor,
                  borderRadius: BorderRadius.circular(navBarCornerRadius),
                  border: Border.all(color: bottomNavBarBorderColor, width: 0.8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _buildNavItem(iconName: 'home_icon', index: 0),
                    _buildNavItem(iconName: 'list_icon', index: 1),
                    _buildNavItem(iconName: 'warehouses_shops_icon', index: 2),
                    _buildNavItem(iconName: 'sales_icon', index: 3),
                    _buildNavItem(iconName: 'settings_icon', index: 4),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Taşma hatasını önlemek için özel olarak tasarlanmış navigasyon butonu.
  Widget _buildNavItem({required String iconName, required int index}) {
    const String iconPath = 'assets/nav_icons/';
    final bool isSelected = _selectedIndex == index;
    
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onItemTapped(index),
          borderRadius: BorderRadius.circular(30), // Geniş bir dokunma alanı için
          child: Center( // İkonu dikey ve yatayda ortalar
            child: Image.asset(
              '$iconPath$iconName.png',
              width: 24.0,
              height: 24.0,
              color: isSelected ? AppTheme.primaryColor : const Color(0xBEFFFFFF),
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
    );
  }
}

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
            if (settings.name == '/') {
              return initialPage;
            }
            return initialPage;
          },
        );
      },
    );
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      _navigateAndPopToRoot(index);
    } else {
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
    if (navigatorKeys[index].currentState != null && navigatorKeys[index].currentState!.canPop()) {
      navigatorKeys[index].currentState!.popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavBarEffectiveColor = AppTheme.glassNavBarBackgroundColor;
    final bottomNavBarBorderColor = AppTheme.glassNavBarBorderColor;

    const double navBarHeight = 58.0;
    const double navBarHorizontalMargin = 20.0;
    const double navBarBottomMargin = 22.0;
    final double navBarCornerRadius = navBarHeight / 2;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return PopScope(
      canPop: false, // Biz yöneteceğiz
      // onPopInvoked yerine onPopInvokedWithResult kullanılıyor.
      // İkinci parametre (result) bizim senaryomuzda kullanılmıyor ama imza için gerekli.
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
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
          // Eğer iç navigator'da geri gidilecek sayfa yoksa (kök sayfadasınız).
          // Bu durumda uygulamanın kapanmasına izin ver.
          // `SystemNavigator.pop()` çağırarak uygulamayı kapatabiliriz.
          // Daha iyi bir UX için "Çıkmak için tekrar basın" gibi bir uyarı eklenebilir.
          // Şimdilik, direkt çıkış yapalım.
          if (mounted) { // mounted kontrolü async gap sonrası iyi bir pratiktir.
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
                child: BottomNavigationBar(
                  items: <BottomNavigationBarItem>[
                    BottomNavigationBarItem(icon: _buildIcon('home_icon', 0), label: ''),
                    BottomNavigationBarItem(icon: _buildIcon('list_icon', 1), label: ''),
                    BottomNavigationBarItem(icon: _buildIcon('warehouses_shops_icon', 2), label: ''),
                    BottomNavigationBarItem(icon: _buildIcon('sales_icon', 3), label: ''),
                    BottomNavigationBarItem(icon: _buildIcon('settings_icon', 4), label: ''),
                  ],
                  currentIndex: _selectedIndex,
                  onTap: _onItemTapped,
                  type: BottomNavigationBarType.fixed,
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  backgroundColor: Colors.transparent,
                  selectedItemColor: AppTheme.primaryColor,
                  unselectedItemColor: const Color(0xBEFFFFFF),
                  elevation: 0,
                  iconSize: 24.0,
                  selectedFontSize: 0,
                  unselectedFontSize: 0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const String _iconPath = 'assets/nav_icons/';
  Widget _buildIcon(String iconName, int index) {
    return Image.asset(
      '$_iconPath$iconName.png',
      width: 24.0,
      height: 24.0,
      color: _selectedIndex == index ? AppTheme.primaryColor : const Color(0xBEFFFFFF),
      filterQuality: FilterQuality.high,
    );
  }
}
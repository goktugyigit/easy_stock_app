// lib/screens/home_page_with_search.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import '../models/stock_item.dart';
import './add_edit_stock_page.dart';
import '../widgets/barcode_scanner_page.dart'; // _scanAndSearch için
import './settings_page.dart'; // getGlobalMaxStockThreshold için
import '../widgets/stock_item_card.dart';
import '../utils/app_theme.dart';

class HomePageWithSearch extends StatefulWidget {
  const HomePageWithSearch({super.key});
  @override
  State<HomePageWithSearch> createState() => _HomePageWithSearchState();
}

class _HomePageWithSearchState extends State<HomePageWithSearch> {
  final TextEditingController _searchController = TextEditingController();
  List<StockItem> _filteredItems = [];
  bool _isSearching = false;
  int _globalMaxStockThreshold = 100; // Kullanılıyor, StockItemCard'a geçilecek
  bool _isLoadingSettings = true;

  final Map<String, double> _swipeProgress = {};
  final Map<String, DismissDirection?> _swipeDirection = {};

  static const double pageHorizontalPadding = 20.0;
  static const double listItemVerticalPadding = 6.0;
  static const double actionBackgroundOverdrag = 70.0;

  @override
  void initState() {
    super.initState();
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    _updateFilteredItems(stockProvider.items);
    _searchController.addListener(_onSearchChanged);
    _loadPageData();
    stockProvider.addListener(_providerListener);
  }

  void _providerListener() {
    if (mounted) {
      _onSearchChanged();
    }
  }

  Future<void> _loadPageData() async {
    if (!mounted) return;
    setState(() { _isLoadingSettings = true; });
    try {
      final threshold = await getGlobalMaxStockThreshold(); // settings_page.dart'tan geliyor
      if (mounted) {
          await Provider.of<StockProvider>(context, listen: false).fetchAndSetItems(forceFetch: true);
      }
      if (!mounted) return;
      setState(() { _globalMaxStockThreshold = threshold; }); // _globalMaxStockThreshold güncelleniyor
    } catch (e) {
      if (kDebugMode) print("HomePageWithSearch veri yüklenirken hata: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veri yüklenirken bir hata oluştu: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoadingSettings = false; });
      }
    }
  }

  void _updateFilteredItems(List<StockItem> sourceItems) {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      _isSearching = false;
      _filteredItems = List.from(sourceItems);
    } else {
      _isSearching = true;
      _filteredItems = sourceItems.where((item) {
        return item.name.toLowerCase().contains(query) ||
            (item.stockCode?.toLowerCase().contains(query) ?? false) ||
            (item.brand?.toLowerCase().contains(query) ?? false) ||
            (item.category?.toLowerCase().contains(query) ?? false) ||
            (item.shelfLocation?.toLowerCase().contains(query) ?? false) ||
            (item.supplier?.toLowerCase().contains(query) ?? false) ||
            (item.barcode?.toLowerCase().contains(query) ?? false) ||
            (item.qrCode?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
    _filteredItems.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  void _onSearchChanged() {
    if (!mounted) return;
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    setState(() {
      _updateFilteredItems(stockProvider.items);
    });
  }

  Future<void> _scanAndSearch() async {
    final currentContext = context;
    final scaffoldMessenger = ScaffoldMessenger.of(currentContext);
    try {
      final String? scannedValue = await Navigator.push<String>(
        currentContext,
        MaterialPageRoute(builder: (context) => const BarcodeScannerPage()),
      );
      if (!mounted) return;
      if (scannedValue != null && scannedValue.isNotEmpty) {
        _searchController.text = scannedValue;
      }
    } catch (e) {
      if (kDebugMode) { debugPrint('Barkod/QR tarama hatası (_scanAndSearch): $e'); }
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Kod okuma sırasında bir hata oluştu.')),
        );
      }
    }
  }

  @override
  void dispose() {
    Provider.of<StockProvider>(context, listen: false).removeListener(_providerListener);
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext ctx, StockItem item) async {
    final result = await showDialog<bool>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Silme Onayı'),
        content: Text('"${item.name}" adlı stoğu silmek istediğinizden emin misiniz?'),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: <Widget>[
          TextButton(
            child: const Text('İptal'),
            onPressed: () => Navigator.of(dialogCtx).pop(false),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Evet, Sil'),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
          ),
        ],
      ),
    );
    return result;
  }

  Widget _buildActionBackgroundLayer(Color actionColor, IconData icon, Alignment alignment) {
    return Container(
      decoration: BoxDecoration(
        color: actionColor,
        borderRadius: BorderRadius.circular(StockItemCard.cardRadius),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Icon(icon, color: Colors.white, size: 30),
    );
  }


  @override
  Widget build(BuildContext context) {
    // DÜZELTME: 'theme' değişkeni artık kullanıldığı için hata vermeyecek.
    final ThemeData theme = Theme.of(context);

    // Navigasyon çubuğunun boyutlarını ve ekranın altındaki güvenli alanı (safe area)
    // kullanarak ListView için gerekli olan alt boşluğu dinamik olarak hesaplıyoruz.
    const double navBarHeight = 58.0;
    const double navBarBottomMargin = 22.0;
    const double navBarTopMargin = 8.0;
    final double bottomSafeArea = MediaQuery.of(context).padding.bottom;

    // ListView'un altına eklenmesi gereken toplam boşluk ve gradyan alanı için referans
    final double totalBottomClearance = navBarHeight + navBarBottomMargin + navBarTopMargin + bottomSafeArea;

    return Scaffold(
      // Arka plan rengini AppTheme'den alıyoruz ki gradyan rengiyle tam uyumlu olsun.
      backgroundColor: AppTheme.appBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.appBackgroundColor,
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: pageHorizontalPadding, vertical: 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Stok Ara...',
              prefixIcon: const Icon(Icons.search, size: 22),
              suffixIcon: IconButton(
                icon: const Icon(Icons.qr_code_scanner_outlined, size: 22),
                onPressed: _scanAndSearch,
                tooltip: 'Tara ve Ara',
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            ),
          ),
        ),
      ),
      body: _isLoadingSettings
          ? const Center(child: CircularProgressIndicator())
          : Consumer<StockProvider>(
              builder: (consumerCtx, stockProvider, _) {
                final itemsToDisplay = _filteredItems;
                // --- YENİ DÜZENLEME: Stack ve Gradyan Efekti ---
                return Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: _loadPageData,
                      child: itemsToDisplay.isEmpty
                          // DÜZELTME: Boş liste görünümü tekrar aktif edildi.
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(30.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      // DÜZELTME: _isSearching değişkeni artık kullanılıyor.
                                      _isSearching ? Icons.search_off_rounded : Icons.add_shopping_cart_rounded,
                                      size: 80,
                                      color: theme.textTheme.bodySmall?.color,
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      _isSearching ? 'Aramanızla eşleşen stok bulunamadı.' : 'Henüz hiç stok eklenmemiş.',
                                      style: theme.textTheme.titleMedium?.copyWith(color: theme.textTheme.bodySmall?.color),
                                      textAlign: TextAlign.center,
                                    ),
                                    if (!_isSearching) ...[
                                      const SizedBox(height: 25),
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.add_circle_outline),
                                        label: const Text('İlk Stoğunu Ekle'),
                                        onPressed: () =>
                                            Navigator.of(context, rootNavigator: true).push(
                                          MaterialPageRoute(builder: (navCtx) => const AddEditStockPage()),
                                        ).then((_) {
                                          if (mounted) _loadPageData();
                                        }),
                                      )
                                    ]
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.only(
                                top: listItemVerticalPadding,
                                bottom: totalBottomClearance + listItemVerticalPadding,
                              ),
                              itemCount: itemsToDisplay.length,
                              itemBuilder: (listCtx, i) {
                                final item = itemsToDisplay[i];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: pageHorizontalPadding,
                                    vertical: listItemVerticalPadding,
                                  ),
                                  child: LayoutBuilder(
                                    builder: (BuildContext layoutBuilderContext, BoxConstraints constraints) {
                                      final double cardWidth = constraints.maxWidth;
                                      final double currentProgress = _swipeProgress[item.id] ?? 0.0;
                                      final DismissDirection? currentDirection = _swipeDirection[item.id];
                                      double backgroundRevealWidth = cardWidth * currentProgress;
                                      double totalBackgroundWidth = backgroundRevealWidth + (currentProgress > 0.01 ? actionBackgroundOverdrag : 0.0);
                                      if (currentProgress < 0.01) totalBackgroundWidth = 0;

                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(StockItemCard.cardRadius),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            if (currentDirection != null)
                                              Positioned(
                                                top: 0, bottom: 0,
                                                left: currentDirection == DismissDirection.startToEnd ? 0 : null,
                                                right: currentDirection == DismissDirection.endToStart ? 0 : null,
                                                width: totalBackgroundWidth.clamp(0.0, cardWidth + actionBackgroundOverdrag),
                                                child: _buildActionBackgroundLayer(
                                                  currentDirection == DismissDirection.startToEnd ? Colors.red.shade700 : AppTheme.accentColor,
                                                  currentDirection == DismissDirection.startToEnd ? Icons.delete_sweep_outlined : Icons.push_pin_outlined,
                                                  currentDirection == DismissDirection.startToEnd ? Alignment.centerLeft : Alignment.centerRight,
                                                ),
                                              ),
                                            Dismissible(
                                                key: ValueKey(item.id),
                                                background: Container(color: Colors.transparent),
                                                secondaryBackground: Container(color: Colors.transparent),
                                                onUpdate: (details) {
                                                  setState(() {
                                                    _swipeProgress[item.id] = details.progress;
                                                    _swipeDirection[item.id] = details.direction;
                                                  });
                                                },
                                                confirmDismiss: (direction) async {
                                                  bool? confirmed = false;
                                                  final currentItemContext = listCtx;
                                                  if (direction == DismissDirection.endToStart) {
                                                    if (!mounted) return false;
                                                    ScaffoldMessenger.of(currentItemContext).showSnackBar(
                                                      SnackBar(content: Text('"${item.name}" için sabitleme özelliği eklenecek.')),
                                                    );
                                                    confirmed = false;
                                                  } else if (direction == DismissDirection.startToEnd) {
                                                    confirmed = await _showDeleteConfirmationDialog(currentItemContext, item);
                                                    confirmed ??= false;
                                                  }
                                                  if (confirmed == false) {
                                                    setState(() {
                                                      _swipeProgress.remove(item.id);
                                                      _swipeDirection.remove(item.id);
                                                    });
                                                  }
                                                  return confirmed;
                                                },
                                                onDismissed: (direction) {
                                                  if (direction == DismissDirection.startToEnd) {
                                                    final originalItem = StockItem.fromMap(item.toMap());
                                                    stockProvider.deleteItem(item.id, notify: true);

                                                    final scaffoldCtx = listCtx;
                                                    if (mounted) {
                                                      ScaffoldMessenger.of(scaffoldCtx).showSnackBar(
                                                        SnackBar(
                                                          content: Text('"${originalItem.name}" silindi.'),
                                                          action: SnackBarAction(
                                                            label: "GERİ AL",
                                                            onPressed: () {
                                                              stockProvider.addItem(
                                                                name: originalItem.name,
                                                                quantity: originalItem.quantity,
                                                                barcode: originalItem.barcode,
                                                                qrCode: originalItem.qrCode,
                                                                shelfLocation: originalItem.shelfLocation,
                                                                stockCode: originalItem.stockCode,
                                                                category: originalItem.category,
                                                                localImagePath: originalItem.localImagePath,
                                                                alertThreshold: originalItem.alertThreshold,
                                                                brand: originalItem.brand,
                                                                supplier: originalItem.supplier,
                                                                invoiceNumber: originalItem.invoiceNumber,
                                                                maxStockThreshold: originalItem.maxStockThreshold,
                                                                warehouseId: originalItem.warehouseId,
                                                                shopId: originalItem.shopId,
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                  setState(() {
                                                    _swipeProgress.remove(item.id);
                                                    _swipeDirection.remove(item.id);
                                                  });
                                                },
                                                child: StockItemCard(
                                                  key: ValueKey('stock_card_fg_${item.id}'),
                                                  stockItem: item,
                                                  globalMaxStockThreshold: _globalMaxStockThreshold,
                                                  onTap: () {
                                                    Navigator.of(layoutBuilderContext, rootNavigator: true).push(
                                                      MaterialPageRoute(builder: (navCtx) => AddEditStockPage(existingItemId: item.id)),
                                                    ).then((_) {
                                                      if (mounted) _loadPageData();
                                                    });
                                                  },
                                                ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                    // Listenin üzerine binen ve "yok olma" efektini yaratan gradyan katmanı
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      // Gradyanın yüksekliği, navbar ve alt boşlukları kaplayacak kadar olmalı
                      height: totalBottomClearance + 20, // Daha yumuşak bir geçiş için ekstra yükseklik
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              // DÜZELTME: withOpacity yerine withAlpha kullanıldı.
                              AppTheme.appBackgroundColor.withAlpha(0),
                              AppTheme.appBackgroundColor,
                            ],
                            stops: const [0.0, 0.85],
                          ),
                        ),
                        child: const IgnorePointer(),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

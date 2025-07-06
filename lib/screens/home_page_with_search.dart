// lib/screens/home_page_with_search.dart
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // GestureRecognizer için eklendi
import 'package:flutter/foundation.dart' show kDebugMode, setEquals;
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import '../models/stock_item.dart';
import './add_edit_stock_page.dart';
// import '../widgets/barcode_scanner_page.dart';
import './settings_page.dart';
import '../widgets/stock_item_card.dart';
import '../utils/app_theme.dart';
import '../widgets/dialogs/show_stock_options_dialog.dart';

class HomePageWithSearch extends StatefulWidget {
  const HomePageWithSearch({super.key});

  @override
  State<HomePageWithSearch> createState() => _HomePageWithSearchState();
}

class _HomePageWithSearchState extends State<HomePageWithSearch> {
  final TextEditingController _searchController = TextEditingController();
  List<StockItem> _filteredItems = [];
  bool _isSearching = false;
  int _globalMaxStockThreshold = 100;
  bool _isLoadingSettings = true;

  // Orijinal yapınız korundu
  final Map<String, double> _swipeProgress = {};
  final Map<String, DismissDirection?> _swipeDirection = {};

  static const double pageHorizontalPadding = 20.0;
  static const double listItemVerticalPadding = 6.0;
  static const double actionBackgroundOverdrag = 70.0;

  final ScrollController _scrollController = ScrollController();
  final Set<String> _disabledCardIds = {};
  double _totalBottomClearance = 0.0;

  final Map<String, GlobalKey> _itemDismissibleKeys = {};


  @override
  void initState() {
    super.initState();
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    _updateFilteredItems(stockProvider.items);
    _searchController.addListener(_onSearchChanged);
    _loadPageData();
    stockProvider.addListener(_providerListener);

    _scrollController.addListener(_updateCardInteractivity);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateTotalBottomClearance();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateCardInteractivity();
    });
  }

  void _providerListener() {
    if (mounted) {
      _onSearchChanged();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _updateCardInteractivity();
      });
    }
  }

  Future<void> _loadPageData() async {
    if (!mounted) return;
    
    // --- ÇÖZÜM 2: Yenileme başlamadan önce tüm kaydırma animasyonlarını sıfırla ---
    // Bu, yenileme sırasında "zımba" ikonunun görünmesini engeller.
    setState(() {
      _swipeProgress.clear();
      _swipeDirection.clear();
      _isLoadingSettings = true; 
    });

    try {
      // Bu metodun içeriği, projenizin global ayarlarını nasıl çektiğinize bağlıdır.
      // Örnek olarak 100 değeri atanmıştır.
      const threshold = 100; // await getGlobalMaxStockThreshold();
      if (mounted) {
          await Provider.of<StockProvider>(context, listen: false).fetchAndSetItems(forceFetch: true);
      }
      if (!mounted) return;
      setState(() { _globalMaxStockThreshold = threshold; }); 
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _updateCardInteractivity();
      });
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateCardInteractivity();
    });
  }

  Future<void> _scanAndSearch() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Barkod tarama özelliği eklenecek.")));
    }
  }

  @override
  void dispose() {
    Provider.of<StockProvider>(context, listen: false).removeListener(_providerListener);
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.removeListener(_updateCardInteractivity);
    _scrollController.dispose();
    _itemDismissibleKeys.clear();
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

  void _updateTotalBottomClearance() {
    const double navBarHeight = 58.0;
    const double navBarBottomMargin = 22.0;
    const double navBarTopMargin = 8.0;
    final double bottomSafeArea = MediaQuery.of(context).padding.bottom;
    _totalBottomClearance = navBarHeight + navBarBottomMargin + navBarTopMargin + bottomSafeArea;
  }

  void _updateCardInteractivity() {
    if (!mounted || !_scrollController.hasClients) return;

    final double screenHeight = MediaQuery.of(context).size.height;
    final double navBarTopY = screenHeight - _totalBottomClearance;

    final Set<String> newlyDisabledCardIds = {};

    for (final item in _filteredItems) {
      final GlobalKey? itemDismissibleKey = _itemDismissibleKeys[item.id];
      if (itemDismissibleKey == null) continue;

      final RenderObject? renderObject = itemDismissibleKey.currentContext?.findRenderObject();

      if (renderObject is RenderBox && renderObject.attached) {
        final RenderBox cardRenderBox = renderObject;
        final Offset cardGlobalPosition = cardRenderBox.localToGlobal(Offset.zero);
        final Size cardSize = cardRenderBox.size;
        
        final Rect cardRect = Rect.fromLTWH(
          cardGlobalPosition.dx,
          cardGlobalPosition.dy,
          cardSize.width,
          cardSize.height,
        );

        if (cardRect.bottom > navBarTopY) {
          final double overlapHeight = cardRect.bottom - navBarTopY;
          if (overlapHeight / cardSize.height >= 1.70) {
            newlyDisabledCardIds.add(item.id);
          }
        }
      }
    }

    if (!setEquals(_disabledCardIds, newlyDisabledCardIds)) {
      setState(() {
        _disabledCardIds
          ..clear()
          ..addAll(newlyDisabledCardIds);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    _updateTotalBottomClearance();

    return Scaffold(
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
                _updateFilteredItems(stockProvider.items);
                final itemsToDisplay = _filteredItems;
                return Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: _loadPageData,
                      child: itemsToDisplay.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(30.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
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
                          // --- ÇÖZÜM 1: "Işık huzmesi" efektini (overscroll glow) engelle ---
                          : NotificationListener<OverscrollIndicatorNotification>(
                              onNotification: (OverscrollIndicatorNotification notification) {
                                notification.disallowIndicator(); // Efekti engelle
                                return true;
                              },
                              child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                controller: _scrollController,
                                padding: EdgeInsets.only(
                                  top: listItemVerticalPadding,
                                  bottom: _totalBottomClearance - 8.0,
                                ),
                                itemCount: itemsToDisplay.length,
                                itemBuilder: (listCtx, i) {
                                  final item = itemsToDisplay[i];
                                  final bool isTappable = !_disabledCardIds.contains(item.id);
                                  final GlobalKey dismissibleKey = _itemDismissibleKeys.putIfAbsent(item.id, () => GlobalKey());

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
                                                    currentDirection == DismissDirection.startToEnd ? AppTheme.accentColor : Colors.red.shade700,
                                                    currentDirection == DismissDirection.startToEnd ? Icons.push_pin_outlined : Icons.delete_sweep_outlined,
                                                    currentDirection == DismissDirection.startToEnd ? Alignment.centerLeft : Alignment.centerRight,
                                                  ),
                                                ),
                                              Dismissible(
                                                key: dismissibleKey,
                                                background: Container(color: Colors.transparent),
                                                secondaryBackground: Container(color: Colors.transparent),
                                                onUpdate: (details) { setState(() { _swipeProgress[item.id] = details.progress; _swipeDirection[item.id] = details.direction; }); },
                                                direction: DismissDirection.horizontal,
                                                confirmDismiss: (direction) async {
                                                  bool? confirmed = false;
                                                  final currentItemContext = listCtx;
                                                  
                                                  if (direction == DismissDirection.startToEnd) {
                                                    if (!mounted) return false;
                                                    ScaffoldMessenger.of(currentItemContext).showSnackBar(SnackBar(content: Text('"${item.name}" için sabitleme özelliği eklenecek.')));
                                                    confirmed = false;
                                                  } else if (direction == DismissDirection.endToStart) {
                                                    confirmed = await _showDeleteConfirmationDialog(currentItemContext, item);
                                                    confirmed ??= false;
                                                  }

                                                  if (confirmed == false) {
                                                    setState(() { _swipeProgress.remove(item.id); _swipeDirection.remove(item.id); });
                                                  }
                                                  return confirmed;
                                                },
                                                onDismissed: (direction) {
                                                  if (direction == DismissDirection.endToStart) {
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
                                                                name: originalItem.name, quantity: originalItem.quantity,
                                                                barcode: originalItem.barcode, qrCode: originalItem.qrCode,
                                                                shelfLocation: originalItem.shelfLocation, stockCode: originalItem.stockCode,
                                                                category: originalItem.category, localImagePath: originalItem.localImagePath,
                                                                alertThreshold: originalItem.alertThreshold, brand: originalItem.brand,
                                                                supplier: originalItem.supplier, invoiceNumber: originalItem.invoiceNumber,
                                                                maxStockThreshold: originalItem.maxStockThreshold,
                                                                warehouseId: originalItem.warehouseId, shopId: originalItem.shopId,
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                  setState(() { _swipeProgress.remove(item.id); _swipeDirection.remove(item.id); });
                                                },
                                                child: StockItemCard(
                                                  key: ValueKey('stock_card_fg_${item.id}'),
                                                  stockItem: item,
                                                  globalMaxStockThreshold: _globalMaxStockThreshold,
                                                  onTap: isTappable ? () {
                                                    showStockOptionsDialog(context, item);
                                                  } : null,
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
                    ),
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      height: _totalBottomClearance,
                      child: IgnorePointer(
                        ignoring: true,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter, end: Alignment.bottomCenter,
                              colors: [ AppTheme.appBackgroundColor.withAlpha(0), AppTheme.appBackgroundColor, ],
                              stops: const [0.0, 0.85],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

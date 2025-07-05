// lib/screens/home_page_with_search.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
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

  final Map<String, double> _swipeProgress = {};
  final Map<String, DismissDirection?> _swipeDirection = {};

  static const double pageHorizontalPadding = 20.0;
  static const double listItemVerticalPadding = 6.0;
  static const double actionBackgroundOverdrag = 70.0;

  // New variables for card interactivity based on position
  final ScrollController _scrollController = ScrollController();
  final Set<String> _disabledCardIds = {};
  double _totalBottomClearance = 0.0;

  // Map to store GlobalKeys for each Dismissible item to allow lookup from scroll listener
  final Map<String, GlobalKey> _itemDismissibleKeys = {};


  @override
  void initState() {
    super.initState();
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    _updateFilteredItems(stockProvider.items);
    _searchController.addListener(_onSearchChanged);
    _loadPageData();
    stockProvider.addListener(_providerListener);

    // Add scroll listener to update card interactivity
    _scrollController.addListener(_updateCardInteractivity);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update totalBottomClearance when dependencies change (e.g., safe area, orientation)
    _updateTotalBottomClearance();
    // After dependencies change and layout might shift, re-check interactivity in the next frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCardInteractivity();
    });
  }

  void _providerListener() {
    if (mounted) {
      _onSearchChanged();
      // When stock items change, card interactivity might need re-evaluation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateCardInteractivity();
      });
    }
  }

  Future<void> _loadPageData() async {
    if (!mounted) return;
    setState(() { _isLoadingSettings = true; });
    try {
      // Assuming getGlobalMaxStockThreshold is defined elsewhere or is part of StockProvider
      final threshold = await getGlobalMaxStockThreshold();
      if (mounted) {
          await Provider.of<StockProvider>(context, listen: false).fetchAndSetItems(forceFetch: true);
      }
      if (!mounted) return;
      // Fix: Corrected typo from _globalMaxMaxStockThreshold to _globalMaxStockThreshold
      setState(() { _globalMaxStockThreshold = threshold; }); 
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateCardInteractivity(); // Initial check after data loads and layout is complete
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
      _updateCardInteractivity(); // Re-check interactivity after search filter changes
    });
  }

  Future<void> _scanAndSearch() async {
    // BarcodeScannerPage importu aktifse bu çalışır.
    // Şimdilik SnackBar gösteriyor.
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
    _itemDismissibleKeys.clear(); // Clear the map of GlobalKeys
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

    // Get the global Y coordinate where the bottom navigation area starts
    final double screenHeight = MediaQuery.of(context).size.height;
    final double navBarTopY = screenHeight - _totalBottomClearance;

    final Set<String> newlyDisabledCardIds = {};

    // Iterate over all filtered items. Only items currently rendered will have a RenderBox.
    for (final item in _filteredItems) {
      // Use the stored GlobalKey for the Dismissible widget to find its RenderBox.
      final GlobalKey? itemDismissibleKey = _itemDismissibleKeys[item.id];
      if (itemDismissibleKey == null) continue; // Item might not be rendered yet or was disposed.

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

        // Check if the card's bottom edge is below the navbar's top edge (i.e., it's overlapping)
        if (cardRect.bottom > navBarTopY) {
          final double overlapHeight = cardRect.bottom - navBarTopY;
          // If 90% or more of the card's height is overlapping the navbar area, disable it.
          if (overlapHeight / cardSize.height >= 1.70) {
            newlyDisabledCardIds.add(item.id);
          }
        }
      }
    }

    // Manually compare sets to avoid unnecessary setState calls.
    bool setsAreDifferent = false;
    if (_disabledCardIds.length != newlyDisabledCardIds.length) {
      setsAreDifferent = true;
    } else {
      // Check if all elements in newlyDisabledCardIds are present in _disabledCardIds
      for (final id in newlyDisabledCardIds) {
        if (!_disabledCardIds.contains(id)) {
          setsAreDifferent = true;
          break;
        }
      }
    }

    if (setsAreDifferent) {
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
    // Ensure _totalBottomClearance is up-to-date for the current build frame
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
                _updateFilteredItems(stockProvider.items); // Update list on every build for reactivity
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
                          : ListView.builder(
                              // Removed key: _listViewKey as it's no longer used for RenderBox lookup
                              controller: _scrollController, // Assign controller
                              padding: EdgeInsets.only(
                                top: listItemVerticalPadding,
                                bottom: _totalBottomClearance + listItemVerticalPadding,
                              ),
                              itemCount: itemsToDisplay.length,
                              itemBuilder: (listCtx, i) {
                                final item = itemsToDisplay[i];
                                // Determine if the card should be tappable based on its ID's presence in _disabledCardIds
                                final bool isTappable = !_disabledCardIds.contains(item.id);

                                // Ensure a GlobalKey exists for this Dismissible and store it
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
                                                    currentDirection == DismissDirection.startToEnd ? Colors.red.shade700 : AppTheme.accentColor,
                                                    currentDirection == DismissDirection.startToEnd ? Icons.delete_sweep_outlined : Icons.push_pin_outlined,
                                                    currentDirection == DismissDirection.startToEnd ? Alignment.centerLeft : Alignment.centerRight,
                                                  ),
                                                ),
                                              Dismissible(
                                                key: dismissibleKey, // Use the unique GlobalKey for this Dismissible
                                                background: Container(color: Colors.transparent),
                                                secondaryBackground: Container(color: Colors.transparent),
                                                onUpdate: (details) { setState(() { _swipeProgress[item.id] = details.progress; _swipeDirection[item.id] = details.direction; }); },
                                                confirmDismiss: (direction) async {
                                                  bool? confirmed = false;
                                                  final currentItemContext = listCtx;
                                                  if (direction == DismissDirection.endToStart) {
                                                    if (!mounted) return false;
                                                    ScaffoldMessenger.of(currentItemContext).showSnackBar(SnackBar(content: Text('"${item.name}" için sabitleme özelliği eklenecek.')));
                                                    confirmed = false;
                                                  } else if (direction == DismissDirection.startToEnd) {
                                                    confirmed = await _showDeleteConfirmationDialog(currentItemContext, item);
                                                    confirmed ??= false;
                                                  }
                                                  if (confirmed == false) {
                                                    setState(() { _swipeProgress.remove(item.id); _swipeDirection.remove(item.id); });
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
                                                  key: ValueKey('stock_card_fg_${item.id}'), // Original key for StockItemCard
                                                  stockItem: item,
                                                  globalMaxStockThreshold: _globalMaxStockThreshold,
                                                  // Conditionally set onTap to null to disable it
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
                    // This `Positioned` widget is the translucent overlay at the bottom.
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      height: _totalBottomClearance + 20, // Use the state variable
                      child: IgnorePointer( // This already makes the gradient non-interactive
                        ignoring: true,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter, end: Alignment.bottomCenter,
                              // Fix: Use .withAlpha(0) instead of .withOpacity(0) for transparency
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
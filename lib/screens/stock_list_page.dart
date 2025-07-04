// lib/screens/stock_list_page.dart
// import 'dart:io'; // Image.file burada kullanılmıyor, StockItemCard içinde
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode; // kIsWeb burada kullanılmıyor
import 'package:provider/provider.dart';
import '../models/stock_item.dart';
import '../providers/stock_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/stock_item_card.dart';
import './add_edit_stock_page.dart';
import './settings_page.dart';

class StockListPage extends StatefulWidget {
  const StockListPage({super.key});

  @override
  State<StockListPage> createState() => _StockListPageState();
}

class _StockListPageState extends State<StockListPage> {
  int _globalMaxStockThreshold = 100;
  bool _isLoadingSettings = true;

  final Map<String, double> _swipeProgress = {};
  final Map<String, DismissDirection?> _swipeDirection = {};

  static const double pageHorizontalPadding = 20.0;
  static const double listItemVerticalPadding = 6.0;
  static const double actionBackgroundOverdrag = 70.0;
  static const double bottomNavBarSpaceEstimate = 88.0;

  @override
  void initState() {
    super.initState();
    _loadPageData();
  }

  Future<void> _loadPageData() async {
    if (!mounted) return;
    if (!_isLoadingSettings) {
      setState(() { _isLoadingSettings = true; });
    }
    try {
      _globalMaxStockThreshold = await getGlobalMaxStockThreshold();
      if (mounted) {
        await Provider.of<StockProvider>(context, listen: false).fetchAndSetItems(forceFetch: true);
      }
    } catch (e) {
      if (kDebugMode) print("StockListPage veri yüklenirken hata: $e");
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

  void _navigateToAddEdit({String? id}) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (ctx) => AddEditStockPage(existingItemId: id)),
    ).then((_) {
      if (mounted) {
        _loadPageData();
      }
    });
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
    final stockProviderForInitialCheck = Provider.of<StockProvider>(context, listen: false);
    if (_isLoadingSettings && stockProviderForInitialCheck.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Stok Listesi')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Consumer<StockProvider>(
      builder: (consumerContext, stockProvider, _) {
        final List<StockItem> items = List.from(stockProvider.items);
        items.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

        return Scaffold(
          appBar: AppBar(
            title: const Text('Stok Listesi'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Yeni Stok Ekle',
                onPressed: () => _navigateToAddEdit(),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _loadPageData,
            child: items.isEmpty
                ? _EmptyList(onAddFirst: () => _navigateToAddEdit())
                : ListView.builder(
                    padding: EdgeInsets.only(
                      top: listItemVerticalPadding,
                      bottom: bottomNavBarSpaceEstimate + MediaQuery.of(context).padding.bottom + listItemVerticalPadding,
                    ),
                    itemCount: items.length,
                    itemBuilder: (listViewContext, i) {
                      final currentItem = items[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: pageHorizontalPadding,
                          vertical: listItemVerticalPadding,
                        ),
                        child: LayoutBuilder(
                          builder: (layoutBuilderContext, constraints) {
                            final double cardWidth = constraints.maxWidth;
                            final double currentProgress = _swipeProgress[currentItem.id] ?? 0.0;
                            final DismissDirection? currentDirection = _swipeDirection[currentItem.id];
                            double backgroundRevealWidth = cardWidth * currentProgress;
                            double totalBackgroundWidth = backgroundRevealWidth + (currentProgress > 0.01 ? actionBackgroundOverdrag : 0.0);
                            if (currentProgress < 0.01) {
                              totalBackgroundWidth = 0;
                            }

                            return ClipRRect(
                              borderRadius: BorderRadius.circular(StockItemCard.cardRadius),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (currentDirection != null)
                                    Positioned(
                                      top: 0,
                                      bottom: 0,
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
                                    key: ValueKey(currentItem.id),
                                    background: Container(color: Colors.transparent),
                                    secondaryBackground: Container(color: Colors.transparent),
                                    onUpdate: (details) {
                                      setState(() {
                                        _swipeProgress[currentItem.id] = details.progress;
                                        _swipeDirection[currentItem.id] = details.direction;
                                      });
                                    },
                                    confirmDismiss: (direction) async {
                                      bool? confirmed = false;
                                      final currentItemContextForDialog = listViewContext;
                                      if (direction == DismissDirection.endToStart) {
                                        if (!mounted) return false;
                                        ScaffoldMessenger.of(currentItemContextForDialog).showSnackBar(
                                          SnackBar(content: Text('"${currentItem.name}" için sabitleme özelliği eklenecek.')),
                                        );
                                        confirmed = false;
                                      } else if (direction == DismissDirection.startToEnd) {
                                        confirmed = await _showDeleteConfirmationDialog(currentItemContextForDialog, currentItem);
                                        confirmed ??= false;
                                      }
                                      if (confirmed == false) {
                                        setState(() {
                                          _swipeProgress.remove(currentItem.id);
                                          _swipeDirection.remove(currentItem.id);
                                        });
                                      }
                                      return confirmed;
                                    },
                                    onDismissed: (direction) {
                                      if (direction == DismissDirection.startToEnd) {
                                        final originalItem = StockItem.fromMap(currentItem.toMap());
                                        stockProvider.deleteItem(currentItem.id);

                                        final scaffoldCtxForDismiss = listViewContext;
                                        if (mounted) {
                                          ScaffoldMessenger.of(scaffoldCtxForDismiss).showSnackBar(
                                            SnackBar(
                                              content: Text('"${originalItem.name}" silindi.'),
                                              action: SnackBarAction(
                                                label: 'GERİ AL',
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
                                        _swipeProgress.remove(currentItem.id);
                                        _swipeDirection.remove(currentItem.id);
                                      });
                                    },
                                    child: StockItemCard(
                                      key: ValueKey('list_stock_card_${currentItem.id}'),
                                      stockItem: currentItem,
                                      globalMaxStockThreshold: _globalMaxStockThreshold,
                                      onTap: () => _navigateToAddEdit(id: currentItem.id),
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
        );
      },
    );
  }
}

// ----- boş liste widget'ı -----
class _EmptyList extends StatelessWidget {
  final VoidCallback? onAddFirst;
  const _EmptyList({this.onAddFirst});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_shopping_cart_rounded, size: 80, color: theme.textTheme.bodySmall?.color),
            const SizedBox(height: 20),
            Text(
              'Henüz hiç stok eklenmemiş.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(color: theme.textTheme.bodySmall?.color),
            ),
            if (onAddFirst != null) ...[
                const SizedBox(height: 25),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('İlk Stoğunu Ekle'),
                  onPressed: onAddFirst,
                )
            ]
          ],
        ),
      ),
    );
  }
}
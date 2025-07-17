// lib/screens/stock_list_page.dart
// import 'dart:io'; // Image.file burada kullanılmıyor, StockItemCard içinde
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart'
    show kDebugMode; // kIsWeb burada kullanılmıyor
import 'package:provider/provider.dart';
import 'package:another_flushbar/flushbar.dart'; // Flushbar paketi
import '../models/stock_item.dart';
import '../providers/stock_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/stock_item_card.dart';
import '../widgets/corporate_header.dart';
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
  // Bottom navigation bar için dinamik hesaplama yapacağız - sabit değer kaldırıldı

  @override
  void initState() {
    super.initState();
    _loadPageData();
  }

  Future<void> _loadPageData() async {
    if (!mounted) return;
    if (!_isLoadingSettings) {
      setState(() {
        _isLoadingSettings = true;
      });
    }
    try {
      _globalMaxStockThreshold = await getGlobalMaxStockThreshold();
      if (mounted) {
        await Provider.of<StockProvider>(context, listen: false)
            .fetchAndSetItems(forceFetch: true);
      }
    } catch (e) {
      if (kDebugMode) print("StockListPage veri yüklenirken hata: $e");
      if (mounted) {
        _showStyledFlushbar(context, 'Veri yüklenirken bir hata oluştu.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSettings = false;
        });
      }
    }
  }

  void _navigateToAddEdit({String? id}) {
    Navigator.of(context, rootNavigator: true)
        .push(
      MaterialPageRoute(builder: (ctx) => AddEditStockPage(existingItemId: id)),
    )
        .then((_) {
      if (mounted) {
        _loadPageData();
      }
    });
  }

  // Logo seçme
  void _selectLogo() {
    _showStyledFlushbar(context, "Logo seçme özelliği yakında eklenecek.");
  }

  Future<bool?> _showDeleteConfirmationDialog(
      BuildContext ctx, StockItem item) async {
    final result = await showDialog<bool>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Silme Onayı'),
        content: Text(
            '"${item.name}" adlı stoğu silmek istediğinizden emin misiniz?'),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: <Widget>[
          TextButton(
            child: const Text('İptal'),
            onPressed: () => Navigator.of(dialogCtx).pop(false),
          ),
          TextButton(
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Evet, Sil'),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
          ),
        ],
      ),
    );
    return result;
  }

  Widget _buildActionBackgroundLayer(
      Color actionColor, IconData icon, Alignment alignment) {
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

  void _showStyledFlushbar(BuildContext context, String message,
      {Widget? mainButton}) {
    // AMK 1 YAPALIM BAKALIM NE OLACAK
    final double bottomSafeArea = MediaQuery.of(context).padding.bottom;

    Flushbar(
      messageText: Row(
        children: [
          Icon(Icons.info_outline,
              color: Theme.of(context).primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                  color: Colors.black87, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      mainButton: mainButton,
      flushbarPosition: FlushbarPosition.BOTTOM,
      forwardAnimationCurve: Curves.elasticOut,
      reverseAnimationCurve: Curves.fastOutSlowIn,
      backgroundColor: Colors.white,
      borderRadius: BorderRadius.circular(30.0),
      margin: EdgeInsets.only(
        bottom: bottomSafeArea + MediaQuery.of(context).viewInsets.bottom + 1.0,
        left: 20,
        right: 20,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          offset: const Offset(0, 2),
          blurRadius: 10,
        ),
      ],
      duration: const Duration(seconds: 4),
      animationDuration: const Duration(milliseconds: 400),
      isDismissible: true,
      // rootNavigator'ı false yaparak navbar'ın erişilebilir kalmasını sağlıyoruz
      routeBlur: 0.0, // Arka planı bulanıklaştırma
      routeColor: Colors.transparent, // Arka plan rengi şeffaf
    ).show(context);
  }

  // WhatsApp benzeri sıralama mantığı
  List<StockItem> _getSortedItems(List<StockItem> sourceItems) {
    final List<StockItem> sortedItems = List.from(sourceItems);

    // WhatsApp MANTĞINDA: SABİTLENEN KARTLAR EN ÜSTTE, EN SON SABİTLENEN EN ÜST SIRA
    sortedItems.sort((a, b) {
      // Sabitleme durumuna göre ana sıralama
      if (a.isPinned && !b.isPinned) {
        return -1; // Sabitlenmiş önce gelir
      } else if (!a.isPinned && b.isPinned) {
        return 1; // Sabitlenmiş önce gelir
      }

      // İkisi de sabitlenmişse: EN SON SABİTLENEN EN ÜSTE (WhatsApp mantığı)
      if (a.isPinned && b.isPinned) {
        final aTime = a.pinnedTimestamp;
        final bTime = b.pinnedTimestamp;

        // İkisinin de zaman damgası varsa, en yeni olan üstte
        if (aTime != null && bTime != null) {
          return bTime.compareTo(aTime); // Yeni tarih önce gelir
        }
        // Sadece birinin zaman damgası varsa, o üstte
        else if (aTime != null && bTime == null) {
          return -1; // a üstte
        } else if (aTime == null && bTime != null) {
          return 1; // b üstte
        }
        // İkisinin de zaman damgası yoksa alfabetik
        else {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        }
      }

      // İkisi de sabitlenmemişse alfabetik sıralama
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return sortedItems;
  }

  @override
  Widget build(BuildContext context) {
    final stockProviderForInitialCheck =
        Provider.of<StockProvider>(context, listen: false);
    if (_isLoadingSettings && stockProviderForInitialCheck.items.isEmpty) {
      return Scaffold(
        appBar: CorporateHeader(
          title: 'Stok Listesi',
          showBackButton: true,
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Consumer<StockProvider>(
      builder: (consumerContext, stockProvider, _) {
        // WhatsApp benzeri sıralama uygula
        final List<StockItem> items = _getSortedItems(stockProvider.items);

        return Scaffold(
          appBar: CorporateHeader(
            title: 'Stok Listesi',
            showBackButton: true,
            showAddButton: true,
            centerTitle: true,
            onAddPressed: () => _navigateToAddEdit(),
          ),
          body: CustomScrollView(
            // iOS refresh için gerekli physics
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // iOS tarzı refresh control
              CupertinoSliverRefreshControl(
                onRefresh: _loadPageData,
                refreshTriggerPullDistance: 80.0, // iOS standart
                refreshIndicatorExtent: 60.0, // iOS standart
              ),
              // Ana içerik
              items.isEmpty
                  ? SliverFillRemaining(
                      child: _EmptyList(onAddFirst: () => _navigateToAddEdit()),
                    )
                  : SliverPadding(
                      padding: EdgeInsets.only(
                        top: listItemVerticalPadding,
                        // Dinamik bottom padding hesaplama - overflow çözümü (artırıldı)
                        bottom: MediaQuery.of(context).padding.bottom +
                            MediaQuery.of(context).viewInsets.bottom +
                            120.0, // 120px navbar için güvenli alan
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (listViewContext, i) {
                            final currentItem = items[i];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: pageHorizontalPadding,
                                vertical: listItemVerticalPadding,
                              ),
                              child: LayoutBuilder(
                                builder: (layoutBuilderContext, constraints) {
                                  final double cardWidth = constraints.maxWidth;
                                  final double currentProgress =
                                      _swipeProgress[currentItem.id] ?? 0.0;
                                  final DismissDirection? currentDirection =
                                      _swipeDirection[currentItem.id];
                                  double backgroundRevealWidth =
                                      cardWidth * currentProgress;
                                  double totalBackgroundWidth =
                                      backgroundRevealWidth +
                                          (currentProgress > 0.01
                                              ? actionBackgroundOverdrag
                                              : 0.0);
                                  if (currentProgress < 0.01) {
                                    totalBackgroundWidth = 0;
                                  }

                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        StockItemCard.cardRadius),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        if (currentDirection != null)
                                          Positioned(
                                            top: 0,
                                            bottom: 0,
                                            left: currentDirection ==
                                                    DismissDirection.startToEnd
                                                ? 0
                                                : null,
                                            right: currentDirection ==
                                                    DismissDirection.endToStart
                                                ? 0
                                                : null,
                                            width: totalBackgroundWidth.clamp(
                                                0.0,
                                                cardWidth +
                                                    actionBackgroundOverdrag),
                                            child: _buildActionBackgroundLayer(
                                              currentDirection ==
                                                      DismissDirection
                                                          .startToEnd
                                                  ? AppTheme.accentColor
                                                  : Colors.red.shade700,
                                              currentDirection ==
                                                      DismissDirection
                                                          .startToEnd
                                                  ? Icons.push_pin
                                                  : Icons.delete_sweep_outlined,
                                              currentDirection ==
                                                      DismissDirection
                                                          .startToEnd
                                                  ? Alignment.centerLeft
                                                  : Alignment.centerRight,
                                            ),
                                          ),
                                        Dismissible(
                                          key: ValueKey(currentItem.id),
                                          background: Container(
                                              color: Colors.transparent),
                                          secondaryBackground: Container(
                                              color: Colors.transparent),
                                          onUpdate: (details) {
                                            setState(() {
                                              _swipeProgress[currentItem.id] =
                                                  details.progress;
                                              _swipeDirection[currentItem.id] =
                                                  details.direction;
                                            });
                                          },
                                          confirmDismiss: (direction) async {
                                            bool? confirmed = false;
                                            final currentItemContextForDialog =
                                                listViewContext;

                                            if (direction ==
                                                DismissDirection.startToEnd) {
                                              if (!mounted) return false;
                                              // SABİTLEME MANTIĞI
                                              await stockProvider
                                                  .togglePinStatus(
                                                      currentItem.id);
                                              final updatedItem = stockProvider
                                                  .items
                                                  .firstWhere((i) =>
                                                      i.id == currentItem.id);

                                              // LİSTEYİ YENIDEN SIRALA (WhatsApp mantığı için kritik!)
                                              if (mounted) {
                                                setState(() {
                                                  // Sıralama otomatik olarak Consumer rebuild ile yapılacak
                                                });
                                              }

                                              _showStyledFlushbar(
                                                currentItemContextForDialog,
                                                updatedItem.isPinned
                                                    ? '"${currentItem.name}" sabitlendi.'
                                                    : '"${currentItem.name}" sabitlemesi kaldırıldı.',
                                              );
                                              confirmed =
                                                  false; // Kartın kaybolmasını engelle
                                            } else if (direction ==
                                                DismissDirection.endToStart) {
                                              confirmed =
                                                  await _showDeleteConfirmationDialog(
                                                      currentItemContextForDialog,
                                                      currentItem);
                                              confirmed ??= false;
                                            }

                                            if (confirmed == false) {
                                              setState(() {
                                                _swipeProgress
                                                    .remove(currentItem.id);
                                                _swipeDirection
                                                    .remove(currentItem.id);
                                              });
                                            }
                                            return confirmed;
                                          },
                                          onDismissed: (direction) {
                                            if (direction ==
                                                DismissDirection.endToStart) {
                                              final originalItem =
                                                  StockItem.fromMap(
                                                      currentItem.toMap());
                                              stockProvider
                                                  .deleteItem(currentItem.id);

                                              final scaffoldCtxForDismiss =
                                                  listViewContext;
                                              if (mounted) {
                                                bool isUndoPressed = false;

                                                final undoButton = TextButton(
                                                  onPressed: () {
                                                    if (isUndoPressed) return;
                                                    isUndoPressed = true;

                                                    stockProvider.addItem(
                                                      name: originalItem.name,
                                                      quantity:
                                                          originalItem.quantity,
                                                      barcode:
                                                          originalItem.barcode,
                                                      qrCode:
                                                          originalItem.qrCode,
                                                      shelfLocation:
                                                          originalItem
                                                              .shelfLocation,
                                                      stockCode: originalItem
                                                          .stockCode,
                                                      category:
                                                          originalItem.category,
                                                      localImagePath:
                                                          originalItem
                                                              .localImagePath,
                                                      alertThreshold:
                                                          originalItem
                                                              .alertThreshold,
                                                      brand: originalItem.brand,
                                                      supplier:
                                                          originalItem.supplier,
                                                      invoiceNumber:
                                                          originalItem
                                                              .invoiceNumber,
                                                      maxStockThreshold:
                                                          originalItem
                                                              .maxStockThreshold,
                                                      warehouseId: originalItem
                                                          .warehouseId,
                                                      shopId:
                                                          originalItem.shopId,
                                                    );

                                                    Navigator.of(context,
                                                            rootNavigator: true)
                                                        .pop();
                                                  },
                                                  child: Text(
                                                    "GERİ AL",
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                );

                                                if (mounted) {
                                                  _showStyledFlushbar(
                                                    scaffoldCtxForDismiss,
                                                    '"${originalItem.name}" silindi.',
                                                    mainButton: undoButton,
                                                  );
                                                }
                                              }
                                            }
                                            setState(() {
                                              _swipeProgress
                                                  .remove(currentItem.id);
                                              _swipeDirection
                                                  .remove(currentItem.id);
                                            });
                                          },
                                          child: Stack(
                                            children: [
                                              StockItemCard(
                                                key: ValueKey(
                                                    'list_stock_card_${currentItem.id}'),
                                                stockItem: currentItem,
                                                globalMaxStockThreshold:
                                                    _globalMaxStockThreshold,
                                                onTap: () => _navigateToAddEdit(
                                                    id: currentItem.id),
                                              ),
                                              // RAPTIYE IKONU (Home page ile aynı)
                                              if (currentItem.isPinned)
                                                Positioned(
                                                  top: 6,
                                                  right: 8,
                                                  child: Transform.rotate(
                                                    angle:
                                                        0.4, // İkonu hafifçe eğ
                                                    child: Icon(
                                                      Icons.push_pin,
                                                      color: Colors.white
                                                          .withValues(
                                                              alpha: 0.95),
                                                      size: 20,
                                                      shadows: const [
                                                        BoxShadow(
                                                          color: Colors.black54,
                                                          blurRadius: 6.0,
                                                          offset: Offset(1, 1),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          childCount: items.length,
                        ),
                      ),
                    ),
            ],
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
            Icon(Icons.add_shopping_cart_rounded,
                size: 80, color: theme.textTheme.bodySmall?.color),
            const SizedBox(height: 20),
            Text(
              'Henüz hiç stok eklenmemiş.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: theme.textTheme.bodySmall?.color),
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

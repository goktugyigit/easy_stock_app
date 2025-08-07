import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kDebugMode, setEquals;
import 'package:provider/provider.dart';
import 'package:another_flushbar/flushbar.dart'; // Flushbar paketi

import '../providers/stock_provider.dart';
import '../models/stock_item.dart';
import './add_edit_stock_page.dart';
import '../widgets/stock_item_card.dart';
import '../utils/app_theme.dart';
import '../widgets/dialogs/show_stock_options_dialog.dart';
import '../widgets/ultra_modern_header.dart';
import '../widgets/modern_empty_state.dart';
import '../widgets/main_screen_with_bottom_nav.dart'; // Navbar boyutları için import

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

class HomePageWithSearch extends StatefulWidget {
  const HomePageWithSearch({super.key});

  @override
  State<HomePageWithSearch> createState() => _HomePageWithSearchState();
}

class _HomePageWithSearchState extends State<HomePageWithSearch> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode(); // App Store mantığı için
  List<StockItem> _filteredItems = [];
  bool _isSearching = false;
  int _globalMaxStockThreshold = 100;
  bool _isLoadingSettings = true;

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
    // App Store mantığı için focus listener
    _searchFocusNode.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
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

  void _showStyledFlushbar(BuildContext context, String message,
      {Widget? mainButton}) {
    // KESİN ÇÖZÜM: Navbar'ın gerçek boyutlarını ve aradaki boşluğu tanımlıyoruz.
    const double navBarHeight = MainScreenWithBottomNav.navBarHeight;
    const double navBarMargin = MainScreenWithBottomNav.navBarBottomMargin;
    const double flushbarGap = 8.0; // Navbar ile arasındaki boşluk

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
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      backgroundColor: Colors.white,
      borderRadius: BorderRadius.circular(25.0),
      margin: EdgeInsets.only(
        // DÜZELTME: Alt boşluk, sadece navbar'ın kapladığı alan + istenen boşluk kadar olmalı.
        bottom: navBarHeight + navBarMargin + flushbarGap,
        left: 20.0,
        right: 20.0,
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
      animationDuration: const Duration(milliseconds: 300),
      isDismissible: true,
    ).show(context);
  }

  Future<void> _loadPageData() async {
    if (!mounted) return;

    setState(() {
      _swipeProgress.clear();
      _swipeDirection.clear();
      _isLoadingSettings = true;
    });

    try {
      const threshold = 100;
      if (mounted) {
        await Provider.of<StockProvider>(context, listen: false)
            .fetchAndSetItems(forceFetch: true);
      }
      if (!mounted) return;
      setState(() {
        _globalMaxStockThreshold = threshold;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _updateCardInteractivity();
      });
    } catch (e) {
      if (kDebugMode) print("HomePageWithSearch veri yuklenirken hata: $e");
      if (mounted) {
        _showStyledFlushbar(context, 'Veri yuklenirken bir hata olustu.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSettings = false;
        });
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
    // WhatsApp MANTĞINDA: SABİTLENEN KARTLAR EN ÜSTTE, EN SON SABİTLENEN EN ÜST SIRA
    _filteredItems.sort((a, b) {
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

  // App Store mantığı - Vazgeç butonu fonksiyonu
  void _cancelSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _isSearching = false;
    });
  }

  // Keyboard'u kapat ve search'i iptal et
  void _dismissKeyboard() {
    if (_searchFocusNode.hasFocus) {
      _cancelSearch(); // Search aktifse tamamen iptal et
    }
  }

  // QR Kod tarama
  void _scanQRCode() {
    _showStyledFlushbar(context, "QR kod tarama özelliği yakında eklenecek.");
  }

  // Barkod tarama
  void _scanBarcode() {
    _showStyledFlushbar(context, "Barkod tarama özelliği yakında eklenecek.");
  }

  // Gelişmiş filtreleme
  void _showAdvancedFilter() {
    _showStyledFlushbar(
        context, "Gelişmiş filtreleme özelliği yakında eklenecek.");
  }

  @override
  void dispose() {
    Provider.of<StockProvider>(context, listen: false)
        .removeListener(_providerListener);
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose(); // Focus node'u dispose et
    _scrollController.removeListener(_updateCardInteractivity);
    _scrollController.dispose();
    _itemDismissibleKeys.clear();
    super.dispose();
  }

  Future<bool?> _showDeleteConfirmationDialog(
      BuildContext ctx, StockItem item) async {
    final result = await showDialog<bool>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Silme Onayi'),
        content: Text(
            '"${item.name}" adli stogu silmek istediginizden emin misiniz?'),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: <Widget>[
          TextButton(
            child: const Text('Iptal'),
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

  void _updateTotalBottomClearance() {
    const double navBarHeight =
        90.0; // Modern navbar yüksekliği - artırıldı (70->90)
    const double navBarBottomMargin = 25.0; // Modern navbar alt boşluğu
    const double navBarGap =
        10.0; // Flushbar'ın navbar üzerinde bırakacağı boşluk

    final double bottomSafeArea = MediaQuery.of(context).padding.bottom;

    final double totalBottomSpace =
        navBarHeight + navBarBottomMargin + navBarGap + bottomSafeArea;
    _totalBottomClearance = totalBottomSpace;
  }

  void _updateCardInteractivity() {
    if (!mounted || !_scrollController.hasClients) return;

    final double screenHeight = MediaQuery.of(context).size.height;
    final double navBarTopY = screenHeight - _totalBottomClearance;

    final Set<String> newlyDisabledCardIds = {};

    for (final item in _filteredItems) {
      final GlobalKey? itemDismissibleKey = _itemDismissibleKeys[item.id];
      if (itemDismissibleKey == null) continue;

      final RenderObject? renderObject =
          itemDismissibleKey.currentContext?.findRenderObject();

      if (renderObject is RenderBox && renderObject.attached) {
        final RenderBox cardRenderBox = renderObject;
        final Offset cardGlobalPosition =
            cardRenderBox.localToGlobal(Offset.zero);
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
    _updateTotalBottomClearance();

    return GestureDetector(
      // App Store mantığı - dışarıya tıklanınca klavye kapansın
      onTap: _dismissKeyboard,
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset:
            false, // Klavye açılınca resize yapmasını engelle
        appBar: UltraModernHeader(
          title: 'Ana Sayfa',
          searchController: _searchController,
          searchFocusNode: _searchFocusNode,
          onQRScan: _scanQRCode,
          onBarcodeScan: _scanBarcode,
          onFilterTap: _showAdvancedFilter,
          onSearchCancel: _cancelSearch,
          searchHint: 'Stok ara',
        ),
        body: Container(
          decoration: const BoxDecoration(
            color: Colors.black,
          ),
          child: SafeArea(
            child: _isLoadingSettings
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF00C6FF),
                    ),
                  )
                : Consumer<StockProvider>(
                    builder: (consumerCtx, stockProvider, _) {
                      _updateFilteredItems(stockProvider.items);
                      final itemsToDisplay = _filteredItems;
                      // Empty state tamamen ayrı widget - keyboard-aware
                      if (itemsToDisplay.isEmpty) {
                        return ModernEmptyState(
                          title: _isSearching
                              ? 'Sonuç Bulunamadı'
                              : 'Henüz Hiç Stok Eklenmedi',
                          subtitle: _isSearching
                              ? 'Aramanızla eşleşen stok bulunamadı. Farklı kelimeler deneyin.'
                              : 'İlk stoğunuzu ekleyerek envanter yönetiminize başlayın.',
                          icon: _isSearching
                              ? Icons.search_off_rounded
                              : Icons.inventory_2_outlined,
                          buttonText: 'İlk Stoğunu Ekle',
                          isSearching: _isSearching,
                          onButtonPressed: _isSearching
                              ? null
                              : () => Navigator.of(context, rootNavigator: true)
                                      .push(
                                    MaterialPageRoute(
                                        builder: (navCtx) =>
                                            const AddEditStockPage()),
                                  )
                                      .then((_) {
                                    if (mounted) {
                                      _loadPageData();
                                    }
                                  }),
                        );
                      }

                      return Stack(
                        children: [
                          // iOS Style Pull-to-Refresh with CupertinoSliverRefreshControl
                          NotificationListener<OverscrollIndicatorNotification>(
                            onNotification:
                                (OverscrollIndicatorNotification notification) {
                              notification.disallowIndicator();
                              return true;
                            },
                            child: CustomScrollView(
                              controller: _scrollController,
                              physics: const BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics(),
                              ),
                              slivers: [
                                // iOS tarzı refresh control
                                CupertinoSliverRefreshControl(
                                  onRefresh: _loadPageData,
                                  refreshTriggerPullDistance:
                                      80.0, // iOS standart
                                  refreshIndicatorExtent: 60.0, // iOS standart
                                ),
                                // Ana içerik
                                SliverPadding(
                                  padding: EdgeInsets.only(
                                    top: listItemVerticalPadding,
                                    bottom: _totalBottomClearance +
                                        MediaQuery.of(context)
                                            .viewInsets
                                            .bottom +
                                        12.0,
                                  ),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (listCtx, i) {
                                        final item = itemsToDisplay[i];
                                        final bool isTappable =
                                            !_disabledCardIds.contains(item.id);
                                        final GlobalKey dismissibleKey =
                                            _itemDismissibleKeys.putIfAbsent(
                                                item.id, () => GlobalKey());

                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: pageHorizontalPadding,
                                            vertical: listItemVerticalPadding,
                                          ),
                                          child: LayoutBuilder(
                                            builder: (BuildContext
                                                    layoutBuilderContext,
                                                BoxConstraints constraints) {
                                              final double cardWidth =
                                                  constraints.maxWidth;
                                              final double currentProgress =
                                                  _swipeProgress[item.id] ??
                                                      0.0;
                                              final DismissDirection?
                                                  currentDirection =
                                                  _swipeDirection[item.id];
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
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        StockItemCard
                                                            .cardRadius),
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    if (currentDirection !=
                                                        null)
                                                      Positioned(
                                                        top: 0,
                                                        bottom: 0,
                                                        left: currentDirection ==
                                                                DismissDirection
                                                                    .startToEnd
                                                            ? 0
                                                            : null,
                                                        right: currentDirection ==
                                                                DismissDirection
                                                                    .endToStart
                                                            ? 0
                                                            : null,
                                                        width: totalBackgroundWidth
                                                            .clamp(
                                                                0.0,
                                                                cardWidth +
                                                                    actionBackgroundOverdrag),
                                                        child:
                                                            _buildActionBackgroundLayer(
                                                          currentDirection ==
                                                                  DismissDirection
                                                                      .startToEnd
                                                              ? AppTheme
                                                                  .accentColor
                                                              : Colors
                                                                  .red.shade700,
                                                          currentDirection ==
                                                                  DismissDirection
                                                                      .startToEnd
                                                              ? Icons.push_pin
                                                              : Icons
                                                                  .delete_sweep_outlined, // İkonu değiştirdik
                                                          currentDirection ==
                                                                  DismissDirection
                                                                      .startToEnd
                                                              ? Alignment
                                                                  .centerLeft
                                                              : Alignment
                                                                  .centerRight,
                                                        ),
                                                      ),
                                                    Dismissible(
                                                      key: dismissibleKey,
                                                      background: Container(
                                                          color: Colors
                                                              .transparent),
                                                      secondaryBackground:
                                                          Container(
                                                              color: Colors
                                                                  .transparent),
                                                      onUpdate: (details) {
                                                        setState(() {
                                                          _swipeProgress[
                                                                  item.id] =
                                                              details.progress;
                                                          _swipeDirection[
                                                                  item.id] =
                                                              details.direction;
                                                        });
                                                      },
                                                      direction:
                                                          DismissDirection
                                                              .horizontal,
                                                      confirmDismiss:
                                                          (direction) async {
                                                        bool? confirmed = false;
                                                        final currentItemContext =
                                                            listCtx;

                                                        if (direction ==
                                                            DismissDirection
                                                                .startToEnd) {
                                                          if (!mounted) {
                                                            return false;
                                                          }
                                                          // SABİTLEME MANTIĞI
                                                          await stockProvider
                                                              .togglePinStatus(
                                                                  item.id);
                                                          final updatedItem =
                                                              stockProvider
                                                                  .items
                                                                  .firstWhere((i) =>
                                                                      i.id ==
                                                                      item.id);

                                                          // LİSTEYİ YENIDEN SIRALA (WhatsApp mantığı için kritik!)
                                                          if (mounted) {
                                                            setState(() {
                                                              _updateFilteredItems(
                                                                  stockProvider
                                                                      .items);
                                                            });
                                                          }
                                                          if (!mounted) {
                                                            return false;
                                                          }
                                                          if (currentItemContext
                                                              .mounted) {
                                                            _showStyledFlushbar(
                                                                currentItemContext,
                                                                updatedItem
                                                                        .isPinned
                                                                    ? '"${item.name}" sabitlendi.'
                                                                    : '"${item.name}" sabitlemesi kaldırıldı.');
                                                          }
                                                          confirmed =
                                                              false; // Kartın kaybolmasını engelle
                                                        } else if (direction ==
                                                            DismissDirection
                                                                .endToStart) {
                                                          confirmed =
                                                              await _showDeleteConfirmationDialog(
                                                                  currentItemContext,
                                                                  item);
                                                          confirmed ??= false;
                                                        }

                                                        if (confirmed ==
                                                            false) {
                                                          setState(() {
                                                            _swipeProgress
                                                                .remove(
                                                                    item.id);
                                                            _swipeDirection
                                                                .remove(
                                                                    item.id);
                                                          });
                                                        }
                                                        return confirmed;
                                                      },
                                                      onDismissed: (direction) {
                                                        if (direction ==
                                                            DismissDirection
                                                                .endToStart) {
                                                          final originalItem =
                                                              StockItem.fromMap(
                                                                  item.toMap());
                                                          stockProvider
                                                              .deleteItem(
                                                                  item.id,
                                                                  notify: true);
                                                          if (mounted) {
                                                            bool isUndoPressed =
                                                                false;

                                                            final undoButton =
                                                                TextButton(
                                                              onPressed: () {
                                                                if (isUndoPressed) {
                                                                  return;
                                                                }
                                                                isUndoPressed =
                                                                    true;

                                                                stockProvider
                                                                    .addItem(
                                                                  name:
                                                                      originalItem
                                                                          .name,
                                                                  quantity:
                                                                      originalItem
                                                                          .quantity,
                                                                  barcode:
                                                                      originalItem
                                                                          .barcode,
                                                                  qrCode:
                                                                      originalItem
                                                                          .qrCode,
                                                                  shelfLocation:
                                                                      originalItem
                                                                          .shelfLocation,
                                                                  stockCode:
                                                                      originalItem
                                                                          .stockCode,
                                                                  category:
                                                                      originalItem
                                                                          .category,
                                                                  localImagePath:
                                                                      originalItem
                                                                          .localImagePath,
                                                                  alertThreshold:
                                                                      originalItem
                                                                          .alertThreshold,
                                                                  brand:
                                                                      originalItem
                                                                          .brand,
                                                                  supplier:
                                                                      originalItem
                                                                          .supplier,
                                                                  invoiceNumber:
                                                                      originalItem
                                                                          .invoiceNumber,
                                                                  maxStockThreshold:
                                                                      originalItem
                                                                          .maxStockThreshold,
                                                                  warehouseId:
                                                                      originalItem
                                                                          .warehouseId,
                                                                  shopId:
                                                                      originalItem
                                                                          .shopId,
                                                                );

                                                                // Güvenli pop
                                                                if (Navigator
                                                                    .canPop(
                                                                        context)) {
                                                                  Navigator.pop(
                                                                      context);
                                                                }
                                                              },
                                                              child: Text(
                                                                "GERİ AL",
                                                                style: TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            );
                                                            if (!mounted) {
                                                              return;
                                                            }
                                                            _showStyledFlushbar(
                                                              context,
                                                              '"${originalItem.name}" silindi.',
                                                              mainButton:
                                                                  undoButton,
                                                            );
                                                          }
                                                        }
                                                        setState(() {
                                                          _swipeProgress
                                                              .remove(item.id);
                                                          _swipeDirection
                                                              .remove(item.id);
                                                        });
                                                      },
                                                      child: StockItemCard(
                                                        key: ValueKey(
                                                            'stock_card_fg_${item.id}'),
                                                        stockItem: item,
                                                        globalMaxStockThreshold:
                                                            _globalMaxStockThreshold,
                                                        onTap: isTappable
                                                            ? () {
                                                                showStockOptionsDialog(
                                                                    context,
                                                                    item);
                                                              }
                                                            : null,
                                                      ),
                                                    ),
                                                    // RAPTIYE IKONU
                                                    if (item.isPinned)
                                                      Positioned(
                                                        top: 6,
                                                        right: 8,
                                                        child: Transform.rotate(
                                                          angle:
                                                              0.4, // Ikonu hafifçe eğ
                                                          child: Icon(
                                                            Icons.push_pin,
                                                            color: Colors.white
                                                                .withValues(
                                                                    alpha:
                                                                        0.95),
                                                            size: 20,
                                                            shadows: const [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .black54,
                                                                blurRadius: 6.0,
                                                                offset: Offset(
                                                                    1, 1),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                      childCount: itemsToDisplay.length,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),

                          Positioned(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                            left: 0,
                            right: 0,
                            height: _totalBottomClearance +
                                MediaQuery.of(context).viewInsets.bottom,
                            child: IgnorePointer(
                              ignoring: true,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppTheme.appBackgroundColor.withAlpha(0),
                                      AppTheme.appBackgroundColor,
                                    ],
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
          ),
        ),
      ),
    );
  }
}

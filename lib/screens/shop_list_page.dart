// lib/screens/shop_list_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../models/shop_item.dart';
import '../providers/shop_provider.dart';
import './add_edit_shop_page.dart';

class ShopListPage extends StatefulWidget {
  const ShopListPage({super.key});

  @override
  State<ShopListPage> createState() => _ShopListPageState();
}

class _ShopListPageState extends State<ShopListPage> {
  bool _isInitialLoading = true; // İlk yükleme için bayrak

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    // Sayfa ilk açıldığında verileri yükle
    if (mounted) {
      // forceFetch: true ile Provider'daki _hasFetchedOnce kontrolünü atla
      // ve SharedPreferences'tan veriyi çek.
      await Provider.of<ShopProvider>(context, listen: false).fetchAndSetItems(forceFetch: true);
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
        });
      }
    }
  }

  Future<void> _refreshShops() async {
    if (mounted) {
      await Provider.of<ShopProvider>(context, listen: false).fetchAndSetItems(forceFetch: true);
      debugPrint("ShopListPage: RefreshIndicator ile fetchAndSetItems(forceFetch: true) çağrıldı.");
    }
  }

  void _navigateToAddEditShop({String? id}) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (ctx) => AddEditShopPage(existingItemId: id)),
    ).then((_) {
      // Geri dönüldüğünde Provider'ın notifyListeners'ına güveniyoruz.
      // Ekstra fetchAndSetItems ÇAĞIRMIYORUZ.
      debugPrint("ShopListPage: AddEditShopPage'den dönüldü.");
    });
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext ctx, ShopItem item) async {
    final result = await showDialog<bool>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Silme Onayı'),
        content: Text('"${item.name}" adlı dükkanı silmek istediğinizden emin misiniz?'),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: <Widget>[
          TextButton(
            child: const Text('İptal'),
            onPressed: () => Navigator.of(dialogCtx).pop(false),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Evet, Sil'),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
          ),
        ],
      ),
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dükkanlarım')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Consumer<ShopProvider>(
      builder: (consumerCtx, shopProvider, _) {
        final List<ShopItem> shops = List.from(shopProvider.items);
        shops.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        debugPrint("ShopListPage Consumer REBUILD - Dükkan sayısı: ${shops.length}");

        return Scaffold(
          appBar: AppBar(
            title: const Text('Dükkanlarım'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Yeni Dükkan Ekle',
                onPressed: () => _navigateToAddEditShop(),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _refreshShops,
            child: shops.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.storefront_outlined, size: 80, color: Colors.grey),
                          const SizedBox(height: 20),
                          Text(
                            'Henüz hiç dükkan eklenmemiş.',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 25),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text('İlk Dükkanını Ekle'),
                            onPressed: () => _navigateToAddEditShop(),
                          )
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                    itemCount: shops.length,
                    itemBuilder: (listViewCtx, i) {
                      final shop = shops[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                        child: ListTile(
                          leading: shop.localImagePath != null && shop.localImagePath!.isNotEmpty
                              ? SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: kIsWeb
                                        ? Image.network(shop.localImagePath!, fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40))
                                        : Image.file(File(shop.localImagePath!), fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40)),
                                  ),
                                )
                              : const Icon(Icons.store_mall_directory_rounded, size: 40),
                          title: Text(shop.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(shop.address ?? 'Adres belirtilmemiş'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit_outlined, color: Theme.of(context).colorScheme.primary),
                                tooltip: 'Düzenle',
                                onPressed: () => _navigateToAddEditShop(id: shop.id),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                                tooltip: 'Sil',
                                onPressed: () async {
                                  final confirmed = await _showDeleteConfirmationDialog(listViewCtx, shop);
                                  if (confirmed == true && mounted) {
                                    shopProvider.deleteItem(shop.id);
                                  }
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                             _navigateToAddEditShop(id: shop.id);
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
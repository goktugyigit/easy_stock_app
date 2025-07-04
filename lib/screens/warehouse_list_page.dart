// lib/screens/warehouse_list_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../models/warehouse_item.dart';
import '../providers/warehouse_provider.dart';
import './add_edit_warehouse_page.dart';

class WarehouseListPage extends StatefulWidget {
  const WarehouseListPage({super.key});

  @override
  State<WarehouseListPage> createState() => _WarehouseListPageState();
}

class _WarehouseListPageState extends State<WarehouseListPage> {
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    if (mounted) {
      await Provider.of<WarehouseProvider>(context, listen: false).fetchAndSetItems(forceFetch: true);
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
        });
      }
    }
  }

  Future<void> _refreshWarehouses() async {
    if (mounted) {
      await Provider.of<WarehouseProvider>(context, listen: false).fetchAndSetItems(forceFetch: true);
      debugPrint("WarehouseListPage: RefreshIndicator ile fetchAndSetItems(forceFetch: true) çağrıldı.");
    }
  }

  void _navigateToAddEditWarehouse({String? id}) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (ctx) => AddEditWarehousePage(existingItemId: id)),
    ).then((_) {
      debugPrint("WarehouseListPage: AddEditWarehousePage'den dönüldü.");
    });
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext ctx, WarehouseItem item) async {
    final result = await showDialog<bool>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Silme Onayı'),
        content: Text('"${item.name}" adlı depoyu silmek istediğinizden emin misiniz?'),
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
        appBar: AppBar(title: const Text('Depolarım')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Consumer<WarehouseProvider>(
      builder: (consumerCtx, warehouseProvider, _) {
        final List<WarehouseItem> warehouses = List.from(warehouseProvider.items);
        warehouses.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        debugPrint("WarehouseListPage Consumer REBUILD - Depo sayısı: ${warehouses.length}");

        return Scaffold(
          appBar: AppBar(
            title: const Text('Depolarım'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Yeni Depo Ekle',
                onPressed: () => _navigateToAddEditWarehouse(),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _refreshWarehouses,
            child: warehouses.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.warehouse_outlined, size: 80, color: Colors.grey),
                          const SizedBox(height: 20),
                          Text(
                            'Henüz hiç depo eklenmemiş.',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 25),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text('İlk Deponu Ekle'),
                            onPressed: () => _navigateToAddEditWarehouse(),
                          )
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                    itemCount: warehouses.length,
                    itemBuilder: (listViewCtx, i) {
                      final warehouse = warehouses[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                        child: ListTile(
                          leading: warehouse.localImagePath != null && warehouse.localImagePath!.isNotEmpty
                              ? SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: kIsWeb
                                        ? Image.network(warehouse.localImagePath!, fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40))
                                        : Image.file(File(warehouse.localImagePath!), fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40)),
                                  ),
                                )
                              : const Icon(Icons.warehouse_rounded, size: 40),
                          title: Text(warehouse.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(warehouse.address ?? 'Adres belirtilmemiş'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit_outlined, color: Theme.of(context).colorScheme.primary),
                                tooltip: 'Düzenle',
                                onPressed: () => _navigateToAddEditWarehouse(id: warehouse.id),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                                tooltip: 'Sil',
                                onPressed: () async {
                                  final confirmed = await _showDeleteConfirmationDialog(listViewCtx, warehouse);
                                  if (confirmed == true && mounted) {
                                    warehouseProvider.deleteItem(warehouse.id);
                                  }
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                             _navigateToAddEditWarehouse(id: warehouse.id);
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
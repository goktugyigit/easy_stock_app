// lib/screens/add_edit_stock_page.dart
import 'dart:io'; // Image.file için
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show kDebugMode, kIsWeb; // kIsWeb ve kDebugMode için
import 'package:flutter/services.dart'; // FilteringTextInputFormatter için (aslında material.dart'tan geliyor)
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import '../providers/warehouse_provider.dart';
import '../providers/shop_provider.dart';
import '../models/stock_item.dart';
import '../models/warehouse_item.dart';
import '../models/shop_item.dart';
import '../widgets/corporate_header.dart';
import './warehouses_shops_page.dart';
// Eğer barkod/QR tarama butonları aktif edilecekse bu import geri eklenmeli
// import '../widgets/barcode_scanner_page.dart';

enum AssignmentType { none, warehouse, shop }

class AddEditStockPage extends StatefulWidget {
  final String? existingItemId;
  final bool showQuantityField;

  const AddEditStockPage({super.key, this.existingItemId, this.showQuantityField = true});

  @override
  State<AddEditStockPage> createState() => _AddEditStockPageState();
}

class _AddEditStockPageState extends State<AddEditStockPage> {
  final _formKey = GlobalKey<FormState>();
  var _editedStockItem = StockItem(id: '', name: '', quantity: 0);
  var _isInit = true;
  var _isLoading = false;
  XFile? _pickedImageFile;

  // TextEditingController'lar
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _qrCodeController = TextEditingController();
  final _shelfLocationController = TextEditingController();
  final _stockCodeController = TextEditingController();
  final _categoryController = TextEditingController();
  final _brandController = TextEditingController();
  final _supplierController = TextEditingController();
  final _invoiceNumberController = TextEditingController();
  final _alertThresholdController = TextEditingController();
  final _maxStockThresholdController = TextEditingController();

  // Depo/Dükkan seçimi için state'ler
  AssignmentType _assignmentType = AssignmentType.none;
  String? _selectedWarehouseId;
  String? _selectedShopId;

  List<WarehouseItem> _warehouses = [];
  List<ShopItem> _shops = [];
  bool _areWarehousesAndShopsLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWarehousesAndShops();
    });
  }

  Future<void> _loadWarehousesAndShops() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    }); // Genel yükleme göstergesi
    try {
      final warehouseProvider =
          Provider.of<WarehouseProvider>(context, listen: false);
      final shopProvider = Provider.of<ShopProvider>(context, listen: false);

      await warehouseProvider.fetchAndSetItems(forceFetch: true);
      await shopProvider.fetchAndSetItems(forceFetch: true);

      if (mounted) {
        setState(() {
          _warehouses = warehouseProvider.items;
          _shops = shopProvider.items;
          _areWarehousesAndShopsLoaded = true;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("AddEditStockPage: Depo/Dükkan yükleme hatası: $e");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      if (widget.existingItemId != null) {
        final existingItem = Provider.of<StockProvider>(context, listen: false)
            .findById(widget.existingItemId!);
        if (existingItem != null) {
          _editedStockItem = existingItem;
          _nameController.text = _editedStockItem.name;
          _quantityController.text = _editedStockItem.quantity.toString();
          _barcodeController.text = _editedStockItem.barcode ?? '';
          _qrCodeController.text = _editedStockItem.qrCode ?? '';
          _shelfLocationController.text = _editedStockItem.shelfLocation ?? '';
          _stockCodeController.text = _editedStockItem.stockCode ?? '';
          _categoryController.text = _editedStockItem.category ?? '';
          _brandController.text = _editedStockItem.brand ?? '';
          _supplierController.text = _editedStockItem.supplier ?? '';
          _invoiceNumberController.text = _editedStockItem.invoiceNumber ?? '';
          _alertThresholdController.text =
              _editedStockItem.alertThreshold?.toString() ?? '';
          _maxStockThresholdController.text =
              _editedStockItem.maxStockThreshold?.toString() ?? '';

          if (_editedStockItem.localImagePath != null &&
              _editedStockItem.localImagePath!.isNotEmpty) {
            _pickedImageFile = XFile(_editedStockItem.localImagePath!);
          }

          if (_editedStockItem.warehouseId != null) {
            _assignmentType = AssignmentType.warehouse;
            _selectedWarehouseId = _editedStockItem.warehouseId;
          } else if (_editedStockItem.shopId != null) {
            _assignmentType = AssignmentType.shop;
            _selectedShopId = _editedStockItem.shopId;
          }
        }
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _barcodeController.dispose();
    _qrCodeController.dispose();
    _shelfLocationController.dispose();
    _stockCodeController.dispose();
    _categoryController.dispose();
    _brandController.dispose();
    _supplierController.dispose();
    _invoiceNumberController.dispose();
    _alertThresholdController.dispose();
    _maxStockThresholdController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 800,
      );
      if (pickedFile != null) {
        setState(() {
          _pickedImageFile = pickedFile;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Resim seçme hatası: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Resim seçilemedi: ${e.toString()}')),
        );
      }
    }
  }

  // Eğer barkod/QR tarama butonları eklenecekse bu metod ve ilgili import geri getirilmeli
  // Future<void> _scanCode(TextEditingController controllerToUpdate) async { ... }

  Future<void> _doSaveForm() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    if (_warehouses.isEmpty && _shops.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Kaydetmeden önce en az bir depo veya dükkân oluşturun.'),
          ),
        );
      }
      return;
    }
    // _formKey.currentState!.save(); // onSaved kullanmıyorsak gereksiz olabilir
    setState(() {
      _isLoading = true;
    });

    final stockProvider = Provider.of<StockProvider>(context, listen: false);

    final name = _nameController.text;
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final barcode =
        _barcodeController.text.isEmpty ? null : _barcodeController.text;
    final qrCode =
        _qrCodeController.text.isEmpty ? null : _qrCodeController.text;
    final shelfLocation = _shelfLocationController.text.isEmpty
        ? null
        : _shelfLocationController.text;
    final stockCode =
        _stockCodeController.text.isEmpty ? null : _stockCodeController.text;
    final category =
        _categoryController.text.isEmpty ? null : _categoryController.text;
    final brand = _brandController.text.isEmpty ? null : _brandController.text;
    final supplier =
        _supplierController.text.isEmpty ? null : _supplierController.text;
    final invoiceNumber = _invoiceNumberController.text.isEmpty
        ? null
        : _invoiceNumberController.text;
    final alertThreshold = _alertThresholdController.text.isEmpty
        ? null
        : int.tryParse(_alertThresholdController.text);
    final maxStockThreshold = _maxStockThresholdController.text.isEmpty
        ? null
        : int.tryParse(_maxStockThresholdController.text);
    final String? imagePath = _pickedImageFile?.path;

    String? finalWarehouseId;
    String? finalShopId;
    if (_assignmentType == AssignmentType.warehouse) {
      finalWarehouseId = _selectedWarehouseId;
    } else if (_assignmentType == AssignmentType.shop) {
      finalShopId = _selectedShopId;
    }

    try {
      if (widget.existingItemId != null && _editedStockItem.id.isNotEmpty) {
        stockProvider.updateItem(
          id: _editedStockItem.id,
          name: name,
          quantity: quantity,
          localImagePath: imagePath,
          shelfLocation: shelfLocation,
          stockCode: stockCode,
          category: category,
          brand: brand,
          supplier: supplier,
          invoiceNumber: invoiceNumber,
          barcode: barcode,
          qrCode: qrCode,
          alertThreshold: alertThreshold,
          maxStockThreshold: maxStockThreshold,
          warehouseId: finalWarehouseId,
          shopId: finalShopId,
        );
      } else {
        stockProvider.addItem(
          name: name,
          quantity: quantity,
          localImagePath: imagePath,
          shelfLocation: shelfLocation,
          stockCode: stockCode,
          category: category,
          brand: brand,
          supplier: supplier,
          invoiceNumber: invoiceNumber,
          barcode: barcode,
          qrCode: qrCode,
          alertThreshold: alertThreshold,
          maxStockThreshold: maxStockThreshold,
          warehouseId: finalWarehouseId,
          shopId: finalShopId,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Stok kaydetme hatası: $error');
      }
      if (mounted) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Hata Oluştu!'),
            content: Text(
                'Stok kaydedilirken bir sorun oluştu: ${error.toString()}'),
            actions: [
              TextButton(
                  child: const Text('Tamam'),
                  onPressed: () => Navigator.of(ctx).pop())
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildImagePreview() {
    if (_pickedImageFile == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo_outlined, size: 45, color: Colors.grey[700]),
          const SizedBox(height: 8),
          Text('Stok Resmi Seç',
              style: TextStyle(color: Colors.grey[800], fontSize: 13)),
        ],
      );
    }
    if (kIsWeb) {
      return Image.network(_pickedImageFile!.path,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(Icons.broken_image, color: Colors.grey)));
    } else {
      return Image.file(File(_pickedImageFile!.path),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(Icons.broken_image, color: Colors.grey)));
    }
  }

  Widget _buildAssignmentSection() {
    if (!_areWarehousesAndShopsLoaded) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: Center(child: Text('Depo/Dükkan listesi yükleniyor...')),
      );
    }

    if (_warehouses.isEmpty && _shops.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          children: [
            Icon(Icons.info_outline,
                size: 40, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(height: 10),
            const Text(
              'Stok eklemek için lütfen önce bir depo veya dükkân oluşturun.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_business_outlined),
              label: const Text('Depo/Dükkan Yönetimine Git'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (_) => const WarehousesShopsPage(),
                  ),
                );
              },
            )
          ],
        ),
      );
    }

    final List<DropdownMenuItem<String>> dropdownItems = [
      const DropdownMenuItem(value: '', child: Text('Seçim yapma')),
      ..._warehouses
          .map((w) => DropdownMenuItem(value: 'w:${w.id}', child: Text('Depo: ${w.name}')))
          .toList(),
      ..._shops
          .map((s) => DropdownMenuItem(value: 's:${s.id}', child: Text('Dükkan: ${s.name}')))
          .toList(),
    ];

    String? currentValue;
    if (_assignmentType == AssignmentType.warehouse && _selectedWarehouseId != null) {
      currentValue = 'w:${_selectedWarehouseId!}';
    } else if (_assignmentType == AssignmentType.shop && _selectedShopId != null) {
      currentValue = 's:${_selectedShopId!}';
    } else {
      currentValue = '';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Depo/Dükkan (Opsiyonel)',
            border: OutlineInputBorder(),
          ),
          value: currentValue,
          isExpanded: true,
          items: dropdownItems,
          onChanged: (String? value) {
            setState(() {
              if (value == null || value.isEmpty) {
                _assignmentType = AssignmentType.none;
                _selectedWarehouseId = null;
                _selectedShopId = null;
              } else if (value.startsWith('w:')) {
                _assignmentType = AssignmentType.warehouse;
                _selectedWarehouseId = value.substring(2);
                _selectedShopId = null;
              } else if (value.startsWith('s:')) {
                _assignmentType = AssignmentType.shop;
                _selectedWarehouseId = null;
                _selectedShopId = value.substring(2);
              }
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CorporateHeader(
        title: widget.existingItemId == null
            ? (widget.showQuantityField ? 'Yeni Stok Ekle' : 'Stok Kartı Oluştur')
            : 'Stok Düzenle',
        showBackButton: true,
        showSaveButton: true,
        centerTitle: true,
        onSavePressed: _isLoading ? null : _doSaveForm,
      ),
      body: SafeArea(
        child: (_isLoading && !_areWarehousesAndShopsLoaded)
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.fromLTRB(
                  16.0,
                  16.0,
                  16.0,
                  16.0 + MediaQuery.of(context).padding.bottom,
                ),
                child: Form(
                  key: _formKey,
                  child: ListView(
                  children: <Widget>[
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage, // Kullanılıyor
                        child: Container(
                          width: 130,
                          height: 130,
                          margin:
                              const EdgeInsets.only(bottom: 20.0, top: 10.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.grey.shade400, width: 1.5),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.5),
                            child: _buildImagePreview(), // Kullanılıyor
                          ),
                        ),
                      ),
                    ),
                    TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                            labelText: 'Stok Adı (*)',
                            border: OutlineInputBorder()),
                        textInputAction: TextInputAction.next,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Stok adı zorunludur.'
                            : null),
                    const SizedBox(height: 12),
                    if (widget.showQuantityField) ...[
                      TextFormField(
                          controller: _quantityController,
                          decoration: const InputDecoration(
                              labelText: 'Miktar (*)',
                              border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          textInputAction: TextInputAction.next,
                          validator: (v) {
                            if (!widget.showQuantityField) return null;
                            if (v == null || v.isEmpty) {
                              return 'Miktar zorunludur.';
                            }
                            final n = int.tryParse(v);
                            if (n == null || n < 0) {
                              return 'Geçerli pozitif bir miktar girin.';
                            }
                            return null;
                          }),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                        controller: _shelfLocationController,
                        decoration: const InputDecoration(
                            labelText: 'Raf Lokasyonu',
                            border: OutlineInputBorder()),
                        textInputAction: TextInputAction.next),
                    const SizedBox(height: 12),
                    TextFormField(
                        controller: _stockCodeController,
                        decoration: const InputDecoration(
                            labelText: 'Ürün Kodu',
                            border: OutlineInputBorder()),
                        textInputAction: TextInputAction.next),
                    const SizedBox(height: 12),
                    TextFormField(
                        controller: _categoryController,
                        decoration: const InputDecoration(
                            labelText: 'Kategori',
                            border: OutlineInputBorder()),
                        textInputAction: TextInputAction.next),
                    const SizedBox(height: 12),
                    TextFormField(
                        controller: _brandController,
                        decoration: const InputDecoration(
                            labelText: 'Marka', border: OutlineInputBorder()),
                        textInputAction: TextInputAction.next),
                    const SizedBox(height: 12),
                    TextFormField(
                        controller: _supplierController,
                        decoration: const InputDecoration(
                            labelText: 'Tedarikçi',
                            border: OutlineInputBorder()),
                        textInputAction: TextInputAction.next),
                    const SizedBox(height: 12),
                    TextFormField(
                        controller: _invoiceNumberController,
                        decoration: const InputDecoration(
                            labelText: 'Fatura Numarası',
                            border: OutlineInputBorder()),
                        textInputAction: TextInputAction.next),
                    const SizedBox(height: 12),
                    // Barkod/QR tarama için butonlar ve _scanCode metodu gerekirse eklenecek
                    Row(children: [
                      Expanded(
                          child: TextFormField(
                              controller: _barcodeController,
                              decoration: const InputDecoration(
                                  labelText: 'Barkod',
                                  border: OutlineInputBorder()),
                              textInputAction: TextInputAction
                                  .next)), /*const SizedBox(width: 8), IconButton(icon: const Icon(Icons.qr_code_scanner_rounded), onPressed: () => _scanCode(_barcodeController), tooltip: 'Barkod Tara')*/
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                          child: TextFormField(
                              controller: _qrCodeController,
                              decoration: const InputDecoration(
                                  labelText: 'QR Kod',
                                  border: OutlineInputBorder()),
                              textInputAction: TextInputAction
                                  .next)), /*const SizedBox(width: 8), IconButton(icon: const Icon(Icons.qr_code_scanner_rounded), onPressed: () => _scanCode(_qrCodeController), tooltip: 'QR Kod Tara')*/
                    ]),
                    const SizedBox(height: 12),
                    TextFormField(
                        controller: _alertThresholdController,
                        decoration: const InputDecoration(
                            labelText: 'Düşük Stok Alarm Eşiği (Bu ürüne özel)',
                            border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v != null && v.isNotEmpty) {
                            final n = int.tryParse(v);
                            if (n == null || n < 0) {
                              return 'Geçerli pozitif bir sayı girin.';
                            }
                          }
                          return null;
                        }),
                    const SizedBox(height: 12),
                    TextFormField(
                        controller: _maxStockThresholdController,
                        decoration: const InputDecoration(
                            labelText:
                                'Maksimum Stok Eşiği (Bu ürüne özel - Fanus için)',
                            border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) =>
                            _isLoading ? null : _doSaveForm(),
                        validator: (v) {
                          if (v != null && v.isNotEmpty) {
                            final n = int.tryParse(v);
                            if (n == null || n <= 0) {
                              return '0\'dan büyük bir sayı girin.';
                            }
                          }
                          return null;
                        }),

                    _buildAssignmentSection(), // Depo/Dükkan atama bölümü

                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
    );
  }
}

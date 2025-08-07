// lib/screens/add_edit_stock_page.dart - FİNAL VE HATASIZ KOD

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import '../providers/warehouse_provider.dart';
import '../providers/shop_provider.dart';
import '../models/stock_item.dart';
import '../models/warehouse_item.dart';
import '../models/shop_item.dart';
import '../widgets/corporate_header.dart';
import '../utils/app_theme.dart';
import './add_edit_warehouse_page.dart';
import './add_edit_shop_page.dart';
import '../widgets/barcode_scanner_page.dart';

enum AssignmentType { none, warehouse, shop }

class AddEditStockPage extends StatefulWidget {
  final String? existingItemId;
  final bool showQuantityField;

  const AddEditStockPage(
      {super.key, this.existingItemId, this.showQuantityField = true});

  @override
  State<AddEditStockPage> createState() => _AddEditStockPageState();
}

class _AddEditStockPageState extends State<AddEditStockPage> {
  final _formKey = GlobalKey<FormState>();
  var _editedStockItem = StockItem(id: '', name: '', quantity: 0);
  var _isInit = true;
  var _isLoading = false;
  XFile? _pickedImageFile;

  // Controllers
  final _nameController = TextEditingController();
  final _stockCodeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _qrCodeController = TextEditingController();
  final _shelfLocationController = TextEditingController();
  final _categoryController = TextEditingController();
  final _brandController = TextEditingController();
  final _supplierController = TextEditingController();
  final _invoiceNumberController = TextEditingController();
  final _alertThresholdController = TextEditingController();
  final _maxStockThresholdController = TextEditingController();

  AssignmentType _assignmentType = AssignmentType.none;
  String? _selectedWarehouseId;
  String? _selectedShopId;

  List<WarehouseItem> _warehouses = [];
  List<ShopItem> _shops = [];
  bool _areWarehousesAndShopsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadWarehousesAndShops();
  }

  Future<void> _loadWarehousesAndShops() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final warehouseProvider =
          Provider.of<WarehouseProvider>(context, listen: false);
      final shopProvider = Provider.of<ShopProvider>(context, listen: false);

      await Future.wait([
        warehouseProvider.fetchAndSetItems(forceFetch: true),
        shopProvider.fetchAndSetItems(forceFetch: true)
      ]);

      if (mounted) {
        setState(() {
          _warehouses = warehouseProvider.items;
          _shops = shopProvider.items;
          _areWarehousesAndShopsLoaded = true;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("AddEditStockPage: Depo/Dükkan yükleme hatası: $e");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
          _stockCodeController.text = _editedStockItem.stockCode ?? '';
          if (widget.showQuantityField) {
            _quantityController.text = _editedStockItem.quantity.toString();
          }
          _barcodeController.text = _editedStockItem.barcode ?? '';
          _qrCodeController.text = _editedStockItem.qrCode ?? '';
          _shelfLocationController.text = _editedStockItem.shelfLocation ?? '';
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
      } else {
        if (widget.showQuantityField) _quantityController.text = '0';
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _stockCodeController.dispose();
    _quantityController.dispose();
    _barcodeController.dispose();
    _qrCodeController.dispose();
    _shelfLocationController.dispose();
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
          source: ImageSource.gallery, imageQuality: 70, maxWidth: 800);
      if (pickedFile != null) {
        setState(() => _pickedImageFile = pickedFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Resim seçilemedi: $e')));
      }
    }
  }

  Future<void> _scanCode(TextEditingController controller) async {
    FocusScope.of(context).unfocus();
    final result =
        await Navigator.of(context, rootNavigator: true).push<String>(
      MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
    );
    if (result != null && mounted) {
      setState(() {
        controller.text = result;
      });
    }
  }

  Future<void> _doSaveForm() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    if (_warehouses.isEmpty && _shops.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Kaydetmeden önce en az bir depo veya dükkân oluşturmalısınız.')));
      }
      return;
    }

    setState(() => _isLoading = true);

    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    final name = _nameController.text;
    final quantity = widget.showQuantityField
        ? (int.tryParse(_quantityController.text) ?? 0)
        : 0;
    final imagePath = _pickedImageFile?.path;
    final finalWarehouseId = _assignmentType == AssignmentType.warehouse
        ? _selectedWarehouseId
        : null;
    final finalShopId =
        _assignmentType == AssignmentType.shop ? _selectedShopId : null;

    try {
      if (widget.existingItemId != null) {
        stockProvider.updateItem(
          id: _editedStockItem.id,
          name: name,
          quantity: quantity,
          localImagePath: imagePath,
          shelfLocation: _shelfLocationController.text,
          stockCode: _stockCodeController.text,
          category: _categoryController.text,
          brand: _brandController.text,
          supplier: _supplierController.text,
          invoiceNumber: _invoiceNumberController.text,
          barcode: _barcodeController.text,
          qrCode: _qrCodeController.text,
          alertThreshold: int.tryParse(_alertThresholdController.text),
          maxStockThreshold: int.tryParse(_maxStockThresholdController.text),
          warehouseId: finalWarehouseId,
          shopId: finalShopId,
        );
      } else {
        stockProvider.addItem(
          name: name,
          quantity: quantity,
          localImagePath: imagePath,
          shelfLocation: _shelfLocationController.text,
          stockCode: _stockCodeController.text,
          category: _categoryController.text,
          brand: _brandController.text,
          supplier: _supplierController.text,
          invoiceNumber: _invoiceNumberController.text,
          barcode: _barcodeController.text,
          qrCode: _qrCodeController.text,
          alertThreshold: int.tryParse(_alertThresholdController.text),
          maxStockThreshold: int.tryParse(_maxStockThresholdController.text),
          warehouseId: finalWarehouseId,
          shopId: finalShopId,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Hata Oluştu!'),
            content: Text('Stok kaydedilirken bir sorun oluştu: $error'),
            actions: [
              TextButton(
                  child: const Text('Tamam'),
                  onPressed: () => Navigator.of(ctx).pop())
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {IconData? icon,
      TextInputType? keyboardType,
      List<TextInputFormatter>? inputFormatters,
      String? Function(String?)? validator,
      Widget? suffixIcon}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey[400]) : null,
        suffixIcon: suffixIcon,
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildEmptyStateCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 20.0),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline, size: 40, color: AppTheme.primaryColor),
          const SizedBox(height: 12),
          const Text(
            'Stok ekleyebilmek için önce bir depo veya dükkan oluşturmalısınız.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          _buildAddLocationButtons(),
        ],
      ),
    );
  }

  // DÜZELTME: Butonların eşit genişlikte ve her zaman yan yana olması için güncellendi.
  Widget _buildAddLocationButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_business_outlined, size: 18),
            label: const Text('Depo Ekle'),
            onPressed: () => Navigator.of(context, rootNavigator: true)
                .push(
                  MaterialPageRoute(
                      builder: (_) => const AddEditWarehousePage()),
                )
                .then((_) => _loadWarehousesAndShops()),
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12)),
          ),
        ),
        const SizedBox(width: 12), // Butonlar arası boşluk
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_shopping_cart, size: 18),
            label: const Text('Dükkan Ekle'),
            onPressed: () => Navigator.of(context, rootNavigator: true)
                .push(
                  MaterialPageRoute(builder: (_) => const AddEditShopPage()),
                )
                .then((_) => _loadWarehousesAndShops()),
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.appBackgroundColor,
      appBar: CorporateHeader(
        title: widget.existingItemId == null
            ? (widget.showQuantityField
                ? 'Yeni Stok Ekle'
                : 'Stok Kartı Oluştur')
            : 'Stok Düzenle',
        showBackButton: true,
        showSaveButton: true,
        centerTitle: true,
        onSavePressed: _isLoading ? null : _doSaveForm,
      ),
      body: SafeArea(
        child: (_isLoading && !_areWarehousesAndShopsLoaded)
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    16.0,
                    16.0,
                    16.0,
                    16.0 +
                        MediaQuery.of(context).padding.bottom +
                        MediaQuery.of(context).viewInsets.bottom,
                  ),
                  children: <Widget>[
                    Column(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(65),
                              border: Border.all(
                                  color: Colors.grey.shade700, width: 2),
                            ),
                            child: ClipOval(
                              child: _pickedImageFile == null
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_a_photo_outlined,
                                            size: 45, color: Colors.grey[400]),
                                        const SizedBox(height: 8),
                                        Text('Resim Seç',
                                            style: TextStyle(
                                                color: Colors.grey[400],
                                                fontSize: 13)),
                                      ],
                                    )
                                  : (kIsWeb
                                      ? Image.network(_pickedImageFile!.path,
                                          fit: BoxFit.cover)
                                      : Image.file(File(_pickedImageFile!.path),
                                          fit: BoxFit.cover)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: Text(_pickedImageFile == null
                                  ? 'Resim Ekle'
                                  : 'Değiştir'),
                              onPressed: _pickImage,
                            ),
                            if (_pickedImageFile != null) ...[
                              const SizedBox(width: 8),
                              TextButton.icon(
                                icon: const Icon(Icons.delete_outline,
                                    size: 16, color: Colors.redAccent),
                                label: const Text('Kaldır',
                                    style: TextStyle(color: Colors.redAccent)),
                                onPressed: () =>
                                    setState(() => _pickedImageFile = null),
                              ),
                            ]
                          ],
                        )
                      ],
                    ),
                    _buildSectionHeader('Temel Bilgiler'),
                    _buildTextField('Stok Adı (*)', _nameController,
                        icon: Icons.label_important_outline,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Stok adı zorunludur.'
                            : null),
                    const SizedBox(height: 12),
                    _buildTextField('Stok Kodu', _stockCodeController,
                        icon: Icons.qr_code_2),
                    if (widget.showQuantityField) ...[
                      const SizedBox(height: 12),
                      _buildTextField('Miktar (*)', _quantityController,
                          icon: Icons.format_list_numbered,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ], validator: (v) {
                        if (v == null || v.isEmpty) return 'Miktar zorunludur.';
                        if ((int.tryParse(v) ?? -1) < 0) {
                          return 'Geçerli bir miktar girin.';
                        }
                        return null;
                      }),
                    ],
                    _buildSectionHeader('Konum'),
                    if (_warehouses.isEmpty && _shops.isEmpty)
                      _buildEmptyStateCard()
                    else
                      Column(
                        children: [
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                                labelText: 'Depo/Dükkan',
                                prefixIcon: Icon(Icons.place_outlined,
                                    color: Colors.grey[400])),
                            value: _assignmentType == AssignmentType.warehouse
                                ? 'w:${_selectedWarehouseId ?? ''}'
                                : _assignmentType == AssignmentType.shop
                                    ? 's:${_selectedShopId ?? ''}'
                                    : '',
                            items: [
                              const DropdownMenuItem(
                                  value: '', child: Text('Atanmamış')),
                              ..._warehouses.map((w) => DropdownMenuItem(
                                  value: 'w:${w.id}',
                                  child: Text('Depo: ${w.name}'))),
                              ..._shops.map((s) => DropdownMenuItem(
                                  value: 's:${s.id}',
                                  child: Text('Dükkan: ${s.name}'))),
                            ],
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
                          const SizedBox(height: 16),
                          _buildAddLocationButtons(),
                        ],
                      ),
                    const SizedBox(height: 12),
                    _buildTextField('Raf Lokasyonu', _shelfLocationController,
                        icon: Icons.shelves),
                    _buildSectionHeader('Detaylar'),
                    _buildTextField('Kategori', _categoryController,
                        icon: Icons.category_outlined),
                    const SizedBox(height: 12),
                    _buildTextField('Marka', _brandController,
                        icon: Icons.star_border_outlined),
                    const SizedBox(height: 12),
                    _buildTextField('Tedarikçi', _supplierController,
                        icon: Icons.business_center_outlined),
                    const SizedBox(height: 12),
                    _buildTextField('Fatura Numarası', _invoiceNumberController,
                        icon: Icons.receipt_long_outlined),
                    _buildSectionHeader('Kodlar'),
                    _buildTextField('Barkod', _barcodeController,
                        icon: Icons.barcode_reader,
                        suffixIcon: IconButton(
                          icon: Icon(Icons.camera_alt_outlined,
                              color: AppTheme.primaryColor),
                          onPressed: () => _scanCode(_barcodeController),
                          tooltip: 'Barkod Tara',
                        )),
                    const SizedBox(height: 12),
                    _buildTextField('QR Kod', _qrCodeController,
                        icon: Icons.qr_code_scanner,
                        suffixIcon: IconButton(
                          icon: Icon(Icons.camera_alt_outlined,
                              color: AppTheme.primaryColor),
                          onPressed: () => _scanCode(_qrCodeController),
                          tooltip: 'QR Kod Tara',
                        )),
                    _buildSectionHeader('Stok Eşikleri (Opsiyonel)'),
                    _buildTextField(
                        'Düşük Stok Alarmı', _alertThresholdController,
                        icon: Icons.warning_amber_rounded,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ]),
                    const SizedBox(height: 12),
                    _buildTextField('Maksimum Stok (Fanus için)',
                        _maxStockThresholdController,
                        icon: Icons.opacity_rounded,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ]),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
      ),
    );
  }
}

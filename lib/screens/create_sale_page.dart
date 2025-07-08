// lib/screens/create_sale_page.dart
import 'package:flutter/material.dart';
// debugPrint için
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/stock_item.dart';
import '../providers/stock_provider.dart'; // Stok miktarını düşürmek için
import '../providers/sale_provider.dart'; // Satışı kaydetmek için

class CreateSalePage extends StatefulWidget {
  final StockItem stockItem;

  const CreateSalePage({super.key, required this.stockItem});

  @override
  State<CreateSalePage> createState() => _CreateSalePageState();
}

class _CreateSalePageState extends State<CreateSalePage> {
  final _customerNameController = TextEditingController();
  final _quantityController =
      TextEditingController(text: '1'); // Varsayılan miktar 1
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = 1;
    // TextField'a manuel giriş yapıldığında _quantity'yi güncelle
    _quantityController.addListener(() {
      final parsedQuantity = int.tryParse(_quantityController.text);
      if (parsedQuantity != null && parsedQuantity != _quantity) {
        setState(() {
          _quantity = parsedQuantity;
        });
      }
    });
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _updateQuantity(int change) {
    setState(() {
      int newQuantity = _quantity + change;
      // Miktar 1'den az ve stoğun mevcut miktarından fazla olamaz
      if (newQuantity >= 1 && newQuantity <= widget.stockItem.quantity) {
        _quantity = newQuantity;
        _quantityController.text = _quantity.toString();
      } else if (newQuantity < 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Miktar 1'den az olamaz."),
              backgroundColor: Colors.orange),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Stokta yeterli ürün yok! Maksimum: ${widget.stockItem.quantity}"),
              backgroundColor: Colors.redAccent),
        );
      }
    });
  }

  Widget _buildQuantityButton(String label, int value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onPressed: () => _updateQuantity(value),
        child: Text(label),
      ),
    );
  }

  void _completeSale() {
    if (_quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Lütfen geçerli bir miktar girin."),
            backgroundColor: Colors.orange),
      );
      return;
    }

    if (_quantity > widget.stockItem.quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Stokta yeterli ürün yok! Maksimum: ${widget.stockItem.quantity}"),
            backgroundColor: Colors.redAccent),
      );
      return;
    }

    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    final saleProvider = Provider.of<SaleProvider>(context, listen: false);

    // 1. SaleProvider'a yeni satışı ekle
    saleProvider.addSale(
      soldStockItem: widget.stockItem,
      quantitySold: _quantity,
      customerName: _customerNameController.text.isEmpty
          ? null
          : _customerNameController.text,
    );

    // 2. StockProvider'daki ilgili stoğun miktarını düşür
    // (updateItem metodu tüm alanları gerektiriyor, bu yüzden mevcut item'ı kopyalayıp miktarını değiştiriyoruz)
    stockProvider.updateItem(
      id: widget.stockItem.id,
      name: widget.stockItem.name,
      quantity: widget.stockItem.quantity - _quantity, // Miktarı düşür
      localImagePath: widget.stockItem.localImagePath,
      shelfLocation: widget.stockItem.shelfLocation,
      stockCode: widget.stockItem.stockCode,
      category: widget.stockItem.category,
      brand: widget.stockItem.brand,
      supplier: widget.stockItem.supplier,
      invoiceNumber: widget.stockItem.invoiceNumber,
      barcode: widget.stockItem.barcode,
      qrCode: widget.stockItem.qrCode,
      alertThreshold: widget.stockItem.alertThreshold,
      maxStockThreshold: widget.stockItem.maxStockThreshold,
      warehouseId: widget.stockItem.warehouseId,
      shopId: widget.stockItem.shopId,
    );

    // 3. Kullanıcıya başarı mesajı göster ve sayfayı kapat
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Satış başarıyla kaydedildi!"),
          backgroundColor: Colors.green),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.shopping_cart_checkout_rounded, size: 28),
            const SizedBox(width: 8),
            Expanded(child: Text('${widget.stockItem.name} - Satış Oluştur')),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue.shade50,
                        child: const Icon(Icons.inventory_2_outlined, color: Colors.blue, size: 28),
                        radius: 28,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.stockItem.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('Stokta: ${widget.stockItem.quantity}', style: TextStyle(color: Colors.grey[700])),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Müşteri ismi autocomplete
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      // Burada örnek müşteri isimleri kullanılabilir, gerçek uygulamada müşteri listesi çekilebilir
                      final customers = ['Ali Yılmaz', 'Ayşe Demir', 'Mehmet Kaya', 'Zeynep Çelik'];
                      return customers.where((c) => c.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                    },
                    fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Müşteri İsmi (Opsiyonel)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      );
                    },
                    onSelected: (String selection) {
                      _customerNameController.text = selection;
                    },
                  ),
                  const SizedBox(height: 24),
                  Text('Satış Miktarı', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildQuantityButton('-5', -5, color: Colors.red.shade800),
                      _buildQuantityButton('-1', -1, color: Colors.red.shade400),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 80,
                        child: TextFormField(
                          controller: _quantityController,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: (value) {
                            int newQuantity = int.tryParse(value) ?? 0;
                            if (newQuantity >= 1 && newQuantity <= widget.stockItem.quantity) {
                              _quantity = newQuantity;
                            } else if (newQuantity < 1) {
                              _quantity = 1;
                              _quantityController.text = '1';
                            } else {
                              _quantity = widget.stockItem.quantity;
                              _quantityController.text = _quantity.toString();
                            }
                            setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildQuantityButton('+1', 1, color: Colors.green.shade400),
                      _buildQuantityButton('+5', 5, color: Colors.green.shade800),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildQuantityButton('-2', -2),
                      _buildQuantityButton('+2', 2),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Satış özeti
                  Card(
                    color: Colors.grey.shade50,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Satış Özeti', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text('Ürün: ${widget.stockItem.name}'),
                          Text('Miktar: $_quantity'),
                          if (_customerNameController.text.isNotEmpty) Text('Müşteri: ${_customerNameController.text}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.shopping_cart_checkout_rounded),
                    label: Text('$_quantity Adet Satışı Tamamla'),
                    onPressed: _completeSale,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

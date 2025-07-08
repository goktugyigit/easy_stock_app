// lib/screens/create_sale_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/stock_item.dart';
import '../providers/stock_provider.dart';
import '../providers/sale_provider.dart';

class CreateSalePage extends StatefulWidget {
  final StockItem stockItem;

  const CreateSalePage({super.key, required this.stockItem});

  @override
  State<CreateSalePage> createState() => _CreateSalePageState();
}

class _CreateSalePageState extends State<CreateSalePage>
    with TickerProviderStateMixin {
  // Controllers
  final _customerNameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _scrollController = ScrollController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  final _unitPriceController = TextEditingController(text: '0');
  final _discountController = TextEditingController(text: '0');
  final _paidAmountController = TextEditingController(text: '0');

  // State variables
  int _quantity = 1;
  double _unitPrice = 0.0;
  double _discountAmount = 0.0;
  double _discountPercent = 0.0;
  double _taxRate = 18.0; // KDV %18 varsayılan
  double _paidAmount = 0.0;
  bool _isLoading = false;
  bool _showCustomerSelection = false;
  bool _isDiscountPercent = true; // true: %, false: TL

  // Selections
  String _selectedCurrency = 'TRY';
  String _selectedPaymentMethod = 'Nakit';
  String _selectedDocumentType = 'Fatura';
  String _selectedTaxType = 'KDV';
  String _selectedPaymentStatus = 'Ödendi'; // Yeni eklendi

  // Date controllers
  final _checkDateController = TextEditingController();
  final _promiseDateController = TextEditingController();

  // Animation
  late TabController _tabController;

  // Static data
  final List<String> _currencies = ['TRY', 'USD', 'EUR', 'GBP'];
  final List<String> _paymentMethods = [
    'Nakit',
    'Kredi Kartı',
    'Banka Kartı',
    'Havale/EFT',
    'Çek',
    'Senet'
  ];
  final List<String> _documentTypes = ['Fatura', 'İrsaliye', 'Fış'];
  final List<String> _taxTypes = ['KDV', 'ÖTV', 'Vergisiz'];
  final List<String> _paymentStatuses = ['Ödendi', 'Ödenmedi']; // Yeni eklendi
  final Map<String, double> _taxRates = {
    'KDV': 18.0,
    'ÖTV': 25.0,
    'Vergisiz': 0.0,
  };

  final List<Map<String, String>> _customers = [
    {
      'name': 'Ali Yılmaz',
      'phone': '0532 123 4567',
      'address': 'Atatürk Mah. No:15 Kadıköy/İstanbul',
      'taxNumber': '1234567890'
    },
    {
      'name': 'Ayşe Demir',
      'phone': '0533 234 5678',
      'address': 'Çamlıca Sok. No:8 Üsküdar/İstanbul',
      'taxNumber': '0987654321'
    },
    {
      'name': 'ABC Ltd. Şti.',
      'phone': '0212 555 0123',
      'address': 'Levent Mah. Büyükdere Cad. No:100 Şişli/İstanbul',
      'taxNumber': '5555555555'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _quantityController.addListener(_onQuantityChanged);
    _unitPriceController.addListener(_calculateTotal);
    _discountController.addListener(_calculateTotal);
    _paidAmountController.addListener(_onPaidAmountChanged);

    // Varsayılan birim fiyat (gerçek uygulamada ürün modelinden gelir)
    _unitPrice = 10.0;
    _unitPriceController.text = _unitPrice.toString();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _quantityController.dispose();
    _scrollController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    _unitPriceController.dispose();
    _discountController.dispose();
    _paidAmountController.dispose();
    _checkDateController.dispose();
    _promiseDateController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onQuantityChanged() {
    final parsedQuantity = int.tryParse(_quantityController.text);
    if (parsedQuantity != null && parsedQuantity != _quantity && mounted) {
      setState(() {
        _quantity = parsedQuantity;
      });
      _calculateTotal();
    }
  }

  void _onPaidAmountChanged() {
    final parsedAmount = double.tryParse(_paidAmountController.text);
    if (parsedAmount != null && parsedAmount != _paidAmount && mounted) {
      setState(() {
        _paidAmount = parsedAmount;
      });
    }
  }

  void _calculateTotal() {
    if (!mounted) return;

    final price = double.tryParse(_unitPriceController.text) ?? 0.0;
    final discount = double.tryParse(_discountController.text) ?? 0.0;

    setState(() {
      _unitPrice = price;
      if (_isDiscountPercent) {
        _discountPercent = discount;
        _discountAmount = (_unitPrice * _quantity * discount) / 100;
      } else {
        _discountAmount = discount;
        _discountPercent = _unitPrice * _quantity > 0
            ? (discount * 100) / (_unitPrice * _quantity)
            : 0;
      }
    });
  }

  double get _subtotal => _unitPrice * _quantity;
  double get _totalAfterDiscount => _subtotal - _discountAmount;
  double get _taxAmount => (_totalAfterDiscount * _taxRate) / 100;
  double get _grandTotal => _totalAfterDiscount + _taxAmount;
  double get _remainingAmount => _grandTotal - _paidAmount;

  void _updateQuantity(int change) {
    if (!mounted) return;

    setState(() {
      int newQuantity = _quantity + change;
      if (newQuantity >= 1 && newQuantity <= widget.stockItem.quantity) {
        _quantity = newQuantity;
        _quantityController.text = _quantity.toString();
        _calculateTotal();
      } else if (newQuantity < 1) {
        HapticFeedback.lightImpact();
        _showMessage("Miktar 1'den az olamaz!", Colors.orange);
      } else {
        HapticFeedback.lightImpact();
        _showMessage(
            "Stokta yeterli ürün yok! Maksimum: ${widget.stockItem.quantity}",
            Colors.red);
      }
    });
  }

  void _showMessage(String message, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _selectCustomer(Map<String, String> customer) {
    if (!mounted) return;

    setState(() {
      _customerNameController.text = customer['name']!;
      _phoneController.text = customer['phone']!;
      _addressController.text = customer['address']!;
      _showCustomerSelection = false;
    });
  }

  Future<void> _completeSale() async {
    if (_isLoading || !mounted) return;

    // Validasyon kontrolleri
    if (_quantity <= 0) {
      _showMessage("Lütfen geçerli bir miktar girin!", Colors.orange);
      return;
    }

    if (_quantity > widget.stockItem.quantity) {
      _showMessage(
          "Stokta yeterli ürün yok! Maksimum: ${widget.stockItem.quantity}",
          Colors.red);
      return;
    }

    if (_unitPrice <= 0) {
      _showMessage("Lütfen geçerli bir birim fiyat girin!", Colors.orange);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final stockProvider = Provider.of<StockProvider>(context, listen: false);
      final saleProvider = Provider.of<SaleProvider>(context, listen: false);

      // Satış verilerini hazırla
      final saleData = {
        'product': widget.stockItem.name,
        'quantity': _quantity,
        'unitPrice': _unitPrice,
        'currency': _selectedCurrency,
        'discount': _discountAmount,
        'taxType': _selectedTaxType,
        'taxRate': _taxRate,
        'taxAmount': _taxAmount,
        'subtotal': _subtotal,
        'total': _grandTotal,
        'paidAmount': _paidAmount,
        'remainingAmount': _remainingAmount,
        'paymentMethod': _selectedPaymentMethod,
        'documentType': _selectedDocumentType,
        'customer': _customerNameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'note': _noteController.text,
        'date': DateTime.now().toIso8601String(),
      };

      // Satışı kaydet
      saleProvider.addSale(
        soldStockItem: widget.stockItem,
        quantitySold: _quantity,
        customerName: _customerNameController.text.isEmpty
            ? null
            : _customerNameController.text,
      );

      // Stok miktarını güncelle
      stockProvider.updateItem(
        id: widget.stockItem.id,
        name: widget.stockItem.name,
        quantity: widget.stockItem.quantity - _quantity,
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

      if (!mounted) return;

      HapticFeedback.selectionClick();

      // Başarı mesajı ve seçenekler
      _showSaleCompletedDialog(saleData);
    } catch (e) {
      if (mounted) {
        _showMessage("Satış kaydedilirken bir hata oluştu!", Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSaleCompletedDialog(Map<String, dynamic> saleData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Satış Tamamlandı! 🎉',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Toplam: ${_grandTotal.toStringAsFixed(2)} $_selectedCurrency',
              style: const TextStyle(
                  color: Colors.green,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            if (_remainingAmount > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Kalan Borç: ${_remainingAmount.toStringAsFixed(2)} $_selectedCurrency',
                style: const TextStyle(color: Colors.orange, fontSize: 14),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Kapat', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _generateDocument();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text('$_selectedDocumentType Oluştur'),
          ),
        ],
      ),
    );
  }

  void _generateDocument() {
    _showMessage("$_selectedDocumentType oluşturuluyor...", Colors.blue);
    // Burada fatura/irsaliye oluşturma işlemi yapılır
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }

  Future<void> _selectDate(
      TextEditingController controller, String title) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Color(0xFF2D2D2D),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        controller.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Widget _buildCircularButton(String text, int value, Color color) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _updateQuantity(value);
      },
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Müşteri seçimi
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (mounted) {
                      setState(() {
                        _showCustomerSelection = !_showCustomerSelection;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.person_add, color: Colors.blue, size: 30),
                        SizedBox(height: 8),
                        Text(
                          'Yeni Müşteri',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Manuel giriş',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (mounted) {
                      setState(() {
                        _showCustomerSelection = true;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.green.withValues(alpha: 0.3)),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.people, color: Colors.green, size: 30),
                        SizedBox(height: 8),
                        Text(
                          'Mevcut Müşteri',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Listeden seç',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Müşteri listesi
          if (_showCustomerSelection) ...[
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: _customers.map((customer) {
                  return GestureDetector(
                    onTap: () => _selectCustomer(customer),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue.withValues(alpha: 0.2),
                            child: Text(
                              customer['name']![0].toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  customer['name']!,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  customer['phone']!,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 12),
                                ),
                                if (customer['taxNumber'] != null)
                                  Text(
                                    'VKN: ${customer['taxNumber']}',
                                    style: const TextStyle(
                                        color: Colors.white60, fontSize: 11),
                                  ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios,
                              color: Colors.white38, size: 16),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Müşteri bilgileri form
          _buildTextInput(
              'Müşteri/Firma Adı', _customerNameController, Icons.business),
          const SizedBox(height: 12),
          _buildTextInput('Telefon', _phoneController, Icons.phone,
              keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          _buildTextInput('Adres', _addressController, Icons.location_on,
              maxLines: 2),
        ],
      ),
    );
  }

  Widget _buildProductTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Ürün bilgisi
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.inventory_2, color: Colors.blue, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'ÜRÜN BİLGİLERİ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.stockItem.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildInfoChip('Mevcut Stok',
                        '${widget.stockItem.quantity}', Colors.blue),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                        'Satış Sonrası',
                        '${widget.stockItem.quantity - _quantity}',
                        Colors.green),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Miktar kontrolü
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'SATIŞ MİKTARI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCircularButton('-10', -10, Colors.red[800]!),
                      const SizedBox(width: 8),
                      _buildCircularButton('-5', -5, Colors.red[600]!),
                      const SizedBox(width: 8),
                      _buildCircularButton('-1', -1, Colors.red[400]!),
                      const SizedBox(width: 12),
                      Container(
                        width: 80,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                        child: TextFormField(
                          controller: _quantityController,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildCircularButton('+1', 1, Colors.green[400]!),
                      const SizedBox(width: 8),
                      _buildCircularButton('+5', 5, Colors.green[600]!),
                      const SizedBox(width: 8),
                      _buildCircularButton('+10', 10, Colors.green[800]!),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Fiyat bilgileri
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.attach_money, color: Colors.green, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'FİYAT BİLGİLERİ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTextInput('Birim Fiyat',
                          _unitPriceController, Icons.price_change,
                          keyboardType: TextInputType.number),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdown(
                          'Para Birimi', _selectedCurrency, _currencies,
                          (value) {
                        setState(() => _selectedCurrency = value!);
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTextInput(
                          'İndirim', _discountController, Icons.discount,
                          keyboardType: TextInputType.number),
                    ),
                    const SizedBox(width: 8),
                    ToggleButtons(
                      isSelected: [_isDiscountPercent, !_isDiscountPercent],
                      onPressed: (index) {
                        setState(() {
                          _isDiscountPercent = index == 0;
                          _calculateTotal();
                        });
                      },
                      children: const [
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('%')),
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('TL')),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                          'Vergi Türü', _selectedTaxType, _taxTypes, (value) {
                        setState(() {
                          _selectedTaxType = value!;
                          _taxRate = _taxRates[value] ?? 0.0;
                          _calculateTotal();
                        });
                      }),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '%${_taxRate.toStringAsFixed(0)}',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Tutar özeti
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.receipt_long, color: Colors.orange, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'TUTAR ÖZETİ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSummaryRow('Ara Toplam',
                    '${_subtotal.toStringAsFixed(2)} $_selectedCurrency'),
                if (_discountAmount > 0)
                  _buildSummaryRow('İndirim',
                      '-${_discountAmount.toStringAsFixed(2)} $_selectedCurrency',
                      color: Colors.red),
                _buildSummaryRow('Vergi ($_selectedTaxType)',
                    '${_taxAmount.toStringAsFixed(2)} $_selectedCurrency'),
                const Divider(color: Colors.white24),
                _buildSummaryRow('GENEL TOPLAM',
                    '${_grandTotal.toStringAsFixed(2)} $_selectedCurrency',
                    isTotal: true, color: Colors.green),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Ödeme durumu seçimi
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.payment, color: Colors.blue, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'ÖDEME DURUMU',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (mounted) {
                            setState(() {
                              _selectedPaymentStatus = 'Ödendi';
                              // Ödendi seçildiğinde ödenen tutarı otomatik doldur
                              _paidAmount = _grandTotal;
                              _paidAmountController.text =
                                  _grandTotal.toStringAsFixed(2);
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _selectedPaymentStatus == 'Ödendi'
                                ? Colors.green.withValues(alpha: 0.2)
                                : Colors.grey[700],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedPaymentStatus == 'Ödendi'
                                  ? Colors.green
                                  : Colors.grey[600]!,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: _selectedPaymentStatus == 'Ödendi'
                                    ? Colors.green
                                    : Colors.grey[400],
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'ÖDENDİ',
                                style: TextStyle(
                                  color: _selectedPaymentStatus == 'Ödendi'
                                      ? Colors.green
                                      : Colors.grey[400],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (mounted) {
                            setState(() {
                              _selectedPaymentStatus = 'Ödenmedi';
                              // Ödenmedi seçildiğinde ödenen tutarı sıfırla
                              _paidAmount = 0.0;
                              _paidAmountController.text = '0';
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _selectedPaymentStatus == 'Ödenmedi'
                                ? Colors.red.withValues(alpha: 0.2)
                                : Colors.grey[700],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedPaymentStatus == 'Ödenmedi'
                                  ? Colors.red
                                  : Colors.grey[600]!,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.schedule,
                                color: _selectedPaymentStatus == 'Ödenmedi'
                                    ? Colors.red
                                    : Colors.grey[400],
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'ÖDENMEDİ',
                                style: TextStyle(
                                  color: _selectedPaymentStatus == 'Ödenmedi'
                                      ? Colors.red
                                      : Colors.grey[400],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Ödeme bilgileri - duruma göre dinamik
          if (_selectedPaymentStatus == 'Ödendi') ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.credit_card, color: Colors.green, size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'ÖDEME BİLGİLERİ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                      'Ödeme Yöntemi', _selectedPaymentMethod, _paymentMethods,
                      (value) {
                    setState(() => _selectedPaymentMethod = value!);
                  }),
                  const SizedBox(height: 12),
                  _buildTextInput(
                      'Ödenen Tutar', _paidAmountController, Icons.money,
                      keyboardType: TextInputType.number),

                  // Çek seçildiyse tarih alanı göster
                  if (_selectedPaymentMethod == 'Çek') ...[
                    const SizedBox(height: 12),
                    _buildDateInput(
                        'Çek Tarihi', _checkDateController, Icons.date_range),
                  ],

                  const SizedBox(height: 12),
                  if (_paidAmount > _grandTotal) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.green.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Para Üstü: ${(_paidAmount - _grandTotal).toStringAsFixed(2)} $_selectedCurrency',
                            style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ] else if (_paidAmount < _grandTotal && _paidAmount > 0) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Eksik Ödeme: ${(_grandTotal - _paidAmount).toStringAsFixed(2)} $_selectedCurrency',
                            style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ] else ...[
            // Ödenmedi durumu
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule_send, color: Colors.red, size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'ÖDEME TAAHHÜDÜ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Ödenecek Tutar: ${_grandTotal.toStringAsFixed(2)} $_selectedCurrency',
                            style: const TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDateInput(
                      'Vade Tarihi', _promiseDateController, Icons.event),
                  const SizedBox(height: 8),
                  const Text(
                    'Müşterinin ödeme yapacağı tarih',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Belge türü
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.description, color: Colors.purple, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'BELGE TİPİ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                    'Belge Türü', _selectedDocumentType, _documentTypes,
                    (value) {
                  setState(() => _selectedDocumentType = value!);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.note_alt, color: Colors.teal, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'SATIŞ NOTLARI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText:
                        'Satış ile ilgili notlarınızı buraya yazın...\n\nÖrnek:\n- Müşteri özel talebi\n- Teslimat bilgileri\n- Garanti koşulları',
                    hintStyle:
                        TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[600]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: Colors.teal, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[900],
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Özet bilgi
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Text(
                  'SATIŞ ÖZETİ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.stockItem.name} × $_quantity',
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  'Toplam: ${_grandTotal.toStringAsFixed(2)} $_selectedCurrency',
                  style: const TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
                if (_customerNameController.text.isNotEmpty)
                  Text(
                    'Müşteri: ${_customerNameController.text}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInput(
      String label, TextEditingController controller, IconData icon,
      {TextInputType? keyboardType, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              color: Colors.white70, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white54),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[600]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[900],
          ),
        ),
      ],
    );
  }

  Widget _buildDateInput(
      String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              color: Colors.white70, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => _selectDate(controller, label),
          child: AbsorbPointer(
            child: TextFormField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: Colors.white54),
                suffixIcon: const Icon(Icons.calendar_today,
                    color: Colors.white54, size: 20),
                hintText: 'Tarih seçin...',
                hintStyle: const TextStyle(color: Colors.white38),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[900],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>(
      String label, T value, List<T> items, ValueChanged<T?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              color: Colors.white70, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<T>(
          value: value,
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(item.toString(),
                        style: const TextStyle(color: Colors.white)),
                  ))
              .toList(),
          onChanged: onChanged,
          dropdownColor: Colors.grey[800],
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[600]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[900],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(color: color, fontSize: 12),
          ),
          Text(
            value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isTotal = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? Colors.white : Colors.white70,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color ?? (isTotal ? Colors.white : Colors.white70),
              fontWeight: FontWeight.bold,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Icon(
              Icons.point_of_sale,
              color: Colors.blue,
              size: 28,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Müşteri'),
            Tab(icon: Icon(Icons.inventory_2), text: 'Ürün'),
            Tab(icon: Icon(Icons.payment), text: 'Ödeme'),
            Tab(icon: Icon(Icons.note_alt), text: 'Notlar'),
          ],
          indicatorColor: Colors.blue,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCustomerTab(),
                _buildProductTab(),
                _buildPaymentTab(),
                _buildNotesTab(),
              ],
            ),
          ),
          // Sabit footer buton
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border(
                top: BorderSide(color: Colors.grey[800]!, width: 1),
              ),
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _completeSale,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          'Satışı Tamamla (${_grandTotal.toStringAsFixed(2)} $_selectedCurrency)',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

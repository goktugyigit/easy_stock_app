// lib/screens/add_edit_customer_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:another_flushbar/flushbar.dart';
import '../models/customer.dart';
import '../providers/customer_provider.dart';
import '../widgets/corporate_header.dart';

class AddEditCustomerPage extends StatefulWidget {
  final Customer? customer; // null ise yeni ekleme, değilse düzenleme

  const AddEditCustomerPage({super.key, this.customer});

  @override
  State<AddEditCustomerPage> createState() => _AddEditCustomerPageState();
}

class _AddEditCustomerPageState extends State<AddEditCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _customerNumberController = TextEditingController();
  final _supplierNumberController = TextEditingController();
  final _taxNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  // Başlangıç Borcu ve Alacağı için ayrı controller'lar
  final _initialDebtController = TextEditingController();
  final _initialCreditController = TextEditingController();
  final _notesController = TextEditingController();

  CustomerType _selectedType = CustomerType.customer;
  bool _isLoading = false;

  bool get _isEditing => widget.customer != null;

  void _showStyledFlushbar(BuildContext context, String message,
      {bool isError = false}) {
    Flushbar(
      messageText: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? Colors.red : Colors.green,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      flushbarPosition: FlushbarPosition.BOTTOM,
      forwardAnimationCurve: Curves.elasticOut,
      reverseAnimationCurve: Curves.fastOutSlowIn,
      backgroundColor: Colors.grey[900]!,
      borderRadius: BorderRadius.circular(12.0),
      margin: const EdgeInsets.only(
        bottom: 1.0,
        left: 20,
        right: 20,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          offset: const Offset(0, 2),
          blurRadius: 10,
        ),
      ],
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 400),
      isDismissible: true,
    ).show(context);
  }

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      final customer = widget.customer!;
      _nameController.text = customer.name;
      _customerNumberController.text = customer.customerNumber ?? '';
      _supplierNumberController.text = customer.supplierNumber ?? '';
      _taxNumberController.text = customer.taxNumber ?? '';
      _phoneController.text = customer.phone ?? '';
      _emailController.text = customer.email ?? '';
      _addressController.text = customer.address ?? '';
      // Varolan bakiyeyi borç/alacak alanlarına dağıt
      if (customer.balance < 0) {
        _initialDebtController.text = customer.balance.abs().toString();
        _initialCreditController.text = '0';
      } else {
        _initialDebtController.text = '0';
        _initialCreditController.text = customer.balance.toString();
      }
      _selectedType = customer.type;
    } else {
      _initialDebtController.text = '0';
      _initialCreditController.text = '0';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _customerNumberController.dispose();
    _supplierNumberController.dispose();
    _taxNumberController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _initialDebtController.dispose();
    _initialCreditController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<CustomerProvider>(context, listen: false);

      if (_isEditing) {
        await provider.updateCustomer(
          id: widget.customer!.id,
          name: _nameController.text.trim(),
          customerNumber: _customerNumberController.text.trim().isEmpty
              ? null
              : _customerNumberController.text.trim(),
          supplierNumber: _supplierNumberController.text.trim().isEmpty
              ? null
              : _supplierNumberController.text.trim(),
          taxNumber: _taxNumberController.text.trim().isEmpty
              ? null
              : _taxNumberController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          address: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          type: _selectedType,
          initialDebt: double.tryParse(_initialDebtController.text) ?? 0.0,
          initialCredit: double.tryParse(_initialCreditController.text) ?? 0.0,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
      } else {
        await provider.addCustomer(
          name: _nameController.text.trim(),
          customerNumber: _customerNumberController.text.trim().isEmpty
              ? null
              : _customerNumberController.text.trim(),
          supplierNumber: _supplierNumberController.text.trim().isEmpty
              ? null
              : _supplierNumberController.text.trim(),
          taxNumber: _taxNumberController.text.trim().isEmpty
              ? null
              : _taxNumberController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          address: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          type: _selectedType,
          initialDebt: double.tryParse(_initialDebtController.text) ?? 0.0,
          initialCredit: double.tryParse(_initialCreditController.text) ?? 0.0,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
        Future.delayed(Duration(milliseconds: 100), () {
          _showStyledFlushbar(
            context,
            _isEditing
                ? 'Cari başarıyla güncellendi'
                : 'Cari başarıyla eklendi',
          );
        });
      }
    } catch (error) {
      if (mounted) {
        _showStyledFlushbar(
          context,
          'Hata: $error',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Artık balance hesaplaması model içinde yapılacak

  Widget _buildTextInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.white54),
            prefixIcon: Icon(icon, color: Colors.blue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[600]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[900],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cari Türü',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () =>
                    setState(() => _selectedType = CustomerType.customer),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _selectedType == CustomerType.customer
                        ? Colors.blue.withValues(alpha: 0.2)
                        : Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedType == CustomerType.customer
                          ? Colors.blue
                          : Colors.grey[600]!,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.person,
                        color: _selectedType == CustomerType.customer
                            ? Colors.blue
                            : Colors.grey[400],
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'MÜŞTERİ',
                        style: TextStyle(
                          color: _selectedType == CustomerType.customer
                              ? Colors.blue
                              : Colors.grey[400],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () =>
                    setState(() => _selectedType = CustomerType.supplier),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _selectedType == CustomerType.supplier
                        ? Colors.orange.withValues(alpha: 0.2)
                        : Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedType == CustomerType.supplier
                          ? Colors.orange
                          : Colors.grey[600]!,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.business,
                        color: _selectedType == CustomerType.supplier
                            ? Colors.orange
                            : Colors.grey[400],
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'TEDARİKÇİ',
                        style: TextStyle(
                          color: _selectedType == CustomerType.supplier
                              ? Colors.orange
                              : Colors.grey[400],
                          fontWeight: FontWeight.bold,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CorporateHeader(
        title: _isEditing ? 'Cari Düzenle' : 'Yeni Cari Ekle',
        showBackButton: true,
        showSaveButton: true,
        centerTitle: true,
        onSavePressed: _isLoading ? null : _saveCustomer,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Cari Türü
                _buildTypeSelector(),
                const SizedBox(height: 24),

                // Ad/Firma Adı
                _buildTextInput(
                  label: 'Ad/Soyad veya Firma Adı *',
                  controller: _nameController,
                  icon: Icons.person,
                  hintText: 'Örn: Ali Yılmaz veya ABC Ltd. Şti.',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Bu alan zorunludur';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Müşteri/Tedarikçi Numarası (dinamik olarak görünür)
                if (_selectedType == CustomerType.customer)
                  _buildTextInput(
                    label: 'Müşteri Numarası',
                    controller: _customerNumberController,
                    icon: Icons.numbers,
                    keyboardType: TextInputType.number,
                    hintText: 'Boş bırakılırsa otomatik oluşturulur',
                  ),
                if (_selectedType == CustomerType.supplier)
                  _buildTextInput(
                    label: 'Tedarikçi Numarası',
                    controller: _supplierNumberController,
                    icon: Icons.numbers,
                    keyboardType: TextInputType.number,
                    hintText: 'Boş bırakılırsa otomatik oluşturulur',
                  ),
                const SizedBox(height: 20),

                // Vergi Numarası
                _buildTextInput(
                  label: 'Vergi Numarası',
                  controller: _taxNumberController,
                  icon: Icons.business_center,
                  keyboardType: TextInputType.number,
                  hintText: 'Vergi veya T.C. kimlik numarası',
                  validator: null,
                ),
                const SizedBox(height: 20),

                // Telefon
                _buildTextInput(
                  label: 'Telefon',
                  controller: _phoneController,
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  hintText: 'Örn: 0532 123 4567',
                ),
                const SizedBox(height: 20),

                // E-posta
                _buildTextInput(
                  label: 'E-posta',
                  controller: _emailController,
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  hintText: 'Örn: ornek@email.com',
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value.trim())) {
                        return 'Geçerli bir e-posta adresi girin';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Adres
                _buildTextInput(
                  label: 'Adres',
                  controller: _addressController,
                  icon: Icons.location_on,
                  maxLines: 3,
                  hintText: 'Tam adres bilgisi',
                ),
                const SizedBox(height: 20),

                // Başlangıç Borcu
                _buildTextInput(
                  label: 'Başlangıç Borcu (₺)',
                  controller: _initialDebtController,
                  icon: Icons.trending_down,
                  keyboardType: TextInputType.number,
                  hintText: '0',
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      if (double.tryParse(value.trim()) == null) {
                        return 'Geçerli bir sayı girin';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Başlangıç Alacağı
                _buildTextInput(
                  label: 'Başlangıç Alacağı (₺)',
                  controller: _initialCreditController,
                  icon: Icons.trending_up,
                  keyboardType: TextInputType.number,
                  hintText: '0',
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      if (double.tryParse(value.trim()) == null) {
                        return 'Geçerli bir sayı girin';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Notlar
                _buildTextInput(
                  label: 'Notlar',
                  controller: _notesController,
                  icon: Icons.note,
                  maxLines: 3,
                  hintText: 'Cari ile ilgili notlar',
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

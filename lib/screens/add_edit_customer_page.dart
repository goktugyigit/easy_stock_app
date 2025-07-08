// lib/screens/add_edit_customer_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/customer.dart';
import '../providers/customer_provider.dart';

class AddEditCustomerPage extends StatefulWidget {
  final Customer? customer; // null ise yeni ekleme, değilse düzenleme

  const AddEditCustomerPage({super.key, this.customer});

  @override
  State<AddEditCustomerPage> createState() => _AddEditCustomerPageState();
}

class _AddEditCustomerPageState extends State<AddEditCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _taxNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _balanceController = TextEditingController();
  final _notesController = TextEditingController();

  CustomerType _selectedType = CustomerType.customer;
  bool _isLoading = false;

  bool get _isEditing => widget.customer != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      final customer = widget.customer!;
      _nameController.text = customer.name;
      _taxNumberController.text = customer.taxNumber ?? '';
      _phoneController.text = customer.phone ?? '';
      _emailController.text = customer.email ?? '';
      _addressController.text = customer.address ?? '';
      _balanceController.text = customer.balance.toString();
      _notesController.text = customer.notes ?? '';
      _selectedType = customer.type;
    } else {
      _balanceController.text = '0';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taxNumberController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _balanceController.dispose();
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
          balance: double.tryParse(_balanceController.text) ?? 0.0,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
      } else {
        await provider.addCustomer(
          name: _nameController.text.trim(),
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
          balance: double.tryParse(_balanceController.text) ?? 0.0,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'Cari başarıyla güncellendi'
                : 'Cari başarıyla eklendi'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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
      appBar: AppBar(
        title: Text(_isEditing ? 'Cari Düzenle' : 'Yeni Cari Ekle'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            )
          else
            IconButton(
              onPressed: _saveCustomer,
              icon: const Icon(Icons.check),
            ),
        ],
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

                // Vergi Numarası
                _buildTextInput(
                  label: 'Vergi Numarası',
                  controller: _taxNumberController,
                  icon: Icons.business_center,
                  keyboardType: TextInputType.number,
                  hintText: '10 haneli vergi numarası',
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      if (value.trim().length != 10) {
                        return 'Vergi numarası 10 haneli olmalıdır';
                      }
                    }
                    return null;
                  },
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

                // Başlangıç Bakiyesi
                _buildTextInput(
                  label: 'Başlangıç Bakiyesi (₺)',
                  controller: _balanceController,
                  icon: Icons.account_balance_wallet,
                  keyboardType: TextInputType.number,
                  hintText: 'Pozitif: Alacak, Negatif: Borç',
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

                // Kaydet Butonu
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveCustomer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _isEditing ? 'Güncelle' : 'Kaydet',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

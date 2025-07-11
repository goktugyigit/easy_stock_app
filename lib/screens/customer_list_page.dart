// lib/screens/customer_list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:another_flushbar/flushbar.dart';
import '../models/customer.dart';
import '../providers/customer_provider.dart';
import '../widgets/customer_card.dart';
import './add_edit_customer_page.dart';
import './customer_detail_page.dart';

enum CustomerFilterType {
  customers,
  suppliers,
}

class CustomerListPage extends StatefulWidget {
  final CustomerFilterType initialFilter;
  final String? title;

  const CustomerListPage({
    super.key,
    this.initialFilter = CustomerFilterType.customers,
    this.title,
  });

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final TextEditingController _searchController = TextEditingController();
  CustomerFilterType _filterType = CustomerFilterType.customers;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _filterType = widget.initialFilter;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCustomers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      await Provider.of<CustomerProvider>(context, listen: false)
          .fetchAndSetCustomers(forceFetch: true);
    } catch (error) {
      if (mounted) {
        _showStyledFlushbar(
          context,
          'Cariler yüklenirken hata: $error',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteCustomer(Customer customer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Cari Sil', style: TextStyle(color: Colors.white)),
        content: Text(
          '${customer.name} adlı cariyi silmek istediğinizden emin misiniz?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('İptal', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await Provider.of<CustomerProvider>(context, listen: false)
            .deleteCustomer(customer.id);

        if (mounted) {
          _showStyledFlushbar(
            context,
            'Cari başarıyla silindi',
          );
        }
      } catch (error) {
        if (mounted) {
          _showStyledFlushbar(
            context,
            'Silme hatası: $error',
            isError: true,
          );
        }
      }
    }
  }

  List<Customer> _getFilteredCustomers(CustomerProvider provider) {
    CustomerType? filterType;

    switch (_filterType) {
      case CustomerFilterType.customers:
        filterType = CustomerType.customer;
        break;
      case CustomerFilterType.suppliers:
        filterType = CustomerType.supplier;
        break;
    }

    return provider.searchCustomers(
      _searchController.text,
      filterType: filterType,
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterChip('Müşteriler', CustomerFilterType.customers),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                _buildFilterChip('Tedarikçiler', CustomerFilterType.suppliers),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, CustomerFilterType type) {
    final isSelected = _filterType == type;
    IconData icon =
        type == CustomerFilterType.customers ? Icons.person : Icons.business;

    // Müşteriler için mavi, tedarikçiler için turuncu renk
    Color activeColor = type == CustomerFilterType.customers
        ? Colors.blue
        : Colors.orange.shade400;

    return GestureDetector(
      onTap: () => setState(() => _filterType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.2)
              : Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey[600]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : Colors.white70,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Cari ara (ad, vergi no, telefon)...',
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: const Icon(Icons.search, color: Colors.white54),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white54),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[600]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[900],
        ),
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  Widget _buildStatistics(CustomerProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Visibility(
            visible: _filterType != CustomerFilterType.suppliers,
            child: Expanded(
              child: _buildStatItem(
                'Toplam Müşteri',
                provider.totalCustomers.toString(),
                Icons.people,
                Colors.blue,
              ),
            ),
          ),
          Visibility(
            visible: _filterType != CustomerFilterType.customers,
            child: Expanded(
              child: _buildStatItem(
                'Toplam Tedarikçi',
                provider.totalSuppliers.toString(),
                Icons.business,
                Colors.orange.shade400,
              ),
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Borç',
              '${provider.totalPayables > 0 ? '-' : ''}${provider.totalPayables.toStringAsFixed(0)} ₺',
              Icons.account_balance_wallet,
              _filterType == CustomerFilterType.suppliers
                  ? Colors.orange.shade400
                  : Colors.blue,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Alacak',
              '${provider.totalReceivables > 0 ? '+' : ''}${provider.totalReceivables.toStringAsFixed(0)} ₺',
              Icons.account_balance_wallet,
              _filterType == CustomerFilterType.suppliers
                  ? Colors.orange.shade400
                  : Colors.blue,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Bakiye',
              '${(provider.totalReceivables - provider.totalPayables).toStringAsFixed(0)} ₺',
              Icons.account_balance_wallet,
              Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  void _showStyledFlushbar(BuildContext context, String message,
      {Widget? mainButton, bool isError = false}) {
    Flushbar(
      messageText: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.info_outline,
            color: isError ? Colors.red : Colors.blue,
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
      mainButton: mainButton,
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
      duration: const Duration(seconds: 4),
      animationDuration: const Duration(milliseconds: 400),
      isDismissible: true,
    ).show(context);
  }

  Widget _buildStatItem(
      String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title ?? 'Cari Listesi'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (_) => const AddEditCustomerPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCustomers,
          ),
        ],
      ),
      body: Consumer<CustomerProvider>(
        builder: (context, provider, child) {
          if (_isLoading || provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }

          final customers = _getFilteredCustomers(provider);

          return Column(
            children: [
              _buildSearchBar(),
              _buildFilterChips(),
              _buildStatistics(provider),
              Expanded(
                child: customers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 80,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'Henüz cari eklenmemiş'
                                  : 'Arama kriterlerine uygun cari bulunamadı',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true).push(
                                  MaterialPageRoute(
                                    builder: (_) => const AddEditCustomerPage(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('İlk Cariyi Ekle'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: customers.length,
                        itemBuilder: (context, index) {
                          final customer = customers[index];
                          return CustomerCard(
                            customer: customer,
                            onTap: () {
                              Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      CustomerDetailPage(customer: customer),
                                ),
                              );
                            },
                            onEdit: () {
                              Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AddEditCustomerPage(customer: customer),
                                ),
                              );
                            },
                            onDelete: () => _deleteCustomer(customer),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

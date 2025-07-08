// lib/screens/customer_list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/customer.dart';
import '../providers/customer_provider.dart';
import '../widgets/customer_card.dart';
import './add_edit_customer_page.dart';
import './customer_detail_page.dart';

enum CustomerFilterType {
  all,
  customers,
  suppliers,
}

class CustomerListPage extends StatefulWidget {
  final CustomerFilterType initialFilter;
  final String? title;

  const CustomerListPage({
    super.key,
    this.initialFilter = CustomerFilterType.all,
    this.title,
  });

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final TextEditingController _searchController = TextEditingController();
  CustomerFilterType _filterType = CustomerFilterType.all;
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cariler yüklenirken hata: $error'),
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cari başarıyla silindi'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Silme hatası: $error'),
              backgroundColor: Colors.red,
            ),
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
      case CustomerFilterType.all:
        filterType = null;
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
          _buildFilterChip('Tümü', CustomerFilterType.all),
          const SizedBox(width: 8),
          _buildFilterChip('Müşteriler', CustomerFilterType.customers),
          const SizedBox(width: 8),
          _buildFilterChip('Tedarikçiler', CustomerFilterType.suppliers),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, CustomerFilterType type) {
    final isSelected = _filterType == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _filterType = type);
        }
      },
      selectedColor: Colors.blue.withValues(alpha: 0.3),
      checkmarkColor: Colors.blue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.blue : Colors.white70,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.grey[800],
      side: BorderSide(
        color: isSelected ? Colors.blue : Colors.grey[600]!,
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
          Expanded(
            child: _buildStatItem(
              'Toplam Müşteri',
              provider.totalCustomers.toString(),
              Icons.people,
              Colors.blue,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Toplam Tedarikçi',
              provider.totalSuppliers.toString(),
              Icons.business,
              Colors.green,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Alacak',
              '+${provider.totalReceivables.toStringAsFixed(0)} ₺',
              Icons.trending_up,
              Colors.green,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Borç',
              '-${provider.totalPayables.toStringAsFixed(0)} ₺',
              Icons.trending_down,
              Colors.red,
            ),
          ),
        ],
      ),
    );
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

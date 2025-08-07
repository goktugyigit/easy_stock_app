// lib/screens/customer_detail_page.dart
import 'package:flutter/material.dart';
import '../models/customer.dart';
import './add_edit_customer_page.dart';
import './customer_statement_page.dart';
import 'package:another_flushbar/flushbar.dart';

class CustomerDetailPage extends StatelessWidget {
  final Customer customer;

  const CustomerDetailPage({super.key, required this.customer});

  Widget _buildInfoCard(String title, Widget content) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

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
        bottom: 20.0,
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

  Widget _buildInfoRow(String label, String? value, IconData icon) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
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
      appBar: AppBar(
        title: Text(customer.name),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result =
                  await Navigator.of(context, rootNavigator: true).push<String>(
                MaterialPageRoute(
                  builder: (_) => AddEditCustomerPage(customer: customer),
                ),
              );
              if (result != null && result.isNotEmpty && context.mounted) {
                _showStyledFlushbar(context, result);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (_) => CustomerStatementPage(customer: customer),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Cari Özeti
            _buildInfoCard(
              'CARİ ÖZETİ',
              Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: customer.isCustomer
                              ? Colors.blue.withValues(alpha: 0.2)
                              : Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          customer.isCustomer ? Icons.person : Icons.business,
                          color:
                              customer.isCustomer ? Colors.blue : Colors.orange,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.typeDisplay,
                              style: TextStyle(
                                color: customer.isCustomer
                                    ? Colors.blue
                                    : Colors.orange,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              customer.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Borç, Alacak, Bakiye Gösterimi
                  Row(
                    children: [
                      // Borç
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.blue.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'BORÇ',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${customer.debtAmount.toStringAsFixed(2)} ₺',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Alacak
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.blue.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'ALACAK',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${customer.creditAmount.toStringAsFixed(2)} ₺',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Bakiye
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.red.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'BAKİYE',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${customer.balanceDisplay} ₺',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // İletişim Bilgileri
            _buildInfoCard(
              'İLETİŞİM BİLGİLERİ',
              Column(
                children: [
                  _buildInfoRow('Telefon', customer.phone, Icons.phone),
                  _buildInfoRow('E-posta', customer.email, Icons.email),
                  _buildInfoRow('Adres', customer.address, Icons.location_on),
                ],
              ),
            ),

            // Vergi Bilgileri
            if (customer.taxNumber != null)
              _buildInfoCard(
                'VERGİ BİLGİLERİ',
                _buildInfoRow('Vergi Numarası', customer.taxNumber,
                    Icons.business_center),
              ),

            // Notlar
            if (customer.notes != null)
              _buildInfoCard(
                'NOTLAR',
                Text(
                  customer.notes!,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),

            // Tarih Bilgileri
            _buildInfoCard(
              'TARİH BİLGİLERİ',
              Column(
                children: [
                  _buildInfoRow(
                      'Oluşturulma Tarihi',
                      '${customer.createdDate.day.toString().padLeft(2, '0')}/${customer.createdDate.month.toString().padLeft(2, '0')}/${customer.createdDate.year}',
                      Icons.calendar_today),
                  if (customer.lastTransactionDate != null)
                    _buildInfoRow(
                        'Son İşlem Tarihi',
                        '${customer.lastTransactionDate!.day.toString().padLeft(2, '0')}/${customer.lastTransactionDate!.month.toString().padLeft(2, '0')}/${customer.lastTransactionDate!.year}',
                        Icons.history),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Hızlı İşlemler
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const Text(
                    'HIZLI İŞLEMLER',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    AddEditCustomerPage(customer: customer),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Düzenle'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    CustomerStatementPage(customer: customer),
                              ),
                            );
                          },
                          icon: const Icon(Icons.receipt_long),
                          label: const Text('Ekstre'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

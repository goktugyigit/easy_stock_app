// lib/widgets/customer_card.dart
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../models/customer.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CustomerCard({
    super.key,
    required this.customer,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  static const double cardRadius = 16.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cardRadius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[900]?.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(cardRadius),
              border: Border.all(
                color: customer.hasDebt
                    ? Colors.red.withValues(alpha: 0.5)
                    : customer.hasCredit
                        ? Colors.green.withValues(alpha: 0.5)
                        : Colors.grey.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(cardRadius),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        children: [
                          // Customer Type Icon
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: customer.isCustomer
                                  ? Colors.blue.withValues(alpha: 0.2)
                                  : Colors.orange.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              customer.isCustomer
                                  ? Icons.person
                                  : Icons.business,
                              color: customer.isCustomer
                                  ? Colors.blue
                                  : Colors.orange,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Name and Type
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  customer.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  customer.typeDisplay,
                                  style: TextStyle(
                                    color: customer.isCustomer
                                        ? Colors.blue
                                        : Colors.orange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Balance
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: customer.hasDebt
                                  ? Colors.red.withValues(alpha: 0.2)
                                  : customer.hasCredit
                                      ? Colors.green.withValues(alpha: 0.2)
                                      : Colors.grey.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${customer.balanceDisplay} ₺',
                              style: TextStyle(
                                color: customer.hasDebt
                                    ? Colors.red
                                    : customer.hasCredit
                                        ? Colors.green
                                        : Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Contact Info
                      if (customer.phone != null || customer.email != null) ...[
                        Row(
                          children: [
                            if (customer.phone != null) ...[
                              Icon(Icons.phone,
                                  color: Colors.white54, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                customer.phone!,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              ),
                              if (customer.email != null) ...[
                                const SizedBox(width: 16),
                                Icon(Icons.email,
                                    color: Colors.white54, size: 16),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    customer.email!,
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ] else if (customer.email != null) ...[
                              Icon(Icons.email,
                                  color: Colors.white54, size: 16),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  customer.email!,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Address
                      if (customer.address != null) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.location_on,
                                color: Colors.white54, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                customer.address!,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Action Buttons
                      Row(
                        children: [
                          // Tax Number
                          if (customer.taxNumber != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'VKN: ${customer.taxNumber}',
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],

                          const Spacer(),

                          // Action Buttons
                          if (onEdit != null)
                            IconButton(
                              onPressed: onEdit,
                              icon: const Icon(Icons.edit,
                                  color: Colors.blue, size: 20),
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(
                                  minWidth: 32, minHeight: 32),
                            ),
                          if (onDelete != null)
                            IconButton(
                              onPressed: onDelete,
                              icon: const Icon(Icons.delete,
                                  color: Colors.red, size: 20),
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(
                                  minWidth: 32, minHeight: 32),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

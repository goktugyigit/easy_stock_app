// lib/utils/flushbar_helper.dart
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'app_theme.dart';

class FlushbarHelper {
  // Basit navbar yükseklik hesaplaması
  static double _calculateBottomMargin(BuildContext context) {
    final double bottomSafeArea = MediaQuery.of(context).padding.bottom;
    // Standard Flushbar pozisyonu - navbar'ın üstünde
    return bottomSafeArea + 100.0; // Standart gap
  }

  /// Başarı mesajı gösterir
  static void showSuccessFlushbar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    showOptimizedFlushbar(
      context,
      message,
      duration: duration,
      type: FlushbarType.success,
    );
  }

  /// Hata mesajı gösterir
  static void showErrorFlushbar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    showOptimizedFlushbar(
      context,
      message,
      duration: duration,
      type: FlushbarType.error,
    );
  }

  /// Standard Flushbar - basit ve güvenilir
  static void showOptimizedFlushbar(
    BuildContext context,
    String message, {
    Widget? actionButton,
    Duration duration = const Duration(seconds: 4),
    FlushbarType type = FlushbarType.info,
  }) {
    // Icon ve renk seçimi
    IconData icon;
    Color iconColor;

    switch (type) {
      case FlushbarType.success:
        icon = Icons.check_circle_outline;
        iconColor = Colors.green;
        break;
      case FlushbarType.error:
        icon = Icons.error_outline;
        iconColor = Colors.red;
        break;
      case FlushbarType.warning:
        icon = Icons.warning_outlined;
        iconColor = Colors.orange;
        break;
      case FlushbarType.info:
        icon = Icons.info_outline;
        iconColor = AppTheme.primaryColor;
        break;
    }

    Flushbar(
      messageText: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      mainButton: actionButton,
      flushbarPosition: FlushbarPosition.BOTTOM,

      // Standard animasyonlar
      forwardAnimationCurve: Curves.elasticOut,
      reverseAnimationCurve: Curves.fastOutSlowIn,
      animationDuration: const Duration(milliseconds: 400),

      // Basit tasarım
      backgroundColor: Colors.white,
      borderRadius: BorderRadius.circular(12.0),
      margin: EdgeInsets.only(
        bottom: _calculateBottomMargin(context),
        left: 20.0,
        right: 20.0,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),

      // Standard gölge
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          offset: const Offset(0, 2),
          blurRadius: 10,
        ),
      ],

      // Standard davranış
      duration: duration,
      isDismissible: true,
      blockBackgroundInteraction: false,
    ).show(context);
  }
}

enum FlushbarType {
  info,
  success,
  error,
  warning,
}

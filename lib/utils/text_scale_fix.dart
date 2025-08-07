// lib/utils/text_scale_fix.dart

import 'package:flutter/material.dart';

// Bu widget, içine aldığı `child` widget'ının sistemin yazı tipi
// boyutu ayarlarından etkilenmemesini sağlar.
class UnscaledTextWrapper extends StatelessWidget {
  final Widget child;

  const UnscaledTextWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Mevcut MediaQuery verilerini alıyoruz.
    final mediaQueryData = MediaQuery.of(context);

    // Yeni bir MediaQuery widget'ı oluşturup, textScaler'ı 1.0'a sabitliyoruz.
    // Bu, yazı tipi boyutunun asla değişmemesini sağlar.
    return MediaQuery(
      data: mediaQueryData.copyWith(
        textScaler: const TextScaler.linear(1.0),
      ),
      child: child,
    );
  }
}

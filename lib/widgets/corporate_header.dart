// lib/widgets/corporate_header.dart - ULTRA PROFESYONEL TASARIM

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../utils/app_theme.dart';

extension ColorValues on Color {
  Color withValues({double? alpha}) {
    if (alpha != null) {
      return withAlpha((alpha * 255).round().clamp(0, 255));
    }
    return this;
  }
}

class CorporateHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showSearchBar;
  final bool showActionButtons;
  final TextEditingController? searchController;
  final FocusNode? searchFocusNode;
  final VoidCallback? onQRScan;
  final VoidCallback? onBarcodeScan;
  final VoidCallback? onFilterTap;
  final VoidCallback? onSearchCancel;
  final bool isSearchFocused;
  final String searchHint;
  final List<Widget>? additionalActions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool showSaveButton;
  final VoidCallback? onSavePressed;
  final bool showAddButton;
  final VoidCallback? onAddPressed;
  final bool centerTitle;

  const CorporateHeader({
    super.key,
    required this.title,
    this.showSearchBar = false,
    this.showActionButtons = false,
    this.searchController,
    this.searchFocusNode,
    this.onQRScan,
    this.onBarcodeScan,
    this.onFilterTap,
    this.onSearchCancel,
    this.isSearchFocused = false,
    this.searchHint = 'Ara...',
    this.additionalActions,
    this.showBackButton = false,
    this.onBackPressed,
    this.showSaveButton = false,
    this.onSavePressed,
    this.showAddButton = false,
    this.onAddPressed,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.appBackgroundColor,
        border: Border(
          bottom:
              BorderSide(color: Colors.grey.withValues(alpha: 0.2), width: 0.5),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: showSearchBar
              ? _buildSearchWithActionsSection(context)
              : _buildRegularHeader(context),
        ),
      ),
    );
  }

  Widget _buildSearchWithActionsSection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Bu önemli - minimum boyut kullan
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Sayfa başlığı
        SizedBox(
          height: 40,
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: AppTheme.primaryTextColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (showActionButtons) ...[
          const SizedBox(height: 6), // 8'den 6'ya düşürüldü
          _buildActionButtons(context),
          const SizedBox(height: 10), // 12'den 10'a düşürüldü
        ],
        SizedBox(
          height: 44,
          child: Row(
            children: [
              Expanded(
                child: CupertinoSearchTextField(
                  controller: searchController,
                  focusNode: searchFocusNode,
                  placeholder: searchHint,
                  style: TextStyle(color: AppTheme.primaryTextColor),
                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  onSuffixTap: () {
                    searchController?.clear();
                  },
                ),
              ),
              if (isSearchFocused) ...[
                const SizedBox(width: 8),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: onSearchCancel,
                  child: const Text(
                    'Vazgeç',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRegularHeader(BuildContext context) {
    return SizedBox(
      height: 56, // Standart AppBar yüksekliği
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showBackButton)
            CupertinoButton(
              padding: const EdgeInsets.only(right: 16),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
            )
          else if (additionalActions == null &&
              (showSaveButton || showAddButton))
            const SizedBox(width: 48),
          Expanded(
            child: Text(
              title,
              textAlign: centerTitle ? TextAlign.center : TextAlign.start,
              style: TextStyle(
                color: AppTheme.primaryTextColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (showSaveButton)
            CupertinoButton(
              padding: const EdgeInsets.only(left: 16),
              onPressed: onSavePressed,
              child: const Icon(Icons.check_rounded, size: 28),
            )
          else if (showAddButton)
            CupertinoButton(
              padding: const EdgeInsets.only(left: 16),
              onPressed: onAddPressed,
              child: const Icon(Icons.add_rounded, size: 28),
            )
          else if (additionalActions != null)
            Row(mainAxisSize: MainAxisSize.min, children: additionalActions!)
          else if (showBackButton)
            const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildCompactActionButton(
          icon: Icons.qr_code_scanner_rounded,
          label: 'QR Tara',
          onTap: onQRScan,
          color: AppTheme.primaryColor,
        ),
        _buildCompactActionButton(
          icon: CupertinoIcons.barcode_viewfinder,
          label: 'Barkod',
          onTap: onBarcodeScan,
          color: AppTheme.accentColor,
        ),
        _buildCompactActionButton(
          icon: Icons.tune_rounded,
          label: 'Filtrele',
          onTap: onFilterTap,
          color: Colors.orange.shade400,
        ),
      ],
    );
  }

  Widget _buildCompactActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required Color color,
  }) {
    return CupertinoButton(
      onPressed: onTap,
      padding: const EdgeInsets.symmetric(
          vertical: 2, horizontal: 6), // Padding azaltıldı
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22), // 24'ten 22'ye küçültüldü
          const SizedBox(height: 2), // 4'ten 2'ye küçültüldü
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11, // 12'den 11'e küçültüldü
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize {
    double height = 56;
    if (showSearchBar) {
      height = 44 + 48; // 44 (search) + 48 (title + spacing)
      if (showActionButtons) {
        height += 66; // 72'den 66'ya düşürüldü (6+50+10=66)
      }
    }
    return Size.fromHeight(height);
  }
}

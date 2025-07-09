import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../utils/app_theme.dart';

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
  final VoidCallback? onLogoTap; // Logo tıklama için

  // Yeni parametreler
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
    this.onLogoTap,
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
        // Siyah arka plan - theme'e uyumlu
        color: AppTheme.appBackgroundColor,
        // Subtle shadow for depth
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Overflow önlemek için
          children: [
            // KURUMSAL BRAND HEADER - BEE HESAP (Küçük)
            _buildCompactCorporateHeader(context),

            // SEARCH VE ACTION BUTTONS AREA
            if (showSearchBar)
              _buildSearchWithActionsSection(context)
            else
              _buildRegularHeader(context),
          ],
        ),
      ),
    );
  }

  // Kurumsal Brand Header - En üst kısım
  Widget _buildCorporateBrandHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: BoxDecoration(
        // Premium brand area gradient
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.15),
            AppTheme.accentColor.withValues(alpha: 0.1),
            Colors.purple.withValues(alpha: 0.08),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primaryColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Ana brand bilgisi
          Row(
            children: [
              // Premium Logo
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFFD700), // Gold
                      const Color(0xFFFFA500), // Orange
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded, // AI/Premium icon
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),

              // Brand name ve açıklama
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ana brand
                    Row(
                      children: [
                        Text(
                          'Bee Hesap',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            letterSpacing: 0.5,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          width: 2,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                        Text(
                          'Pro',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),

                    // Service description - küçük yazı
                    Text(
                      'Yapay Zeka Destekli Ön Muhasebe, Stok Takip, Operasyonel Yönetim, Analiz',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Poppins',
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // (additionalActions kaldırıldı - header üzerinde buton yok)
            ],
          ),
        ],
      ),
    );
  }

  // Search ve Action buttons section - Butonlar üstte
  Widget _buildSearchWithActionsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 20.0, vertical: 8.0), // Daha da küçültüldü
      child: Column(
        mainAxisSize: MainAxisSize.min, // Overflow önlemek için
        children: [
          // ACTION BUTTONS - Üstte ve daha küçük
          if (showActionButtons) ...[
            Row(
              children: [
                // QR Kod Tarama
                Expanded(
                  child: _buildCompactActionButton(
                    icon: Icons.qr_code_rounded,
                    label: 'QR Tara',
                    onTap: onQRScan,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 8),

                // Barkod Tarama
                Expanded(
                  child: _buildCompactActionButton(
                    icon: Icons.qr_code_scanner_rounded,
                    label: 'Barkod',
                    onTap: onBarcodeScan,
                    color: AppTheme.accentColor,
                  ),
                ),
                const SizedBox(width: 8),

                // Gelişmiş Filtreleme
                Expanded(
                  child: _buildCompactActionButton(
                    icon: Icons.tune_rounded,
                    label: 'Filtre',
                    onTap: onFilterTap,
                    color: Colors.orange.shade400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // iOS Style Search bar
          Row(
            children: [
              // iOS CupertinoSearchTextField
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    // iOS tarzı hafif gri arka plan
                    color:
                        const Color(0xFF1C1C1E), // iOS Dark Mode search color
                    borderRadius:
                        BorderRadius.circular(10), // iOS corner radius
                  ),
                  child: CupertinoSearchTextField(
                    controller: searchController,
                    focusNode: searchFocusNode,
                    placeholder: searchHint,
                    style: TextStyle(
                      color: AppTheme.primaryTextColor,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                    placeholderStyle: TextStyle(
                      color: AppTheme.hintTextColor,
                      fontSize: 13,
                      fontFamily: 'Poppins',
                    ),
                    backgroundColor:
                        Colors.transparent, // Container'da renk var
                    borderRadius: BorderRadius.circular(10),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 16.0,
                    ),
                    suffixIcon: isSearchFocused
                        ? const Icon(CupertinoIcons.clear_circled_solid)
                        : Icon(
                            CupertinoIcons.qrcode_viewfinder,
                            color: Colors.grey[400],
                            size: 18,
                          ),
                    onSuffixTap: isSearchFocused ? null : onQRScan,
                    prefixIcon: Icon(
                      CupertinoIcons.search,
                      color: Colors.grey[400],
                      size: 18,
                    ),
                  ),
                ),
              ),

              // Vazgeç Butonu (Search Focus'ta)
              if (isSearchFocused) ...[
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onSearchCancel,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Vazgeç',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // Kompakt Kurumsal Header - Küçültülmüş versiyon
  Widget _buildCompactCorporateHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: 20.0, vertical: 6.0), // Daha da küçültüldü
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Logo Area - Resim seçilebilir
          GestureDetector(
            onTap: onLogoTap,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                color: Colors.grey,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Brand name ve açıklama - Küçük
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ana brand
                Row(
                  children: [
                    Text(
                      'Bee Hesap',
                      style: TextStyle(
                        color: AppTheme.primaryTextColor,
                        fontSize: 16, // Küçültüldü
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 1.5,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    Text(
                      'Pro',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12, // Küçültüldü
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),

                // Service description - Daha küçük yazı
                Text(
                  'Yapay Zeka Destekli Ön Muhasebe, Stok Takip, Operasyonel Yönetim, Analiz',
                  style: TextStyle(
                    color: AppTheme.secondaryTextColor,
                    fontSize: 9, // Küçültüldü
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Poppins',
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // (additionalActions kaldırıldı - header üzerinde buton yok)
        ],
      ),
    );
  }

  // Regular header (diğer sayfalar için)
  Widget _buildRegularHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: 20.0, vertical: 12.0), // Küçültüldü
      child: Row(
        children: [
          // Sol taraf - Geri butonu
          if (showBackButton)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                color: AppTheme.primaryTextColor,
                iconSize: 20,
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
              ),
            )
          else
            const SizedBox(width: 40), // Boş alan (ortalama için)

          // Orta kısım - Başlık
          Expanded(
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  color: AppTheme.primaryTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
                textAlign: centerTitle ? TextAlign.center : TextAlign.left,
              ),
            ),
          ),

          // Sağ taraf - Kaydet veya Ekleme butonu
          if (showSaveButton)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.check_rounded), // Güzel kaydet ikonu
                color: AppTheme.primaryColor,
                iconSize: 20,
                onPressed: onSavePressed,
                padding: EdgeInsets.zero,
                tooltip: 'Kaydet',
              ),
            )
          else if (showAddButton)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.add_rounded), // Güzel ekleme ikonu
                color: AppTheme.primaryColor,
                iconSize: 20,
                onPressed: onAddPressed,
                padding: EdgeInsets.zero,
                tooltip: 'Yeni Ekle',
              ),
            )
          else
            const SizedBox(width: 40), // Boş alan (ortalama için)
        ],
      ),
    );
  }

  // Kompakt Action Button - Küçük boyut
  Widget _buildCompactActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: 6, horizontal: 10), // Daha da küçültüldü
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 18, // Küçültüldü
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10, // Küçültüldü
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize {
    double height = 0;

    // Status bar height
    height += MediaQueryData.fromView(
            WidgetsBinding.instance.platformDispatcher.views.first)
        .padding
        .top;

    // Compact corporate brand header - Daha da küçültüldü
    height += 45; // 50'den 45'e

    if (showSearchBar) {
      // Search section height - Daha da küçültüldü
      height += 50; // 55'den 50'ye

      if (showActionButtons) {
        // Action buttons height - Daha da küçültüldü
        height += 45; // 50'den 45'e
      }
    } else {
      // Regular header height - artırıldı (overflow fix)
      height += 60; // 35 -> 60 (25px ekstra)
    }

    return Size.fromHeight(height);
  }
}

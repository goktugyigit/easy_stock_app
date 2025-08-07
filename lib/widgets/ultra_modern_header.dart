// lib/widgets/ultra_modern_header.dart - ULTRA PROFESYONEL HEADER

import 'package:flutter/material.dart';
import 'dart:ui';

class UltraModernHeader extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final TextEditingController? searchController;
  final FocusNode? searchFocusNode;
  final VoidCallback? onQRScan;
  final VoidCallback? onBarcodeScan;
  final VoidCallback? onFilterTap;
  final VoidCallback? onSearchCancel;
  final String searchHint;

  const UltraModernHeader({
    super.key,
    required this.title,
    this.searchController,
    this.searchFocusNode,
    this.onQRScan,
    this.onBarcodeScan,
    this.onFilterTap,
    this.onSearchCancel,
    this.searchHint = 'Stok ara',
  });

  @override
  State<UltraModernHeader> createState() => _UltraModernHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(180);
}

class _UltraModernHeaderState extends State<UltraModernHeader>
    with TickerProviderStateMixin {
  bool _isSearchActive = false;
  late final AnimationController _shimmer; // controller
  late final Animation<double> _x; // -1.5 … +1.5

  @override
  void initState() {
    super.initState();
    widget.searchFocusNode?.addListener(_onFocusChanged);

    _shimmer = AnimationController(
      duration: const Duration(
          milliseconds:
              4000), // 4 sn sola→sağa, 4 sn sağa→sola = 8 sn tam devir
      vsync: this,
    )..repeat(reverse: true); // ping-pong

    _x = Tween<double>(begin: -1.5, end: 1.5).animate(_shimmer);
  }

  void _onFocusChanged() {
    if (widget.searchFocusNode?.hasFocus == true && !_isSearchActive) {
      _activateSearch();
    } else if (widget.searchFocusNode?.hasFocus == false && _isSearchActive) {
      // Focus kaybedildiğinde search state'ini sıfırla
      setState(() {
        _isSearchActive = false;
      });
    }
  }

  void _activateSearch() {
    setState(() {
      _isSearchActive = true;
    });
  }

  void _cancelSearch() {
    setState(() {
      _isSearchActive = false;
    });
    widget.searchController?.clear();
    widget.searchFocusNode?.unfocus();
    widget.onSearchCancel?.call();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    widget.searchFocusNode?.removeListener(_onFocusChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black,
            Colors.black.withValues(alpha: 0.95),
          ],
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.1),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title her zaman göster
                    _buildTopRow(),
                    const SizedBox(height: 10),
                    _buildSearchRow(),
                    const SizedBox(height: 10),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopRow() {
    return _buildTitle();
  }

  Widget _buildSearchRow() {
    return SizedBox(
      height: 40, // Sabit yükseklik
      child: Row(
        children: [
          // Search Field - tam genişlik kullan
          Expanded(
            child: _buildUnifiedSearchField(),
          ),
          // Cancel Button - sadece aktifken göster, boşluk bırakma
          if (_isSearchActive) ...[
            const SizedBox(width: 12),
            _buildCancelButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive değerler - ekran boyutuna göre
        final screenWidth = constraints.maxWidth;
        final isSmallScreen = screenWidth < 400;

        // Responsive boyutlar
        final horizontalPadding =
            isSmallScreen ? 36.0 : 52.0; // Çok daha uzun padding
        final verticalPadding = isSmallScreen ? 6.0 : 8.0;
        final borderRadius = isSmallScreen ? 12.0 : 16.0;
        final fontSize = isSmallScreen ? 18.0 : 20.0;
        final borderWidth = isSmallScreen ? 1.0 : 1.5;

        return AnimatedBuilder(
          animation: _x,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Arka plan pulse efekti - cool renkli
                Container(
                  width: screenWidth + 8, // Biraz daha geniş pulse
                  height: isSmallScreen ? 38 : 42, // Yüksekliği biraz artır
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9)
                        .withValues(alpha: 0.12), // Cool sky blue pulse
                    borderRadius: BorderRadius.circular(borderRadius + 2),
                  ),
                ),
                // Shimmerlı arka plan (text'in arkasında kalacak)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: Stack(
                      children: [
                        // Arka plan gradient (sabit)
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF0EA5E9)
                                    .withValues(alpha: 0.25), // Sky blue
                                const Color(0xFF0284C7)
                                    .withValues(alpha: 0.3), // Blue
                                const Color(0xFF0369A1)
                                    .withValues(alpha: 0.25), // Dark blue
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        // Yavaş ve yumuşak shimmer - Ana katman
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.white.withValues(alpha: 0.03),
                                Colors.white.withValues(alpha: 0.08),
                                Colors.white.withValues(alpha: 0.15),
                                Colors.white.withValues(alpha: 0.25),
                                Colors.white.withValues(alpha: 0.35),
                                Colors.white.withValues(alpha: 0.25),
                                Colors.white.withValues(alpha: 0.15),
                                Colors.white.withValues(alpha: 0.08),
                                Colors.white.withValues(alpha: 0.03),
                                Colors.transparent,
                              ],
                              stops: const [
                                0.0,
                                0.1,
                                0.2,
                                0.3,
                                0.4,
                                0.5,
                                0.6,
                                0.7,
                                0.8,
                                0.9,
                                1.0
                              ],
                              // Animasyonun x-eksenindeki pozisyonu, -1.5 ile 1.5 arasında.
                              // Bu, gradient'in başlangıç ve bitiş noktalarını belirler.
                              begin: Alignment(
                                  _x.value - 1.5, -0.2), // -3.0'dan başlar
                              end: Alignment(
                                  _x.value + 1.5, 0.2), // 3.0'da biter
                            ),
                          ),
                        ),
                        // İkinci yumuşak katman - İnce accent
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.white.withValues(alpha: 0.05),
                                Colors.white.withValues(alpha: 0.12),
                                Colors.white.withValues(alpha: 0.18),
                                Colors.white.withValues(alpha: 0.12),
                                Colors.white.withValues(alpha: 0.05),
                                Colors.transparent,
                              ],
                              stops: const [
                                0.0,
                                0.25,
                                0.4,
                                0.5,
                                0.6,
                                0.75,
                                1.0
                              ],
                              begin: Alignment(-_x.value - 1.0,
                                  -0.1), // Ters yönde ve simetrik
                              end: Alignment(-_x.value + 1.0, 0.1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Yazı (shimmer'ın üstünde sabit duran katman)
                Container(
                  key: const ValueKey('title'),
                  width: screenWidth, // Tam genişlik, search bar ile eşit
                  alignment: Alignment.center, // Text'i ortala
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: Border.all(
                      // Daha koyu çizgi - cool tone
                      color: const Color(0xFF075985)
                          .withValues(alpha: 0.6), // Dark blue border
                      width: borderWidth,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0EA5E9).withValues(alpha: 0.3),
                        blurRadius: isSmallScreen ? 8 : 12,
                        offset: Offset(0, isSmallScreen ? 3 : 4),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.3,
                      height: 1.2, // Line height kontrolü
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildUnifiedSearchField() {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth < 400 ? 14.0 : 16.0;
    final iconSize = screenWidth < 400 ? 18.0 : 20.0;

    return TextField(
      controller: widget.searchController,
      focusNode: widget.searchFocusNode,
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
      ),
      cursorColor: const Color(0xFF00E5FF),
      decoration: InputDecoration(
        hintText: widget.searchHint,
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: fontSize,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: _isSearchActive
              ? const Color(0xFF00C6FF).withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.5),
          size: iconSize,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: const Color(0xFF00C6FF).withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }

  Widget _buildCancelButton() {
    return GestureDetector(
      onTap: _cancelSearch,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: const Text(
          'Vazgeç',
          style: TextStyle(
            color: Color(0xFF00C6FF),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: _buildGradientActionButton(
            label: 'QR Tara',
            icon: Icons.qr_code_scanner_rounded,
            gradient: const [Color(0xFF00C6FF), Color(0xFF0072FF)],
            onTap: widget.onQRScan,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildGradientActionButton(
            label: 'Barkod',
            icon: Icons.qr_code_rounded,
            gradient: const [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
            onTap: widget.onBarcodeScan,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildGradientActionButton(
            label: 'Filtrele',
            icon: Icons.filter_alt_rounded,
            gradient: const [Color(0xFFFFAF7B), Color(0xFFFF5200)],
            onTap: widget.onFilterTap,
          ),
        ),
      ],
    );
  }

  Widget _buildGradientActionButton({
    required String label,
    required IconData icon,
    required List<Color> gradient,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.25),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

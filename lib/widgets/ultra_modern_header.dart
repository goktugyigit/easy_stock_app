// lib/widgets/ultra_modern_header.dart - ULTRA PROFESYONEL HEADER

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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

class _UltraModernHeaderState extends State<UltraModernHeader> {
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    widget.searchFocusNode?.addListener(_onFocusChanged);
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
    return Center(
      child: Text(
        widget.title,
        key: const ValueKey('title'),
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.4,
        ),
      ),
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

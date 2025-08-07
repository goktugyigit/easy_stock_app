// lib/widgets/shimmer_title_header.dart - SADECE SHIMMER EFEKTLİ BAŞLIK

import 'package:flutter/material.dart';
import 'dart:ui';

class ShimmerTitleHeader extends StatefulWidget implements PreferredSizeWidget {
  final String title;

  const ShimmerTitleHeader({
    super.key,
    required this.title,
  });

  @override
  State<ShimmerTitleHeader> createState() => _ShimmerTitleHeaderState();

  @override
  Size get preferredSize =>
      const Size.fromHeight(120); // Ana sayfadan daha küçük
}

class _ShimmerTitleHeaderState extends State<ShimmerTitleHeader>
    with TickerProviderStateMixin {
  late final AnimationController _shimmer;
  late final Animation<double> _x;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat(reverse: true);

    _x = Tween<double>(begin: -1.5, end: 1.5).animate(_shimmer);
  }

  @override
  void dispose() {
    _shimmer.dispose();
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
                    _buildTitle(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Ana sayfadaki aynı responsive değerler
        final screenWidth = constraints.maxWidth;
        final isSmallScreen = screenWidth < 400;

        final horizontalPadding = isSmallScreen ? 36.0 : 52.0;
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
                // Arka plan pulse efekti
                Container(
                  width: screenWidth + 8,
                  height: isSmallScreen ? 38 : 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(borderRadius + 2),
                  ),
                ),
                // Shimmerlı arka plan
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: Stack(
                      children: [
                        // Arka plan gradient
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF0EA5E9).withValues(alpha: 0.25),
                                const Color(0xFF0284C7).withValues(alpha: 0.3),
                                const Color(0xFF0369A1).withValues(alpha: 0.25),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        // Ana shimmer katmanı
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
                              begin: Alignment(_x.value - 1.5, -0.2),
                              end: Alignment(_x.value + 1.5, 0.2),
                            ),
                          ),
                        ),
                        // İkinci shimmer katmanı
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
                              begin: Alignment(-_x.value - 1.0, -0.1),
                              end: Alignment(-_x.value + 1.0, 0.1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Başlık yazısı
                Container(
                  key: const ValueKey('title'),
                  width: screenWidth,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: Border.all(
                      color: const Color(0xFF075985).withValues(alpha: 0.6),
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
                      height: 1.2,
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
}

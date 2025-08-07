// lib/widgets/modern_empty_state.dart - MODERN VE MİNİMAL EMPTY STATE

import 'package:flutter/material.dart';
import 'dart:ui';

class ModernEmptyState extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String buttonText;
  final VoidCallback? onButtonPressed;
  final bool isSearching;

  const ModernEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.buttonText,
    this.onButtonPressed,
    this.isSearching = false,
  });

  @override
  State<ModernEmptyState> createState() => _ModernEmptyStateState();
}

class _ModernEmptyStateState extends State<ModernEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = constraints.maxHeight;
          final isLargeScreen = availableHeight > 600;

          return Center(
            child: SingleChildScrollView(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: _buildContent(isLargeScreen),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(bool isLargeScreen) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 40 : 24,
        vertical: isLargeScreen ? 60 : 40,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIconSection(isLargeScreen),
          SizedBox(height: isLargeScreen ? 32 : 24),
          _buildTextSection(isLargeScreen),
          if (!widget.isSearching) ...[
            SizedBox(height: isLargeScreen ? 40 : 32),
            _buildActionButton(isLargeScreen),
          ],
        ],
      ),
    );
  }

  Widget _buildIconSection(bool isLargeScreen) {
    return Container(
      width: isLargeScreen ? 120 : 100,
      height: isLargeScreen ? 120 : 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0EA5E9).withValues(alpha: 0.2),
            const Color(0xFF0284C7).withValues(alpha: 0.3),
            const Color(0xFF0369A1).withValues(alpha: 0.2),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0EA5E9).withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Icon(
        widget.icon,
        size: isLargeScreen ? 50 : 40,
        color: Colors.white.withValues(alpha: 0.9),
      ),
    );
  }

  Widget _buildTextSection(bool isLargeScreen) {
    return Column(
      children: [
        Text(
          widget.title,
          style: TextStyle(
            color: Colors.white,
            fontSize: isLargeScreen ? 24 : 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isLargeScreen ? 12 : 8),
        Text(
          widget.subtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: isLargeScreen ? 16 : 14,
            fontWeight: FontWeight.w400,
            height: 1.4,
            letterSpacing: 0.1,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildActionButton(bool isLargeScreen) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0EA5E9),
            const Color(0xFF0284C7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0EA5E9).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onButtonPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isLargeScreen ? 32 : 28,
              vertical: isLargeScreen ? 16 : 14,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: isLargeScreen ? 22 : 20,
                ),
                SizedBox(width: isLargeScreen ? 12 : 10),
                Text(
                  widget.buttonText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isLargeScreen ? 16 : 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

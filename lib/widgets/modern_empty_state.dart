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
    return _CoolActionButton(
      text: widget.buttonText,
      onPressed: widget.onButtonPressed,
      isLargeScreen: isLargeScreen,
    );
  }
}

class _CoolActionButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLargeScreen;

  const _CoolActionButton({
    required this.text,
    required this.onPressed,
    required this.isLargeScreen,
  });

  @override
  State<_CoolActionButton> createState() => _CoolActionButtonState();
}

class _CoolActionButtonState extends State<_CoolActionButton>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.4,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _pressController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: Listenable.merge([_hoverController, _pressController]),
          builder: (context, child) {
            final scale =
                _scaleAnimation.value * (1.0 - (_pressController.value * 0.05));

            return Transform.scale(
              scale: scale,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF00E5FF),
                      const Color(0xFF0EA5E9),
                      const Color(0xFF0284C7),
                      const Color(0xFF0369A1),
                    ],
                    stops: const [0.0, 0.3, 0.7, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF)
                          .withValues(alpha: _glowAnimation.value * 0.4),
                      blurRadius: 20 + (_hoverController.value * 5),
                      offset: const Offset(0, 8),
                      spreadRadius: 1 + (_hoverController.value * 1),
                    ),
                    BoxShadow(
                      color: const Color(0xFF0EA5E9).withValues(alpha: 0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(
                          alpha: 0.3 + (_hoverController.value * 0.2)),
                      width: 1.5,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onPressed,
                      borderRadius: BorderRadius.circular(24),
                      splashColor: Colors.white.withValues(alpha: 0.3),
                      highlightColor: Colors.white.withValues(alpha: 0.1),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: widget.isLargeScreen ? 40 : 36,
                          vertical: widget.isLargeScreen ? 20 : 18,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Text
                            Text(
                              widget.text,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: widget.isLargeScreen ? 18 : 17,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: widget.isLargeScreen ? 12 : 10),
                            // Arrow icon with transparent container
                            Transform.translate(
                              offset: Offset(_hoverController.value * 4, 0),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  size: widget.isLargeScreen ? 18 : 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

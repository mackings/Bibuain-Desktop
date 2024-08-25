import 'dart:math';
import 'package:flutter/material.dart';

class Bubble extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  Bubble({required this.size, required this.color, required this.duration});

  @override
  _BubbleState createState() => _BubbleState();
}

class _BubbleState extends State<Bubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  late Animation<double> _sizeAnimation;

  late double _velocityX;
  late double _velocityY;

  @override
  void initState() {
    super.initState();
    
    // Initialize the animation controller
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    // Define slower velocities for movement
    _velocityX = (Random().nextDouble() * 2 - 1) * 0.01;
    _velocityY = (Random().nextDouble() * 2 - 1) * 0.01;

    // Define the animation to continuously move the bubble
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    // Define size animation for bubble size
    _sizeAnimation = Tween<double>(
      begin: widget.size,
      end: widget.size * 1.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Update position based on velocity
    _controller.addListener(() {
      final position = _animation.value;
      final size = MediaQuery.of(context).size;
      final newOffsetX = (position.dx + _velocityX) % 1.0;
      final newOffsetY = (position.dy + _velocityY) % 1.0;

      // Bounce off edges
      if (newOffsetX <= 0 || newOffsetX >= 1) _velocityX = -_velocityX;
      if (newOffsetY <= 0 || newOffsetY >= 1) _velocityY = -_velocityY;

      _animation = Tween<Offset>(
        begin: Offset(newOffsetX, newOffsetY),
        end: Offset(newOffsetX, newOffsetY),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ));
      setState(() {}); // Update position
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final offset = _animation.value;
        return Positioned(
          left: offset.dx * size.width,
          top: offset.dy * size.height,
          child: Container(
            width: _sizeAnimation.value,
            height: _sizeAnimation.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withOpacity(0.7),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
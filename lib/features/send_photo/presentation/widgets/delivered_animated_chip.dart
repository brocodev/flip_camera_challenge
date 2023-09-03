import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ui_common/ui_common.dart';

class DeliveredAnimatedChip extends StatelessWidget {
  const DeliveredAnimatedChip({
    required this.animation,
    super.key,
  });

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, child) => Positioned.fill(
        top: lerpDouble(-100, context.mediaQuery.padding.top, animation.value),
        bottom: null,
        child: child!,
      ),
      child: const Chip(
        backgroundColor: Colors.black,
        label: Text('Delivered', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

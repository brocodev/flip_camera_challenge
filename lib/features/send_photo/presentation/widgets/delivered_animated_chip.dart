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
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: 20.borderRadiusA,
          ),
          child: Padding(
            padding: [20, 10, 20, 10].edgeInsetsLTRB,
            child: const Text(
              'Delivered',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

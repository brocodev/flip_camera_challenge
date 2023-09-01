import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ui_common/ui_common.dart';

class VerticalDraggableWidget extends StatefulWidget {
  const VerticalDraggableWidget({
    required this.child,
    required this.enableDrag,
    required this.onDragPercentChanged,
    required this.onFlickUp,
    required this.onReleaseReady,
    required this.onReleased,
    super.key,
  });

  /// [bool] to enable or disable drag
  final bool enableDrag;

  /// [ValueChanged] which is executed every time the widget position changes
  /// and sends the drag percentage with values ranging from 0.0 to 1.0
  final ValueChanged<double> onDragPercentChanged;

  /// [VoidCallback] what is executed when the user swipe up
  final VoidCallback onFlickUp;

  /// [ValueChanged] indicating that the user maintained the final
  /// drag position for at least 2 seconds
  final ValueChanged<bool> onReleaseReady;

  /// [Future] function that is executed after releasing the drag and having
  /// maintained the final position for at least 2 seconds
  final Future<void> Function() onReleased;

  /// [Widget] that will be wrapped and to which the drag will be applied
  final Widget child;

  @override
  State<VerticalDraggableWidget> createState() =>
      _VerticalDraggableWidgetState();
}

class _VerticalDraggableWidgetState extends State<VerticalDraggableWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animation;
  final double maxVerticalDrag = .3.sh;
  final GlobalKey globalKey = GlobalKey();
  double startOffsetY = 0;
  ValueNotifier<double> offsetYNotifier = ValueNotifier(0);
  final VelocityTracker velocityTracker =
      VelocityTracker.withKind(PointerDeviceKind.touch);

  Offset get position {
    final renderBox =
        globalKey.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
  }

  void restoreControllerListener() {
    if (controller.isCompleted) {
      controller.reset();
      offsetYNotifier.value = 0;
    }
    if (controller.value != 0) {
      final restorePercent =
          (offsetYNotifier.value / maxVerticalDrag) * animation.value;
      widget.onDragPercentChanged(restorePercent);
    }
  }

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(restoreControllerListener);
    animation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
    );
    super.initState();
  }

  @override
  void dispose() {
    controller
      ..removeListener(restoreControllerListener)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = SizedBox(key: globalKey, child: widget.child);
    if (!widget.enableDrag) return child;
    return GestureDetector(
      onVerticalDragStart: (details) {
        if (controller.isAnimating) return;
        startOffsetY = details.globalPosition.dy;
      },
      onVerticalDragUpdate: (details) {
        if (controller.isAnimating) return;
        offsetYNotifier.value = (details.globalPosition.dy - startOffsetY)
            .clamp(0, maxVerticalDrag);
        widget.onDragPercentChanged(offsetYNotifier.value / maxVerticalDrag);
        if (details.primaryDelta! < 0) {
          velocityTracker.addPosition(details.sourceTimeStamp!, position);
          final velocity =
              velocityTracker.getVelocityEstimate()?.pixelsPerSecond.dy;
          if ((velocity ?? 0) < -1500) {
            widget.onFlickUp();
          }
        }
      },
      onVerticalDragEnd: (details) {
        if (controller.isAnimating) return;
        controller.forward();
      },
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, child) => ValueListenableBuilder<double>(
          valueListenable: offsetYNotifier,
          builder: (__, value, _) => Transform.translate(
            offset: Offset(0, value * animation.value),
            child: child,
          ),
        ),
        child: child,
      ),
    );
  }
}

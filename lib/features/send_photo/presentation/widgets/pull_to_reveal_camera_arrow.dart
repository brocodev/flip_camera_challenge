import 'package:flutter/material.dart';
import 'package:ui_common/ui_common.dart';

class PullToRevealCameraArrow extends StatelessWidget {
  const PullToRevealCameraArrow({
    required this.hide,
    super.key,
  });

  final bool hide;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: kThemeAnimationDuration,
      opacity: hide ? 0 : 1,
      child: Column(
        children: [
          const Text('Pull down to reveal the camera'),
          height16,
          Expanded(
            child: CustomPaint(
              painter: ArrowPainter(),
              child: SizedBox(width: 40.w),
            ),
          ),
        ],
      ),
    );
  }
}

class ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final w = size.width;
    final bodyPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.r
      ..strokeCap = StrokeCap.round
      ..color = Colors.black;
    final bodyPath = Path()
      ..moveTo(w * .5, 0)
      ..cubicTo(w * .4, h * .3, 0, h * .4, w * .2, h * .45)
      ..cubicTo(w * .6, h * .5, w * .6, h * .35, w * .2, h * .45)
      ..cubicTo(0, h * .6, w * .7, h * .65, w * .5, h * .93);
    canvas.drawPath(bodyPath, bodyPaint);
    final headPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black;
    final headPath = Path()
      ..moveTo(w * .3, h * .93)
      ..lineTo(w * .7, h * .93)
      ..lineTo(w * .5, h);
    canvas.drawPath(headPath, headPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Hilo de atención: se desvía y vuelve a su punto de partida.
class AttentionThread extends StatelessWidget {
  const AttentionThread({super.key, this.height = 72, this.semanticLabel});
  final double height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    image: true,
    child: ExcludeSemantics(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _ThreadPainter(
            context.palette.primary,
          ),
        ),
      ),
    ),
  );
}

class _ThreadPainter extends CustomPainter {
  const _ThreadPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * .08, size.height * .64)
      ..cubicTo(
        size.width * .28,
        size.height * .18,
        size.width * .38,
        size.height * .88,
        size.width * .57,
        size.height * .43,
      )
      ..cubicTo(
        size.width * .76,
        size.height * .01,
        size.width * .72,
        size.height * .97,
        size.width * .93,
        size.height * .48,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: .88)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      Offset(size.width * .93, size.height * .48),
      3.2,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_ThreadPainter oldDelegate) => oldDelegate.color != color;
}

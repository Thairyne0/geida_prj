import 'package:flutter/material.dart';

/// Avvolge un widget scrollabile aggiungendo sfumature ai bordi
/// superiore e inferiore che danno l'effetto "dissolvi" agli elementi.
class FadeEdgeScrollWrapper extends StatelessWidget {
  final Widget child;
  final double fadeHeight;

  const FadeEdgeScrollWrapper({
    super.key,
    required this.child,
    this.fadeHeight = 32,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.white,
            Colors.white,
            Colors.transparent,
          ],
          stops: [
            0.0,
            fadeHeight / bounds.height,
            1.0 - (fadeHeight / bounds.height),
            1.0,
          ],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: child,
    );
  }
}



import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown_selectionarea/flutter_markdown_selectionarea.dart';

class TextElement extends HookWidget {
  const TextElement({
    super.key,
    required this.textToShow,
    this.inlineSpans,
    required this.onEnd,
    this.style,
    this.child,
  });

  final String textToShow;
  final InlineSpan? inlineSpans;
  final VoidCallback onEnd;
  final TextStyle? style;
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    final controller =
        useAnimationController(duration: const Duration(milliseconds: 250));
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        controller.forward();
      });
      return;
    }, []);
    useAnimation(controller);

    return AnimatedOpacity(
      opacity: controller.value,
      onEnd: onEnd,
      duration: controller.duration ?? const Duration(seconds: 1),
      child: child ??
          (inlineSpans != null
              ? Text.rich(
                  inlineSpans!,
                )
              : Text(
                  textToShow,
                  style: style,
                )),
    );
  }
}

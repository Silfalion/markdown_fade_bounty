import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown_selectionarea/flutter_markdown_selectionarea.dart';

class TextElement extends HookWidget {
  const TextElement({
    super.key,
    required this.inlineSpans,
  });

  final InlineSpan inlineSpans;
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
      duration: controller.duration ?? const Duration(seconds: 1),
      child: inlineSpans is TextSpan
          ? Text(
              (inlineSpans as TextSpan).text ?? '',
            )
          : Text.rich(TextSpan(children: [inlineSpans])),
    );
  }
}

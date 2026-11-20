import 'package:flutter/material.dart';

/// Teks tautan: menjadi bold + underline saat di-hover (mouse) atau ditekan (sentuh).
class HoverText extends StatefulWidget {
  const HoverText({
    super.key,
    required this.text,
    required this.style,
    required this.onTap,
    this.textAlign,
  });

  final String text;
  final TextStyle style;
  final VoidCallback onTap;
  final TextAlign? textAlign;

  @override
  State<HoverText> createState() => _HoverTextState();
}

class _HoverTextState extends State<HoverText> {
  bool _active = false;

  void _set(bool v) {
    if (_active != v) setState(() => _active = v);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _set(true),
      onExit: (_) => _set(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        onTap: widget.onTap,
        child: Text(
          widget.text,
          textAlign: widget.textAlign,
          style: widget.style.copyWith(
            fontWeight: _active ? FontWeight.w800 : widget.style.fontWeight,
            decoration: _active ? TextDecoration.underline : TextDecoration.none,
            decorationColor: widget.style.color,
          ),
        ),
      ),
    );
  }
}

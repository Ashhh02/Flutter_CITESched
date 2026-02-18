import 'package:flutter/material.dart';

/// A wrapper widget that makes its child draggable within a Stack.
/// This widget MUST be a direct child of a Stack.
class DraggableFab extends StatefulWidget {
  final Widget child;

  const DraggableFab({
    super.key,
    required this.child,
  });

  @override
  State<DraggableFab> createState() => _DraggableFabState();
}

class _DraggableFabState extends State<DraggableFab> {
  Offset? _offset;

  @override
  Widget build(BuildContext context) {
    if (_offset == null) {
      final size = MediaQuery.of(context).size;
      // Initialize to bottom-right (approximating Scaffold's FAB position)
      // Standard FAB is usually 16-24px from bottom/right.
      // FloatingActionButton.extended is wider, so we adjust.
      _offset = Offset(size.width - 180, size.height - 110);
    }

    return Positioned(
      left: _offset!.dx,
      top: _offset!.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _offset = Offset(
              _offset!.dx + details.delta.dx,
              _offset!.dy + details.delta.dy,
            );
          });
        },
        child: widget.child,
      ),
    );
  }
}

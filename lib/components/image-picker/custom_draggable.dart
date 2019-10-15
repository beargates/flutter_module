import 'dart:ui';

import 'package:flutter/material.dart';

class CustomDraggable extends StatefulWidget {
  final Widget feedback;
  final double opacity;
  final GestureTapDownCallback onTapDown;
  final GestureTapUpCallback onTapUp;
  final GestureDragDownCallback onHorizontalDragDown;
  final GestureDragStartCallback onHorizontalDragStart;
  final GestureDragUpdateCallback onHorizontalDragUpdate;
  final GestureDragEndCallback onHorizontalDragEnd;
  final GestureDragDownCallback onVerticalDragDown;
  final GestureDragEndCallback onVerticalDragEnd;

  CustomDraggable({
    @required this.feedback,
    this.opacity = 1,
    this.onTapDown,
    this.onTapUp,
    this.onHorizontalDragDown,
    this.onHorizontalDragStart,
    this.onHorizontalDragUpdate,
    this.onHorizontalDragEnd,
    this.onVerticalDragDown,
    this.onVerticalDragEnd,
  });

  _CustomDraggableState createState() => _CustomDraggableState();
}

class _CustomDraggableState extends State<CustomDraggable> {
  Offset _startOffset;
  Offset _offset = Offset(0, 0);
  OverlayEntry _entry;
  double _opacity = 0;
  dynamic direction;

  void initState() {
    super.initState();

    _entry = OverlayEntry(builder: (_) {
      return Positioned(
        left: _offset.dx,
        top: _offset.dy,
        right: -_offset.dx,
        bottom: -_offset.dy,
        child: IgnorePointer(
          child: Opacity(opacity: widget.opacity, child: widget.feedback),
          ignoringSemantics: true,
        ),
      );
    });

    Future.delayed(Duration(seconds: 0)).then((_) {
      Overlay.of(context).insert(_entry);
    });
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    _entry.markNeedsBuild();
  }

  void dispose() {
    super.dispose();
    _entry?.remove();
  }

  Widget build(ctx) {
    /// 创建opacity为0的widget是为了可以响应手势处理
    return Listener(
        onPointerDown: (e) {
          _startOffset = e.position;
        },
        onPointerMove: (e) {
          var offset = e.position - _startOffset;

          /// 横向处理
          if (offset.dx >= 5) {
            /// 方向锁定
            if (direction == null) {
              direction = 0;
            }
            if (direction == 0) {
              if (_opacity != 1) {
                _opacity = 1;
                setState(() {});
              }
              _entry.markNeedsBuild();
            }
          }

          /// 纵向处理
          if (offset.dy >= 5) {
            /// 方向锁定
            if (direction == null) {
              direction = 1;
            }
            if (direction == 1) {
              _offset = offset;
              _entry.markNeedsBuild();
              setState(() {});
            }
          }
        },
        onPointerUp: (_) {
          direction = null;
        },
        onPointerCancel: (_) {
          direction = null;
        },
        behavior: direction == 1
            ? HitTestBehavior.translucent
            : HitTestBehavior.opaque,
        child: Opacity(opacity: _opacity, child: widget.feedback));
  }
}

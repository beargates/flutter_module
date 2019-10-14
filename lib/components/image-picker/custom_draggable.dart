import 'dart:ui';

import 'package:flutter/material.dart';

class CustomDraggable extends StatefulWidget {
  final Widget feedback;
  final BuildContext context;
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
    @required this.context,
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

  void initState() {
    super.initState();

    _entry = OverlayEntry(builder: (_) {
      return Positioned(
        left: _offset.dx,
        top: _offset.dy,
        right: -_offset.dx,
        bottom: -_offset.dy,
        child: IgnorePointer(
          child: widget.opacity == 1
              ? widget.feedback
              : Opacity(opacity: widget.opacity, child: widget.feedback),
          ignoringSemantics: true,
        ),
      );
    });

    Future.delayed(Duration(milliseconds: 100)).then((_) {
      Overlay.of(widget.context).insert(_entry);
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
    return GestureDetector(
        onPanStart: (e) {
          _startOffset = e.globalPosition;
        },
        onPanUpdate: (e) {
          print('paning');
          _offset = Offset(
            e.globalPosition.dx - _startOffset.dx,
            e.globalPosition.dy - _startOffset.dy,
          );

          _entry.markNeedsBuild();
        },
//        onTapDown: (_) {
//          print('tapdown');
//          setState(() {
//
//            Future.delayed(Duration(milliseconds: 100)).then((_){
//              widget.onTapDown(_);
//            });
//          });
//        },
//        onTapCancel: (){
//          print('cancel');
//        },
//        onTapUp: (_) {
//          print('tapup');
////          widget.onTapUp(_);
//        },
        onHorizontalDragDown: widget.onHorizontalDragDown,
        onHorizontalDragStart: widget.onHorizontalDragStart,
        onHorizontalDragUpdate: widget.onHorizontalDragUpdate,
        onHorizontalDragEnd: widget.onHorizontalDragEnd,
        child: Opacity(
            opacity: 0,
            child: widget.feedback));
  }
}

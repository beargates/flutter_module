import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../utils/rect.dart';

const Duration _endDuration = Duration(milliseconds: 300);

class CustomDraggable extends StatefulWidget {
  final Widget feedback;
  final double opacity;
  final Function getRect;
  final GestureTapDownCallback onTapDown;
  final GestureTapUpCallback onTapUp;
  final GestureDragDownCallback onHorizontalDragDown;
  final GestureDragStartCallback onHorizontalDragStart;
  final GestureDragUpdateCallback onHorizontalDragUpdate;
  final GestureDragEndCallback onHorizontalDragEnd;
  final GestureDragDownCallback onVerticalDragDown;
  final GestureDragUpdateCallback onVerticalDragUpdate;
  final GestureDragEndCallback onVerticalDragEnd;
  final Function onEnd;

  CustomDraggable({
    @required this.feedback,
    this.opacity = 1,
    this.getRect,
    this.onTapDown,
    this.onTapUp,
    this.onHorizontalDragDown,
    this.onHorizontalDragStart,
    this.onHorizontalDragUpdate,
    this.onHorizontalDragEnd,
    this.onVerticalDragDown,
    this.onVerticalDragUpdate,
    this.onVerticalDragEnd,
    this.onEnd,
  });

  _CustomDraggableState createState() => _CustomDraggableState();
}

class _CustomDraggableState extends State<CustomDraggable>
    with SingleTickerProviderStateMixin {
  AnimationController _endController;
  Animation<Rect> endAnimation;
//  CurvedAnimation _curvedEndAnimation;
  Animation<Alignment> alignAnimation;

  Offset _delta = Offset.zero;
  double _scale = 1;
  bool _ending = false;

  static final double screenHeight =
      window.physicalSize.height / window.devicePixelRatio;

  dispose() {
    super.dispose();

    _endController?.dispose();
  }

  get dragItemRect {
    var cur = _dragItemKey.currentContext.findRenderObject();
    return getRect(cur);
  }

  _move(_) {
    _delta += _.delta;
    _scale = 1 - _delta.dy / screenHeight / 1.5;
    _scale = math.min(1, _scale);

    widget.onVerticalDragUpdate(_);
    setState(() {});
  }

  _end(_) {
    _ending = true;

    var pos = widget.getRect();
    var pos1 = dragItemRect;
    var _scale = 1 - _delta.dy / screenHeight / 1.5;
    _scale = math.min(1, _scale);
    _endController = AnimationController(
        duration: _endDuration * ((pos1.top + _delta.dy - pos.top) / 200),
        vsync: this);
    alignAnimation =
        AlignmentTween(begin: Alignment(0, 0), end: Alignment(-1, -1))
            .animate(_endController);
    endAnimation = RectTween(
        begin: Rect.fromLTWH(
          _delta.dx,
          _delta.dy,
          pos1.width * _scale,
          pos1.height * _scale,
        ),
        end: Rect.fromLTWH(
          pos.left - pos1.left,
          pos.top - pos1.top,
          pos.width,
          pos.height,
        )).animate(_endController);
    endAnimation
      ..addListener(animUpdate)
      ..addStatusListener(endAnimationStatusCallback);
//    CurveTween(curve: Curves.easeOut).animate(endAnimation);
    _endController.forward();
  }

  animUpdate() {
    setState(() {});
  }

  endAnimationStatusCallback(status) {
    if (status == AnimationStatus.completed) {
      widget.onEnd();
    }
  }

  final GlobalKey _dragItemKey = GlobalKey();

  Widget build(ctx) {
    var offset = _delta;
    var scale = _scale;
    if (_ending) {
      var rect = endAnimation?.value;
      offset = Offset(rect.left, rect.top);
      scale = rect.height / dragItemRect.height;
    }
    return GestureDetector(
        onPanUpdate: _move,
        onPanEnd: _end,
        child: RepaintBoundary(
            child: Center(
                child: Transform.translate(
                    key: _dragItemKey,
                    offset: offset,
                    child: Transform.scale(
                        alignment: alignAnimation?.value ??
                            AlignmentDirectional.center,
                        scale: scale,
                        child: widget.feedback)))));
  }
}

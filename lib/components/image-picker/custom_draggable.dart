import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';

const Duration _kBaseSettleDuration = Duration(milliseconds: 246);

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
  final GestureDragUpdateCallback onVerticalDragUpdate;
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
    this.onVerticalDragUpdate,
    this.onVerticalDragEnd,
  });

  _CustomDraggableState createState() => _CustomDraggableState();
}

class _CustomDraggableState extends State<CustomDraggable>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  double _deltaY = 0;

  static final double screenHeight =
      window.physicalSize.height / window.devicePixelRatio;

  void initState() {
    super.initState();

    _controller =
        AnimationController(duration: _kBaseSettleDuration, vsync: this)
          ..addListener(_animationChanged);
  }

  void _animationChanged() {
    setState(() {
      // The animation controller's state is our build state, and it changed already.
    });
  }

  _move(_) {
    double delta = _.primaryDelta / _height;
    _controller.value += delta;
    _deltaY += _.primaryDelta;
    widget.onVerticalDragUpdate(_);
//    print(_controller.value);
  }

  _end(_) {
    _deltaY = 0;
    widget.onVerticalDragEnd(_);
  }

  final GlobalKey _drawerKey = GlobalKey();

  double get _height {
    final RenderBox box = _drawerKey.currentContext?.findRenderObject();
    if (box != null) return box.size.height;
    return 300; // drawer not being shown currently
  }

  Widget build(ctx) {
    var _scale = 1 - _deltaY / screenHeight;
    _scale = math.min(1, _scale);
    return GestureDetector(
        onVerticalDragUpdate: _move,
        onVerticalDragEnd: _end,
        child: RepaintBoundary(
            child: Center(
                child: Align(
                    alignment: AlignmentDirectional.bottomCenter,
                    heightFactor: _controller.value * 1.5 + 1,
                    child: Transform.scale(
                        key: _drawerKey,
                        scale: _scale,
                        child: widget.feedback)))));
  }
}

import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../utils/rect.dart';

const Duration _endDuration = Duration(milliseconds: 3000);

class CustomDraggable extends StatefulWidget {
  final bool initialPage;
  final Widget feedback;
  final double opacity;
  final Function getRect;
  final Function onPanUpdate;
  final Function onAnimate;
  final Function onEnd;

  CustomDraggable({
    @required this.initialPage,
    @required this.feedback,
    this.opacity = 1,
    this.getRect,
    this.onPanUpdate,
    this.onAnimate,
    this.onEnd,
  });

  _CustomDraggableState createState() => _CustomDraggableState();
}

class _CustomDraggableState extends State<CustomDraggable>
    with TickerProviderStateMixin {
  AnimationController _endController;
  Animation<Rect> _endAnimation;

  Offset _delta = Offset.zero;
  Offset _lastDelta = Offset.zero;
  double _scale = 1;
  bool _animating = false;
  bool _canceling = false;
  List<double> _deltaYTmp = [];
  bool show = false;

  static final double screenHeight =
      window.physicalSize.height / window.devicePixelRatio;

  Rect get dragItemRect {
    var cur = _dragItemKey.currentContext.findRenderObject();
    return getRect(cur);
  }

  initState() {
    super.initState();

    _endController = AnimationController(duration: _endDuration, vsync: this);

    /// 0s延迟模拟didMount效果
    if (widget.initialPage) {
      Future.delayed(Duration(milliseconds: 1000)).then((_) {
        Rect _source = widget.getRect();
        Rect _target = dragItemRect;
        Rect source = Rect.fromLTWH(
          _source.left + _source.width / 2 - _target.width / 2 - _target.left,
          _source.top + _source.height / 2 - _target.height / 2 - _target.top,
          _target.width,
          _target.height,
        );
        _delta = Offset(source.left - _target.left, source.top - _target.top);
        _scale = math.max(
            _source.width / source.width, _source.height / source.height);

        _canceling = true;
        show = true;
        animate(source, _target.translate(_delta.dx, _delta.dy));
      });
    } else {
      show = true;
    }
  }

  dispose() {
    super.dispose();

    _endController?.dispose();
  }

  _move(_) {
    _lastDelta = _.delta;
    _delta += _lastDelta;
    _scale = 1 - _delta.dy / screenHeight / 1.5;
    _scale = math.min(1, _scale);
    _scale = math.max(0.8, _scale); // 最小不会超过0.8

    if (_lastDelta.dy < 0) {
      _deltaYTmp.add(_lastDelta.dy);
    } else {
      _deltaYTmp = [];
    }

    setState(() {});
    widget.onPanUpdate(_delta.dy);
  }

  _end(_) {
    _canceling = false;

    /// 取消动作判定
    var cancel = _deltaYTmp.length >= 3;
    if (cancel) {
      var totalDeltaY = _deltaYTmp.reduce((pre, after) => pre + after);
      cancel = cancel && totalDeltaY.abs() > 10;
    }

    Rect target;
    if (cancel) {
      target = dragItemRect;
      _canceling = true;
    } else {
      target = widget.getRect();
    }
    animate(dragItemRect, target);
  }

  animate(Rect source, Rect target) {
    _animating = true;

    var startX = _delta.dx;
    var startY = _delta.dy;
    var targetX =
        target.left + target.width / 2 - source.width / 2 - source.left;
    var targetY =
        target.top + target.height / 2 - source.height / 2 - source.top;
    _endController.reset();
    _endAnimation = RectTween(
        begin: Rect.fromLTWH(
          startX,
          startY,
          source.width * _scale,
          source.height * _scale,
        ),
        end: Rect.fromLTWH(
          targetX,
          targetY,
          target.width,
          target.height,
        )).animate(_endController);
    _endAnimation
      ..addListener(() => animUpdate((targetY - startY).abs()))
      ..addStatusListener(endAnimationStatusCallback);
    _endController.forward();
  }

  animUpdate(double total) {
    setState(() {});

    /// 下滑退出预览的流程是下滑+松手后返回图片位置动画两个过程，_canceling表示的是松手后
    /// 的过程，所以需要处理delta，以保证松手后的delta仍是增长状态
    var deltaY = _endAnimation?.value?.top ?? 0;
    if (!_canceling) {
      deltaY = _delta.dy + _endController.value * total;
    }
    widget.onPanUpdate(deltaY);
  }

  endAnimationStatusCallback(status) {
    if (status == AnimationStatus.completed) {
      if (!_canceling) {
        widget.onEnd();
      }
      _lastDelta = Offset.zero;
      _delta = Offset.zero;
      _deltaYTmp = [];
      _scale = 1;
      _animating = false;
      _canceling = false;
    }
  }

  final GlobalKey _dragItemKey = GlobalKey();

  Widget build(ctx) {
    var offset = _delta;
    var scale = _scale;
    if (_animating) {
      var rect = _endAnimation?.value;
      offset = Offset(rect.left, rect.top);
      var scaleX = rect.width / dragItemRect.width;
      var scaleY = rect.height / dragItemRect.height;
      scale = math.max(scaleX, scaleY);
    }
    return Opacity(
      opacity: show ? 1 : 0,
      child: GestureDetector(
          onPanUpdate: _move,
          onPanEnd: _end,
          child: RepaintBoundary(
              child: Center(
                  child: Transform.translate(
                      key: _dragItemKey,
                      offset: offset,
                      child: Transform.scale(
                          scale: scale, child: widget.feedback))))),
    );
  }
}

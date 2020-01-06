import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../utils/rect.dart';

const Duration _endDuration = Duration(milliseconds: 300);

class CustomDraggable extends StatefulWidget {
  final Widget feedback;
  final double opacity;
  final Function getRect;
  final Function onPanUpdate;
  final Function onAnimate;
  final Function onEnd;

  CustomDraggable({
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
  bool _ending = false;
  bool _canceling = false;
  List<double> _deltaYTmp = [];

  static final double screenHeight =
      window.physicalSize.height / window.devicePixelRatio;

  get dragItemRect {
    var cur = _dragItemKey.currentContext.findRenderObject();
    return getRect(cur);
  }

  dispose() {
    super.dispose();

    _endController?.dispose();
  }

  /// 获取四边中位移最长的一个
  double getLongestDuration(Rect source, Rect target) {
    var deltaX = source.width * (1 - _scale) / 2 + _delta.dx;
    var deltaY = source.height * (1 - _scale) / 2 + _delta.dy;
    var top = source.top + deltaY;
    var left = source.left + deltaX;
    return math.max(target.top - top, target.left - left);
  }

  _move(_) {
    _lastDelta = _.delta;
    _delta += _lastDelta;
    _scale = 1 - _delta.dy / screenHeight / 1.5;
    _scale = math.min(1, _scale);

    if (_lastDelta.dy < 0) {
      _deltaYTmp.add(_lastDelta.dy);
    } else {
      _deltaYTmp = [];
    }

    setState(() {});
    widget.onPanUpdate(_delta.dy);
  }

  _end(_) {
    _ending = true;
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
    animateTo(target);
  }

  animateTo(Rect target) {
    var source = dragItemRect;
    _endController = AnimationController(
        duration:
            _endDuration * (getLongestDuration(source, target) / 200).abs(),
        vsync: this);
    _endAnimation = RectTween(
        begin: Rect.fromLTWH(
          _delta.dx,
          _delta.dy,
          source.width * _scale,
          source.height * _scale,
        ),
        end: Rect.fromLTWH(
          target.left + target.width / 2 - source.width / 2 - source.left,
          target.top + target.height / 2 - source.height / 2 - source.top,
          target.width,
          target.height,
        )).animate(_endController);
    _endAnimation
      ..addListener(() => animUpdate(dragItemRect))
      ..addStatusListener(endAnimationStatusCallback);
    _endController.forward();
  }

  animUpdate(Rect start) {
    setState(() {});

    /// 下滑退出预览的流程是下滑+松手后返回图片位置动画两个过程，_canceling表示的是松手后
    /// 的过程，所以需要处理delta，以保证松手后的delta仍是增长状态
    var deltaY = _endAnimation?.value?.top ?? 0;
    if (!_canceling) {
      deltaY = 2 * _delta.dy - deltaY;
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
      _ending = false;
      _canceling = false;
    }
  }

  final GlobalKey _dragItemKey = GlobalKey();

  Widget build(ctx) {
    var offset = _delta;
    var scale = _scale;
    if (_ending) {
      var rect = _endAnimation?.value;
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
                        scale: scale, child: widget.feedback)))));
  }
}

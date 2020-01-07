import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:photo_manager/photo_manager.dart';

import '../../utils/rect.dart';

const Duration _endDuration = Duration(milliseconds: 300);

class CustomDraggable extends StatefulWidget {
  final bool initialPage;
  final AssetEntity img;
  final Widget feedback;
  final double opacity;
  final Function getRect;
  final Function onPanUpdate;
  final Function onAnimate;
  final Function onEnd;

  CustomDraggable({
    @required this.initialPage,
    @required this.img,
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

  Rect get originRect {
    var cur = _dragItemKey.currentContext.findRenderObject();
    return getRect(cur);
  }

  AssetEntity get img => widget.img;

  initState() {
    super.initState();

    _endController = AnimationController(duration: _endDuration, vsync: this);

    /// 0s延迟模拟didMount效果
    if (widget.initialPage) {
      Future.delayed(Duration.zero).then((_) {
        Rect _source = widget.getRect();
        _delta = _source.center - originRect.center;
        _scale = math.max(_source.width / originRect.width,
            _source.height / originRect.height);

        _canceling = true;
        show = true;

        double ratio = 1;
        if (img.width > img.height) {
          ratio = img.width / img.height;
        }
        var source = Rect.fromLTWH(
          _delta.dx,
          _delta.dy,
          originRect.width * _scale * ratio,
          originRect.height * _scale * ratio,
        );
        animate(source, originRect);
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
      target = originRect;
      _canceling = true;
    } else {
      double ratio = 1;
      if (img.width > img.height) {
        ratio = img.width / img.height;
      }

      target = widget.getRect();
      target = Rect.fromLTWH(
          target.left - target.width * (ratio - 1) / 2,
          target.top - target.height * (ratio - 1) / 2,
          target.width * ratio,
          target.height * ratio);
    }
    var source = Rect.fromLTWH(
      _delta.dx,
      _delta.dy,
      originRect.width * _scale,
      originRect.height * _scale,
    );
    animate(source, target);
  }

  /// 计算移动的开始，结束位置
  /// 接收原始数据（即显示在屏幕上的位置，大小），根据originRect计算目标位置
  animate(Rect source, Rect _target) {
    _animating = true;

    var targetX = _target.left +
        _target.width / 2 -
        originRect.width / 2 -
        originRect.left;
    var targetY = _target.top +
        _target.height / 2 -
        originRect.height / 2 -
        originRect.top;
    var target = Rect.fromLTWH(
      targetX,
      targetY,
      _target.width,
      _target.height,
    );
    _endController.reset();
    _endAnimation?.removeStatusListener(endAnimationStatusCallback);
    _endAnimation =
        RectTween(begin: source, end: target).animate(_endController);
    _endAnimation
      ..addListener(() => animUpdate((targetY - _delta.dy).abs()))
      ..addStatusListener(endAnimationStatusCallback);
    _endController.forward();
  }

  animUpdate(double total) {
    setState(() {});

    var deltaY = _endAnimation.value.top;
    /// 下滑退出预览的流程是下滑+松手后返回图片位置动画两个过程，_canceling表示的是松手后
    /// 的过程，所以需要处理delta，以保证松手后的delta仍是增长状态
    if (!_canceling) {
      deltaY = _delta.dy + _endController.value * total;
    }
    print(deltaY.abs());
    widget.onPanUpdate(deltaY.abs());
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
//      var scaleX = rect.width / originRect.width;
//      var scaleY = rect.height / originRect.height;
      offset = Offset(rect.left, rect.top);
      scale = rect.width / originRect.width;
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
                            scale: scale,
                            child:
                                SizedBox.expand(child: widget.feedback)))))));
  }
}

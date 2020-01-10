import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../image-picker/big_image.dart';

const Duration _endDuration = Duration(milliseconds: 300);

class PreviewItem extends StatefulWidget {
  final bool initialPage;
  final BigImage feedback;
  final double opacity;
  final Function getRect;
  final Function onPanUpdate;
  final Function onAnimate;
  final Function onEnd;
  final Function onScaleStatusChange;

  PreviewItem({
    @required this.initialPage,
    @required this.feedback,
    this.opacity = 1,
    this.getRect,
    this.onPanUpdate,
    this.onAnimate,
    this.onEnd,
    this.onScaleStatusChange,
  });

  _PreviewItemState createState() => _PreviewItemState();
}

class _PreviewItemState extends State<PreviewItem>
    with TickerProviderStateMixin {
  AnimationController _endController;
  Animation<Rect> _endAnimation;

  Offset _delta = Offset.zero;
  Offset _lastDelta = Offset.zero;
  double _scale = 1; // pan手势产生的缩放值
  double zoom = 1;
  bool _zooming = false;
  bool _entering = false;
  bool _animating = false;
  bool _canceling = false;
  List<double> _deltaYTmp = [];
  bool show = false;

  static final double screenWidth =
      window.physicalSize.width / window.devicePixelRatio;
  static final double screenHeight =
      window.physicalSize.height / window.devicePixelRatio;

  initState() {
    super.initState();

    _endController = AnimationController(duration: _endDuration, vsync: this);

    /// 0s延迟模拟didMount效果
    if (widget.initialPage) {
      /// 入场时，假设先有一个从中间到入场位置的位移，执行'取消'，完成入场动作
      Future.delayed(Duration.zero).then((_) {
        _delta = _targetMin.center - _targetMax.center;
        _entering = true;
        _canceling = true;
        show = true;

        animate(_targetMin, _targetMax);
      });
    } else {
      show = true;
    }
  }

  dispose() {
    super.dispose();

    _endController?.dispose();
  }

  _panUpdate(delta) {
    _lastDelta = delta;
    _delta += _lastDelta;

    if (!_zooming) {
      _scale = 1 - _delta.dy / screenHeight / 1.5;
      _scale = math.min(1, _scale);
      _scale = math.max(0.8, _scale); // 最小不会超过0.8

      /// 用于判定取消动作
      if (_lastDelta.dy < 0) {
        _deltaYTmp.add(_lastDelta.dy);
      } else {
        _deltaYTmp = [];
      }

      widget.onPanUpdate(_delta.dy);
    }

    setState(() {});
  }

  _panEnd(_) {
    if (_zooming) return;
    _canceling = false;

    /// 取消动作判定
    var cancel = _deltaYTmp.length >= 3;
    if (cancel) {
      var totalDeltaY = _deltaYTmp.reduce((pre, after) => pre + after);
      cancel = cancel && totalDeltaY.abs() > 10;
    }

    Rect target;
    if (!cancel) {
      target = widget.getRect();
    } else {
      _canceling = true;
      target = _targetMax;
    }
    var source = _targetMax.translate(_delta.dx, _delta.dy);
    source = Rect.fromLTWH(
      source.left,
      source.top,
      source.width * _scale,
      source.height * _scale,
    );
    animate(source, target);
  }

  /// 计算移动的开始，结束位置
  /// 接收原始数据（即显示在屏幕上的位置，大小），根据originRect计算目标位置
  animate(Rect source, Rect target) {
    _animating = true;
    _endController.reset();
    _endAnimation?.removeStatusListener(endAnimationStatusCallback);
    _endAnimation =
        RectTween(begin: source, end: target).animate(_endController);
    _endAnimation
      ..addListener(() => animUpdate((target.top - _delta.dy).abs()))
      ..addStatusListener(endAnimationStatusCallback);
    _endController.forward();
  }

  animUpdate(double total) {
    setState(() {});

    double deltaY = 0;
    if (_canceling) {
      deltaY = 0;
    } else {
      /// 下滑退出预览的流程是下滑+松手后返回图片位置动画两个过程，_canceling表示的是松手后
      /// 的过程，所以需要处理delta，以保证松手后的delta仍是增长状态
      deltaY = _delta.dy + _endController.value * total;
    }

    /// 入场时
    if (_entering) {
      deltaY = (1 - _endController.value) * total;
    }
    deltaY = deltaY.floor().toDouble();

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
      _entering = false;
      _animating = false;
      _canceling = false;
    }
  }

  _scaleStart() {
    widget.onScaleStatusChange(true);
  }

  _scaleUpdate(_) {
    zoom = _;
    _zooming = true;
    setState(() {});
  }

  _scaleEnd(_) {
    zoom = 1;
    _zooming = false;
    _delta = Offset.zero;
    setState(() {});
    widget.onScaleStatusChange(false);
  }

  BigImage get _img => widget.feedback;

  int get _imgWidth => widget.feedback.entity.width;

  int get _imgHeight => widget.feedback.entity.height;

  Rect get _targetMin => widget.getRect();

  Rect get _targetMax {
    var _r = math.min(screenWidth / _imgWidth, screenHeight / _imgHeight);
    var width = (_imgWidth * _r).floor().toDouble();
    var height = (_imgHeight * _r).floor().toDouble();
    return Rect.fromLTWH(
      (screenWidth - width) / 2,
      (screenHeight - height) / 2,
      width,
      height,
    );
  }

  Widget build(ctx) {
    var offset = Offset(_targetMax.left, _targetMax.top) + _delta;
    if (_animating) {
      var rect = _endAnimation.value;
      offset = Offset(rect.left, rect.top);
    }
    return Opacity(
        opacity: show ? 1 : 0,
        child: _GestureDetector(
            onPanUpdate: _panUpdate,
            onPanEnd: _panEnd,
            onScaleStart: _scaleStart,
            onScaleUpdate: _scaleUpdate,
            onScaleEnd: _scaleEnd,
            child: Container(
                width: screenWidth,
                height: screenHeight,
                color: Color.fromARGB(0, 255, 255, 255), // 有颜色才能全屏拖动，什么鬼？
                child: RepaintBoundary(
                    child: Align(
                        alignment: AlignmentDirectional.topStart,
                        child: Transform.translate(
                            offset: offset,
                            child: Transform.scale(
                                scale: zoom,
                                // todo 配合Align才能将img限制在宽高范围内
                                child: Container(
                                    // todo 有可能是targetMin
                                    width: _endAnimation?.value?.width ??
                                        _targetMax.width * _scale,
                                    height: _endAnimation?.value?.height ??
                                        _targetMax.height * _scale,
                                    child: _img))))))));
  }
}

class _GestureDetector extends StatefulWidget {
  final Widget child;
  final Function onPanUpdate;
  final Function onPanEnd;
  final Function onScaleStart;
  final Function onScaleUpdate;
  final Function onScaleEnd;

  _GestureDetector({
    this.child,
    this.onPanUpdate,
    this.onPanEnd,
    this.onScaleStart,
    this.onScaleUpdate,
    this.onScaleEnd,
  });

  __GestureDetectorState createState() => __GestureDetectorState();
}

class __GestureDetectorState extends State<_GestureDetector> {
  Widget get child => widget.child ?? Container();

  get _panUpdate => widget.onPanUpdate ?? () {};

  get _panEnd => widget.onPanEnd ?? () {};

  get _scaleStart => widget.onScaleStart ?? () {};

  get _scaleUpdate => widget.onScaleUpdate ?? () {};

  get _scaleEnd => widget.onScaleEnd ?? () {};

  bool _panning = false;
  bool _zooming = false;
  Offset _lastFocalPoint = Offset.zero;
  double _zoom = 1; // 累计缩放量，累计缩放量小于等于1时，退出缩放模式
  double _tmpZoom = 1; // 一次缩放操作最终的缩放值
  /// 手势控制器
  _start(_) {
    _lastFocalPoint = _.focalPoint;
  }

  /// 手势控制器
  _update(_) {
    // 处理缩放
    if (_.scale == 1) {
      if (!_panning) {
        _panning = true;
      }
      var delta = _.focalPoint - _lastFocalPoint;
      _panUpdate(delta);
      _lastFocalPoint = _.focalPoint;
    }
    // 处理平移
    if (!_panning && _.scale != 1) {
      if (!_zooming) {
        _scaleStart();
        _zooming = true;
      }
      _tmpZoom = _zoom * _.scale;
      _scaleUpdate(_tmpZoom);
    }
  }

  /// 手势控制器
  /// bug: end触发两次
  _end(_) {
    if (_zooming) {
      _zoom = _tmpZoom;
      if (_tmpZoom <= 1) {
        _zooming = false;
        _tmpZoom = 1;
        _zoom = 1;
        _scaleEnd(_);
      }
    }
    if (_panning) {
      _panEnd(null);
    }
    _panning = false;
    _lastFocalPoint = Offset.zero;
  }

  Widget build(BuildContext context) {
    return GestureDetector(
        onScaleStart: _start,
        onScaleUpdate: _update,
        onScaleEnd: _end,
        child: child);
  }
}

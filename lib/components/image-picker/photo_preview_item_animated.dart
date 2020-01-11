import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../image-picker/big_image.dart';

const Duration _endDuration = Duration(milliseconds: 260);

class PreviewItem extends StatefulWidget {
  final bool initialPage;
  final BigImage feedback;
  final Function getRect;
  final Function onAnimateStart;
  final Function onAnimateEnd;
  final Function onEnd;
  final Function onScaleStatusChange;

  PreviewItem({
    @required this.initialPage,
    @required this.feedback,
    this.getRect,
    this.onAnimateStart,
    this.onAnimateEnd,
    this.onEnd,
    this.onScaleStatusChange,
  });

  _PreviewItemState createState() => _PreviewItemState();
}

class _PreviewItemState extends State<PreviewItem> {
  Offset _delta = Offset.zero;
  Offset _lastDelta = Offset.zero;
  double _scale = 1; // pan手势产生的缩放值
  double zoom = 1;
  bool _zooming = false;
  bool _animating = false;
  bool _canceling = false;
  List<double> _deltaYTmp = [];
  bool show = false;

  Rect _curRect;
  bool _updating = false;
  double _opacity = 0;

  static final double screenWidth =
      window.physicalSize.width / window.devicePixelRatio;
  static final double screenHeight =
      window.physicalSize.height / window.devicePixelRatio;
  static final Widget bg = BlackBg();

  initState() {
    super.initState();

    init();
  }

  init() async {
    /// 0s延迟模拟didMount效果
    if (widget.initialPage) {
      await Future.delayed(Duration.zero);
      _canceling = true;
      animate(_targetMin, _targetMax, 0, 1);
    } else {
      _opacity = 1;
      _curRect = _targetMax;
    }
    show = true;
  }

  _panStart() {
    widget.onAnimateStart();
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

      var deltaY = _delta.dy * 8;
      deltaY = math.min(screenHeight, deltaY);
      deltaY = math.max(0, deltaY);
      _opacity = 1 - deltaY / screenHeight;
    }
    setState(() {});
  }

  _panEnd(_) {
    if (_zooming) return;
    _canceling = false;
    _updating = false;

    /// 取消动作判定
    var cancel = _deltaYTmp.length >= 3;
    if (cancel) {
      var totalDeltaY = _deltaYTmp.reduce((pre, after) => pre + after);
      cancel = cancel && totalDeltaY.abs() > 10;
    }

    Rect target;
    double tOpacity = 0;
    if (!cancel) {
      target = _targetMin;
    } else {
      _canceling = true;
      tOpacity = 1;
      target = _targetMax;
    }
    var source = _targetMax.translate(_delta.dx, _delta.dy).scale(_scale);
    target = target.translate(-_delta.dx, -_delta.dy).scale(1 / _scale);
    animate(source, target, _opacity, tOpacity);
  }

  animate(Rect source, Rect target, double sOpacity, double tOpacity) async {
    _animating = true;

    if (_curRect != source) {
      _curRect = source;
      _opacity = sOpacity;
      setState(() {});
    }

    await Future.delayed(Duration(milliseconds: 100));
    _curRect = target;
    _opacity = tOpacity;
    setState(() {});
  }

  animationEnd() {
    widget.onAnimateEnd();
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
    if (!show) {
      return Container();
    }
    return _GestureDetector(
        onPanStart: _panStart,
        onPanUpdate: _panUpdate,
        onPanEnd: _panEnd,
        onScaleStart: _scaleStart,
        onScaleUpdate: _scaleUpdate,
        onScaleEnd: _scaleEnd,
        child: Container(
            width: screenWidth,
            height: screenHeight,
            color: Color.fromARGB(0, 0, 0, 0), // 有颜色才能全屏拖动，什么鬼？
            child: RepaintBoundary(
              child: Stack(
                children: [
                  _animating
                      ? AnimatedOpacity(
                          opacity: _opacity, duration: _endDuration, child: bg)
                      : Opacity(opacity: _opacity, child: bg),
                  _curRect == null
                      ? Container()
                      : AnimatedPositioned.fromRect(
                          duration: _updating ? Duration.zero : _endDuration,
                          curve: Curves.easeOut,
                          rect: _curRect,
                          child: Transform.translate(
                              offset: _delta,
                              child: Transform.scale(
                                  scale: _scale * zoom, child: _img)),
                          onEnd: animationEnd)
                ],
              ),
            )));
  }
}

class BlackBg extends StatelessWidget {
  Widget build(_) {
    return Container(color: Colors.black);
  }
}

extension _Rect on Rect {
  Rect scale(_scale) {
    return Rect.fromLTWH(
      this.left + this.width * (1 - _scale) / 2,
      this.top + this.height * (1 - _scale) / 2,
      this.width * _scale,
      this.height * _scale,
    );
  }
}

class _GestureDetector extends StatefulWidget {
  final Widget child;
  final Function onPanStart;
  final Function onPanUpdate;
  final Function onPanEnd;
  final Function onScaleStart;
  final Function onScaleUpdate;
  final Function onScaleEnd;

  _GestureDetector({
    this.child,
    this.onPanStart,
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

  get _panStart => widget.onPanStart ?? () {};

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
    _panStart();
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

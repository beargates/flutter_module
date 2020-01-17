import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

const _duration = Duration(milliseconds: 246);
const _minScale = .8;

void fn() {}

class PreviewItem extends StatefulWidget {
  PreviewItem({
    this.tag,
    this.img,
    this.child,
    this.show = true,
    this.onWillExit,
    this.onScaleStatusChange,
    this.onPanStatusChange,
  });

  final Object tag;
  final AssetEntity img;
  final Widget child;
  final bool show;
  final Function onWillExit;
  final Function onScaleStatusChange;
  final Function onPanStatusChange;

  _PreviewItemState createState() => _PreviewItemState();
}

class _PreviewItemState extends State<PreviewItem>
    with SingleTickerProviderStateMixin {
  static final double screenWidth =
      window.physicalSize.width / window.devicePixelRatio;
  static final double screenHeight =
      window.physicalSize.height / window.devicePixelRatio;

  AnimationController _controller;

  /// 位移
  Offset _delta = Offset.zero;

  /// _scaleOrigin的临时值，每次点击屏幕（即双击屏幕前）生成，因双击回调中取不到点击的坐标
  Offset _origin = Offset.zero;

  /// 不使用_origin作为缩放中心的原因是，希望缩小的时候使用跟放大时是同一个点
  Offset _scaleOrigin = Offset.zero;
  double _scale = 1;
  double _opacity = 1;
  double _tmpZoom = 1;
  double _zoom = 1;
  bool _zooming = false;

  /// 用于判定'取消退出预览'手势
  List<double> _deltaYTmp = [];

  initState() {
    super.initState();

    _controller = AnimationController(duration: _duration, vsync: this);
  }

  _panUpdate(delta) {
    _delta += delta;

    if (!_zooming) {
      _scale = 1 - _delta.dy / screenHeight;
      _opacity = 1 - _delta.dy / 100;

      /// 用于判定取消动作
      if (delta.dy < 0) {
        _deltaYTmp.add(delta.dy);
      } else {
        _deltaYTmp = [];
      }
    }

    _update();
    widget.onPanStatusChange(true);
  }

  _panEnd(_) {
    if (_zooming) return;

    /// 取消动作判定
    var cancel = _deltaYTmp.length >= 3;
    if (cancel) {
      var totalDeltaY = _deltaYTmp.reduce((pre, after) => pre + after);
      cancel = cancel && totalDeltaY.abs() > 10;
    }

    if (cancel) {
      /// 弹回
      moveWithAnimation(_delta, Offset.zero);
      widget.onPanStatusChange(false);
    } else {
      widget.onWillExit();
    }
  }

  moveWithAnimation(Offset from, Offset to) {
    _animate(
      Tween(begin: from, end: to),
      onUpdate: (AnimationController controller, Animation animation) {
        _delta = animation.value;
        _scale = _scale + controller.value * (1 - _scale);
        _update();
      },
    );
  }

  zoomWithAnimation(double from, double to, {Offset offset}) {
    Animation moveAnimation;
    if (offset != null) {
      Animatable<Offset> animatable =
          Tween(begin: _delta, end: _delta + offset);
      moveAnimation = animatable.animate(_controller);
    }

    _animate(
      Tween(begin: from, end: to),
      onUpdate: (AnimationController controller, Animation animation) {
        _zoom = animation.value;
        if (moveAnimation != null) {
          _delta = moveAnimation.value;
        }
        _update();
      },
    );
  }

  _animate(Animatable _animatable, {onUpdate = fn}) {
    _controller.reset();
    Animation _animation = _animatable.animate(_controller);
    _animation.addListener(() => onUpdate(_controller, _animation));
    _controller.forward();
  }

  _scaleStart() {
    _zooming = true;
    widget.onScaleStatusChange(_zooming);
  }

  _scaleUpdate(_) {
    _zoom = (_tmpZoom * _.scale).clamp(double.negativeInfinity, _maxScale);
    _update();
  }

  _scaleEnd(_) {
    _tmpZoom = _zoom;
    if (_tmpZoom <= 1) {
      _zooming = false;
      _tmpZoom = 1;
      _delta = Offset.zero;
      zoomWithAnimation(_zoom, 1);
      widget.onScaleStatusChange(_zooming);
    }
  }

  _doubleTap() {
    if (_zooming) {
      zoomWithAnimation(_zoom, 1, offset: -_delta);
    } else {
      _tmpZoom = _maxScaleWhenDoubleTap;

      /// 改变锚点位置为图片的center（默认左上角）
      _scaleOrigin = _origin - _displaySize.toOffset() / 2;

      double from = 1;
      double to = _maxScaleWhenDoubleTap;
      var scale = to / from;

      /// 缩放方向
      var symbolX = _scaleOrigin.dx / _scaleOrigin.dx.abs();
      var symbolY = _scaleOrigin.dy / _scaleOrigin.dy.abs();

      var displaySize =
          Offset(_displaySize.width * -symbolX, _displaySize.height * -symbolY);

      /// 将点击位置最近的顶点移至中心
      Offset offset = displaySize * scale / 2;

      /// 位移
      var delta = offset.abs() - (_scaleOrigin * scale).abs();
      // 修正
      delta = Offset(
        delta.dx.clamp(screenWidth / 2, double.infinity),
        delta.dy.clamp(screenHeight / 2, double.infinity),
      );
      delta = Offset(delta.dx * -symbolX, delta.dy * -symbolY);

      offset = offset - delta;

      zoomWithAnimation(from, to, offset: offset);
    }
    _zooming = !_zooming;
    widget.onScaleStatusChange(_zooming);
  }

  checkPointerDownPos(_) {
    _origin = _.localPosition;
    _update();
  }

  _update() {
    setState(() {});
  }

  int get _imgWidth => widget.img.width;

  int get _imgHeight => widget.img.height;

  /// 缩放的极限
  double get _maxScale => _imgWidth / _displaySize.width;

  /// 双击时缩放到屏幕高度的1.1倍
  double get _maxScaleWhenDoubleTap => _imgHeight / screenHeight * 1.1;

  Size get _displaySize {
    var _r = math.min(screenWidth / _imgWidth, screenHeight / _imgHeight);
    var width = (_imgWidth * _r).floor().toDouble();
    var height = (_imgHeight * _r).floor().toDouble();
    return Size(width, height);
  }

  Widget get child => widget.tag != null
      ? Hero(
          tag: widget.tag,
          // 控制飞行路径
          createRectTween: (Rect begin, Rect end) =>
              RectTween(begin: begin, end: end),
          child: widget.child,
        )
      : widget.child;

  Widget build(BuildContext context) {
    var alpha = (_opacity.clamp(0, 1) * 255).toInt();
    var delta = _delta;
    var scale = _scale.clamp(_minScale, 1).toDouble();
    var zoom = _zoom.clamp(double.negativeInfinity, _maxScale);
    return _GestureDetector(
//        onPanStart: _panStart,
        onPanUpdate: _panUpdate,
        onPanEnd: _panEnd,
        onScaleStart: _scaleStart,
        onScaleUpdate: _scaleUpdate,
        onScaleEnd: _scaleEnd,
        onDoubleTap: _doubleTap,
        child: Container(
          color: Color.fromARGB(alpha, 0, 0, 0),
          child: Center(
            child: Transform.translate(
              offset: delta,
              child: Transform.scale(
                scale: scale * zoom,
                child: Listener(
                  onPointerDown: checkPointerDownPos,
                  child: Container(
                      width: _displaySize.width,
                      height: _displaySize.height,
                      child: child),
                ),
              ),
            ),
          ),
        ));
  }
}

extension _Size on Size {
  Offset toOffset() {
    return Offset(this.width, this.height);
  }
}

extension _Offset on Offset {
  Offset abs() {
    return Offset(this.dx.abs(), this.dy.abs());
  }

  Offset operator *(Offset offset) {
    return Offset(this.dx * offset.dx, this.dy * offset.dy);
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
  final Function onDoubleTap;

  _GestureDetector({
    this.child,
    this.onPanStart = fn,
    this.onPanUpdate = fn,
    this.onPanEnd = fn,
    this.onScaleStart = fn,
    this.onScaleUpdate = fn,
    this.onScaleEnd = fn,
    this.onDoubleTap = fn,
  });

  __GestureDetectorState createState() => __GestureDetectorState();
}

class __GestureDetectorState extends State<_GestureDetector> {
  Widget get child => widget.child ?? Container();

  get _panStart => widget.onPanStart;

  get _panUpdate => widget.onPanUpdate;

  get _panEnd => widget.onPanEnd;

  get _scaleStart => widget.onScaleStart;

  get _scaleUpdate => widget.onScaleUpdate;

  get _scaleEnd => widget.onScaleEnd;

  get _doubleTap => widget.onDoubleTap;

  bool _panStarted = false;
  bool _panning = false;
  bool _zooming = false;
  Offset _lastFocalPoint = Offset.zero;

  /// 手势控制器
  _start(_) {
    _lastFocalPoint = _.focalPoint;
  }

  /// 手势控制器
  _update(_) {
    /// 平移
    if (_.scale == 1) {
      if (!_panning) {
        _panning = true;
      }
      if (!_panStarted) {
        _panStarted = true;
        _panStart();
      } else {
        var delta = _.focalPoint - _lastFocalPoint;
        _panUpdate(delta);
      }
      _lastFocalPoint = _.focalPoint;
    }

    /// 缩放
    if (!_panning && _.scale != 1) {
      if (!_zooming) {
        _scaleStart();
        _zooming = true;
      } else {
        _scaleUpdate(_);
      }
    }
  }

  /// 手势控制器
  /// bug: end触发两次
  _end(_) {
    if (_zooming) {
      _scaleEnd(_);
    }
    if (_panning) {
      _panEnd(null);
    }
    _panStarted = false;
    _zooming = false;
    _panning = false;
    _lastFocalPoint = Offset.zero;
  }

  Widget build(BuildContext context) {
    return GestureDetector(
        onDoubleTap: _doubleTap,
        onScaleStart: _start,
        onScaleUpdate: _update,
        onScaleEnd: _end,
        child: child);
  }
}

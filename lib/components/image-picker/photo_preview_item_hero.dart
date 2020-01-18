import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

const _duration = Duration(milliseconds: 246);
const _minScale = .8;

void fn() {}

void animateCallback(AnimationController c, Animation a) {}

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

/// todo 动画过程中，不处理手势
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

  /// 计算图片移动的范围，缩放后该值发生变化
  Offset clampArea = Offset.zero;

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
    } else {
      // 修正
      _delta = Offset(
        _delta.dx.clamp(-clampArea.dx, clampArea.dx),
        _delta.dy.clamp(-clampArea.dy, clampArea.dy),
      );
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
      onUpdate: (AnimationController c, Animation a) {
        _zoom = a.value.clamp(0, _maxScale);
        _delta = moveAnimation?.value ?? _delta;
        _update();
      },
      onComplete: (AnimationController c, Animation a) {
        _handleZoomUpdate(a.value);
      },
    );
  }

  _animate(Animatable _animatable,
      {onUpdate = animateCallback, onComplete = animateCallback}) {
    _controller.reset();
    Animation _animation = _animatable.animate(_controller);
    var updater = () => onUpdate(_controller, _animation);
    var statusChangeUpdater;
    statusChangeUpdater = (status) {
      if (status == AnimationStatus.completed) {
        onComplete(_controller, _animation);

        _animation.removeListener(updater);
        _animation.removeStatusListener(statusChangeUpdater);
      }
    };
    _animation.addListener(updater);
    _animation.addStatusListener(statusChangeUpdater);
    _controller.forward();
  }

  _scaleStart() {
    _zooming = true;
    widget.onScaleStatusChange(_zooming);
  }

  _scaleUpdate(_) {
    _zoom = (_tmpZoom * _.scale).clamp(0, _maxScale);
    _update();
    _handleZoomUpdate(_zoom);
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
      /// 缩小
      _tmpZoom = 1;
      zoomWithAnimation(_zoom, 1, offset: -_delta);
    } else {
      /// 放大
      _tmpZoom = _maxScaleWhenDoubleTap;

      /// 两个思路
      /// 1。屏幕不动，移动图片
      /// 2。图片不动，移动屏幕（镜头）
      /// 改变锚点位置为图片的center（默认左上角）
      _scaleOrigin = _origin - _displaySize.toOffset() / 2;

      double from = 1;
      double to = _maxScaleWhenDoubleTap;
      var scale = to / from;

      /// 缩放方向
      var symbolX = _scaleOrigin.dx / _scaleOrigin.dx.abs();
      var symbolY = _scaleOrigin.dy / _scaleOrigin.dy.abs();

      var displaySize =
          _displaySize.toOffset().addDirection(-symbolX, -symbolY);

      /// 将点击位置最近的顶点移至中心
      Offset offset = displaySize * scale / 2;

      /// 位移
      var delta = offset.abs() - (_scaleOrigin * scale).abs();
      // 修正
      delta = Offset(
        delta.dx.clamp(screenWidth / 2, double.infinity),
        delta.dy.clamp(screenHeight / 2, double.infinity),
      );
      delta = delta.addDirection(-symbolX, -symbolY);

      offset = offset - delta;

//      /// 从镜头移动的视角，把屏幕当成镜头
//      /// 左上角移至屏幕center需要的位移
//      Offset a = _displaySize.toOffset() * scale / 2;
//
//      /// 点击点距离左上角的offset
//      Offset b = _origin * scale;
//
//      /// 点击点移至屏幕center需要的位移
//      offset = a - b;
//
//      /// 修正
//      offset = offset.clamp(
//        Offset(screenWidth / 2, screenHeight / 2),
//        a - Offset(screenWidth / 2, screenHeight / 2),
//      );
//      offset = offset.addDirection(-symbolX, -symbolY);

      zoomWithAnimation(from, to, offset: offset);
    }
    _zooming = !_zooming;
    widget.onScaleStatusChange(_zooming);
  }

  _handleZoomUpdate(double zoom) {
    clampArea = getClampArea(zoom);
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
  double get _maxScale => (_imgWidth / _displaySize.width)
      .clamp(_maxScaleWhenDoubleTap, double.infinity);

  /// 双击时缩放到屏幕高度的1.1倍
  double get _maxScaleWhenDoubleTap => screenHeight * 1.1 / _displaySize.height;

  Size get _displaySize {
    var _r = math.min(screenWidth / _imgWidth, screenHeight / _imgHeight);
    var width = (_imgWidth * _r).floor().toDouble();
    var height = (_imgHeight * _r).floor().toDouble();
    return Size(width, height);
  }

  Size get screenSize => Size(screenWidth, screenHeight);

  Widget get child => widget.tag != null
      ? Hero(
          tag: widget.tag,
          // 控制飞行路径
          createRectTween: (Rect begin, Rect end) =>
              RectTween(begin: begin, end: end),
          child: widget.child,
        )
      : widget.child;

  /// 根据当前缩放值计算_delta的活动范围
  /// 比如当前返回（516.8, 31）则表示活动区域为
  /// （516.8, 31）---（-516.8, 31）
  ///      ｜       |        ｜
  ///      ｜----（0, 0）----｜
  ///      ｜       |       ｜
  /// （516.8, -31）---（-516.8, -31）
  Offset getClampArea(double scale) {
    var area = (_displaySize.toOffset() * scale - screenSize.toOffset()) / 2;
    /// 不能为负，为负说明图片放大尺寸没有达到屏幕尺寸，也就不能有该方向上的位移
    return area.clamp(Offset.zero, Offset.infinite);
  }

  Widget build(BuildContext context) {
    var alpha = (_opacity.clamp(0, 1) * 255).toInt();
    var delta = _delta;
    var scale = _scale.clamp(_minScale, 1).toDouble();
    var zoom = _zoom;
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

  Offset clamp(Offset min, Offset max) {
    return Offset(
      this.dx.clamp(min.dx, max.dx),
      this.dy.clamp(min.dy, max.dy),
    );
  }

  /// 变成向量
  /// positiveX,positiveY通常是+1或者-1
  Offset addDirection(double positiveX, double positiveY) {
    return Offset(this.dx * positiveX, this.dy * positiveY);
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

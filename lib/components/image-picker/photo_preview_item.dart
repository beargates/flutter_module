import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../image-picker/big_image.dart';

const Duration _endDuration = Duration(milliseconds: 30000);

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

  static Rect originRect = Rect.fromLTWH(0, 0, screenWidth, screenHeight);

  initState() {
    super.initState();

    _endController = AnimationController(duration: _endDuration, vsync: this);

    /// 0s延迟模拟didMount效果
    if (widget.initialPage) {
      /// 入场时，假设先有一个从中间到入场位置的位移，执行'取消'，完成入场动作
      Future.delayed(Duration.zero).then((_) {
        Rect _source = widget.getRect();
        _delta = _source.center - originRect.center;
        _scale = math.max(
          _source.width / originRect.width,
          _source.height / originRect.height,
        );

        _entering = true;
        _canceling = true;
        show = true;

        double ratio = 1;
        if (_imgWidth > _imgHeight) {
          ratio = _imgWidth / _imgHeight;
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
    if (cancel) {
      target = originRect;
      _canceling = true;
    } else {

      double ratio = 1;
      if (_imgWidth > _imgHeight) {
        ratio = _imgWidth / _imgHeight;
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
    if (!_entering) {
      deltaY = math.max(0, deltaY);
    }
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

  Widget build(ctx) {
    var offset = _delta;
    var scale = _scale;
    double widthFactor = 1;
    double heightFactor = 1;
    if (_animating) {
      var rect = _endAnimation?.value;
      offset = Offset(rect.left, rect.top);
      scale = rect.width / originRect.width;
//      widthFactor = _imgWidth > _imgHeight ? scale : 1;
//      heightFactor = _imgWidth < _imgHeight ? scale : 1;
    }
    print(scale);
//    debugPrint('${_img.entity.width}, ${_img.entity.height}');
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
                    child: Center(
                        child: Transform.translate(
                            offset: offset,
                            child: Transform.scale(
                                scale: scale * zoom,
                                child: ClipRect(
                                    child: Align(
                                        widthFactor: widthFactor,
                                        heightFactor: heightFactor,
                                        child: _img)))))))));
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

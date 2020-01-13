import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class PreviewItem extends StatefulWidget {
  PreviewItem({
    this.tag,
    this.img,
    this.child,
    this.show = true,
    this.onWillExit,
    this.onScaleStatusChange,
  });

  final Object tag;
  final AssetEntity img;
  final Widget child;
  final bool show;
  final Function onWillExit;
  final Function onScaleStatusChange;

  _PreviewItemState createState() => _PreviewItemState();
}

class _PreviewItemState extends State<PreviewItem> {
  static final double screenWidth =
      window.physicalSize.width / window.devicePixelRatio;
  static final double screenHeight =
      window.physicalSize.height / window.devicePixelRatio;

  Offset _delta = Offset.zero;
  double _scale = 1;
  double _opacity = 1;
  double zoom = 1;
  bool _zooming = false;
  List<double> _deltaYTmp = [];

  _panUpdate(delta) {
    _delta += delta;

    if (!_zooming) {
      _scale = 1 - _delta.dy / (screenHeight * .3);
      _opacity = 1 - _delta.dy / 100;

      /// 用于判定取消动作
      if (delta.dy < 0) {
        _deltaYTmp.add(delta.dy);
      } else {
        _deltaYTmp = [];
      }
    }

    setState(() {});
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
      _delta = Offset.zero;
      setState(() {});
    } else {
      widget.onWillExit();
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
    // todo
    setState(() {});
    widget.onScaleStatusChange(false);
  }

  int get _imgWidth => widget.img.width;

  int get _imgHeight => widget.img.height;

  Size get _displaySize {
    var _r = math.min(screenWidth / _imgWidth, screenHeight / _imgHeight);
    var width = (_imgWidth * _r).floor().toDouble();
    var height = (_imgHeight * _r).floor().toDouble();
    return Size(width, height);
  }

  Widget get child => widget.tag != null
      ? Hero(tag: widget.tag, child: widget.child)
      : widget.child;

  /// todo hero动画完成后有一次闪动
  Widget build(BuildContext context) {
    var alpha = (_opacity.clamp(0, 1) * 255).toInt();
    var delta = _delta;
    var scale = _scale.clamp(.8, 1).toDouble();
    return _GestureDetector(
//        onPanStart: _panStart,
        onPanUpdate: _panUpdate,
        onPanEnd: _panEnd,
        onScaleStart: _scaleStart,
        onScaleUpdate: _scaleUpdate,
        onScaleEnd: _scaleEnd,
        child: Container(
          width: screenWidth,
          color: Color.fromARGB(alpha, 0, 0, 0),
          child: Center(
            child: Transform.translate(
              offset: delta,
              child: Transform.scale(
                scale: scale * zoom,
                child: Container(
                    width: _displaySize.width,
                    height: _displaySize.height,
                    child: child),
              ),
            ),
          ),
        ));
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

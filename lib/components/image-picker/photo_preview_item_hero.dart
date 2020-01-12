import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class PreviewItem extends StatefulWidget {
  final Object tag;
  final AssetEntity img;
  final Widget child;
  final bool show;
  final Function onWillExit;

  PreviewItem(
      {this.tag, this.img, this.child, this.show = true, this.onWillExit});

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

  _move(_) {
    _delta += _.delta;
    _scale = 1 - _delta.dy / (screenHeight * .2);
    _opacity = 1 - _delta.dy / 100;

    setState(() {});
  }

  _end(_) {
    widget.onWillExit();
    Navigator.of(context).pop();
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

  Widget build(BuildContext context) {
    var alpha = (_opacity.clamp(0, 1) * 255).toInt();
    var delta = _delta;
    var scale = _scale.clamp(.8, 1).toDouble();
    return GestureDetector(
        onPanUpdate: _move,
        onPanEnd: _end,
        child: Container(
          width: screenWidth,
          color: Color.fromARGB(alpha, 0, 0, 0),
          child: Center(
            child: Transform.translate(
              offset: delta,
              child: Transform.scale(
                scale: scale,
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

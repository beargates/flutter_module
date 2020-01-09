import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../image-picker/big_image.dart';
import '../image-picker/photo_preview_item.dart';

class PhotoPreview extends StatefulWidget {
  final List<AssetEntity> list;
  final int initialPage;
  final exitPreview;
  final Function getRect;

  PhotoPreview(
      {@required this.list,
      this.initialPage = 0,
      this.exitPreview,
      this.getRect});

  _PhotoPreviewState createState() => _PhotoPreviewState();
}

class _PhotoPreviewState extends State<PhotoPreview> {
  bool showPreview = false;
  bool dragging = false;
  bool showLayer = false;
  bool _scaling = false; // 缩放时禁用page的滚动

  double pageViewHeight;

  /// 屏幕宽度（or MediaQuery.of(context).size.width）
  static final double screenWidth =
      window.physicalSize.width / window.devicePixelRatio;
  static final double screenHeight =
      window.physicalSize.height / window.devicePixelRatio;
  PageController _pageController;
  List<BigImage> _list;
  OverlayEntry overlayEntry;
  bool horizontalScrolling;
  double opacity = 0.5;
  double _deltaY;
  int _index;

  initState() {
    super.initState();

    horizontalScrolling = false;
    _list = widget.list.map((v) {
      return BigImage(
          entity: v,
          maxWidth: screenWidth.floor(),
          maxHeight: screenHeight.floor());
    }).toList();
    _pageController = PageController(
        initialPage: widget.initialPage, viewportFraction: 0.9999);
    _index = widget.initialPage;
  }

  void dispose() {
    super.dispose();
    _pageController?.dispose();
  }

  toggleLayer() {
    setState(() {
      showLayer = !showLayer;
    });
  }

  Widget previewItem(ctx, index) {
    var child = _list[index];
    return PreviewItem(
        initialPage: widget.initialPage == index,
        feedback: child,
        getRect: () {
          return widget.getRect(_index);
        },
        onScaleStatusChange: (scaling) {
          _scaling = scaling;
          setState(() {});
        },
        onPanUpdate: (_) {
          _deltaY = _.toDouble();
          setState(() {});
        },
        onEnd: () {
          _deltaY = null;
          widget.exitPreview();
        });
  }

  Widget build(BuildContext context) {
    double alpha = 0;
    if (_deltaY != null) {
      var validDis = math.max(0, _deltaY);
      alpha = (1 - validDis / screenHeight * 5);
      alpha = math.max(0, alpha);
    }

    return Stack(
      children: [
        Container(color: Color.fromARGB((alpha * 255).toInt(), 0, 0, 0)),
        PageView.builder(
            physics: _scaling ? NeverScrollableScrollPhysics() : null,
            controller: _pageController,
            onPageChanged: (_) {
              _index = _;
            },
            itemBuilder: previewItem,
            itemCount: widget.list.length,
            dragStartBehavior: DragStartBehavior.start)
      ],
    );
  }
}

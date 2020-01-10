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
    _list = widget.list
        .map((v) => BigImage(
            entity: v,
            maxWidth: screenWidth.floor(),
            maxHeight: screenHeight.floor()))
        .toList();
    _pageController = PageController(
        initialPage: widget.initialPage, viewportFraction: 0.9999);
    _index = widget.initialPage;
  }

  void dispose() {
    super.dispose();
    _pageController?.dispose();
  }

  Widget previewItem(ctx, index) {
    var child = _list[index];
    return PreviewItem(
        initialPage: widget.initialPage == index,
        feedback: child,
        getRect: () => widget.getRect(_index),
        onScaleStatusChange: (scaling) {
          _scaling = scaling;
          setState(() {});
        },
        onPanUpdate: (_) {
          _deltaY = _?.toDouble();

          double alpha = 0;
          if (_deltaY != null) {
            alpha = 1 - _deltaY / screenHeight;
            alpha = math.min(1, alpha);
          }
          _bgKey.currentState.setAlpha(alpha);
        },
        onEnd: () {
          _deltaY = null;
          widget.exitPreview();
        });
  }

  /// 不指定范型，访问不到方法（编译不通过）
  GlobalKey<BlackBgState> _bgKey = GlobalKey();

  Widget build(BuildContext context) {
    return Stack(
      children: [
        BlackBg(key: _bgKey),
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

class BlackBg extends StatefulWidget {
  BlackBg({Key key}) : super(key: key);

  BlackBgState createState() => BlackBgState(key);
}

class BlackBgState extends State<BlackBg> {
  double _alpha = 0;

  BlackBgState(setAlpha);

  void setAlpha(double alpha) {
    _alpha = alpha;
    setState(() {});
  }

  Widget build(BuildContext context) {
    return Container(color: Color.fromARGB((_alpha * 255).toInt(), 0, 0, 0));
  }
}

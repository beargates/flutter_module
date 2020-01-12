import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../image-picker/big_image.dart';
import '../image-picker/photo_preview_item_hero.dart';

class PhotoPreview extends StatefulWidget {
  final List<AssetEntity> list;
  final int initialPage;
  final List<Object> tags;
  final Function onWillExit; // 页面即将退出
  final Function onExit; // 页面已退出（hero动画已结束）

  PhotoPreview({
    @required this.list,
    this.initialPage = 0,
    this.tags,
    this.onWillExit,
    this.onExit,
  });

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

  initState() {
    super.initState();

    horizontalScrolling = false;
    _list = widget.list
        .map((v) => BigImage(
            entity: v,
            maxWidth: screenWidth.floor(),
            maxHeight: screenHeight.floor()))
        .toList();
    _pageController = PageController(initialPage: widget.initialPage);
  }

  void dispose() {
    super.dispose();
    _pageController?.dispose();
  }

  void deactivate() {
    super.deactivate();

    widget.onExit();
  }

  Widget previewItem(ctx, index) {
    var child = _list[index];
    return PreviewItem(
      tag: widget.tags[index],
      img: widget.list[index],
      child: child,
      onWillExit: () => widget.onWillExit(index),
    );
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

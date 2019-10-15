//import 'dart:async';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../image-picker/custom_draggable.dart';

class PhotoPreview extends StatefulWidget {
  final List<AssetEntity> list;
  final int initialPage;
  final exitPreview;

  PhotoPreview({@required this.list, this.initialPage = 0, this.exitPreview});

  _PhotoPreviewState createState() => _PhotoPreviewState();
}

class _PhotoPreviewState extends State<PhotoPreview> {
  bool showPreview = false;
  bool dragging = false;
  bool showLayer = false;

//  static final GlobalKey pageViewKey = GlobalKey();
  double pageViewHeight;

  /// 屏幕宽度（or MediaQuery.of(context).size.width）
  static final double screenWidth =
      window.physicalSize.width / window.devicePixelRatio;
  PageController _pageController;
  int _index;
  OverlayEntry overlayEntry;
  bool horizontalScrolling;
  double opacity = 0.5;
//  DragStartDetails _start;
//  Offset _offset;

//  GlobalKey targetKey = GlobalKey();

  initState() {
    super.initState();

    horizontalScrolling = false;
    _index = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);
//    _pageController.addListener(() {
//      print('h-scrolling');
//      if (!horizontalScrolling) {
//        setState(() {
//          horizontalScrolling = true;
//        });
//      }
//    });
  }

  void dispose() {
    super.dispose();
    _pageController?.dispose();
  }

  void startDragging() {
//    pageViewHeight = targetKey.currentContext.size.height;
//    var renderObject = targetKey.currentContext.findRenderObject();
//    var context = RenderAbstractViewport.of(renderObject);
//    var top = context.getOffsetToReveal(renderObject, 0);
  }

  toggleLayer() {
    setState(() {
      showLayer = !showLayer;
    });
  }

  Widget previewCustomDragItem(ctx, index) {
    var child = BigImage(entity: widget.list[index]);
    if (horizontalScrolling) {
      return child;
    }
    return CustomDraggable(
      feedback: child,
      opacity: _index != index ? 0 : 1);
  }

  Widget previewItem(ctx, index) {
    var target = BigImage(entity: widget.list[index]);
    var feedback =
        Container(width: screenWidth, height: 813.0 - 56, child: target);
    return Draggable(
        affinity: Axis.vertical,
        child: target,
        childWhenDragging: Container(),
        feedback: feedback,
        onDragStarted: startDragging,
        onDragEnd: (_) {
          widget.exitPreview(_);
        });
  }

  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: PageView.builder(
//          key: pageViewKey,
          controller: _pageController,
          onPageChanged: (_) {
            _index = _;
          },
          itemBuilder: previewItem,
          itemCount: widget.list.length,
          dragStartBehavior: DragStartBehavior.start),
    );
  }
}

class BigImage extends StatefulWidget {
  final AssetEntity entity;

  BigImage({Key key, this.entity}) : super(key: key);

  _BigImageState createState() => _BigImageState();
}

class _BigImageState extends State<BigImage>
    with AutomaticKeepAliveClientMixin {
  get wantKeepAlive => true;

  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: widget.entity.fullData,
      builder: (ctx, snapshot) {
        var data = snapshot.data;
        if (snapshot.connectionState == ConnectionState.done && data != null) {
          return Image.memory(data, fit: BoxFit.contain);
        }
        return Container();
      },
    );
  }
}

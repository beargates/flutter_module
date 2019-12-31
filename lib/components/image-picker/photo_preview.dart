//import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;

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
  static final double screenHeight =
      window.physicalSize.height / window.devicePixelRatio;
  PageController _pageController;
  int _index;
  List<BigImage> _list;
  OverlayEntry overlayEntry;
  bool horizontalScrolling;
  double opacity = 0.5;
  double _deltaY = 0;

//  DragStartDetails _start;
//  Offset _offset;

//  GlobalKey targetKey = GlobalKey();

  initState() {
    super.initState();

    horizontalScrolling = false;
    _index = widget.initialPage;
    _list = widget.list.map((v) {
      var index = widget.list.indexOf(v);
      return BigImage(entity: widget.list[index]);
    }).toList();
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
    var child = _list[index];
    return CustomDraggable(
        feedback: child,
        onVerticalDragUpdate: (_) {
          _deltaY += _.primaryDelta;
          setState(() {});
        },
        onVerticalDragEnd: (_) {
          _deltaY = 0;
          widget.exitPreview(_);
        });
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
    var validDis = math.max(0, _deltaY);
    var alpha = (1 - validDis / screenHeight * 5);
    alpha = math.max(0, alpha);
    return Stack(
      children: [
        Container(color: Color.fromARGB((alpha * 255).toInt(), 0, 0, 0)),
        PageView.builder(
//          key: pageViewKey,
            controller: _pageController,
            onPageChanged: (_) {
              _index = _;
            },
            itemBuilder: previewCustomDragItem,
            itemCount: widget.list.length,
            dragStartBehavior: DragStartBehavior.start)
      ],
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

import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:photo_manager/photo_manager.dart';

class PhotoLibrary extends StatefulWidget {
  _PhotoLibraryState createState() => _PhotoLibraryState();
}

class _PhotoLibraryState extends State<PhotoLibrary> {
  List<AssetEntity> list;
  Future _thumbList;
  bool showPreview = false;
  Offset startOffset;
  Offset _offset = Offset(0, 0);
  StreamController<int> pageChangeController = StreamController();

  Stream<int> get pageStream => pageChangeController.stream;
  PageController _pageController;
  int _index = 0;

  initState() {
    super.initState();

    pageChangeController.add(0);
    _pageController =
        PageController(initialPage: _index, viewportFraction: 0.9999);
    init();
  }

  void dispose() {
    super.dispose();
    pageChangeController?.close();
    _pageController?.dispose();
  }

  void init() async {
    var paths = await PhotoManager.getAssetPathList();
    list = await paths.elementAt(1)?.assetList;
    _thumbList = Future.wait(list.map((v) => v.thumbData));
    setState(() {});
  }

  /// 打开预览
  void enterPreview(int index) {
    _index = index;
    setState(() {
      showPreview = true;
      _pageController =
          PageController(initialPage: index, viewportFraction: 0.9999);
    });
  }

  /// 退出预览
  void exitPreview(_) {
    setState(() {
      showPreview = false;
      _offset = Offset(0, 0);
    });
  }

  Widget previewItem(ctx, index) {
    return GestureDetector(
        onPanStart: (e) {
          startOffset = e.globalPosition;
        },
        onPanUpdate: (e) {
          _offset = Offset(
            e.globalPosition.dx - startOffset.dx,
            e.globalPosition.dy - startOffset.dy,
          );
          setState(() {});
        },
        onPanEnd: exitPreview,
        child: Transform.translate(
            offset: _index == index ? _offset : Offset(0, 0),
            child: BigImage(entity: list[index])));
  }

  Widget preview() {
    return Container(
        color: Colors.black,
        child: PageView.builder(
            controller: _pageController,
            onPageChanged: (_) {
              _index = _;
              pageChangeController.add(_);
            },
            itemBuilder: previewItem,
            itemCount: list.length));
  }

  Widget build(BuildContext context) {
    if ((list?.length ?? 0) == 0) {
      return Container();
    }
    return FutureBuilder(
        future: _thumbList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: GridView.count(
                        crossAxisCount: 4,
                        children: List.from(snapshot.data.map((_) => Container(
                            padding: EdgeInsets.all(4),
                            child: GestureDetector(
                                onTap: () {
                                  var index = snapshot.data.indexOf(_);
                                  enterPreview(index);
                                },
                                child: Image.memory(_, fit: BoxFit.cover))))))),
                Visibility(visible: showPreview, child: preview())
              ],
            );
          }
          return Container();
        });
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

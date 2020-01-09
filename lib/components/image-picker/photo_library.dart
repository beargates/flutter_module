import 'dart:async';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../image-picker/photo_preview.dart';
import '../../utils/rect.dart';

class PhotoLibrary extends StatefulWidget {
  _PhotoLibraryState createState() => _PhotoLibraryState();
}

class _PhotoLibraryState extends State<PhotoLibrary> {
  List<AssetEntity> list;
  List<GlobalKey> _keys;
  Future _thumbList;
  bool showPreview = false;
  int index;
  int hideIndex;

  OverlayState _state;
  OverlayEntry _entry;

  initState() {
    super.initState();
    init();
  }

  void init() async {
    var paths = await PhotoManager.getAssetPathList();
    list = await paths.elementAt(0)?.assetList;
    _keys = list.map((_) => GlobalKey()).toList();
    _thumbList = Future.wait(list.map((v) => v.thumbData));
    setState(() {});
  }

  /// 打开预览
  void enterPreview(i) {
    index = i;
    showPreview = true;
    _state = Overlay.of(context);
    _entry = OverlayEntry(
        builder: (_) => PhotoPreview(
              list: list,
              initialPage: index,
              exitPreview: exitPreview,
              getRect: getCellRect,
            ));
    _state.insert(_entry);
    Future.delayed(Duration(milliseconds: 600)).then((_) {
      if (showPreview) {
        hideIndex = i;
        setState(() {});
      }
    });
  }

  /// 退出预览
  void exitPreview() {
    index = null;
    hideIndex = null;
    showPreview = false;
    _entry.remove();
    setState(() {});
  }

  Rect getCellRect(int index) {
    assert(index >= 0 && index <= list.length - 1);
    var renderObject = _keys[index].currentContext.findRenderObject();
    return getRect(renderObject);
  }

  Widget build(BuildContext context) {
    if ((list?.length ?? 0) == 0) {
      return Container();
    }
    return FutureBuilder(
        future: _thumbList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Container(
                padding: EdgeInsets.symmetric(horizontal: 1),
                child: GridView.count(
                    crossAxisCount: 4,
                    children: List.from(snapshot.data.map((_) => Opacity(
                        opacity: snapshot.data.indexOf(_) == hideIndex ? 0 : 1,
                        child: Container(
                            padding: EdgeInsets.all(1),
                            child: GestureDetector(
                                onTap: () {
                                  var index = snapshot.data.indexOf(_);
                                  enterPreview(index);
                                },
                                child: Image.memory(_,
                                    key: _keys[snapshot.data.indexOf(_)],
                                    fit: BoxFit.cover))))))));
          }
          return Container();
        });
  }
}

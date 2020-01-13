import 'dart:async';
import 'dart:ui';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../image-picker/animated_page_route.dart';
import '../image-picker/photo_preview.dart';

void fn(){}

class PhotoLibrary extends StatefulWidget {
  _PhotoLibraryState createState() => _PhotoLibraryState();
}

/// 关于Hero动画
/// 创建多对多Hero动画，在页面pop时，移除多余的hero动画，只保留一个，
/// 当前页面出现时，再恢复所有hero动画，（其实，进入Hero动画前恢复也可以）
class _PhotoLibraryState extends State<PhotoLibrary> {
  List<AssetEntity> list;
  List<String> _tmpTags;
  List<String> _tags;
  Future _thumbList;
  int _index = 19;
  int hideIndex;

  initState() {
    super.initState();
    init();
  }

  void init() async {
    var paths = await PhotoManager.getAssetPathList();
    list = await paths.elementAt(0)?.assetList;
    _tmpTags = list.map((_) => _.id).toList();
    _tags = _tmpTags;
    _thumbList = Future.wait(list.map((v) => v.thumbData));
    setState(() {});
  }

  /// 打开预览
  /// todo 进入预览前，只有当前tag，在preview页面 mount后，
  /// todo 改为全部都有tag（保证preview切换后都能有退出的hero动画），
  /// todo 这样就能保留preview页面PageView的viewportFraction属性
  void enterPreview(i) {
    _index = i;

    Navigator.of(context).push(AnimatedPageRoute(previewBuilder));
  }

  void resetTags() {
    _tags = _tmpTags;
    setState(() {});
  }

  /// 删除除了当前preview图片外的其他图片的tag（删除其hero动画）
  /// 删除后，会归还回所在的原位置
  void removeOtherUselessTag(int index, {callback = fn}) {
    _tags = _tmpTags.map((_) {
      if (_tmpTags.indexOf(_) == index) {
        return _;
      }
      return null;
    }).toList();
    setState(() {
      callback();
    });
  }

  Widget previewBuilder(BuildContext _) => PhotoPreview(
        list: list,
        tags: _tags,
        initialPage: _index,
        onWillExit: removeOtherUselessTag,
        onExit: resetTags,
      );

  GlobalKey tag = GlobalKey();

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
                    children: List.from(snapshot.data.map((_) {
                      var index = snapshot.data.indexOf(_);
                      return Thumb(
                          show: index != hideIndex,
                          tag: _tags[index],
                          data: _,
                          onTap: () {
                            enterPreview(index);
                          });
                    }))));
          }
          return Container();
        });
  }
}

class Thumb extends StatelessWidget {
  Thumb({
    this.show = true,
    @required this.tag,
    this.data,
    this.onTap,
  });

  final bool show;
  final Object tag;
  final Uint8List data;
  final Function onTap;

  Widget build(BuildContext context) {
    Widget child = GestureDetector(
      onTap: onTap,
      child: Image.memory(data, fit: BoxFit.cover),
    );
    if (tag != null) {
      child = Hero(tag: tag, child: child);
    }
    return Opacity(
        opacity: show ? 1 : 0,
        child: Container(margin: EdgeInsets.all(1), child: child));
  }
}

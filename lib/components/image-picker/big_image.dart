import 'package:flutter/material.dart';

import 'package:photo_manager/photo_manager.dart';

/// 图片缓存
/// 图片预览：执行进入Preview页面的hero动画时会渲染多次BigImage，由于是FutureBuilder
/// 所以，中途会出现短暂的真空期（也就是没有数据时，返回的空的Container）
/// todo 若图片过大，或者手机性能不佳，会导致该动画执行时没有img（只有站位的Container），进而导致动画丢帧
Map<AssetEntity, Image> _map = {};

class BigImage extends StatefulWidget {
  final AssetEntity entity;
  final int maxWidth;
  final int maxHeight;

  BigImage({Key key, this.entity, this.maxWidth, this.maxHeight})
      : super(key: key);

  _BigImageState createState() => _BigImageState();
}

class _BigImageState extends State<BigImage>
    with AutomaticKeepAliveClientMixin {
  get wantKeepAlive => true;

  int get containerWidth => widget.maxWidth;

  int get containerHeight => widget.maxHeight;

  Widget build(BuildContext context) {
    super.build(context);
    if (_map.containsKey(widget.entity)) {
      return _map[widget.entity];
    }
    return FutureBuilder(
      future: widget.entity.thumbDataWithSize(containerWidth, containerHeight),
      builder: (ctx, snapshot) {
        var data = snapshot.data;
        if (snapshot.connectionState == ConnectionState.done && data != null) {
          Image img = Image.memory(data, fit: BoxFit.cover);
          _map.putIfAbsent(widget.entity, () => img);
          return img;
        }
        return Container();
      },
    );
  }
}

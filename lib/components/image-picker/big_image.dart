import 'package:flutter/material.dart';

import 'package:photo_manager/photo_manager.dart';

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
    return FutureBuilder(
      future: widget.entity.thumbDataWithSize(containerWidth, containerHeight),
      builder: (ctx, snapshot) {
        var data = snapshot.data;
        if (snapshot.connectionState == ConnectionState.done && data != null) {
          return Image.memory(data, fit: BoxFit.cover);
        }
        return Container();
      },
    );
  }
}

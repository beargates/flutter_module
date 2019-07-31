import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:photo_manager/photo_manager.dart';

import '../utils/Navigation.dart';
import '../components/image-picker/ImagePicker.dart';
import '../components/video-player/VideoPlayer.dart';

class Feeds extends StatefulWidget {
  _FeedsState createState() => _FeedsState();
}

class _FeedsState extends State<Feeds> {
  List<ImageEntity> list;
  List<String> videoList = [
    'https://asset.txqn.huohua.cn/video/79663ecf-e10c-4452-9496-9eb8051b9af5.mp4',
    'https://asset.txqn.huohua.cn/video/68b83e93-72b9-465d-9b13-8b100f1ec1c8.mp4',
    'https://asset.txqn.huohua.cn/video/357cd502-f288-4aee-81bf-756e512d3fc9.mp4',
    'https://asset.txqn.huohua.cn/video/5c9869bc-22e7-49b8-b259-43b8e2d85c5d.mp4',
    'https://asset.txqn.huohua.cn/video/c5c233a5-1d70-4cb4-89f0-02fe90a78c6c.mp4',
  ];
  String thumbQuery = '?vframe/jpg/offset/0';
  PageController _controller = PageController();
  int current;

  @override
  initState() {
    super.initState();

    init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void init() async {
    var result = await PhotoManager.requestPermission();
    if (result) {
      List<ImagePathEntity> list1 = await PhotoManager.getImagePathList();
      list = await list1.elementAt(1)?.imageList;
      print(list1);
//      list = await ImagePathEntity.all.imageList;
      setState(() {});
    } else {
      PhotoManager.openSetting();
    }
  }

  void toCamera() {
    NavigationUtil.navigate(context, MyHomePage(), withAppBar: false);
  }

  void onPageChanged(int index) {
    current = index;
    setState(() {});
  }

  Future reload() async {
    list = await ImagePathEntity.all.imageList;
    list.shuffle();
    videoList.shuffle();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (list == null || list.length == 0) {
      return Container();
    }
    return Scaffold(
        appBar: AppBar(
          title: Text('推荐'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.camera_alt),
              tooltip: '随拍',
              onPressed: toCamera,
            )
          ],
        ),
        body: RefreshIndicator(
          onRefresh: reload,
          child: PageView.builder(
            key: PageStorageKey('feeds'),
            controller: _controller,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int i) {
              return Item(
                  videoUrl: videoList.elementAt(i),
                  coverUrl: videoList.elementAt(i) + thumbQuery,
                  isCurrent: current == i);
            },
            itemCount: videoList.length,
            onPageChanged: onPageChanged,
          ),
        ));
  }
}

class Item extends StatefulWidget {
  final videoUrl;
  final coverUrl;
  final bool isCurrent;

  const Item({this.videoUrl, this.coverUrl, this.isCurrent});

  _ItemState createState() => _ItemState();
}

class _ItemState extends State<Item> {
  @override
  Widget build(BuildContext context) {
    if (widget.isCurrent) {
      return _buildVideoItem(
          widget.videoUrl, widget.coverUrl, _buildImageItem(widget.coverUrl));
    }
    return _buildImageItem(widget.coverUrl);
  }

  Widget _buildVideoItem(String videoUrl, String coverUrl, Widget holder) {
    return VideoView(
      videoUrl: videoUrl,
      coverUrl: coverUrl,
      holder: holder,
    );
  }

  Widget _buildImageItem(String url) {
    return Image.network(url);
  }
}

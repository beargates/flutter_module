import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:photo_manager/photo_manager.dart';

import '../utils/Navigation.dart';
import '../components/image-picker/ImagePicker.dart';
import '../components/video-player/VideoPlayer.dart';

class Feeds extends StatefulWidget {
  _FeedsState createState() => _FeedsState();
}

class _FeedsState extends State<Feeds> {
  // 获取状态栏高度
  final double statusBarHeight = MediaQueryData.fromWindow(window).padding.top;
  final double bottomTabBarHeight =
      MediaQueryData.fromWindow(window).padding.bottom;
  List<ImageEntity> list;
  List<String> videoList = [
    'https://asset.txqn.huohua.cn/video/0f2a0ebb-c2c6-495d-925f-4a8b97671a36.mp4',
    'https://asset.txqn.huohua.cn/video/79663ecf-e10c-4452-9496-9eb8051b9af5.mp4',
    'https://asset.txqn.huohua.cn/video/68b83e93-72b9-465d-9b13-8b100f1ec1c8.mp4',
    'https://asset.txqn.huohua.cn/video/357cd502-f288-4aee-81bf-756e512d3fc9.mp4',
    'https://asset.txqn.huohua.cn/video/5c9869bc-22e7-49b8-b259-43b8e2d85c5d.mp4',
    'https://asset.txqn.huohua.cn/video/c5c233a5-1d70-4cb4-89f0-02fe90a78c6c.mp4',
  ];
  String thumbQuery = '?vframe/jpg/offset/0';
  PageController _controller = PageController();
  int current;

//  @override
//  initState() {
//    super.initState();
//
//    init();
//  }

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

  Widget top() {
    return SafeArea(
//      alignment: Alignment.topLeft,
//      padding: EdgeInsets.only(top: statusBarHeight),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FlatButton.icon(
              onPressed: () {},
              icon: Icon(Icons.camera_alt),
              label: Text('随拍')),
          // todo tabBar
          Container(
            child: Row(
              children: <Widget>[
                IconButton(icon: Icon(Icons.live_tv), onPressed: () {}),
                IconButton(icon: Icon(Icons.search), onPressed: () {})
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (videoList == null || videoList.length == 0) {
      return Container();
    }

    return RefreshIndicator(
      onRefresh: reload,
      child: Stack(
        children: <Widget>[
          PageView.builder(
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
          top()
        ],
      ),
    );
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
  Widget right() {
    return Container(
      alignment: Alignment.bottomRight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Column(
            children: <Widget>[
              IconButton(icon: Icon(Icons.favorite), onPressed: () {}),
              Text('2.5w')
            ],
          ),
          Column(
            children: <Widget>[
              IconButton(icon: Icon(Icons.message), onPressed: () {}),
              Text('1019')
            ],
          )
        ],
      ),
    );
  }

  Widget bottom() {
    return Container(
      alignment: Alignment.bottomLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Column(
            children: <Widget>[
              IconButton(icon: Icon(Icons.favorite), onPressed: () {}),
              Text('2.5w')
            ],
          ),
          Column(
            children: <Widget>[
              IconButton(icon: Icon(Icons.message), onPressed: () {}),
              Text('1019')
            ],
          )
        ],
      ),
    );
  }

  Widget _buildVideo() {
//    return Container();
    var holder = Image.network(widget.coverUrl);
    return VideoView(
      videoUrl: widget.videoUrl,
      coverUrl: widget.coverUrl,
      holder: holder,
      releaseResource: !widget.isCurrent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[_buildVideo(), right(), bottom()],
      ),
    );
  }
}

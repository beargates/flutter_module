import 'package:flutter/material.dart';
import 'dart:math' as math;

//import '../components/camera/Camera.dart';
import '../components/image-picker/ImagePicker.dart';

class Mine extends StatefulWidget {
  @override
  _MineState createState() => _MineState();
}

class _MineState extends State<Mine> with SingleTickerProviderStateMixin {
  List<Tab> myTabs = const [
    Tab(child: Text('作品0')),
    Tab(child: Text('动态0')),
    Tab(child: Text('喜欢99'))
  ];
  ScrollController _controller = ScrollController();
  Color bgColor = const Color(0xFF151722);
  List<String> videoList = [
    'https://asset.txqn.huohua.cn/video/79663ecf-e10c-4452-9496-9eb8051b9af5.mp4',
    'https://asset.txqn.huohua.cn/video/68b83e93-72b9-465d-9b13-8b100f1ec1c8.mp4',
    'https://asset.txqn.huohua.cn/video/357cd502-f288-4aee-81bf-756e512d3fc9.mp4',
    'https://asset.txqn.huohua.cn/video/5c9869bc-22e7-49b8-b259-43b8e2d85c5d.mp4',
    'https://asset.txqn.huohua.cn/video/c5c233a5-1d70-4cb4-89f0-02fe90a78c6c.mp4',
  ];
  String thumbQuery = '?vframe/jpg/offset/0';

//  @override
//  void initState() {
//    super.initState();
//    _controller.addListener(() {
//      print(_controller.offset);
//    });
//  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget baseView() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
//          todo translate溢出容器后，溢出部分被切掉了，有可能是被appBar盖住了
          Transform.translate(
            offset: Offset(0, -10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 100,
                  height: 100,
                  child: CircleAvatar(
                    backgroundImage: AssetImage('assets/avatar.png'),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: FlatButton(
                      color: Color(0xff3a3a43),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        '编辑资料',
                        style: TextStyle(fontSize: 18),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          new MaterialPageRoute(
                            builder: (context) {
                              return MyHomePage();
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  color: Color(0xff3a3a43),
                  padding: EdgeInsets.all(1.5),
                  child: IconButton(
                    icon: Icon(Icons.group_add),
                    iconSize: 34,
                    onPressed: () {},
                  ),
                )
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
                border: Border(
                    bottom:
                        Divider.createBorderSide(context, color: Colors.grey))),
            padding: EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '社会银儿',
                  style: TextStyle(fontSize: 30),
                ),
                Text('抖音号：dowdiandnei'),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              '🌈认真的男人最帅',
              style: TextStyle(fontSize: 18),
            ),
          ),
          Row(
//            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FlatButton.icon(
                  padding: EdgeInsets.zero,
                  color: Color(0xff232530),
                  onPressed: () {},
                  icon: Icon(
                    Icons.person,
                    color: Colors.blue,
                  ),
                  label: Text(
                    '26岁',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  )),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
                child: FlatButton(
                  padding: EdgeInsets.zero,
                  color: Color(0xff232530),
                  child: Text(
                    '北京·顺义',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  onPressed: () {},
                ),
              ),
              FlatButton(
                padding: EdgeInsets.zero,
                color: Color(0xff232530),
                child: Text(
                  '哈尔滨商业大学',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                onPressed: () {},
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: <Widget>[
                RichText(
                    text: TextSpan(children: [
                  TextSpan(text: '0', style: TextStyle(fontSize: 20)),
                  TextSpan(
                      text: '获赞',
                      style: TextStyle(color: Colors.grey, fontSize: 20)),
                ])),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 22),
                  child: RichText(
                      text: TextSpan(children: [
                    TextSpan(text: '31', style: TextStyle(fontSize: 20)),
                    TextSpan(
                        text: '关注',
                        style: TextStyle(color: Colors.grey, fontSize: 20)),
                  ])),
                ),
                RichText(
                    text: TextSpan(children: [
                  TextSpan(text: '0', style: TextStyle(fontSize: 20)),
                  TextSpan(
                      text: '粉丝',
                      style: TextStyle(color: Colors.grey, fontSize: 20)),
                ]))
              ],
            ),
          ),
          FlatButton.icon(
            color: Color(0xff232530),
            onPressed: () {},
            icon: Icon(Icons.camera_alt),
            label: Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text('添加随拍'),
            ),
          )
        ],
      ),
    );
  }

  Widget tabBar() {
    return Container(
      color: bgColor,
      child: TabBar(
        tabs: myTabs,
        isScrollable: true,
        indicatorColor: Color(0xffE4CD60),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
      ),
    );
  }

  Widget tabBarView() {
    return TabBarView(
      children: myTabs.map((index) {
        return SafeArea(
          top: false,
          bottom: false,
          child: Builder(
            builder: (BuildContext context) {
              return CustomScrollView(
                key: PageStorageKey<String>('$index'),
                slivers: <Widget>[
                  SliverOverlapInjector(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context),
                  ),
                  SliverGrid.count(
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                    children: List.generate(40, (int i) {
                      return Image.network(
                        videoList.elementAt(math.Random().nextInt(4)) +
                            thumbQuery,
                        fit: BoxFit.cover,
                        height: 200,
                      );
                    }).toList(),
                    crossAxisCount: 3,
                  ),
                ],
              );
            },
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    var _baseView = baseView();
    var _tabBar = tabBar();
    var _tabBarView = tabBarView();
    return DefaultTabController(
      length: myTabs.length,
      child: Scaffold(
        backgroundColor: bgColor,
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            // These are the slivers that show up in the "outer" scroll view.
            return <Widget>[
              SliverAppBar(
                backgroundColor: bgColor,
                primary: false,
                automaticallyImplyLeading: false,
                expandedHeight: 100,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.asset(
                    'assets/avatar.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _baseView,
              ),
              SliverOverlapAbsorber(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
//              child: SliverAppBar(
//                automaticallyImplyLeading: false,
////                title: const Text('Books'),
//                pinned: true,
//                expandedHeight: 0.0,
//                forceElevated: innerBoxIsScrolled,
//                bottom: tabBar(),
//              ),
                child: SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    minHeight: 60.0,
                    maxHeight: 60.0,
                    child: _tabBar,
                  ),
                ),
              ),
            ];
          },
          body: _tabBarView,
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => math.max(maxHeight, minHeight);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

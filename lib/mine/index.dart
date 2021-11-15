import 'package:flutter/material.dart';
import 'dart:math' as math;

//import '../components/camera/camera.dart';

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
    // https://xxx.mp4
    // ...
  ];
  List _list;
  String thumbQuery = '?vframe/jpg/offset/0';
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    _list = List.generate(40, (int i) {
      return Image.network(
        videoList.elementAt(math.Random().nextInt(4)) + thumbQuery,
        fit: BoxFit.cover,
        width: 200,
        height: 200,
      );
    }).toList();

    /// 监听滚动，实现伪AppBar的渐隐渐现
    ///
    /// AppBar渐隐渐现的实现思路：
    /// 首先有个透明SliverAppBar占位
    /// 其次监听滚动实现自定义的AppBar
    ///
    _controller.addListener(() {
      double opacity = 0;
      if (_controller.offset > 200 && _controller.offset < 360) {
        opacity = (_controller.offset - 200) / 160;
      } else if (_controller.offset > 360) {
        opacity = 1;
      } else {
        opacity = 0;
      }
      opacity = math.max(math.min(opacity, 1), 0);
      if (opacity != _opacity) {
        setState(() {
          _opacity = opacity;
        });
      } else {
//        print('no render');
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget baseView() {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <
                Widget>[
//          todo translate溢出容器后，溢出部分被切掉了，有可能是被appBar盖住了
          Transform.translate(
              offset: Offset(0, -10),
              child: Row(children: <Widget>[
                GestureDetector(
                    onTap: () {},
                    child: Container(
                        width: 100,
                        height: 100,
                        child: CircleAvatar(
                            backgroundImage: AssetImage('assets/avatar.png')))),
                Expanded(
                    child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: FlatButton(
                            color: Color(0xff3a3a43),
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text('编辑资料', style: TextStyle(fontSize: 18)),
                            onPressed: () {
                              Navigator.of(context).pushNamed('/base_info');
                            }))),
                Container(
                    color: Color(0xff3a3a43),
                    padding: EdgeInsets.all(1.5),
                    child: IconButton(
                        icon: Icon(Icons.group_add),
                        iconSize: 34,
                        onPressed: () {}))
              ])),
          Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: Divider.createBorderSide(context,
                          color: Colors.grey))),
              padding: EdgeInsets.only(bottom: 10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('社会银儿', style: TextStyle(fontSize: 30)),
                    Text('抖音号：dowdiandnei')
                  ])),
          Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text('🌈认真的男人最帅', style: TextStyle(fontSize: 18))),
          Row(
//            mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FlatButton.icon(
                    padding: EdgeInsets.zero,
                    color: Color(0xff232530),
                    onPressed: () {},
                    icon: Icon(Icons.person, color: Colors.blue),
                    label: Text('26岁',
                        style: TextStyle(color: Colors.grey, fontSize: 16))),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  child: FlatButton(
                    padding: EdgeInsets.zero,
                    color: Color(0xff232530),
                    child: Text('北京·顺义',
                        style: TextStyle(color: Colors.grey, fontSize: 16)),
                    onPressed: () {},
                  ),
                ),
                FlatButton(
                  padding: EdgeInsets.zero,
                  color: Color(0xff232530),
                  child: Text('北京科技大学',
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                  onPressed: () {},
                )
              ]),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(children: <Widget>[
                RichText(
                    text: TextSpan(children: [
                  TextSpan(text: '0', style: TextStyle(fontSize: 20)),
                  TextSpan(
                      text: '获赞',
                      style: TextStyle(color: Colors.grey, fontSize: 20))
                ])),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 22),
                  child: RichText(
                      text: TextSpan(children: [
                    TextSpan(text: '31', style: TextStyle(fontSize: 20)),
                    TextSpan(
                        text: '关注',
                        style: TextStyle(color: Colors.grey, fontSize: 20))
                  ])),
                ),
                RichText(
                    text: TextSpan(children: [
                  TextSpan(text: '0', style: TextStyle(fontSize: 20)),
                  TextSpan(
                      text: '粉丝',
                      style: TextStyle(color: Colors.grey, fontSize: 20)),
                ]))
              ])),
          FlatButton.icon(
              color: Color(0xff232530),
              onPressed: () {},
              icon: Icon(Icons.camera_alt),
              label: Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text('添加随拍')))
        ]));
  }

  Widget tabBar() {
    return Container(
        color: bgColor,
        child: TabBar(
            tabs: myTabs,
            isScrollable: true,
            indicatorColor: Color(0xffE4CD60),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey));
  }

  Widget tabBarView() {
    return TabBarView(
        children: myTabs.map((index) {
      return SafeArea(
        top: false,
        bottom: false,
        child: GridView.count(
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          children: _list,
          crossAxisCount: 3,
        ),
//        child: Wrap(alignment: WrapAlignment.spaceBetween, children: _list),
      );
    }).toList());
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
            body: Stack(children: <Widget>[
              NestedScrollView(
                  controller: _controller,
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    // These are the slivers that show up in the "outer" scroll view.
                    return <Widget>[
                      /// 占位AppBar
                      SliverAppBar(
                        title: Text(''),
                        elevation: 0,

                        /// 去掉AppBar下面的阴影
                        pinned: true,
                        backgroundColor: Colors.transparent,
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
                              NestedScrollView.sliverOverlapAbsorberHandleFor(
                                  context),
                          child: SliverPersistentHeader(
                              pinned: true,
                              delegate: _SliverPersistentHeaderDelegate(
                                minHeight: 40.0,
                                maxHeight: 40.0,
                                child: _tabBar,
                              ))),
//                      SliverPersistentHeader(
//                          pinned: true,
//                          delegate: _SliverPersistentHeaderDelegate(
//                              minHeight: 400,
//                              maxHeight: 400,
//                              child:
//                                  Container(height: 100, child: _tabBarView)))
                    ];
                  },
                  body: _tabBarView),
              Opacity(
                  opacity: _opacity,
//              opacity: 1,
                  child: Container(
                      color: bgColor,
                      padding: EdgeInsets.only(top: 50),
                      height: 100,
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              '社会银儿',
                              style: TextStyle(fontSize: 25),
                            )
                          ])))
            ])));
  }
}

class _SliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  _SliverPersistentHeaderDelegate({
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
  bool shouldRebuild(_SliverPersistentHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }
}

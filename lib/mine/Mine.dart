import 'package:flutter/material.dart';
import '../utils/Navigation.dart';

//import '../components/camera/Camera.dart';
import '../components/image-picker/ImagePicker.dart';

//import '../components/image-picker/MultiImagePicker.dart';
import 'package:camera/camera.dart';

class Mine extends StatefulWidget {
  @override
  _MineState createState() => _MineState();
}

class _MineState extends State<Mine> with SingleTickerProviderStateMixin {
  List<Tab> myTabs;
  TabController _tabController;
  ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    myTabs = tabs();
    _tabController = TabController(vsync: this, length: myTabs.length);
    _controller.addListener(() {
      print(_controller.offset);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Widget baseView() {
    return Container(
      color: Color(0xFF151722),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
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
                    textColor: Colors.white,
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
                  color: Colors.white,
                  iconSize: 34,
                  onPressed: () {},
                ),
              )
            ],
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
                  style: TextStyle(color: Colors.white, fontSize: 30),
                ),
                Text(
                  '抖音号：dowdiandnei',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              '🌈认真的男人最帅',
              style: TextStyle(color: Colors.white, fontSize: 18),
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
                  TextSpan(
                      text: '0',
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                  TextSpan(
                      text: '获赞',
                      style: TextStyle(color: Colors.grey, fontSize: 20)),
                ])),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 22),
                  child: RichText(
                      text: TextSpan(children: [
                    TextSpan(
                        text: '31',
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                    TextSpan(
                        text: '关注',
                        style: TextStyle(color: Colors.grey, fontSize: 20)),
                  ])),
                ),
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: '0',
                      style: TextStyle(color: Colors.white, fontSize: 20)),
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
              icon: Icon(
                Icons.camera_alt,
                color: Colors.white,
              ),
              label: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  '添加随拍',
                  style: TextStyle(color: Colors.white),
                ),
              ))
        ],
      ),
    );
  }

  List<Tab> tabs() {
    return List.generate(3, (i) {
      return Tab(
        child: Text('$i'),
      );
    }).toList();
    ;
  }

  Widget tabView() {
    Widget tabBar = Container(
//        color: Colors.white,
        child: TabBar(
      controller: _tabController,
      tabs: myTabs,
      isScrollable: true,
      indicatorColor: Colors.redAccent[400],
      labelColor: Colors.redAccent[400],
      unselectedLabelColor: Colors.black87,
    ));

    TabBarView tabBarView = TabBarView(
        controller: _tabController,
        children: myTabs.map((Tab tab) {
          return ListView.builder(
              // 保存滚动位置
              key: PageStorageKey(myTabs.indexOf(tab)),
              controller: _controller,
              padding: EdgeInsets.all(8.0),
              itemCount: 10,
              itemBuilder: (BuildContext context, int index) {
                return Container();
              });
        }).toList());
    return Column(
      children: <Widget>[
        tabBar,
        Expanded(
          child: tabBarView,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget tabBar = TabBar(
      controller: _tabController,
      tabs: myTabs,
      isScrollable: true,
      indicatorColor: Colors.white,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.grey,
    );

    TabBarView tabBarView = TabBarView(
      controller: _tabController,
      children: myTabs.map((Tab tab) {
        return ListView.builder(
            // 保存滚动位置
            key: PageStorageKey(myTabs.indexOf(tab)),
            controller: _controller,
            padding: EdgeInsets.all(8.0),
            itemCount: 10,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                height: 100,
                child: Text(
                  '$index',
                  style: TextStyle(color: Colors.red),
                ),
              );
            });
      }).toList(),
    );
    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: baseView(),
        ),
        SliverAppBar(
          title: Text('社会银儿'),
          expandedHeight: 100.0,
//          floating: true,
//           snap: snap,
          pinned: true,
          bottom: tabBar,
        ),
        SliverToBoxAdapter(
          child: Container(
            height: 500,
            child: Column(
              children: <Widget>[
                Expanded(child: tabBarView),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

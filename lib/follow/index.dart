import 'package:flutter/material.dart';

class Follow extends StatefulWidget {
  _FollowState createState() => _FollowState();
}

class _FollowState extends State<Follow> {
  final List<Tab> tabs = [
    Tab(child: Text('关注', style: TextStyle(fontSize: 20))),
    Tab(child: Text('好友', style: TextStyle(fontSize: 20))),
  ];
  Color bgColor = const Color(0xFF151722); // todo global

  Widget _tabBar() {
    return TabBar(
      tabs: tabs,
      indicatorColor: Colors.white,
      unselectedLabelColor: Colors.grey,
    );
  }

  Widget _appBar() {
    var tabBar = _tabBar();
    return AppBar(
        title: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 150, maxHeight: 50),
            child: tabBar),
        backgroundColor: bgColor,
        leading: IconButton(
            onPressed: () {},
            icon: Icon(Icons.camera_alt, color: Colors.grey)));
  }

  Widget build(BuildContext context) {
    var appBar = _appBar();
    return DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          backgroundColor: bgColor,
          appBar: appBar,
          body: TabBarView(
            children: List.generate(tabs.length, (_) {
              return TabContent();
            }).toList(),
          ),
        ));
  }
}

///
/// resolve issue: 不能保存tabBarView的滚动状态
/// 方法一：利用 AutomaticKeepAliveClientMixin
///     refer: https://juejin.im/post/5b73c3b3f265da27d701473a
/// 方法二(仅适用于3个及以下的tab)：添加PageController(viewportFraction: 0.9999)
///     refer： https://www.jianshu.com/p/ee149d204e30
///
class TabContent extends StatefulWidget {
  _TabContentState createState() => _TabContentState();
}

class _TabContentState extends State<TabContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Widget _onlines() {
    return Container(
      height: 132,
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
          border: Border(
              bottom:
                  Divider.createBorderSide(context, color: Colors.white10))),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int i) {
          return Container(
            child: Column(
              children: <Widget>[
                Stack(
                  alignment: AlignmentDirectional.bottomEnd,
                  children: <Widget>[
                    Container(
                      width: 80,
                      height: 80,
                      child: CircleAvatar(
                        backgroundImage: AssetImage('assets/avatar.png'),
                      ),
                    ),
                    Icon(Icons.add_circle),
                  ],
                ),
                Text('添加随拍', style: TextStyle(color: Colors.grey))
              ],
            ),
          );
        },
        itemCount: 5,
        itemExtent: 100,
      ),
    );
  }

  Widget _feeds() {
    return ListView.builder(
      itemBuilder: (BuildContext context, int i) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
              border: Border(
                  bottom: Divider.createBorderSide(context,
                      color: Colors.white10))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: CircleAvatar(
                                backgroundImage:
                                    AssetImage('assets/avatar.png')),
                          ),
                          Text('🌍挚爱🇨🇳', style: TextStyle(fontSize: 20))
                        ],
                      ),
                    ),
                    IconButton(icon: Icon(Icons.more_horiz), onPressed: () {}),
                  ],
                ),
              ),
              Container(
                width: 300,
                height: 400,
                child: Image.asset('assets/avatar.png', fit: BoxFit.cover),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('10分钟前'),
                  Row(
                    children: <Widget>[
                      FlatButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.reply),
                          label: Text('分享')),
                      FlatButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.chat),
                          label: Text('分享')),
                      FlatButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.favorite),
                          label: Text('分享')),
                    ],
                  ),
                ],
              ),
              Container(
                color: Color(0xff21202F),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: Divider.createBorderSide(context,
                                    color: Colors.white10))),
                        padding: EdgeInsets.all(6),
                        child: Text('9人赞过')),
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(text: '来福：'),
                        TextSpan(
                            text: '666🌹', style: TextStyle(color: Colors.grey))
                      ]),
                    ),
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(text: '望天涯：'),
                        TextSpan(
                            text: '你咋不上天呢🥒🥒',
                            style: TextStyle(color: Colors.grey))
                      ]),
                    ),
                    Container(
                      width: 50,
                      child: FlatButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.mode_edit),
                          label: Text('添加评论...',
                              style: TextStyle(color: Colors.grey))),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      itemExtent: 672,
      itemCount: 5,
    );
  }

  @override
  Widget build(BuildContext context) {
    var onlines = _onlines();
    var feeds = _feeds();
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverToBoxAdapter(child: onlines),
        ];
      },
      body: feeds,
    );
  }
}

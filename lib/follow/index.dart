import 'package:flutter/material.dart';

class Follow extends StatefulWidget {
  _FollowState createState() => _FollowState();
}

class _FollowState extends State<Follow> {
  final List<Tab> tabs = [
    Tab(
      child: Text('关注', style: TextStyle(fontSize: 20)),
    ),
    Tab(
      child: Text('好友', style: TextStyle(fontSize: 20)),
    ),
  ];
  Color bgColor = const Color(0xFF151722); // todo global

  Widget _tabBar() {
    return TabBar(
      tabs: tabs,
      indicatorColor: Colors.white,
      unselectedLabelColor: Colors.grey,
    );
  }

  Widget _onlines() {
    return Container(
      height: 132,
      padding: EdgeInsets.all(16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int i) {
          return Column(
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
                  Icon(
                    Icons.add_circle,
                    color: Colors.white,
                  )
                ],
              ),
              Text('添加随拍', style: TextStyle(color: Colors.grey))
            ],
          );
        },
        itemCount: 5,
        itemExtent: 100,
      ),
    );
  }

  Widget _feeds() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        itemBuilder: (BuildContext context, int i) {
          return Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: CircleAvatar(
                              backgroundImage: AssetImage('assets/avatar.png')),
                        ),
                        Text('🌍挚爱🇨🇳',
                            style: TextStyle(color: Colors.white, fontSize: 20))
                      ],
                    ),
                  ),
                  Icon(Icons.more_horiz, color: Colors.white,)
                ],
              )
            ],
          );
        },
        itemExtent: 200,
        itemCount: 5,
      ),
    );
  }

  TabBarView _tabBarView() {
    var onlines = _onlines();
    var feeds = _feeds();
    return TabBarView(
      children: <Widget>[
        CustomScrollView(
          slivers: <Widget>[
            SliverFillRemaining(
              child: Column(
                children: <Widget>[
                  onlines,
                  Expanded(
                    child: feeds,
                  )
                ],
              ),
            ),
          ],
        ),
        CustomScrollView(
          slivers: <Widget>[
            SliverFillRemaining(
              child: Column(
                children: <Widget>[
                  onlines,
                  Expanded(
                    child: feeds,
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget build(BuildContext context) {
    var tabBar = _tabBar();
    var tabBarView = _tabBarView();
    return DefaultTabController(
      length: 2, //todo
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          primary: false,
          bottom: tabBar,
        ),
        body: tabBarView,
      ),
    );
  }
}

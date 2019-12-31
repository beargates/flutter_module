import 'package:flutter/material.dart';
import '../feeds/index.dart';
import '../follow/index.dart';
import '../mine/index.dart';
//import '../utils/webview.dart';
import '../components/image-picker/photo_library.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 2;
  static final List<Map<String, dynamic>> _bottomNavBarItems = [
    {"icon": Icons.list, "title": '首页'},
    {"icon": Icons.favorite, "title": '关注'},
    {"icon": Icons.message, "title": '消息'},
    {"icon": Icons.person, "title": '我'},
  ];

  static final _feeds = Feeds();
  static final _fllow = Follow();
//  static final _webview = createBaiduView();
  static final _demo = PhotoLibrary();
  static final _mine = Mine();
  static final List<Widget> _tabbarViews = [_feeds, _fllow, _demo, _mine];

//  @override
//  void initState(){
//    super.initState();
//
//    const timeout = const Duration(seconds: 5);
//    Timer(timeout, () {
//      Navigator.of(context).pop();
//      SystemNavigator.pop();
//      exit(0);
//    });
//  }
//  static createBaiduView() {
//    return LoadWebView('https://www.baidu.com');
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Mine(),
        elevation: 20.0,
      ),
      body: _tabbarViews.elementAt(_selectedIndex),
//      body: IndexedStack(
//        index: _selectedIndex,
//        children: _tabbarViews,
//      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xff1B1C20),
        currentIndex: _selectedIndex,
        fixedColor: Colors.white,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: _bottomNavBarItems.map((_) {
          var current = _bottomNavBarItems.indexOf(_) == _selectedIndex;
          return BottomNavigationBarItem(
              icon: Icon(_['icon'], size: 0), /// 去掉icon
              title: Container(
                padding: EdgeInsets.only(bottom: 8),
                decoration: current
                    ? BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: Colors.white, width: 3)))
                    : null,
                child: Text(
                  _['title'],
                  style: TextStyle(fontSize: 20),
                ),
              ));
        }).toList(),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

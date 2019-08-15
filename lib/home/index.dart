import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import '../feeds/index.dart';
import '../follow/index.dart';
import '../mine/index.dart';
import '../utils/webview.dart';
import '../follow/demo.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  static final Icon iconNote = Icon(Icons.event_note);
  static final Icon iconSchool = Icon(Icons.school);
  static final Icon iconPerson = Icon(Icons.person);
  static final _feeds = Feeds();
  static final _fllow = Follow();
  static final _webview = createBaiduView();
  static final _demo = MyApp();
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
  static createBaiduView() {
    return LoadWebView('https://www.baidu.com');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Mine(),
        elevation: 20.0,
      ),
      body: _tabbarViews.elementAt(_selectedIndex),
//      body: Stack(
//        children: _tabbarViews.map((Widget e) {
//          var i = _tabbarViews.indexOf(e);
//          print('$i,$_selectedIndex');
//          // 首页feeds在active时，在模拟器里会大量占用cpu
//          // todo 这么做无效
//          if (_selectedIndex != 0 && i == 0) {
//            return Container();
//          }
//          return Offstage(offstage: _selectedIndex != i, child: e);
//        }).toList(),
//      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xff1B1C20),
        currentIndex: _selectedIndex,
        fixedColor: Colors.white,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.list), title: Text('首页')),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), title: Text('关注')),
          BottomNavigationBarItem(icon: Icon(Icons.message), title: Text('消息')),
          BottomNavigationBarItem(icon: Icon(Icons.person), title: Text('我')),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import '../feeds/index.dart';
import '../follow/index.dart';
import '../mine/index.dart';
import '../utils/Webview.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  static final Icon iconNote = Icon(Icons.event_note);
  static final Icon iconSchool = Icon(Icons.school);
  static final Icon iconPerson = Icon(Icons.person);
  final List<Widget> _tabbarViews = [
    Feeds(),
    Follow(),
    createBaiduView(),
    Mine(),
  ];

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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
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

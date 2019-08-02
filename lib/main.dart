import 'package:flutter/material.dart';
import 'home/index.dart';

void main() => runApp(new App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter_demo',
      theme: new ThemeData(
        brightness: Brightness.dark, // 状态栏图标与字体颜色为白色
        primaryColor: Colors.black, // 顶部导航栏和状态栏的颜色
      ),
      home: Home(),
//      routes: {
//        "/webview": (_) => LoadWebView('https://baidu.com'),
//      },
    );
  }
}

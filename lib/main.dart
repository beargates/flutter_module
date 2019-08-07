import 'package:flutter/material.dart';
import 'home/index.dart';

void main() => runApp(new App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter_demo',
      theme: new ThemeData(
        // 状态栏图标与字体颜色为白色
        brightness: Brightness.dark,
        // 顶部导航栏和状态栏的颜色
        primaryColor: Colors.black,
        // 去掉点击控件背景出现的水波纹效果,即去掉md的效果
        splashColor: Colors.transparent,
        // 去掉点击控件点击时的背景色
        highlightColor: Colors.transparent,
        // 页面的背景色
        scaffoldBackgroundColor: Colors.black,
      ),
      home: Home(),
//      routes: {
//        "/webview": (_) => LoadWebView('https://baidu.com'),
//      },
    );
  }
}

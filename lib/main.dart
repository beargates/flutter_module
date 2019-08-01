import 'package:flutter/material.dart';
import 'home/index.dart';

void main() => runApp(new App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter_demo',
      theme: new ThemeData(
        primaryColor: Colors.black,
      ),
      home: Home(),
//      routes: {
//        "/webview": (_) => LoadWebView('https://baidu.com'),
//      },
    );
  }
}

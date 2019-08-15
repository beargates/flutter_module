import 'package:flutter/material.dart';
import '../utils/webview.dart';

class NavigationUtil {
  static createPageWithShell(
      Widget page, Map navigationOptions, {bool withAppBar = true}) {
    String title = navigationOptions['title'];
    List<Widget> actions = navigationOptions['actions'];
    return Scaffold(
      appBar: withAppBar == true
          ? AppBar(
              title: title != null ? Text(title) : null,
              actions: actions,
            )
          : null,
      body: page, //直接将准备好的ListTile塞入其中，完成内容填充
    );
  }

  static createWebviewPage(context, String url, Map navigationOptions) {
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          return LoadWebView(url);
        },
      ),
    );
  }

  static navigate(context, Widget page,
      {bool withAppBar = true, Map navigationOptions = const {}}) {
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          return createPageWithShell(page, navigationOptions, withAppBar: withAppBar);
        },
      ),
    );
  }
}

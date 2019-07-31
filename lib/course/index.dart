import 'package:flutter/material.dart';
import '../utils/Navigation.dart';
import '../some-other-page/index.dart';
import 'List.dart';

class CourseListPage extends StatefulWidget {
  @override
  createState() => _CourseListPageState();
}

class _CourseListPageState extends State<CourseListPage> {
  static final Icon iconList = Icon(Icons.list);
  static final Icon iconAdd = Icon(Icons.add);
  static final Icon iconCreate = Icon(Icons.create);
  List<IconButton> actions;

  @override
  void initState() {
    super.initState();

    actions = [
      IconButton(icon: iconList, onPressed: _pushSaved),
      IconButton(icon: iconAdd, onPressed: _openBaidu),
      IconButton(icon: iconCreate, onPressed: _loadUrl),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return NavigationUtil.createPageWithShell(CourseList(), {
      'title': '我的课表',
      'actions': actions,
    });
  }

  void _pushSaved() {
    NavigationUtil.navigate(context, SomeOtherPage(), navigationOptions: {
      'title': '收藏的列表项目',
    });
  }

  void _openBaidu() {
//    Navigator.pushNamed(context, '/webview');
  }

  void _loadUrl() {
    NavigationUtil.createWebviewPage(context, 'https://baidu.com', {
      'title': '百度',
      'withNavigationBar': true,
    });
  }
}

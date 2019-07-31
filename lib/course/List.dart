import 'package:flutter/material.dart';
import 'Item.dart';

class CourseList extends StatefulWidget {
  @override
  createState() => new _CourseListState();
}

class _CourseListState extends State<CourseList>
    with SingleTickerProviderStateMixin {
  List<Tab> myTabs;
  TabController _tabController;
  ScrollController _controller = new ScrollController();

  @override
  void initState() {
    super.initState();
    myTabs = _buildTabs();
    _tabController = TabController(vsync: this, length: myTabs.length);
    _controller.addListener(() {
      print(_controller.offset);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget tabBar = Container(
        color: Colors.white,
        child: TabBar(
          controller: _tabController,
          tabs: myTabs,
          isScrollable: true,
          indicatorColor: Colors.redAccent[400],
          labelColor: Colors.redAccent[400],
          unselectedLabelColor: Colors.black87,
        ));

    TabBarView tabBarView = TabBarView(
        controller: _tabController,
        children: myTabs.map((Tab tab) {
          return ListView.builder(
            // 保存滚动位置
              key: PageStorageKey(myTabs.indexOf(tab)),
              controller: _controller,
              padding: EdgeInsets.all(8.0),
              itemCount: 10,
              itemBuilder: (BuildContext context, int index) {
                return CourseListItem(
                  index: index,
                );
              });
        }).toList());

    return Container(
      color: Colors.black12,
      child: Flex(
        direction: Axis.vertical,
        children: [
          tabBar,
          Expanded(
            child: tabBarView,
          )
        ],
      ),
    );
  }

  List<Tab> _buildTabs() {
    Map data = {
      'day': '一',
      'date': '13/',
      'todo': '0',
    };
    return List.generate(10, (i) {
      Map _data = data.map((k, v) => MapEntry(k, v));
      _data['index'] = i.toString();
      _data['date'] += (++i).toString();
      return Tab(child: _buildDateItem(_data));
    });
  }

  Widget _buildDateItem(Map data) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Column(
        children: [
          Text(
            data['day'],
          ),
          Text(
            data['date'],
          ),
//          Text(
//            data['todo'],
//            style: TextStyle(fontSize: 16),
//          ),
        ],
      ),
    );
  }
}

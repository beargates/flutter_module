import 'package:flutter/material.dart';

class TrailingCenter extends StatelessWidget {
//  final ScrollController _controller = new ScrollController(keepScrollOffset: false);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('关注'),
      ),
      body: ListView.builder(
        key: PageStorageKey<String>('学员中心'),
//        controller: _controller,
        padding: EdgeInsets.all(8.0),
        itemExtent: 100.0,
        itemCount: 20,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            width: 100,
            height: 100,
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/avatar.png'),
            ),
          );
        },
      ),
    );
  }
}

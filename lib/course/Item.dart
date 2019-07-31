import 'package:flutter/material.dart';

class CourseListItem extends StatelessWidget {
  final index;
  static final red = Colors.redAccent[400];

  CourseListItem({this.index});

  @override
  Widget build(BuildContext context) {
    return _buildCard(_buildContent());
  }

  Widget _buildCard(Widget content) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
      child: content,
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('L${this.index + 1}对应与比较第1讲《一一对应》',
            style: TextStyle(fontSize: 18, height: 1.5)),
        Text('11:30 - 12:00',
            style: TextStyle(color: red, fontSize: 14, height: 1.5)),
        Padding(
          padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: Row(
            children: [
              Container(
                color: Colors.black38,
                margin: EdgeInsets.only(right: 8),
                child: Text(
                  '已报名: 0/4',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Container(
                color: Colors.black38,
                child: Text(
                  '直播间无信息',
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Chip(
                avatar: CircleAvatar(backgroundColor: red, child: Text('JL')),
                label: Text('直播间无信息直播间无信息直播间无信息', overflow: TextOverflow.ellipsis,),
              ),
            ),
            Chip(
              avatar: CircleAvatar(backgroundColor: red, child: Text('JL')),
              label: Text('直播间无信息', overflow: TextOverflow.ellipsis,),
            ),
          ],
        )
      ],
    );
  }
}

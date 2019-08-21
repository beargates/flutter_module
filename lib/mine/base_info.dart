import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

class BaseInfo extends StatefulWidget {
  _BaseInfoState createState() => _BaseInfoState();
}

class _BaseInfoState extends State<BaseInfo> {
  var infoList = [
    {"key": '昵称', "value": '社会银儿'},
    {"key": '抖音号', "value": 'dkncnxjkbds'},
    {"key": '简介', "value": '认真的男人最帅'},
    {"key": '学校', "value": '北京科技大学'},
    {"key": '性别', "value": '男'},
    {"key": '生日', "value": '1993-03-01'},
    {"key": '地区', "value": '中国·北京·顺义'},
  ];

  void takePhoto() async {
    await ImagePicker.pickImage(source: ImageSource.camera);
  }

  void pickImage() async {
    await ImagePicker.pickImage(source: ImageSource.gallery);
  }

  void showActionSheet(BuildContext c) {
    showBottomSheet(
        builder: (_) {
          /// todo SafeArea无效
          return SafeArea(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                FlatButton(child: Text('拍照'), onPressed: takePhoto),
                Divider(),
                FlatButton(child: Text('照片'), onPressed: pickImage),
              ]));
        },
        context: c);
  }

  Widget avatar() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        /// todo Builder
        Builder(
            builder: (c) => GestureDetector(
                child: Container(
                    width: 100,
                    height: 100,
                    margin: EdgeInsets.fromLTRB(0, 30, 0, 20),
                    child: CircleAvatar(
                        backgroundImage: AssetImage('assets/avatar.png'),
                        child: Icon(Icons.camera_alt, size: 30))),
                onTap: () {
                  showActionSheet(c);
                })),
        Text('点击更换头像', style: TextStyle(color: Colors.grey))
      ],
    );
  }

  List<Widget> buildInfoList() {
    return infoList
        .map((_) => ListTile(
            title: Container(
                height: 40,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(_['key'], style: TextStyle(fontSize: 20)),
                      Text(_['value'], style: TextStyle(color: Colors.grey))
                    ])),
            trailing:
                Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
            onTap: () {}))
        .toList();
  }

  Widget build(BuildContext c) {
    List<Widget> list = buildInfoList();
    return Scaffold(
        appBar: AppBar(title: Text('编辑个人资料'), elevation: 10),
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [avatar(), Column(children: list)]));
  }
}

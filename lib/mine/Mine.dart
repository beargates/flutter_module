import 'package:flutter/material.dart';
import '../utils/Navigation.dart';
//import '../components/camera/Camera.dart';
import '../components/image-picker/ImagePicker.dart';
//import '../components/image-picker/MultiImagePicker.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras;

class Mine extends StatefulWidget {
  @override
  _MineState createState() => _MineState();
}

class _MineState extends State<Mine> {
  static final arrow = Icon(Icons.keyboard_arrow_right);
  final CameraDescription desc = CameraDescription(
      name: '123',
      lensDirection: CameraLensDirection.back,
      sensorOrientation: 0);
  List<Widget> list;

  @override
  void initState() {
    super.initState();

    list = [
      ListTile(
        title: Text('修改密码'),
        trailing: arrow,
        onTap: () {
          NavigationUtil.createWebviewPage(
              context, 'http://m.t.qa.huohua.cn/user_center/reset_pass', {});
        },
      ),
      ListTile(
        title: Text('我的信息'),
        trailing: arrow,
        onTap: () {
          NavigationUtil.createWebviewPage(
              context, 'http://m.t.qa.huohua.cn/user_center/user_detail', {});
        },
      ),
    ];
  }

  Future<void> init() async {
    cameras = await availableCameras();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: _buildAvatar(),
      ),
      body: _buildList(),
    );
  }

  Widget _buildAvatar() {
    return PreferredSize(
      child: Center(
        child: Column(
          children: [
            FlatButton(
                onPressed: () {
                  Navigator.of(context).push(
                    new MaterialPageRoute(
                      builder: (context) {
                        return MyHomePage();
                      },
                    ),
                  );
                },
                child: Container(
                  width: 100,
                  height: 100,
                  child: CircleAvatar(
                    backgroundImage: AssetImage('assets/avatar.png'),
                  ),
                )),
            Container(
              height: 30,
            ), // 用于撑起上面的头像
          ],
        ),
      ),
      preferredSize: Size(100, 130),
    );
  }

  Widget _buildList() {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.separated(
            itemCount: list.length,
            separatorBuilder: (BuildContext context, int index) => Divider(),
            itemBuilder: (BuildContext context, int index) {
              return list.elementAt(index);
            },
          ),
        )
      ],
    );
  }
}

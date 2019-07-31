import 'dart:io';
import 'package:sy_flutter_qiniu_storage/sy_flutter_qiniu_storage.dart';
import 'package:uuid/uuid.dart';

import '../../utils/request.dart';

var uuid = new Uuid();
String urlGetToken = 'https://api.qa.huohua.cn/upload/token';

class QiniuUploader {
  double _process = 0.0;

  static defaultProgressListener(dynamic percent) {
    print(percent);
  }

  static upload(
      {File file,
      progressListener = QiniuUploader.defaultProgressListener}) async {
    var re = {'code': -1};
    if (file == null) {
      return re;
    }
    var data = await Request.get(urlGetToken);
    String token =
        'bZ-bO9KpdyID3VNOjkP0Rba091tU68RvZctJ5N-D:nTUHMD22Y8kjyrvT1QownnuIsKc=:eyJzY29wZSI6Imh1b2h1YSIsImRlYWRsaW5lIjoxNTY0MDQ0NDA2fQ==';
    if (data != null) {
      token = data['data'];
    }
    final syStorage = new SyFlutterQiniuStorage();
    //监听上传进度
    syStorage.onChanged().listen(progressListener);

    var id = uuid.v4();
    String extraName = file.path.split('.').last;
    String key = id + '.' + extraName;
    String url = 'https://img.txqn.huohua.cn/' + key;
    // 上传文件
    bool result = await syStorage.upload(file.path, token, key);
    if (result) {
      return {'code': 0, 'url': url};
    }
    return re;
  }

  //取消上传
  static cancel() {
    SyFlutterQiniuStorage.cancelUpload();
  }
}

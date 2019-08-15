import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

// todo discord 'url' here
class LoadWebView extends StatefulWidget {
  final String url;

  LoadWebView(this.url);

  @override
  _LoadWebViewState createState() => _LoadWebViewState(url);
}

class _LoadWebViewState extends State<LoadWebView> {
  var url;
  FlutterWebviewPlugin webview = FlutterWebviewPlugin();

  _LoadWebViewState(this.url);

  @override
  void initState() {
    super.initState();

    webview.onStateChanged.listen((WebViewStateChanged wvs) {
      print(wvs.type);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      appBar: AppBar(
        title: Text('Webview Page'),
      ),
      url: url,
      withZoom: false,
    );
  }
}

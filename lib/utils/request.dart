import 'dart:convert';
import 'package:dio/dio.dart';

class Request {
  static get(String url) async {
    try {
      Dio dio = new Dio();
      dio.options.headers = {'user-token': 'bWOxr_7Cjimbpz86G8TdwpJvMnowNIOw'};
      Response response = await dio.get(url);
      print(response.data);
      return response.data;
    } catch (e) {
      print(e);
    }
  }
}

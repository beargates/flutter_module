import 'package:flutter/material.dart';

class AnimatedPageRoute extends PageRouteBuilder {
  final WidgetBuilder builder;

  AnimatedPageRoute(this.builder)
      : super(
            opaque: false,
            transitionDuration: const Duration(milliseconds: 246),
            pageBuilder: (BuildContext context, Animation<double> animation1,
                Animation<double> animation2) {
              return builder(context);
            },
            transitionsBuilder: (BuildContext context,
                Animation<double> animation1,
                Animation<double> animation2,
                Widget child) {
              // 渐变过渡
              return FadeTransition(
                opacity: Tween(begin: 0.0, end: 1.0).animate(animation1),
                child: child,
              );
              // 翻转缩放
              return RotationTransition(
                turns: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                  parent: animation1,
                  curve: Curves.fastOutSlowIn,
                )),
                child: ScaleTransition(
                  scale: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                      parent: animation1, curve: Curves.fastOutSlowIn)),
                  child: child,
                ),
              );
              // 左右滑动
              return SlideTransition(
                position: Tween<Offset>(
                        begin: Offset(-1.0, 0.0), end: Offset(0.0, 0.0))
                    .animate(CurvedAnimation(
                        parent: animation1, curve: Curves.fastOutSlowIn)),
                child: child,
              );
            });
}

import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class VideoView extends StatefulWidget {
  final videoUrl;
  final coverUrl;
  final holder; // load时的占位，如loading/封面图

  VideoView({this.videoUrl, this.coverUrl, this.holder});

  @override
  _VideoViewState createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  VideoPlayerController _controller;
  bool canPlay = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        _controller.play();
        // 使用play().then会有短暂白屏
        _controller.addListener(_onVideoControllerUpdate);
      });
  }

  void _onVideoControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.initialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
//        ? Text('123')
        : widget.holder;
  }

  @override
  void dispose() {
    super.dispose();
    _controller.removeListener(_onVideoControllerUpdate);
    _controller.dispose();
  }
}

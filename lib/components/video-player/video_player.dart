import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class VideoView extends StatefulWidget {
  final videoUrl;
  final coverUrl;
  final holder; // load时的占位，如loading/封面图
  final bool releaseResource;

  VideoView({this.videoUrl, this.coverUrl, this.holder, this.releaseResource});

  @override
  _VideoViewState createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  VideoPlayerController _controller;
  bool canPlay = false;

  @override
  void initState() {
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized,
        // even before the play button has been pressed.
        _controller.play();
        // 使用play().then会有短暂白屏
        _controller.addListener(_onVideoControllerUpdate);
      });
    super.initState();
  }

  @override
  void dispose() {
    _controller.pause();
    _controller.removeListener(_onVideoControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _onVideoControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.releaseResource) {
      return widget.holder;
    } else if (_controller.value.initialized) {
      return AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: VideoPlayer(_controller),
      );
    }
    return widget.holder;
  }
}

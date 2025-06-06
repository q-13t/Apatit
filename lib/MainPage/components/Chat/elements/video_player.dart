import 'dart:async';

import 'package:Apatite/utils/toast_service.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';

class CustomVideoPlayer extends StatefulWidget {
  final File? data;

  const CustomVideoPlayer({super.key, required this.data});

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> with AutomaticKeepAliveClientMixin {
  late VideoPlayerController _controller;

  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      _initializeVideo(widget.data!);
    }
  }

  Future<void> _initializeVideo(File file) async {
    _controller = VideoPlayerController.file(file);
    _controller
        .initialize()
        .catchError((e) {
          ToastService.showToast("Cannot Play Video");
        })
        .then((file) => setState(() {}))
        .catchError((e) {
          ToastService.showToast("Cannot Play Video");
        });
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _showControls = true;
        _hideTimer?.cancel();
      } else {
        _controller.play();
        _startHideTimer();
      }
    });
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (_controller.value.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _onTapVideo() {
    setState(() {
      _showControls = !_showControls;
      if (_controller.value.isPlaying && _showControls) {
        _startHideTimer();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _controller.value.isInitialized
        ? GestureDetector(
          onTap: _onTapVideo,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller)),
              if (_showControls)
                Container(
                  color: Colors.black45,
                  child: IconButton(
                    iconSize: 60,
                    icon: Icon(
                      _controller.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                      color: Colors.white,
                    ),
                    onPressed: _togglePlayPause,
                  ),
                ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    playedColor: Colors.cyan,
                    backgroundColor: Colors.white24,
                    bufferedColor: Colors.white38,
                  ),
                ),
              ),
            ],
          ),
        )
        : const Center(child: CircularProgressIndicator());
  }

  @override
  bool get wantKeepAlive => true;
}

import 'dart:async';

import 'package:Apatite/utils/toast_service.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:just_audio/just_audio.dart';

class CustomAudioPlayer extends StatefulWidget {
  final File? data;

  const CustomAudioPlayer({super.key, required this.data});

  @override
  State<CustomAudioPlayer> createState() => _CustomAudioPlayerState();
}

class _CustomAudioPlayerState extends State<CustomAudioPlayer> with AutomaticKeepAliveClientMixin {
  final AudioPlayer _player = AudioPlayer();
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  bool _isPlaying = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      _initAudio(widget.data!);
    }

    _player.positionStream.listen((position) {
      setState(() {
        _position = position;
      });
    });

    _player.durationStream.listen((duration) {
      if (duration != null) {
        setState(() {
          _duration = duration;
        });
      }
    });

    _player.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });
    });
  }

  Future<void> _initAudio(File file) async {
    _player
        .setFilePath(file.path)
        .catchError((e) {
          ToastService.showToast("Cannot Play Audio");
        })
        .then(
          (file) => setState(() {
            _isInitialized = true;
          }),
        )
        .catchError((e) {
          ToastService.showToast("Cannot Play Audio");
        });
    // setState(() {
    //   _isInitialized = true;
    // });
  }

  void _togglePlayPause() {
    if (!_isInitialized) return;

    if (_isPlaying) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  @override
  bool get wantKeepAlive => true;
  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const CircularProgressIndicator();
    }
    super.build(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Slider(
          min: 0,
          max: _duration.inMilliseconds.toDouble(),
          value: _position.inMilliseconds.clamp(0, _duration.inMilliseconds).toDouble(),
          onChanged: (value) {
            _player.seek(Duration(milliseconds: value.toInt()));
          },
        ),
        IconButton(
          iconSize: 40,
          icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle),
          onPressed: _togglePlayPause,
        ),
      ],
    );
  }
}

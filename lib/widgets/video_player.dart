import 'dart:io';

import 'package:flutter/material.dart';
import 'package:unionchat/common/cache_file.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../common/func.dart';
import 'network_image.dart';

class AppVideo extends StatefulWidget {
  final String url;
  final bool pause;
  final double playSize;
  final bool isMask; //遮罩

  const AppVideo({
    required this.url,
    this.pause = true,
    this.isMask = false,
    this.playSize = 50,
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _AppVideoState();
  }
}

class _AppVideoState extends State<AppVideo> {
  VideoPlayerController? _controller;

  _init() async {
    if (!urlValid(widget.url)) {
      _controller = VideoPlayerController.file(File(widget.url));
    } else {
      File file = await CacheFile.load(widget.url);
      _controller = VideoPlayerController.file(file);
    }
    await _controller!.initialize();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    var local = !urlValid(widget.url);
    var cover = local ? '' : getVideoCover(widget.url);
    if (_controller == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
        ),
        if (!_controller!.value.isPlaying && cover.isNotEmpty)
          AppNetworkImage(
            cover,
            width: double.infinity,
          ),
        if (!_controller!.value.isPlaying)
          Image.asset(
            assetPath('images/play2.png'),
            width: widget.playSize,
          ),
        if (widget.isMask)
          Opacity(
            opacity: 0.2,
            child: Container(color: myColors.lineGrey),
          ),
      ],
    );
  }
}

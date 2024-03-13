import 'dart:io';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/cache_file.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';

class WinPlayVideo extends StatefulWidget {
  final String url;
  final bool autoPlay;
  final bool showContorll;

  const WinPlayVideo({
    required this.url,
    this.autoPlay = true,
    this.showContorll = true,
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _WinPlayVideoState();
  }
}

class _WinPlayVideoState extends State<WinPlayVideo> {
  Player? player;

  winVideo() async {
    File? file;
    logger.d(widget.url);
    if (!urlValid(widget.url)) {
      file = File(widget.url);
    } else {
      file = await CacheFile.load(widget.url);
    }
    player = Player(id: randomNumber(1000000000));
    player!.open(
      Media.file(file),
      autoStart: widget.autoPlay,
      // Media.network(
      //     'https://static.vlian.cn:8090/files/vlian/files/10682/1663430400/pre_AIQN6E1E.mp4'),
    );
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    winVideo();
  }

  @override
  void dispose() {
    super.dispose();
    player?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (player == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: Video(
            player: player,
            // height: 1920.0,
            // width: 1080.0,
            scale: 1.0, // default
            showControls: widget.showContorll, // default
          ),
        ),
      ),
    );
  }
}

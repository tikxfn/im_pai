import 'dart:async';
import 'dart:io';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/cache_file.dart';
import 'package:unionchat/common/func.dart';

class AppVideoWin extends StatefulWidget {
  final String url;
  final bool autoPlay;
  final bool showContorll;

  const AppVideoWin({
    required this.url,
    this.autoPlay = true,
    this.showContorll = true,
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _AppVideoWinState();
  }
}

class _AppVideoWinState extends State<AppVideoWin> {
  Player? player;

  winVideo() async {
    File? file;
    StreamSubscription<PositionState>? sub;
    if (!urlValid(widget.url)) {
      file = File(widget.url);
    } else {
      file = await CacheFile.load(widget.url);
    }
    player = Player(id: randomNumber(1000000000))..setVolume(0);
    stop(PositionState event) {
      sub?.cancel();
      player!.stop();
    }

    sub = player!.positionStream.listen((event) {
      var seconds = event.duration?.inSeconds ?? 0;
      if (seconds <= 0) return;
      stop(event);
    });
    player!.open(
      Media.file(
        file,
      ),
      autoStart: true,
    );
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
    return Stack(
      alignment: Alignment.center,
      children: [
        Video(
          player: player,
          // height: 1920.0,
          // width: 1080.0,
          scale: 1.0, // default
          showControls: widget.showContorll, // default
          fit: BoxFit.cover,
        ),
        Image.asset(
          assetPath('images/play2.png'),
          width: 40,
        ),
      ],
    );
  }
}

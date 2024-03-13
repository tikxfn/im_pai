import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/cache_file.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../common/func.dart';
import '../common/media_save.dart';

class AppPlayVideo extends StatefulWidget {
  final String url;
  final bool showSave;

  const AppPlayVideo({
    required this.url,
    this.showSave = true,
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _AppPlayVideoState();
  }
}

class _AppPlayVideoState extends State<AppPlayVideo> {
  VideoPlayerController? _controller;
  ChewieController? _chewieController;

  _init() async {
    if (!urlValid(widget.url)) {
      _controller = VideoPlayerController.file(File(widget.url));
    } else {
      File file = await CacheFile.load(widget.url);
      _controller = VideoPlayerController.file(file);
    }
    await _controller!.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _controller!,
      autoPlay: true,
      // fullScreenByDefault: true,
      showOptions: false,
      // optionsBuilder: (context, optionItems){
      //   return
      // },
    );
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
    _chewieController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      backgroundColor: myColors.black,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.close,
            color: myColors.white,
          ),
        ),
        backgroundColor: myColors.black,
        actions: [
          if (urlValid(widget.url) && widget.showSave)
            TextButton(
              onPressed: () {
                MediaSave().saveMedia(widget.url, video: true);
              },
              child: Text(
                '保存'.tr(),
                style: TextStyle(color: myColors.primary),
              ),
            ),
        ],
      ),
      body: _controller == null || _chewieController == null
          ? Center(
              child: Image.asset(
                assetPath('images/loading.gif'),
                width: 40,
              ),
            )
          : SafeArea(
              child: Center(
                child: Chewie(controller: _chewieController!),
              ),
            ),
    );
  }
}

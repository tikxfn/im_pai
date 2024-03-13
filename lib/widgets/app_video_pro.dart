import 'dart:io';

import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/widgets/network_image.dart';
import 'package:unionchat/widgets/video_player.dart';
import 'package:unionchat/widgets/video_player_win.dart';

class AppVideoPro extends StatelessWidget {
  final String path;
  final double? loadHeight;

  const AppVideoPro(this.path, {this.loadHeight, super.key});

  @override
  Widget build(BuildContext context) {
    var myColors = ThemeNotifier();
    var local = !urlValid(path);
    var cover = local ? '' : getVideoCover(path);
    return Stack(
      alignment: Alignment.center,
      children: [
        if (local && platformPhone)
          SizedBox(
            width: double.infinity,
            child: AppVideo(url: path),
          ),
        if (local && Platform.isWindows)
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              maxHeight: 300,
            ),
            child: AppVideoWin(
              url: path,
              autoPlay: false,
              showContorll: false,
            ),
          ),
        if (!local)
          cover.isNotEmpty
              ? AppNetworkImage(
                  cover,
                  width: double.infinity,
                  loadHeight: loadHeight,
                  borderRadius: BorderRadius.circular(5),
                )
              : Container(
                  width: double.infinity,
                  height: 300,
                  padding: const EdgeInsets.only(top: 30),
                  alignment: Alignment.topCenter,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: myColors.grey,
                  ),
                  child: Text(
                    '未找到视频封面',
                    style: TextStyle(
                      color: myColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        if (!local) Image.asset(assetPath('images/play2.png'), width: 40),
      ],
    );
  }
}

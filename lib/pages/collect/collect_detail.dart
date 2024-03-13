import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/db/enum.dart';
import 'package:unionchat/db/model/message.dart';
import 'package:unionchat/widgets/network_image.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:unionchat/widgets/url_text.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../common/cache_file.dart';
import '../../notifier/theme_notifier.dart';
import '../../widgets/photo_preview.dart';

class CollectDetail extends StatefulWidget {
  const CollectDetail({super.key});

  static const String path = 'collect/detail';

  @override
  State<CollectDetail> createState() => _CollectDetailState();
}

class _CollectDetailState extends State<CollectDetail> {
  final player = AudioPlayer();
  StreamSubscription<PlayerState>? audioSub;
  Message? data;
  TaskStatus status = TaskStatus.nil;
  bool playing = false;

  //语音播放监听
  audioListen(PlayerState state) {
    bool stop = false;
    switch (state) {
      case PlayerState.stopped:
        stop = true;
        break;
      case PlayerState.playing:
        break;
      case PlayerState.paused:
        stop = true;
        break;
      case PlayerState.completed:
        stop = true;
        break;
      case PlayerState.disposed:
        stop = true;
        break;
    }
    if (stop) {
      setState(() {
        playing = false;
      });
    }
  }

  //播放语音
  playVoice() async {
    if (status == TaskStatus.sending) return;
    String path = data?.content ?? '';
    if (path.isEmpty) return;
    if (player.state == PlayerState.playing) {
      await player.stop();
    }
    setState(() {
      status = TaskStatus.sending;
    });
    var file = await CacheFile.load(path);
    setState(() {
      status = TaskStatus.success;
      playing = true;
    });
    await player.play(DeviceFileSource(file.path));
  }

  @override
  void initState() {
    super.initState();
    audioSub = player.onPlayerStateChanged.listen(audioListen);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      setState(() {
        data = ModalRoute.of(context)?.settings.arguments as Message?;
      });
    });
  }

  @override
  void dispose() {
    if (audioSub != null) audioSub!.cancel();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('收藏详情'),
      ),
      body: ThemeBody(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 10,
          ),
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 1),
                  height: .5,
                  color: myColors.lineGrey,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  decoration: BoxDecoration(
                    color: myColors.white,
                  ),
                  child: Text(
                    '来自 ${data?.senderUser?.nickname ?? ''} ${time2formatDate((data?.createTime ?? 0).toString())}',
                    style: TextStyle(
                      color: myColors.textGrey,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            if (data?.type == GMessageType.TEXT)
              UrlText(data?.content ?? '', select: true),
            if (data?.type == GMessageType.AUDIO)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: playVoice,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: myColors.grey1,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (playing)
                            Image.asset(
                              assetPath('images/voice_play.gif'),
                              width: 20,
                            ),
                          if (!playing)
                            Image.asset(
                              assetPath('images/sp_yuying.png'),
                              width: 20,
                            ),
                          const SizedBox(width: 5),
                          Text('${data?.duration}”'),
                        ],
                      ),
                      if (status == TaskStatus.sending)
                        const CupertinoActivityIndicator(radius: 7),
                    ],
                  ),
                ),
              ),
            if (data?.type == GMessageType.IMAGE)
              Column(
                children: (data?.content ?? '').split(',').map((e) {
                  var mediaList = (data!.content ?? '').split(',');
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhotoPreview(
                            list: mediaList,
                            index: mediaList.indexOf(e),
                          ),
                        ),
                      );
                    },
                    child: AppNetworkImage(
                      e,
                      width: double.infinity,
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(height: .5, color: myColors.lineGrey),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 2,
                  height: 2,
                  decoration: BoxDecoration(
                    color: myColors.lineGrey,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(height: .5, color: myColors.lineGrey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

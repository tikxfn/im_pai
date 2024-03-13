import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/db/message_utils.dart';
import 'package:unionchat/db/model/message.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/widgets/network_image.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../play_video.dart';
import '../play_video_win.dart';

class SearchVideoPage extends StatefulWidget {
  const SearchVideoPage({super.key});

  static const String path = 'SearchVideoPage/talk';

  @override
  State<SearchVideoPage> createState() => _SearchVideoPageState();
}

class _SearchVideoPageState extends State<SearchVideoPage> {
  List<Message> searchImageResults = [];
  String userId = '';
  String pairId = '';
  String roomId = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      dynamic args = ModalRoute.of(context)!.settings.arguments;
      userId = args['id'] ?? '';
      pairId = args['pairId'] ?? '';
      roomId = args['roomId'] ?? '';
      requestImageData();
    });
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          '视频'.tr(),
          style: TextStyle(color: myColors.white),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: myColors.white,
          ),
        ),
      ),
      body: createBody(),
    );
  }

  Widget createBody() {
    return GridView.count(
      padding: const EdgeInsets.all(10),
      scrollDirection: Axis.vertical,
      crossAxisSpacing: 3,
      crossAxisCount: 4,
      mainAxisSpacing: 3,
      childAspectRatio: 1.0,
      children: _getListData(),
    );
  }

  List<Widget> _getListData() {
    var myColors = ThemeNotifier();
    var tempList = searchImageResults.map((model) {
      String cover = model.imageUrl ?? '';
      return GestureDetector(
        onTap: () {
          String url = model.fileUrl ?? '';
          Navigator.push(
            context,
            CupertinoModalPopupRoute(
              builder: (context) {
                if (Platform.isWindows) {
                  return WinPlayVideo(url: url);
                } else {
                  return AppPlayVideo(url: url);
                }
              },
            ),
          );
        },
        child: Stack(
          children: [
            if (cover.isEmpty)
              Container(
                padding: const EdgeInsets.only(top: 30),
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                  color: myColors.grey,
                ),
                child: Text(
                  '未找到视频封面',
                  style: TextStyle(
                    fontSize: 9,
                    color: myColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (cover.isNotEmpty)
              AppNetworkImage(
                cover,
                // imageSpecification: ImageSpecification.w120,
                fit: BoxFit.cover,
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.only(left: 0, right: 0, bottom: 0),
                height: 25,
                color: Colors.black.withOpacity(0.3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.videocam,
                      color: myColors.white,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Text(
                        formatDuration(model.duration ?? 0),
                        style: TextStyle(
                          color: myColors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
    // ('124124','124214')
    return tempList.toList();
  }

  //搜索图片数据
  Future<void> requestImageData() async {
    searchImageResults = await MessageUtil.searchChannelMessage(
      pairId,
      '',
      type: GMessageType.VIDEO,
    );
    setState(() {});
  }

  String formatDuration(int seconds) {
    // int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    // String hoursStr = hours.toString().padLeft(2, '0');
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = remainingSeconds.toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }
}

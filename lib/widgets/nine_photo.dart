//图片九宫格
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/pages/play_video.dart';
import 'package:unionchat/pages/play_video_win.dart';
import 'package:unionchat/widgets/photo_preview.dart';
import 'package:openapi/api.dart';
// import 'package:unionchat/widgets/media_preview.dart';

import 'network_image.dart';

class PhotoList extends StatelessWidget {
  final double width;
  final List<String> photos;
  final GArticleType type;

  const PhotoList({
    required this.photos,
    required this.width,
    required this.type,
    super.key,
  });

  //获取消息中的媒体文件
  getMessageMedia() {
    List<String> mediaList = [];
    for (var v in photos) {
      mediaList.add(v);
    }
    return mediaList;
  }

  //获取当前图片的index
  getCurrentMediaIndex(List<String> list, String url) {
    for (var i = 0; i < list.length; i++) {
      if (list[i] == url) return i;
    }
  }

  //预览图片、视频
  goImage(BuildContext context, url) {
    List<String> mediaList = getMessageMedia();
    int index = getCurrentMediaIndex(mediaList, url);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoPreview(
          list: getMessageMedia(),
          index: index,
        ),
      ),
    );
  }

  goVideo(BuildContext context, String url) {
    if (platformPhone) {
      Navigator.push(
        context,
        CupertinoModalPopupRoute(
          builder: (context) {
            return AppPlayVideo(
              url: url,
            );
          },
        ),
      );
    } else if (Platform.isWindows) {
      Navigator.push(
        context,
        CupertinoModalPopupRoute(
          builder: (context) {
            return WinPlayVideo(
              url: url,
            );
          },
        ),
      );
    } else {
      tip('该平台暂不支持'.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    double spacing = 5;
    var w = width;
    var num = photos.length;
    // double maxWidth = (width - spacing * 2) / 3;
    double minWidth = ((width - spacing * 2) ~/ 3).toDouble();
    double middleWidth = ((width - spacing) ~/ 2).toDouble();
    if (!platformPhone) {
      minWidth = middleWidth = w / 3;
    }
    if (num == 1) {
      w = middleWidth;
    }
    if (num == 2 || num == 4) {
      w = middleWidth;
    }
    if (num == 3 || num > 4) {
      w = minWidth;
    }
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: photos.map((e) {
        String url = e;
        if (type == GArticleType.VIDEO) url = getVideoCover(e);

        return GestureDetector(
          onTap: () {
            if (type == GArticleType.IMAGE) goImage(context, e);
            if (type == GArticleType.VIDEO) goVideo(context, e);
          },
          child: type != GArticleType.VIDEO
              ? AppNetworkImage(
                  url,
                  width: w,
                  height: w,
                  borderRadius: BorderRadius.circular(10),
                  imageSpecification: url.endsWith('.gif')
                      ? ImageSpecification.nil
                      : ImageSpecification.w230,
                  fit: BoxFit.cover,
                )
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    AppNetworkImage(
                      url,
                      width: w,
                      height: w,
                      borderRadius: BorderRadius.circular(10),
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      child: Image.asset(
                        assetPath('images/play2.png'),
                        width: 30,
                      ),
                    )
                  ],
                ),
        );
      }).toList(),
    );
  }
}

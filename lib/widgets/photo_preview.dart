import 'package:easy_localization/easy_localization.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/cache_file.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/media_save.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/widgets/qrcode_result.dart';
import 'package:provider/provider.dart';
import 'package:scan/scan.dart';

import '../common/common_data.dart';
import 'network_image.dart';

class PhotoPreview extends StatefulWidget {
  final List<String> list;
  final int index;
  final bool showSave;
  final bool isImages; //是否是images文件夹

  const PhotoPreview({
    required this.list,
    this.showSave = true,
    this.index = 0,
    this.isImages = false,
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _PhotoPreviewState();
  }
}

class _PhotoPreviewState extends State<PhotoPreview> {
  int index = 0;
  List<String> list = [];
  List<int> originIds = [];

  // 识别图中二维码
  sanPhotoQrcode(String url) async {
    loading();
    try {
      var path = url;
      if (urlValid(url)) {
        var file = await CacheFile.load(url);
        path = file.path;
      }
      var code = await Scan.parse(path);
      if (code == null) tip('未识别到有效信息');
      if (mounted) {
        bool valid = getResult(code!, context);
        if (!valid) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QrcodeResult(code),
            ),
          );
        }
      }
    } catch (e) {
      logger.e(e);
      tipError('未识别到有效信息');
    } finally {
      loadClose();
    }
  }

  // 长按
  photoLongTap() async {
    var url = list[index];
    openSheetMenu(context, list: ['识别图中二维码'], onTap: (i) async {
      sanPhotoQrcode(url);
    });
  }

  //查看原图
  seeOrigin() {
    var url = list[index];
    originalImage.add(url);
    setState(() {});
  }

  //判断是否已经缓存图片
  _imageCached() async {
    index = widget.index;
    list = widget.list;
    for (var v in list) {
      if (!urlValid(v) || originalImage.contains(v)) continue;
      var cacheKey = v.split('/').last.split('.').first;
      bool cached = await cachedImageExists(v, cacheKey: cacheKey);
      if (cached) originalImage.add(v);
    }
    setState(() {});
  }

  @override
  void initState() {
    _imageCached();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    // var url = widget.list[index];
    // bool hasOriginal = true;
    // bool hasOriginal = originalImage.contains(url);
    // if (!urlValid(url)) {
    //   hasOriginal = true;
    // }
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
        title: Text(
          '${index + 1}/${widget.list.length}',
          style: TextStyle(
            color: myColors.white,
          ),
        ),
        actions: [
          if (widget.showSave)
            TextButton(
              onPressed: () {
                // logger.i(index);
                MediaSave().saveMedia(widget.list[index]);
              },
              child: Text(
                '保存'.tr(),
                style: TextStyle(color: myColors.primary),
              ),
            ),
        ],
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onSecondaryTap: () {
              if (!platformPhone) photoLongTap();
            },
            onLongPress: () {
              if (platformPhone) photoLongTap();
            },
            onTap: () {
              Navigator.pop(context);
            },
            child: ExtendedImageGesturePageView.builder(
              itemBuilder: (BuildContext context, int i) {
                var item = widget.list[i];
                Widget image = AppNetworkImage(
                  item,
                  assets:
                      item.contains('assets/images/avatar') || widget.isImages,
                  width: double.infinity,
                  height: double.infinity,
                  mode: ExtendedImageMode.gesture,
                  imageSpecification: ImageSpecification.nil,
                  // imageSpecification: hasOriginal
                  //     ? ImageSpecification.nil
                  //     : ImageSpecification.w120,
                  fit: BoxFit.contain,
                  loadColor: myColors.white,
                );
                if (i == index) {
                  return Hero(
                    tag: item + i.toString(),
                    child: image,
                  );
                } else {
                  return image;
                }
              },
              itemCount: widget.list.length,
              onPageChanged: (int i) {
                setState(() {
                  index = i;
                });
              },
              controller: ExtendedPageController(initialPage: index),
              scrollDirection: Axis.horizontal,
            ),
          ),
          // if (!hasOriginal)
          //   Positioned(
          //     bottom: 20,
          //     child: SafeArea(
          //       child: GestureDetector(
          //         onTap: seeOrigin,
          //         behavior: HitTestBehavior.opaque,
          //         child: Container(
          //           height: 30,
          //           alignment: Alignment.center,
          //           padding: const EdgeInsets.symmetric(
          //             horizontal: 20,
          //           ),
          //           decoration: BoxDecoration(
          //             color: myColors.voiceBg,
          //             borderRadius: BorderRadius.circular(3),
          //           ),
          //           child: Text(
          //             '查看原图',
          //             style: TextStyle(
          //               color: myColors.white,
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // Align(
          //   alignment: Alignment.center,
          //   child: CupertinoActivityIndicator(radius: 15),
          // ),
        ],
      ),
    );
  }
}

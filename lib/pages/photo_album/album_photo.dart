import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/enum.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/pages/photo_album/album_edit.dart';
import 'package:unionchat/pages/photo_album/photo_upload.dart';
import 'package:unionchat/pages/play_video.dart';
import 'package:unionchat/pages/play_video_win.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/network_image.dart';
import 'package:unionchat/widgets/pager_box.dart';
import 'package:unionchat/widgets/photo_preview.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

class AlbumPhoto extends StatefulWidget {
  const AlbumPhoto({super.key});

  static const String path = 'photo/album_photo';

  @override
  State<StatefulWidget> createState() {
    return _AlbumPhotoState();
  }
}

class _AlbumPhotoState extends State<AlbumPhoto> {
  bool showDel = false;
  String albumId = '';
  String albumName = '';
  LoadStatus _loadStatus = LoadStatus.nil; //数据加载状态
  int limit = 100;

  //图片列表
  List<GAlbumContentModel> photoList = [];
  List<GAlbumContentModel> activeIds = [];

  //获取列表
  getList({bool init = false}) async {
    if (_loadStatus == LoadStatus.loading || !mounted) return;
    final api = AlbumApi(apiClient());
    try {
      final res = await api.albumDetails(
        V1AlbumDetailsArgs(
          albumId: albumId,
          pager: GPagination(
            limit: limit.toString(),
            offset: init ? '0' : photoList.length.toString(),
          ),
        ),
      );

      albumName = res?.albumName ?? '';

      List<GAlbumContentModel> newPhotoList = res?.list.toList() ?? [];
      if (!mounted) return;
      if (init) {
        photoList = newPhotoList;
      } else {
        photoList.addAll(newPhotoList);
      }
      _loadStatus =
          (res?.list ?? []).length >= limit ? LoadStatus.more : LoadStatus.no;
      if (mounted) setState(() {});
      if (res == null) return 0;

      return res.list.length;
    } on ApiException catch (e) {
      onError(e);
      return limit;
    } finally {}
  }

  //获取当前图片的index
  getCurrentMediaIndex(List<String> list, String url) {
    for (var i = 0; i < list.length; i++) {
      if (list[i] == url) return i;
    }
  }

  //预览图片
  goImage(url) async {
    //已选择图片列表
    List<GAlbumContentModel> imageData = [];
    for (var v in photoList) {
      if (v.type == GAlbumContentType.PHOTO) {
        imageData.add(v);
      }
    }
    List<String> mediaList = imageData.map((e) => e.url.toString()).toList();
    int index = getCurrentMediaIndex(mediaList, url);
    // ignore: use_build_context_synchronously
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoPreview(
          list: mediaList,
          index: index,
        ),
      ),
    );
  }

  //预览视频
  goVideo(String url) {
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

  //选择图片
  onChoose(GAlbumContentModel e) {
    if (activeIds.contains(e)) {
      activeIds.remove(e);
    } else {
      activeIds.add(e);
    }
    setState(() {});
  }

  //删除图片
  delete() async {
    if (activeIds.isEmpty) return;
    confirm(
      context,
      title: '确定要删除选择的图片？'.tr(),
      onEnter: () async {
        List<String> groupList = [];
        for (var v in activeIds) {
          groupList.add(v.id.toString());
        }
        final api = AlbumApi(apiClient());
        loading();
        try {
          await api.albumDelContent(
            GIdsArgs(
              ids: groupList,
            ),
          );
          if (!mounted) return;
          if (mounted) {
            showDel = false;
            getList(init: true);
          }
        } on ApiException catch (e) {
          onError(e);
        } finally {
          loadClose();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color textColor = myColors.iconThemeColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          albumName,
          style: TextStyle(
            color: textColor,
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            showDel
                ? setState(() {
                    showDel = !showDel;
                  })
                : Navigator.pop(context);
          },
          child: showDel
              ? Container(
                  alignment: Alignment.center,
                  child: Text(
                    '取消'.tr(),
                    style: TextStyle(color: textColor),
                  ),
                )
              : Icon(
                  Icons.arrow_back,
                  color: textColor,
                ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              showDel
                  ? delete()
                  : Navigator.pushNamed(context, AlbumEdit.path, arguments: {
                      'albumName': albumName,
                      'albumId': albumId,
                    }).then((value) {
                      getList(init: true);
                    });
            },
            child: Text(
              showDel ? '删除'.tr() : '编辑相册'.tr(),
              style: TextStyle(
                color: showDel ? myColors.red : myColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: ThemeBody(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: PagerBox(
                limit: limit,
                onInit: () async {
                  if (!mounted) return 0;
                  // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  //   if (!mounted) return;
                  dynamic args =
                      ModalRoute.of(context)!.settings.arguments ?? {};
                  if (args['albumId'] != null) albumId = args['albumId'] ?? '';
                  if (args['albumName'] != null) {
                    albumName = args['albumName'] ?? '';
                  }
                  // });
                  return await getList(init: true);
                },
                onPullDown: () async {
                  //下拉刷新

                  return await getList(init: true);
                },
                onPullUp: () async {
                  //上拉加载
                  return await getList();
                },
                children: [
                  //图片
                  appImages(photoList)
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, PhotoUpload.path, arguments: {
            'albumName': albumName,
            'albumId': albumId,
          }).then((value) {
            getList(init: true);
          });
        },
        child: SizedBox(
          width: 77,
          height: 77,
          child: Image.asset(
            assetPath('images/help/btn_tianjia.png'),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  //图片盒子
  Widget appImages(List<GAlbumContentModel> photoList) {
    var myColors = ThemeNotifier();
    Color bgColor = myColors.themeBackgroundColor;
    double tabSize = MediaQuery.of(context).size.width;
    int rowNumber = 3;
    if (!platformPhone) {
      rowNumber = 4;
      tabSize = tabSize - 370;
    }
    double size = (tabSize - 60) / rowNumber;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: bgColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final asset in photoList) _imagesBox(asset, size), //图片项
            ],
          ),
        ],
      ),
    );
  }

//图片项
  Widget _imagesBox(GAlbumContentModel asset, double size) {
    String url = asset.url!;
    if (asset.type == GAlbumContentType.VIDEO) url = getVideoCover(asset.url!);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: GestureDetector(
        onTap: () async {
          if (showDel) {
            onChoose(asset);
            return;
          }
          if (asset.type == GAlbumContentType.PHOTO) goImage(asset.url);
          if (asset.type == GAlbumContentType.VIDEO) goVideo(asset.url!);
        },
        onLongPress: () {
          showDel = true;
          setState(() {});
        },
        child: asset.type == GAlbumContentType.PHOTO
            ? Stack(
                children: [
                  AppNetworkImage(
                    url,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    imageSpecification: ImageSpecification.w500,
                  ),
                  if (showDel)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: AppCheckbox(
                        value: activeIds.contains(asset),
                        size: 25,
                        paddingLeft: 15,
                      ),
                    )
                ],
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  AppNetworkImage(
                    url,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    imageSpecification: ImageSpecification.w500,
                  ),
                  Positioned(
                    child: Image.asset(
                      assetPath('images/play2.png'),
                      width: 30,
                    ),
                  ),
                  if (showDel)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: AppCheckbox(
                        value: activeIds.contains(asset),
                        size: 25,
                        paddingLeft: 15,
                      ),
                    )
                ],
              ),
      ),
    );
  }
}

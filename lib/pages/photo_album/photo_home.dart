import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/pages/photo_album/album_add.dart';
import 'package:unionchat/pages/photo_album/album_photo.dart';
import 'package:unionchat/pages/photo_album/album_share.dart';
import 'package:unionchat/pages/photo_album/photo_upload.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/network_image.dart';
import 'package:unionchat/widgets/row_list.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';

class PhotoHome extends StatefulWidget {
  const PhotoHome({super.key});

  static const String path = 'photo/home';

  @override
  State<PhotoHome> createState() => _PhotoHomeState();
}

class _PhotoHomeState extends State<PhotoHome> {
  List<GAlbumModel> albumData = [];
  List<GAlbumModel> activeIds = [];
  bool showShare = false;

  //获取列表
  getList() async {
    final api = AlbumApi(apiClient());
    try {
      final res = await api.albumList({});
      albumData = res?.list.toList() ?? [];
      if (mounted) setState(() {});
    } on ApiException catch (e) {
      onError(e);
    }
  }

  //选择相册
  onChoose(GAlbumModel e) {
    if (activeIds.contains(e)) {
      activeIds.remove(e);
    } else {
      activeIds.add(e);
    }
    setState(() {});
  }

  //分享相册
  share() async {
    if (activeIds.isEmpty) return;
    confirm(
      context,
      title: '确定要分享选择的相册？'.tr(),
      onEnter: () async {
        List<String> groupList = [];
        for (var v in activeIds) {
          groupList.add(v.id.toString());
        }
        final api = AlbumApi(apiClient());
        loading();
        try {
          final res = await api.albumShare(
            GIdsArgs(
              ids: groupList,
            ),
          );
          if (!mounted || res == null) return;
          showShare = false;
          activeIds = [];
          String url = res.url!;
          // ClipboardData data = ClipboardData(text: url);
          // Clipboard.setData(data);
          // tipSuccess('分享链接已复制到粘贴板'.tr());
          if (mounted) {
            Navigator.pushNamed(context, AlbumShare.path,
                arguments: {'url': url});
          }

          setState(() {});
        } on ApiException catch (e) {
          onError(e);
        } finally {
          loadClose();
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getList();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color textColor = myColors.iconThemeColor;
    double size = MediaQuery.of(context).size.width;
    int rowNumber = 2;
    if (!platformPhone) {
      rowNumber = 5;
      size = size - 350;
    }
    double w = (size - 10 * (rowNumber - 1)) / rowNumber;
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            showShare
                ? setState(() {
                    showShare = false;
                  })
                : Navigator.pop(context);
          },
          child: showShare
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
        title: Text('相册'.tr()),
        actions: [
          showShare
              ? TextButton(
                  onPressed: activeIds.isEmpty
                      ? null
                      : () {
                          share();
                        },
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      '分享'.tr(),
                      style: TextStyle(
                          color: activeIds.isEmpty
                              ? myColors.subIconThemeColor
                              : myColors.blueTitle),
                    ),
                  ),
                )
              : IconButton(
                  onPressed: () {
                    setState(() {
                      showShare = true;
                    });
                  },
                  icon: Image.asset(
                    assetPath('images/my/fengxiang.png'),
                    height: 18,
                    width: 18,
                  ),
                ),
        ],
      ),
      body: ThemeBody(
        child: RefreshIndicator(
          onRefresh: () async {
            await getList();
          },
          child: ListView(
            children: [
              RowList(
                rowNumber: rowNumber,
                lineSpacing: 10,
                children: [
                  for (var i = 0; i < albumData.length; i++)
                    _photoData(w, albumData[i])
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: !showShare && albumData.isNotEmpty
          ? GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, PhotoUpload.path).then((value) {
                  getList();
                });
              },
              child: SizedBox(
                child: Image.asset(
                  assetPath('images/help/btn_tianjia.png'),
                  width: 53,
                  height: 53,
                  fit: BoxFit.contain,
                ),
              ),
            )
          : null,
      bottomNavigationBar: !showShare
          ? BottomButton(
              title: '新建相册',
              onTap: () {
                Navigator.pushNamed(context, AlbumAdd.path).then((value) {
                  getList();
                });
              },
            )
          : null,
    );
  }

  _photoData(double w, GAlbumModel data) {
    var myColors = ThemeNotifier();
    Color textColor = myColors.iconThemeColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: GestureDetector(
        onTap: () {
          if (showShare) {
            onChoose(data);
            return;
          }
          Navigator.pushNamed(context, AlbumPhoto.path, arguments: {
            'albumId': data.id,
            'albumName': data.name,
          }).then((value) {
            getList();
          });
        },
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                data.cover != null && data.cover!.isNotEmpty
                    ? AppNetworkImage(
                        data.cover!,
                        width: w,
                        height: w,
                        fit: BoxFit.cover,
                        imageSpecification: ImageSpecification.w500,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      )
                    : Container(
                        width: w,
                        height: w,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          assetPath('images/my/sp_tu.png'),
                          width: w,
                          height: w,
                          fit: BoxFit.cover,
                        ),
                      ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.name ?? '',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 17,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        '共张'.tr(args: [
                          (toInt(data.photoQuantity) +
                                  toInt(data.videoQuantity))
                              .toString()
                        ]),
                        style: TextStyle(
                          fontSize: 14,
                          color: myColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            if (showShare)
              Positioned(
                right: 10,
                top: 10,
                child: AppCheckbox(
                  value: activeIds.contains(data),
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

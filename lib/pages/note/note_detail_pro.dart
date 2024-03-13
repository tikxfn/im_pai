import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openapi/api.dart';
import 'package:unionchat/common/media_save.dart';
import 'package:unionchat/db/model/message.dart';
import 'package:unionchat/db/model/notes.dart';
import 'package:unionchat/db/notes_utils.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/pages/note/note_create_pro.dart';
import 'package:unionchat/pages/play_video_win.dart';
import 'package:unionchat/pages/share/share_home.dart';
import 'package:unionchat/widgets/app_video_pro.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/map.dart';
import 'package:unionchat/widgets/network_image.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../../common/func.dart';
import '../../notifier/theme_notifier.dart';
import '../../widgets/photo_preview.dart';
import '../play_video.dart';

class NoteDetailPro extends StatefulWidget {
  const NoteDetailPro({super.key});

  static const String path = 'note/detail/pro';

  @override
  State<NoteDetailPro> createState() => _NoteDetailProState();
}

class _NoteDetailProState extends State<NoteDetailPro> {
  ScreenshotController screenshotController = ScreenshotController();
  Notes? _notes;
  bool editPreview = false;
  bool preview = false;
  String id = '';
  bool collect = false; //是否是收藏的笔记

  // 获取详情
  getDetail() async {
    if (!mounted || collect) return;
    _notes = await NotesUtils.getById(toInt(id));
    setState(() {});
  }

  // 视频播放
  _playVideo(String url) {
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
  }

  // 图片预览
  _previewPhoto(String url) {
    List<String> mediaList = [];
    for (var v in _notes!.items) {
      if (v.type == GNoteType.IMAGE) {
        mediaList.add(v.content ?? '');
      }
    }
    int index = mediaList.indexOf(url);
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

  // 截图
  Future<void> saveImage() async {
    loading(text: '正在生成图片');
    try {
      Uint8List? imageBytes = await screenshotController.capture();
      if (imageBytes != null) {
        loadClose();
        var path = await MediaSave().saveMediaBytes(imageBytes, 'png');
        if (path.isNotEmpty) tipSuccess('已保存到相册');
      }
    } catch (e) {
      logger.e(e);
    } finally {
      loadClose();
    }
  }

  // 标题组件
  Widget _titleWidget(int i) {
    var v = _notes!.items[i];
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Text(
        v.content ?? '',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 文本组件
  Widget _textWidget(int i) {
    var v = _notes!.items[i];
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Text(
        v.content ?? '',
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  // 图片组件
  Widget _imageWidget(int i) {
    var v = _notes!.items[i];
    if ((v.content ?? '').isEmpty) return Container();
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: InkWell(
        onTap: () => _previewPhoto(v.content ?? ''),
        child: AppNetworkImage(
          v.content ?? '',
          width: double.infinity,
          loadHeight: 300,
          // imageSpecification: ImageSpecification.w500,
        ),
      ),
    );
  }

  // 视频组件
  Widget _videoWidget(int i) {
    var v = _notes!.items[i];
    if ((v.content ?? '').isEmpty) return Container();
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: InkWell(
        onTap: () => _playVideo(v.content ?? ''),
        child: AppVideoPro(v.content ?? '', loadHeight: 300),
      ),
    );
  }

  // 位置组件
  Widget _locationWidget(int i) {
    var v = _notes!.items[i];
    if ((v.content ?? '').isEmpty) return Container();
    var myColors = ThemeNotifier();
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return AppMap(
                showMap: true,
                location: MapLocation(
                  location: v.content ?? '',
                  title: v.title ?? '',
                  desc: v.subTitle ?? '',
                ),
              );
            },
          ),
        );
        // Navigator.pushNamed(
        //   context,
        //   MapShowPage.path,
        //   arguments: {
        //     'location': v.content,
        //     'title': v.title,
        //     'content': v.subTitle,
        //   },
        // );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 5),
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          color: myColors.grey1,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: myColors.im2CircleIcon,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.location_on,
                color: myColors.white,
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    v.title ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    v.subTitle ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      dynamic args = ModalRoute.of(context)?.settings.arguments ?? {};
      id = toStr(args['id']);
      preview = args['preview'] ?? false;
      collect = args['collect'] ?? false;
      if (id.isNotEmpty) getDetail();
      if (args['notes'] != null) {
        setState(() {
          if (!collect && !preview) editPreview = true;
          _notes = args['notes'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color textColor = myColors.iconThemeColor;
    Color bgColor = myColors.themeBackgroundColor;
    return Scaffold(
      appBar: AppBar(
        title: Text(editPreview ? '笔记预览' : '笔记详情'),
        actions: [
          if (!editPreview)
            GestureDetector(
              onTap: () {
                if (_notes == null) return;
                Navigator.push(
                  context,
                  CupertinoModalPopupRoute(
                    builder: (context) {
                      var msg = Message()
                        ..senderUser = getSenderUser()
                        ..type = GMessageType.NOTES
                        ..contentId = toInt(id)
                        ..content = _notes!.toJson().toString();
                      return ShareHome(
                        shareText: '[笔记分享]',
                        list: [msg],
                      );
                    },
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.only(right: 15),
                alignment: Alignment.center,
                child: Image.asset(
                  assetPath('images/my/btn_fenxiang.png'),
                  color: textColor,
                  height: 20,
                  width: 20,
                  // color: Colors.white,
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
              child: Stack(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    child: SingleChildScrollView(
                      child: Screenshot(
                        controller: screenshotController,
                        child: Container(
                          color: bgColor,
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: (_notes?.items ?? []).map((v) {
                              var i = _notes!.items.indexOf(v);
                              if (v.type == GNoteType.TITLE) {
                                return _titleWidget(i);
                              }
                              if (v.type == GNoteType.TEXT) {
                                return _textWidget(i);
                              }
                              if (v.type == GNoteType.IMAGE) {
                                return _imageWidget(i);
                              }
                              if (v.type == GNoteType.VIDEO) {
                                return _videoWidget(i);
                              }
                              if (v.type == GNoteType.LOCATION) {
                                return _locationWidget(i);
                              }
                              return Container();
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 20,
                    bottom: 20,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            saveImage();
                          },
                          child: Image.asset(
                            assetPath('images/my/btn_jietu.png'),
                            height: 60,
                            width: 60,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        if (!preview && !editPreview && !collect)
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                NoteCreatePro.path,
                                arguments: {'id': id, 'collect': collect},
                              ).then((_) {
                                getDetail();
                              });
                            },
                            child: Image.asset(
                              assetPath('images/my/btn_bianji.png'),
                              height: 60,
                              width: 60,
                            ),
                          )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (editPreview)
              AppButtonBottomBox(
                child: CircleButton(
                  title: '继续编辑',
                  height: 45,
                  fontSize: 14,
                  radius: 45,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

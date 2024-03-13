import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unionchat/common/about_image.dart';
import 'package:unionchat/db/message_utils.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../common/func.dart';
import '../../common/interceptor.dart';
import '../../notifier/theme_notifier.dart';
import '../../widgets/pager_box.dart';

class ChatAcross extends StatefulWidget {
  const ChatAcross({super.key});

  static const String path = 'chat/across';

  @override
  State<ChatAcross> createState() => _ChatAcrossState();
}

class _ChatAcrossState extends State<ChatAcross> {
  final GlobalKey _globalKey = GlobalKey();
  int limit = 1000;
  List<V1CasualMessageListParam> _list = [];
  List<TextEditingController> ctrList = [];
  String selectIndex = '';

  //获取列表
  _getList({bool load = false}) async {
    if (load) loading();
    final api = CasualMessageApi(apiClient());
    try {
      final res = await api.casualMessageList({});
      if (!mounted) return 0;
      if (mounted) _list = res?.list ?? [];
      setState(() {});
      if (res == null) return 0;
      return res.list.length;
    } on ApiException catch (e) {
      onError(e);
      return 0;
    } finally {
      if (load) loadClose();
    }
  }

  //新增坐席
  apiShareChat() async {
    confirm(
      context,
      content: '确定新增坐席会话？'.tr(),
      onEnter: () async {
        loading();
        var api = CasualMessageApi(apiClient());
        try {
          var res = await api.casualMessageSend({});
          if (res == null) {
            tipError('获取坐席链接失败'.tr());
            return;
          }
          if (mounted) _getList(load: true);
        } on ApiException catch (e) {
          onError(e);
        } finally {
          loadClose();
        }
      },
    );
  }

  // 修改坐席备注
  _updateMark(String mark, V1CasualMessageListParam v) async {
    var api = RoomApi(apiClient());
    loading();
    try {
      await api.roomUpdateRoomInfo(V1UpdateRoomInfoArgs(
        roomId: v.roomId,
        roomName: V1UpdateRoomInfoArgsValue(value: mark),
      ));
      MessageUtil.updateChannelInfo(
        generatePairId(0, toInt(v.roomId)),
        name: mark,
      );
    } on ApiException catch (e) {
      onError(e);
      return false;
    } finally {
      loadClose();
    }
    _getList();
    return;
  }

  //复制
  _copy(String url) {
    logger.d(url);
    ClipboardData data = ClipboardData(text: url);
    Clipboard.setData(data);
    tipSuccess('内容已复制到粘贴板'.tr());
  }

  //结束会话
  _delete(String id) {
    confirm(
      context,
      content: '确定结束会话？'.tr(),
      onEnter: () async {
        loading();
        var api = CasualMessageApi(apiClient());
        try {
          await api.casualMessageEnd(GIdArgs(
            id: id,
          ));
          if (!mounted) return;
          if (mounted) _getList(load: true);
        } on ApiException catch (e) {
          onError(e);
        } finally {
          loadClose();
        }
      },
    );
  }

  // //保存二维码
  // Future<void> globSaveImageToGallery(GlobalKey key) async {
  //   print(key);
  //   Uint8List? imageBytes = await globCaptureScreen(key);
  //   if (imageBytes != null) {
  //     final result = await ImageGallerySaver.saveImage(imageBytes);
  //     if (result['isSuccess']) {
  //       tipSuccess('已保存到相册'.tr());
  //     } else {
  //       tipError('保存失败'.tr());
  //     }
  //   }
  // }

  //展示二维码
  showQr(String url) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          //二维码
          return RepaintBoundary(
            key: _globalKey,
            child: Container(
              decoration: BoxDecoration(
                color: ThemeNotifier().themeBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 160,
                        height: 160,
                        margin: const EdgeInsets.symmetric(vertical: 50),
                        decoration: BoxDecoration(
                          color: ThemeNotifier().white,
                          border: Border.all(
                            color: ThemeNotifier().black,
                            style: BorderStyle.none,
                          ),
                        ),
                        child: CustomPaint(
                          size: const Size.square(100),
                          painter: QrPainter(
                            data: Uri.decodeFull(url),
                            version: QrVersions.auto,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: Colors.black,
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.circle,
                              color: Colors.black,
                            ),
                            // size: 320.0,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 190,
                        height: 190,
                        child: Image.asset(
                          assetPath('images/talk/scan_box.png'),
                          width: 190,
                          height: 190,
                          fit: BoxFit.contain,
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 16,
                      left: 16,
                      right: 16,
                    ),
                    child: CircleButton(
                      elevation: 4,
                      theme: AppButtonTheme.blue,
                      title: '保存'.tr(),
                      fontSize: 19,
                      height: 47,
                      radius: 10,
                      onTap: () async {
                        // globSaveImageToGallery(_globalKey);
                        Uint8List? imageBytes =
                            await globCaptureScreen(_globalKey);
                        if (imageBytes != null) {
                          final result =
                              await ImageGallerySaver.saveImage(imageBytes);
                          if (result['isSuccess']) {
                            tipSuccess('已保存到相册'.tr());

                            Navigator.pop(context);
                          } else {
                            tipError('保存失败'.tr());
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  void dispose() {
    super.dispose();
    if (ctrList.isNotEmpty) {
      ctrList.map((e) => e.dispose());
    }
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      appBar: AppBar(
        title: Text('坐席管理'.tr()),
        actions: [
          IconButton(
            onPressed: () {
              apiShareChat();
            },
            icon: Image.asset(
              assetPath('images/talk/more.png'),
              width: 18,
              height: 18,
              color: myColors.iconThemeColor,
            ),
          ),
        ],
      ),
      body: ThemeBody(
        child: PagerBox(
          padding: const EdgeInsets.all(15),
          limit: limit,
          onInit: () async {
            return await _getList();
          },
          onPullDown: () async {
            return await _getList();
          },
          children: _list.map((v) {
            TextEditingController ctr = TextEditingController();
            ctr.text = v.roomName ?? '';
            ctrList.add(ctr);
            return Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(
                bottom: 15,
              ),
              padding: const EdgeInsets.fromLTRB(15, 14, 15, 23),
              decoration: BoxDecoration(
                color: myColors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: myColors.bottomShadow,
                    blurRadius: 10,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: selectIndex == _list.indexOf(v).toString()
                            ? myColors.chatInputSelectColor
                            : myColors.chatInputColor,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: AppTextarea(
                              readOnly:
                                  selectIndex != _list.indexOf(v).toString(),
                              controller: ctr,
                              fontSize: 16,
                              minLines: 3,
                              radius: 15,
                              hintText: '请输入详细内容'.tr(),
                              maxLength: null,
                              color: selectIndex == _list.indexOf(v).toString()
                                  ? myColors.chatInputSelectColor
                                  : null,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                if (selectIndex ==
                                    _list.indexOf(v).toString()) {
                                  v.roomName = ctr.text;
                                  _updateMark(ctr.text, v);
                                  selectIndex = '';
                                } else {
                                  selectIndex = _list.indexOf(v).toString();
                                }
                                setState(() {});
                              },
                              child: Image.asset(
                                assetPath(
                                    selectIndex == _list.indexOf(v).toString()
                                        ? 'images/yixuan.png'
                                        : 'images/talk/arcoss_bianji.png'),
                                width: 20,
                                height: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: CircleButton(
                          onTap: () {
                            _delete(v.roomId ?? '');
                          },
                          title: '结束会话'.tr(),
                          fontSize: 14,
                          height: 37,
                          radius: 10,
                          theme: AppButtonTheme.red,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        flex: 1,
                        child: CircleButton(
                          onTap: () {
                            showQr(v.url ?? '');
                          },
                          title: '二维码'.tr(),
                          fontSize: 14,
                          height: 37,
                          radius: 10,
                          theme: AppButtonTheme.blue0,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        flex: 1,
                        child: CircleButton(
                          onTap: () {
                            _copy(v.url ?? '');
                          },
                          title: '复制链接'.tr(),
                          fontSize: 14,
                          height: 37,
                          radius: 10,
                          theme: AppButtonTheme.blue0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

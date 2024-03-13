import 'package:flutter/material.dart';
import 'package:unionchat/common/app_prompt.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/db/message_utils.dart';
import 'package:unionchat/db/model/message.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/pages/call/call_variable.dart';
import 'package:unionchat/pages/call/mini_talk_overlay.dart';
import 'package:unionchat/pages/tabs.dart';
import 'package:unionchat/routes.dart';
import 'package:unionchat/widgets/avatar.dart';
import 'package:openapi/api.dart';
import 'package:permission_handler/permission_handler.dart';

// 通话响铃
class CallRemind {
  static CallRemind? _callRemind;
  // 当前消息id
  static int? msgId;
  factory CallRemind() {
    return _callRemind ??= CallRemind._internal();
  }

  CallRemind._internal();
  OverlayEntry? _overlayEntry;
  show({
    required String avatar,
    required String name,
    required Message msg,
    bool video = true,
  }) {
    msgId = msg.id;
    AppPrompt.startVibration(method: VibrationMethod.call);
    AppPrompt.startAudio(type: AudioType.receive);
    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        var myColors = ThemeNotifier();
        return Positioned(
          top: 0,
          left: 0,
          child: SafeArea(
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: NetworkImage(testNetworkPhoto),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 30,
                    horizontal: 15,
                  ),
                  decoration: BoxDecoration(
                    color: myColors.callRemindBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      AppAvatar(
                        list: [avatar],
                        userName: name,
                        userId: (msg.sender ?? 0).toString(),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: myColors.white,
                              ),
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            Text(
                              '邀请您进行${video ? '视频' : '语音'}通话...',
                              style: TextStyle(
                                color: myColors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _callBtn(
                        context,
                        color: myColors.red,
                        icon: Icons.call_end,
                        onTap: () async {
                          MessageUtil.signaler(GNegotiation(
                            sessionId: msg.id.toString(),
                            type: GSignalertType.BYE,
                          ));
                          // 修改本地消息状态
                          await close();
                        },
                      ),
                      _callBtn(
                        context,
                        color: myColors.primary,
                        icon: video ? Icons.videocam_rounded : Icons.call,
                        onTap: () async {
                          await close();
                          List<Permission> permission = [Permission.microphone];
                          if (video) {
                            permission.add(Permission.camera);
                          }
                          if (!await devicePermission(permission)) return;
                          if (useContext != null && useContext!.mounted) {
                            var name = msg.senderUser?.nickname ?? '';
                            var mark = msg.senderUser?.mark ?? '';
                            Future.microtask(() {
                              MiniTalk.open(
                                useContext!,
                                msgId: msg.id,
                                nickname: mark.isNotEmpty ? mark : name,
                                avatar: avatar,
                                isVideo: msg.type == GMessageType.VIDEO_CALL,
                              );
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    if (useContext != null && useContext!.mounted) {
      Overlay.of(useContext!).insert(_overlayEntry!);
    }
  }

  BuildContext? get useContext {
    return Routes.getKey(Tabs.path)?.currentContext;
  }

  Future<void> close() async {
    if (_overlayEntry?.mounted ?? false) _overlayEntry?.remove();
    await AppPrompt.stopAll();
    await CallVariable.close();
    msgId = null;
  }

  _callBtn(
    BuildContext context, {
    required Color color,
    required IconData icon,
    Function()? onTap,
  }) {
    var myColors = ThemeNotifier();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 15),
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Icon(
          icon,
          color: myColors.white,
          size: 20,
        ),
      ),
    );
  }
}

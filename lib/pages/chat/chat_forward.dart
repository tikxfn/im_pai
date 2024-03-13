import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openapi/api.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/db/model/message.dart';
import 'package:unionchat/db/model/notes.dart';
import 'package:unionchat/db/model/show_user.dart';
import 'package:unionchat/db/notifier/message_notifier.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/pages/chat/chat_management/group_card.dart';
import 'package:unionchat/pages/chat/widgets/talk_message.dart';
import 'package:unionchat/pages/file_preview.dart';
import 'package:unionchat/pages/friend/friend_detail.dart';
import 'package:unionchat/pages/help/circle/circle_card.dart';
import 'package:unionchat/pages/note/note_detail_pro.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/map.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../widgets/photo_preview.dart';
import '../help/group/group_home.dart';
import '../play_video.dart';
import '../play_video_win.dart';

class ChatForward extends StatefulWidget {
  const ChatForward({super.key});

  static const String path = 'chat/forward';

  @override
  State<StatefulWidget> createState() {
    return _ChatForwardState();
  }
}

class _ChatForwardState extends State<ChatForward> {
  // List<String> ids = [];
  List<MessageItem> list = [];
  Message? msg;
  String title = '';

  //消息图片点击事件
  messageImageTap(Message data, String url) {
    List<String> mediaList = [];
    for (var v in list) {
      var url = v.content ?? '';
      if (v.type != GMessageType.IMAGE) {
        continue;
      }
      List<String> urls = [];
      for (var u in url.split(',')) {
        if (mediaList.contains(u)) continue;
        urls.add(u);
      }
      mediaList.addAll(urls);
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

  //圈子名片点击事件
  circleTap(Message data) async {
    loading();
    final api = CircleApi(apiClient());
    try {
      final res = await api.circleDetailCircle(
        GIdArgs(id: data.contentId.toString()),
      );
      if (res == null) return;
      if (!mounted) return;
      if (toBool(res.isJoin)) {
        Navigator.pushNamed(
          context,
          GroupHome.path,
          arguments: {
            'circleId': data.contentId.toString(),
          },
        );
      } else {
        Navigator.pushNamed(
          context,
          CircleCard.path,
          arguments: {
            'circleId': data.contentId.toString(),
            'isCard': true,
            'invitedUserId': data.sender.toString(),
            'shareUserId': data.location,
          },
        );
      }
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {
      loadClose();
    }
  }

  //消息点击事件
  messageTap(Message data, int i) async {
    switch (data.type) {
      case GMessageType.VIDEO:
        var url = data.content ?? '';
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
        break;
      case GMessageType.FILE:
        Navigator.pushNamed(
          context,
          FilePreview.path,
          arguments: {
            'file': data.fileUrl,
            'name': data.content,
            'size': data.duration,
          },
        );
        break;
      case GMessageType.LOCATION: //消息点击事件
        if (!platformPhone) {
          tip('不支持的消息类型'.tr());
          return;
        }
        if (!await devicePermission([Permission.location])) return;
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return AppMap(
                showMap: true,
                location: MapLocation(
                  location: data.location ?? '',
                  title: data.title ?? '',
                  desc: data.content ?? '',
                ),
              );
            },
          ),
        );
        break;
      case GMessageType.USER_CARD:
        Navigator.pushNamed(
          context,
          FriendDetails.path,
          arguments: {
            'id': data.contentId.toString(),
            'friendFrom': 'RECOMMEND',
            'removeToTabs': true,
            'detail': GUserModel(
              avatar: data.fileUrl,
              nickname: data.content,
            ),
          },
        );
        break;
      case GMessageType.ROOM_CARD:
        Navigator.pushNamed(
          context,
          GroupCard.path,
          arguments: {
            'roomId': data.contentId.toString(),
            'roomFrom': 'room_card',
            'isCard': false,
            'shareUserId': data.location,
          },
        );
        break;
      case GMessageType.NOTES:
        Navigator.pushNamed(
          context,
          NoteDetailPro.path,
          // NoteDetail.path,
          arguments: {
            'notes': Notes.fromJson(jsonDecode(data.content ?? '')),
            'preview': true,
          },
        );
        break;
      case GMessageType.FORWARD_CIRCLE:
        circleTap(data);
        break;
      case GMessageType.HISTORY:
        Navigator.pushNamed(
          context,
          ChatForward.path,
          arguments: {
            'ids': data.contentId,
            'title': data.title,
            'message': data,
          },
        );
        break;
      case GMessageType.AUDIO:
      case GMessageType.RED_PACKET:
      case GMessageType.RED_INTEGRAL:
      case GMessageType.AUDIO_CALL:
      case GMessageType.VIDEO_CALL:
      case GMessageType.TEXT:
      case GMessageType.IMAGE:
      case GMessageType.NIL:
      case GMessageType.FRIEND_APPLY_PASS:
      case GMessageType.SHAKE:
      case GMessageType.ROOM_NOTICE_JOIN:
      case GMessageType.ROOM_NOTICE_EXIT:
      case GMessageType.GIVE_RELIABLE:
      case GMessageType.FORWARD_ONE_BY_ONE:
      case GMessageType.COLLECT:
        break;
    }
  }

  //内容组件
  Widget? contentWidget(MessageItem data, int i) {
    if (data.type == GMessageType.TEXT) return null;
    var msg = Message();
    var senderUser = ShowUser()
      ..avatar = data.avatar
      ..nickname = data.nickname;
    msg.senderUser = senderUser;
    msg.type = data.type;
    msg.content = data.content;
    msg.contentId = data.contentId;
    msg.fileUrl = data.fileUrl;
    msg.imageUrl = data.imageUrl;
    msg.title = data.title;
    msg.location = data.location;
    msg.createTime = data.createTime ?? 0;
    msg.messageHistory = data.messageHistory;
    msg.quoteMessageId = data.quoteMessageId ?? 0;
    msg.duration = data.duration;
    msg.receiverUserId = data.receiverUserId;
    msg.receiverRoomId = data.receiverRoomId;
    if (msg.type == GMessageType.IMAGE) {
      var imageUrl = msg.imageUrl ?? '';
      msg.content = imageUrl.isNotEmpty ? imageUrl : msg.content;
    }
    if (msg.type == GMessageType.VIDEO) {
      var fileUrl = msg.fileUrl ?? '';
      msg.content = fileUrl.isNotEmpty ? fileUrl : msg.content;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: TalkMessage(
        MessageNotifier(msg),
        isHistory: true,
        onTap: (data) {
          messageTap(data, i);
        },
        onImageTap: messageImageTap,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dynamic args = ModalRoute.of(context)!.settings.arguments ?? {};
    // title = args['title'] ?? '';
    if (args['message'] != null && args['message'] is Message) {
      msg = args['message'];
      list = msg!.messageHistory!.items;
      title = messageHistory2text(msg?.messageHistory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ThemeBody(
        child: ListView(
          children: [
            for (var i = 0; i < list.length; i++)
              ChatItem(
                forward: true,
                hasSlidable: false,
                avatarSize: 37,
                textOverHide: false,
                avatarFrameSizeWidth: 0,
                hideAvatar: i != 0 && list[i].sender == list[i - 1].sender,
                data: ChatItemData(
                  icons: [list[i].avatar ?? ''],
                  title: list[i].nickname ?? '',
                  time: time2formatDate((list[i].createTime ?? '').toString()),
                  text:
                      list[i].type == GMessageType.TEXT ? list[i].content! : '',
                ),
                border: true,
                child: contentWidget(list[i], i),
              ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:openapi/api.dart';
import 'package:unionchat/adapter/adapter.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/db/enum.dart';
import 'package:unionchat/db/model/message.dart';
import 'package:unionchat/db/model/show_user.dart';
import 'package:unionchat/db/notifier/message_notifier.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/pages/chat/widgets/card_message.dart';
import 'package:unionchat/pages/chat/widgets/location_message.dart';
import 'package:unionchat/pages/chat/widgets/long_menu.dart';
import 'package:unionchat/pages/chat/widgets/red_packet_message.dart';
import 'package:unionchat/pages/chat/widgets/text_message_time_icon.dart';
import 'package:unionchat/widgets/avatar.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/network_image.dart';
import 'package:unionchat/widgets/note_item_pro.dart';
import 'package:unionchat/widgets/video_player.dart';
import 'package:unionchat/widgets/video_player_win.dart';

//长按菜单类型
enum MessagePopType {
  //复制
  copy,
  //转发
  forward,
  //撤回
  undo,
  //编辑
  edit,
  //引用
  quote,
  //删除
  remove,
  //置顶
  top,
  //保存
  save,
  //收藏
  collect,
  //分享
  share,
  //多选
  choice,
  //禁言
  ban,
  //保存表情
  saveCustom,
}

extension MessagePopTypeExt on MessagePopType {
  String get toChar {
    switch (this) {
      case MessagePopType.copy:
        return '复制'.tr();
      case MessagePopType.forward:
        return '转发'.tr();
      case MessagePopType.undo:
        return '撤回'.tr();
      case MessagePopType.edit:
        return '编辑'.tr();
      case MessagePopType.quote:
        return '引用'.tr();
      case MessagePopType.remove:
        return '删除'.tr();
      case MessagePopType.top:
        return '置顶'.tr();
      case MessagePopType.save:
        return '保存'.tr();
      case MessagePopType.collect:
        return '收藏'.tr();
      case MessagePopType.share:
        return '分享'.tr();
      case MessagePopType.choice:
        return '多选'.tr();
      case MessagePopType.ban:
        return '禁言'.tr();
      case MessagePopType.saveCustom:
        return '保存为表情'.tr();
    }
  }

  IconData get toIcon {
    switch (this) {
      case MessagePopType.copy:
        return Icons.copy;
      case MessagePopType.forward:
        return Icons.forward;
      case MessagePopType.undo:
        return Icons.undo;
      case MessagePopType.edit:
        return Icons.edit;
      case MessagePopType.quote:
        return Icons.format_quote;
      case MessagePopType.remove:
        return Icons.delete_forever_outlined;
      case MessagePopType.top:
        return Icons.vertical_align_top_outlined;
      case MessagePopType.save:
        return Icons.save_alt;
      case MessagePopType.collect:
        return Icons.favorite_border;
      case MessagePopType.share:
        return Icons.share;
      case MessagePopType.choice:
        return Icons.checklist;
      case MessagePopType.ban:
        return Icons.speaker_notes_off_outlined;
      case MessagePopType.saveCustom:
        return Icons.emoji_emotions_outlined;
    }
  }
}

//对话框消息组件
class TalkMessage extends StatefulWidget {
  //消息数据
  final MessageNotifier data;

  // 显示时间
  final String viewTime;

  //点击事件
  final Function(Message)? onTap;

  //图片点击事件
  final Function(Message, String)? onImageTap;

  //双击事件
  final Function(Message)? onDoubleTap;

  //引用消息点击事件
  final Function(MessageItem)? onQuoteTap;

  //头像点击事件
  final Function()? onAvatarTap;

  //头像长按事件
  final Function(Message)? onAvatarLongTap;

  //长按菜单事件
  final Function(MessagePopType, Message)? onPopTap;

  //是否选择模式
  final bool checkModal;

  // //选择模式类型
  // final MessagePopType checkType;

  //选择事件
  final Function(Message)? onCheck;

  //是否选择
  final bool checked;

  final bool checkDisabled;

  //是否消息记录
  final bool isHistory;

  // //是否有撤回权限
  // final bool hasUndo;

  //是否有编辑权限
  final bool hasEdit;

  //是否有置顶权限
  final bool hasTop;

  //是否有禁言权限
  final bool hasBan;

  //是否显示昵称
  final bool showName;

  final Function(MessageNotifier)? onFailed;

  // 是否群主、管理员
  final Map<String, List<String>>? roomManage;

  // 群主管理员
  final bool roomAdmin;

  const TalkMessage(
    this.data, {
    this.onPopTap,
    this.onTap,
    this.onImageTap,
    this.onDoubleTap,
    this.onQuoteTap,
    this.onCheck,
    this.onAvatarTap,
    this.onAvatarLongTap,
    this.checkModal = false,
    // this.checkType = MessagePopType.forward,
    this.checked = false,
    this.checkDisabled = false,
    this.viewTime = '',
    this.isHistory = false,
    // this.hasUndo = false,
    this.hasEdit = false,
    this.hasTop = false,
    this.hasBan = false,
    this.showName = false,
    this.onFailed,
    this.roomManage,
    this.roomAdmin = false,
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _TalkMessageState();
  }
}

class _TalkMessageState extends State<TalkMessage> {
  double avatarSize = 40; //头像图片大小
  double avatarMargin = 10; //头像margin

  //消息状态组件
  Widget statusWidget(bool sender) {
    var myColors = ThemeNotifier();
    var data = widget.data.message;
    bool sender = (data.sender ?? 0).toString() == (Global.user?.id ?? '');
    return Row(
      children: [
        ValueListenableBuilder(
          valueListenable: widget.data.loading,
          builder: (context, loading, _) {
            if (loading) {
              return MessageProgress(
                data: data,
                loading: loading,
              );
            }
            switch (data.taskStatus) {
              case TaskStatus.sending:
                return ValueListenableBuilder(
                  valueListenable: widget.data.uploadProgress,
                  builder: (context, progress, _) {
                    return MessageProgress(
                      data: data,
                      progress: progress ?? 0,
                      loading: loading,
                    );
                  },
                );
              case TaskStatus.fail:
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (widget.onFailed != null) widget.onFailed!(widget.data);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: sender ? 0 : 10,
                      right: !sender ? 0 : 10,
                    ),
                    child: Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.info,
                        color: myColors.red,
                        size: 20,
                      ),
                    ),
                  ),
                );
              case TaskStatus.nil:
              case TaskStatus.success:
                break;
            }
            return Container();
          },
        ),
        if (!sender &&
            widget.data.message.type == GMessageType.AUDIO &&
            (widget.data.message.isListened ?? false))
          Container(
            width: 5,
            height: 5,
            margin: const EdgeInsets.only(left: 5),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
      ],
    );
  }

  //已读状态
  Widget readWidget() {
    var data = widget.data.message;
    bool sender = (data.sender ?? 0).toString() == (Global.user?.id ?? '');
    if (data.status == null ||
        data.status == GMessageStatus.REVOKE ||
        (data.receiverRoomId ?? 0) > 0 ||
        !sender ||
        data.taskStatus != TaskStatus.success) {
      return Container();
    }
    var img = Image.asset(
      assetPath(
        'images/${data.status == GMessageStatus.READ ? 'yidu' : 'weidu'}.png',
      ),
      width: 12,
      height: 12,
    );
    return img;
  }

  //已读状态
  Widget readNewWidget() {
    var data = widget.data.message;
    bool sender = (data.sender ?? 0).toString() == (Global.user?.id ?? '');
    bool room = (data.receiverRoomId ?? 0) > 0;
    if (data.status == null ||
        data.status == GMessageStatus.REVOKE ||
        room ||
        !sender ||
        data.taskStatus != TaskStatus.success) {
      return Container(width: room ? 0 : 13);
    }
    var img = Image.asset(
      assetPath(
        'images/talk/${data.status == GMessageStatus.READ ? 'yidu' : 'weidu'}_gou.png',
      ),
      width: 13,
      height: 9,
    );
    return img;
  }

  //头像组件
  Widget avatar() {
    if (widget.isHistory) return Container();
    var data = widget.data.message;
    bool isVip =
        (data.senderUser?.vipExpireTime ?? 0) >= toInt(date2time(null));
    bool owner = false;
    bool admin = false;
    bool sender = (data.sender ?? 0).toString() == (Global.user?.id ?? '');
    if (widget.roomManage != null) {
      var userId = (data.sender ?? 0).toString();
      admin = widget.roomManage!['admin']!.contains(userId);
      owner = widget.roomManage!['owner']!.contains(userId);
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () {
        widget.onAvatarLongTap?.call(widget.data.message);
      },
      onTap: () {
        if (widget.checkModal && widget.onCheck != null) {
          // if (widget.checkType == MessagePopType.undo && !sender) {
          //   return;
          // }
          widget.onCheck!(data);
          return;
        }
        if (!widget.checkModal && widget.onAvatarTap != null) {
          widget.onAvatarTap!();
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          right: isVip ? 5 : avatarMargin,
          left: isVip ? 5 : avatarMargin,
        ), //头像边距
        // padding: EdgeInsets.zero,
        child: AppAvatar(
          list: [
            sender
                ? (Global.user?.avatar ?? '')
                : data.senderUser?.avatar ?? '',
          ],
          userName: sender
              ? (Global.user?.nickname ?? '')
              : data.senderUser?.nickname ?? '',
          userId:
              sender ? (Global.user?.id ?? '') : (data.sender ?? 0).toString(),
          size: avatarSize,
          vip: isVip,
          avatarFrameHeightSize: 20,
          avatarTopPadding: isVip ? 5 : 0,
          vipLevel: data.senderUser?.vipLevel,
          isOwner: owner,
          isAdmin: admin,
        ),
      ),
    );
  }

  //名称组件
  Widget nameTitle(Message data) {
    bool owner = false;
    bool admin = false;
    var data = widget.data.message;
    if (widget.roomManage != null) {
      var userId = (data.sender ?? 0).toString();
      admin = widget.roomManage!['admin']!.contains(userId);
      owner = widget.roomManage!['owner']!.contains(userId);
    }
    var myColors = ThemeNotifier();
    var name = data.senderUser?.nickname ?? '';
    var roomMark = data.senderUser?.roomNickname ?? '';
    var mark = data.senderUser?.mark ?? '';
    mark = mark.isNotEmpty ? mark : roomMark;
    return Row(
      children: [
        if (owner || admin)
          Text(
            owner ? '【群主】'.tr() : '【管理员】'.tr(),
            style: TextStyle(
              color: owner ? myColors.vipName : myColors.admin,
              fontSize: 12,
            ),
          ),
        Text(
          mark.isNotEmpty ? mark : name,
          style: TextStyle(
            color: myColors.textGrey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  //头像占位宽度
  avatarWidth() {
    if (widget.isHistory) {
      return 0;
    }
    return avatarSize + avatarMargin * 2; //头像边距
  }

  //内容组件
  Widget contentWidget() {
    var myColors = ThemeNotifier();
    Widget content = Container();
    Message data = widget.data.message;
    bool sender = (data.sender ?? 0).toString() == (Global.user?.id ?? '');
    double boxWidth = MediaQuery.of(context).size.width;
    double maxWidth = boxWidth - avatarWidth() * 2 - 10;
    if (Adapter.isWideScreen) {
      maxWidth = maxWidth > 300 ? 300 : maxWidth;
    }
    List<MessagePopType> pops = [
      if (widget.hasBan) MessagePopType.ban,
      if (widget.hasTop) MessagePopType.top,
      if (data.type != GMessageType.RED_PACKET &&
          data.type != GMessageType.RED_INTEGRAL &&
          data.type != GMessageType.AUDIO &&
          data.type != GMessageType.FORWARD_CIRCLE)
        MessagePopType.forward,
      MessagePopType.quote,
      // if(widget.hasUndo) MessagePopType.remove,
      MessagePopType.remove,
    ];
    if (data.type != GMessageType.RED_PACKET &&
        data.type != GMessageType.RED_INTEGRAL &&
        data.type != GMessageType.AUDIO_CALL &&
        data.type != GMessageType.VIDEO_CALL) {
      pops.add(MessagePopType.collect);
    }
    Color? textColor; //vip阶级字体颜色
    bool isVip =
        (data.senderUser?.vipExpireTime ?? 0) >= toInt(date2time(null));
    if (isVip) {
      textColor = vipStageText(data.senderUser?.vipLevel ?? GVipLevel.NIL);
    }
    switch (data.type) {
      case GMessageType.TEXT: //文字
        content = MessageBox(
          color: sender ? null : myColors.white,
          // leftWidget: readWidget(text: true),
          isHistory: widget.isHistory,
          maxWidth: maxWidth,
          send: sender,
          sendData: data.senderUser,
          padding: const EdgeInsets.all(15),
          child: TextMessageTimeIcon(
            data.content ?? '',
            width: maxWidth - 30,
            //padding
            style: TextStyle(
              fontSize: 17,
              color: textColor ?? (sender ? myColors.white : null),
            ),
            icon: sender ? readNewWidget() : null,
            iconWidth: sender ? 13 : 0,
            time: time2date(
              data.createTime.toString(),
              format: 'HH:mm',
            ),
            timeStyle: TextStyle(
              fontSize: 12,
              color: (textColor != null || sender)
                  ? myColors.white
                  : myColors.subIconThemeColor,
            ),
          ),
        );
        pops.insert(0, MessagePopType.copy);
        break;
      case GMessageType.IMAGE: //图片
        content = Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: readWidget(),
            ),
            MessageImage(
              data: data,
              maxWidth: maxWidth,
              checkModal: widget.checkModal,
              onCheck: widget.onCheck,
              onImageTap: widget.onImageTap,
              isHistory: widget.isHistory,
            ),
          ],
        );
        if (!(data.content ?? '').contains(',')) {
          pops.add(MessagePopType.save);
          pops.add(MessagePopType.saveCustom);
          if (!Platform.isWindows) pops.add(MessagePopType.share);
        }
        break;
      case GMessageType.VIDEO: //视频
        content = Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: readWidget(),
            ),
            MessageVideo(data: data),
          ],
        );
        pops.add(MessagePopType.save);
        if (!Platform.isWindows) pops.add(MessagePopType.share);
        break;
      case GMessageType.AUDIO: //语音
        content = ValueListenableBuilder(
          valueListenable: widget.data.playing,
          builder: (context, playing, _) {
            return MessageVoice(
              data: data,
              maxWidth: maxWidth,
              isHistory: widget.isHistory,
              readWidget: readWidget(),
              playing: playing,
            );
          },
        );
        break;
      case GMessageType.HISTORY: //转发消息
        // content = Stack(
        //   alignment: Alignment.bottomRight,
        //   children: [
        content = MessageForward(
          data: data,
          maxWidth: maxWidth,
          readWidget: readWidget(),
          isHistory: widget.isHistory,
        );
        //     readWidget(),
        //   ],
        // );
        break;
      case GMessageType.NIL:
        break;
      case GMessageType.FILE:
        content = MessageFile(
          data: data,
          isHistory: widget.isHistory,
          readWidget: readWidget(),
        );
        break;
      case GMessageType.LOCATION:
        // content = Stack(
        //   alignment: Alignment.bottomRight,
        //   children: [
        //     locationWidget(maxWidth),
        //     readWidget(shadow: true, right: 10, bottom: 6),
        //   ],
        // );
        content = MessageBox(
          leftWidget: readWidget(),
          isHistory: widget.isHistory,
          maxWidth: maxWidth,
          send: sender,
          color: myColors.tagColor,
          padding: const EdgeInsets.all(0),
          child: LocationMessage(
            name: data.title ?? '',
            desc: data.content ?? '',
          ),
        );
        break;
      case GMessageType.USER_CARD:
      case GMessageType.ROOM_CARD:
      case GMessageType.FORWARD_CIRCLE:
        var target = '';
        if (data.type == GMessageType.USER_CARD) {
          target = '个人名片'.tr();
        }
        if (data.type == GMessageType.ROOM_CARD) {
          target = '群名片'.tr();
        }
        if (data.type == GMessageType.FORWARD_CIRCLE) {
          target = '圈子名片'.tr();
        }
        content = MessageBox(
          leftWidget: readWidget(),
          isHistory: widget.isHistory,
          maxWidth: maxWidth - (widget.isHistory ? 70 : 0),
          send: sender,
          color: myColors.tagColor,
          padding: const EdgeInsets.all(0),
          child: CardMessage(
            CardMessageData(
              userId: data.contentId.toString(),
              avatar: data.fileUrl ?? '',
              name: data.content ?? '',
              tag: target,
            ),
          ),
        );
        break;
      case GMessageType.RED_PACKET:
        content = MessageBox(
          leftWidget: readWidget(),
          isHistory: widget.isHistory,
          maxWidth: maxWidth,
          send: sender,
          color: myColors.red,
          padding: const EdgeInsets.all(0),
          child: RedPacketMessage(
            RedPacketMessageData(
              title: data.content ?? '',
            ),
          ),
        );
        break;
      case GMessageType.RED_INTEGRAL:
        content = MessageBox(
          leftWidget: readWidget(),
          isHistory: widget.isHistory,
          maxWidth: maxWidth,
          send: sender,
          color: myColors.red,
          padding: const EdgeInsets.all(0),
          child: RedPacketMessage(
            RedPacketMessageData(
              title: data.content ?? '',
              target: '派聊红包',
            ),
          ),
        );
        break;
      case GMessageType.AUDIO_CALL:
        content = MessageCall(
          data: data,
          maxWidth: maxWidth,
          isHistory: widget.isHistory,
          icon: Icons.call,
        );
        break;
      case GMessageType.VIDEO_CALL:
        content = MessageCall(
          data: data,
          maxWidth: maxWidth,
          isHistory: widget.isHistory,
          icon: Icons.videocam_rounded,
        );
        break;
      case GMessageType.NOTES:
        content = MessageNote(
          maxWidth: maxWidth,
          data: data,
          readWidget: readWidget(),
          isHistory: widget.isHistory,
        );
        pops.add(MessagePopType.save);
        break;
      case GMessageType.COLLECT:
      case GMessageType.FORWARD_ONE_BY_ONE:
      case GMessageType.ROOM_NOTICE_EXIT:
      case GMessageType.ROOM_NOTICE_JOIN:
      case GMessageType.FRIEND_APPLY_PASS:
      case GMessageType.SHAKE:
      case GMessageType.GIVE_RELIABLE:
        break;
    }
    if (widget.isHistory) {
      return content;
    }
    pops.add(MessagePopType.choice);
    List<LongMenuItem> longMenuItems = [];
    for (var v in pops) {
      longMenuItems.add(
        LongMenuItem(
          icon: v.toIcon,
          label: v.toChar,
          onTap: () {
            widget.onPopTap?.call(v, data);
          },
        ),
      );
    }
    return LongMenu(
      menuItems: longMenuItems,
      child: content,
    );
  }

  @override
  void initState() {
    super.initState();
    widget.data.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    // widget.data.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = ThemeNotifier();
    // logger.d(data.status);
    var data = widget.data.message;
    var type = data.type;
    bool sender = (data.sender ?? 0).toString() == (Global.user?.id ?? '');
    if (type == GMessageType.GIVE_RELIABLE) {
      return MessageTip(
        child: Row(
          children: [
            Image.asset(assetPath('images/kaopu.png'), width: 12),
            const SizedBox(width: 5),
            Text(
              '好友送您 ${data.content} 靠谱草',
              style: TextStyle(
                fontSize: 12,
                color: myColors.textGrey,
              ),
            ),
          ],
        ),
      );
    }
    if (type == GMessageType.FRIEND_APPLY_PASS ||
        type == GMessageType.ROOM_NOTICE_JOIN) {
      return MessageApplyPass(data: data);
    }
    if (type == GMessageType.ROOM_NOTICE_EXIT) {
      if (widget.roomAdmin) {
        return MessageApplyPass(data: data);
      } else {
        return Container();
      }
    }
    if (type == GMessageType.SHAKE) {
      return MessageTip(
        child: Row(
          children: [
            Icon(
              Icons.vibration,
              color: myColors.textGrey,
              size: 14,
            ),
            const SizedBox(width: 5),
            Text(
              '抖一抖',
              style: TextStyle(
                fontSize: 12,
                color: myColors.textGrey,
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        if (widget.viewTime.isNotEmpty) MessageTipTime(widget.viewTime),
        if (data.status != GMessageStatus.REVOKE)
          Container(
            margin: const EdgeInsets.only(
              top: 10,
              // left: data.send ? avatarWidth() : 0,
              // right: data.send ? 0 : avatarWidth(),
            ),
            child: Row(
              children: [
                if (widget.checkModal)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (widget.onCheck == null) return;
                      // if (widget.checkType == MessagePopType.undo &&
                      //     !sender) {
                      //   return;
                      // }
                      widget.onCheck!(data);
                    },
                    child: AppCheckbox(
                      value: widget.checked,
                      paddingLeft: 10,
                      size: 25,
                      disabled: widget.checkDisabled,
                      // disabled: widget.checkType == MessagePopType.undo &&
                      //     !sender,
                    ),
                  ),
                Expanded(
                  flex: 1,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: sender
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      if (!sender) avatar(),
                      Column(
                        crossAxisAlignment: sender
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          contentContainer(data: data, sender: sender), //内容
                          if (toInt(data.quoteMessageId) > 0 &&
                              data.quoteMessage != null)
                            MessageQuote(
                              data: data,
                              avatarWidth: avatarWidth(),
                              checkModal: widget.checkModal,
                              onCheck: widget.onCheck,
                              onQuoteTap: widget.onQuoteTap,
                              // checkType: widget.checkType,
                            ),
                        ],
                      ),
                      if (sender) avatar(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (data.status == GMessageStatus.REVOKE) MessageTipTime('消息已撤回'.tr()),
        if (data.taskStatus == TaskStatus.fail &&
            (data.reason ?? '').isNotEmpty)
          MessageTipTime(data.reason!),
      ],
    );
  }

  //内容框组件
  Widget contentContainer({required Message data, required bool sender}) {
    double titleBottom = 10;
    bool isVip =
        toInt(data.senderUser?.vipExpireTime ?? 0) >= toInt(date2time(null));
    bool isTextOrAudio = data.type == GMessageType.TEXT ||
        data.type == GMessageType.AUDIO; //是文本或者语音
    return isTextOrAudio && isVip
        ? Stack(
            alignment: sender
                ? AlignmentDirectional.topEnd
                : AlignmentDirectional.topStart,
            children: [
              Container(
                //内容
                margin: EdgeInsets.only(
                    top: widget.showName && !sender ? titleBottom : 0),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (widget.checkModal && widget.onCheck != null) {
                      // if (widget.checkType == MessagePopType.undo &&
                      //     !sender) {
                      //   return;
                      // }
                      widget.onCheck!(data);
                      return;
                    }
                    if (!widget.checkModal && widget.onTap != null) {
                      widget.onTap!(data);
                    }
                  },
                  onDoubleTap: widget.checkModal
                      ? null
                      : () {
                          if (!widget.checkModal &&
                              widget.onDoubleTap != null) {
                            widget.onDoubleTap!(data);
                          }
                        },
                  child: Row(
                    children: [
                      if (sender) statusWidget(sender),
                      contentWidget(),
                      if (!sender) statusWidget(sender),
                    ],
                  ),
                ),
              ),
              if (widget.showName && !sender) //title
                Container(
                  padding: EdgeInsets.only(
                    left: sender ? 0 : 5,
                    right: !sender ? 0 : 5,
                  ),
                  child: nameTitle(data),
                ),
            ],
          )
        : Column(
            crossAxisAlignment:
                sender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (widget.showName && !sender) //title
                Container(
                  padding: EdgeInsets.only(
                    left: sender ? 0 : 5,
                    right: !sender ? 0 : 5,
                    bottom: titleBottom,
                  ),
                  child: nameTitle(data),
                ),
              Container(
                //内容
                margin: EdgeInsets.only(
                    top: isVip && widget.showName || !isVip ? 0 : 10),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (widget.checkModal && widget.onCheck != null) {
                      // if (widget.checkType == MessagePopType.undo &&
                      //     !sender) {
                      //   return;
                      // }
                      widget.onCheck!(data);
                      return;
                    }
                    if (!widget.checkModal && widget.onTap != null) {
                      widget.onTap!(data);
                    }
                  },
                  onDoubleTap: widget.checkModal
                      ? null
                      : () {
                          if (!widget.checkModal &&
                              widget.onDoubleTap != null) {
                            widget.onDoubleTap!(data);
                          }
                        },
                  child: Row(
                    children: [
                      if (sender) statusWidget(sender),
                      contentWidget(),
                      if (!sender) statusWidget(sender),
                    ],
                  ),
                ),
              ),
            ],
          );
  }
}

// 上传进度组件
class MessageProgress extends StatelessWidget {
  final Message data;
  final double progress;
  final bool loading;

  const MessageProgress({
    required this.data,
    this.progress = 0,
    this.loading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = ThemeNotifier();
    var rate = '';
    double size = 10;
    double strokeWidth = 1.5;
    bool sender = (data.sender ?? 0).toString() == (Global.user?.id ?? '');
    bool showProgress = false;
    final List<GMessageType> upTypes = [
      GMessageType.IMAGE,
      GMessageType.FILE,
      GMessageType.VIDEO,
      GMessageType.AUDIO,
    ];
    if (!loading && upTypes.contains(data.type) && progress < 100) {
      showProgress = true;
      rate = progress.toString();
      rate = rate.split('.').first;
      size = 30;
      strokeWidth = 2.5;
    }
    return Container(
      width: size,
      height: size,
      margin: EdgeInsets.only(
        left: sender ? 0 : 3,
        right: !sender ? 0 : 3,
      ),
      // color: myColors.white,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: showProgress ? progress / 100 : null,
            strokeWidth: strokeWidth,
            backgroundColor: myColors.white,
          ),
          if (showProgress && rate.isNotEmpty)
            Text(
              '$rate%',
              style: TextStyle(
                fontSize: 8,
                color: myColors.textGrey,
              ),
            ),
        ],
      ),
      // child: const CupertinoActivityIndicator(radius: 7),
    );
  }
}

// 图片组件
class MessageImage extends StatelessWidget {
  final Message data;
  final double maxWidth;
  final bool isHistory;

  //图片点击事件
  final Function(Message, String)? onImageTap;

  //是否选择模式
  final bool checkModal;

  //选择事件
  final Function(Message)? onCheck;

  const MessageImage({
    required this.data,
    required this.maxWidth,
    this.isHistory = false,
    this.onCheck,
    this.onImageTap,
    this.checkModal = false,
    super.key,
  });

  Widget _img(
    String url, {
    required double width,
    double? height,
    double marginBottom = 0,
  }) {
    return GestureDetector(
      onTap: () {
        if (checkModal) {
          onCheck?.call(data);
          return;
        }
        onImageTap?.call(data, url);
      },
      child: AppNetworkImage(
        url,
        width: width,
        height: height,
        maxHeight: 300,
        imageSpecification: ImageSpecification.w120,
        borderRadius: BorderRadius.circular(8),
        fit: BoxFit.cover,
        marginBottom: marginBottom,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var urls = (data.content ?? '').split(',');
    var widthMax = maxWidth;
    if (isHistory) {
      widthMax -= 60;
      return Column(
        children: urls.map((e) => _img(e, width: 150)).toList(),
      );
    }

    var length = urls.length;
    if (length == 1) {
      return _img(urls[0], width: 150);
    } else if (length < 5) {
      double containerPadding = 4;
      double imgHeight = 200;
      return SizedBox(
        width: widthMax,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: _img(
                urls[0],
                width: double.infinity,
                height: imgHeight,
                marginBottom: containerPadding,
              ),
            ),
            SizedBox(width: containerPadding),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  for (var i = 1; i < length; i++)
                    _img(
                      urls[i],
                      width: double.infinity,
                      height: (imgHeight - (length - 2) * containerPadding) /
                          (length - 1),
                      marginBottom: containerPadding,
                    )
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      List<List<int>> show = [];
      if (length == 5) {
        show = [
          [0, 1],
          [2, 3, 4]
        ];
      } else if (length == 6) {
        show = [
          [0, 1, 2],
          [3, 4, 5]
        ];
      } else if (length == 7) {
        show = [
          [0, 1],
          [2, 3],
          [4, 5, 6]
        ];
      } else if (length == 8) {
        show = [
          [0, 1],
          [2, 3, 4],
          [5, 6, 7]
        ];
      } else if (length == 9) {
        show = [
          [0, 1, 2],
          [3, 4, 5],
          [6, 7, 8]
        ];
      }
      double containerPadding = 4;
      double imgHeight = 200;
      return SizedBox(
        width: widthMax,
        child: Column(
          children: show.map((e) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: e.map((i) {
                var imgWidth = widthMax;
                imgWidth -= containerPadding * (e.length - 1);
                imgWidth /= e.length;
                return _img(
                  urls[i],
                  width: imgWidth,
                  height: e.length > 2 ? imgHeight / 2 : imgHeight,
                  marginBottom: containerPadding,
                );
              }).toList(),
            );
          }).toList(),
        ),
      );
    }
  }
}

// 提示、时间组件
class MessageTipTime extends StatelessWidget {
  final String text;

  const MessageTipTime(
    this.text, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = ThemeNotifier();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        text,
        style: TextStyle(
          color: myColors.subIconThemeColor,
          fontSize: 12,
        ),
      ),
    );
  }
}

// 提醒组件
class MessageTip extends StatelessWidget {
  final Widget child;

  const MessageTip({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = ThemeNotifier();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 2,
            horizontal: 10,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: myColors.grey,
            borderRadius: BorderRadius.circular(3),
          ),
          child: child,
        )
      ],
    );
  }
}

// 引用的内容
class MessageQuote extends StatelessWidget {
  final Message data;
  final double avatarWidth;

  //是否选择模式
  final bool checkModal;

  //选择事件
  final Function(Message)? onCheck;

  //引用消息点击事件
  final Function(MessageItem)? onQuoteTap;

  const MessageQuote({
    required this.data,
    required this.avatarWidth,
    this.onCheck,
    this.checkModal = false,
    this.onQuoteTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = ThemeNotifier();
    var sender =
        (data.senderUser?.userId ?? 0).toString() == (Global.user?.id ?? '');
    double padding = 4;
    if (data.type == GMessageType.IMAGE || data.type == GMessageType.VIDEO) {
      padding = 0;
    }
    double imageSize = 40;
    var quote = data.quoteMessage!;
    var type = quote.type;
    double boxWidth = MediaQuery.of(context).size.width;
    double maxWidth = boxWidth - avatarWidth * 2 - 10;
    Widget? contentWidget;
    var content = '${quote.nickname ?? ''}：';
    if (type == GMessageType.TEXT) {
      content += quote.content ?? '';
    } else if (type == GMessageType.IMAGE) {
      contentWidget = Padding(
        padding: const EdgeInsets.only(left: 3),
        child: AppNetworkImage(
          quote.content ?? '',
          imageSpecification: ImageSpecification.w120,
          width: imageSize,
          height: imageSize,
        ),
      );
    } else if (type == GMessageType.VIDEO) {
      var local = !urlValid(quote.content ?? '');
      var cover = getVideoCover(quote.content ?? '');
      contentWidget = Stack(
        alignment: Alignment.center,
        children: [
          if (local)
            SizedBox(
              width: imageSize,
              child: AppVideo(
                url: quote.content ?? '',
                playSize: 20,
              ),
            ),
          if (!local)
            AppNetworkImage(
              cover,
              width: imageSize,
            ),
          if (!local) Image.asset(assetPath('images/play2.png'), width: 20),
        ],
      );
    } else {
      content += messageType2text(type);
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (checkModal && onCheck != null) {
          onCheck!(data);
          return;
        }
        if (!checkModal && onQuoteTap != null) {
          onQuoteTap!(data.quoteMessage!);
        }
      },
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 3,
          horizontal: 10,
        ),
        margin: EdgeInsets.only(
          top: 10,
          right: sender ? padding : 0,
          left: sender ? 0 : padding,
        ),
        decoration: BoxDecoration(
          // color: myColors.white,
          color: myColors.grey0,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                content,
                // maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: myColors.textGrey,
                  fontSize: 12,
                ),
              ),
            ),
            if (contentWidget != null) contentWidget,
          ],
        ),
      ),
    );
  }
}

// 申请通过组件
class MessageApplyPass extends StatelessWidget {
  final Message data;

  const MessageApplyPass({
    required this.data,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = ThemeNotifier();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 2,
            horizontal: 10,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: myColors.tagColor,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            data.content ?? '',
            style: TextStyle(
              fontSize: 12,
              color: myColors.textGrey,
            ),
          ),
        )
      ],
    );
  }
}

// 聊天记录转发消息
class MessageForward extends StatelessWidget {
  final Message data;
  final Widget readWidget;
  final bool isHistory;
  final double maxWidth;

  const MessageForward({
    required this.data,
    required this.readWidget,
    required this.maxWidth,
    this.isHistory = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = ThemeNotifier();
    // return Container();
    bool sender = (data.sender ?? 0).toString() == (Global.user?.id ?? '');
    return MessageBox(
      leftWidget: readWidget,
      isHistory: isHistory,
      send: sender,
      color: myColors.tagColor,
      maxWidth: maxWidth - (isHistory ? 70 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(messageHistory2text(data.messageHistory)),
          if (data.messageHistory != null)
            for (var v in data.messageHistory!.items)
              Text(
                history2Text(v),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: myColors.textGrey,
                ),
              ),
          Divider(
            color: myColors.lineGrey,
            indent: .5,
            height: 10,
          ),
          Text(
            '聊天记录'.tr(),
            style: TextStyle(
              fontSize: 12,
              color: myColors.textGrey,
            ),
          )
        ],
      ),
    );
  }
}

// 视频消息
class MessageVideo extends StatelessWidget {
  final Message data;

  const MessageVideo({
    required this.data,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = ThemeNotifier();
    var local = !urlValid(data.content ?? '');
    var cover =
        local ? (data.fileUrl ?? '') : getVideoCover(data.content ?? '');
    bool sender = (data.sender ?? 0).toString() == (Global.user?.id ?? '');
    double width = 150;
    double? height;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (local && platformPhone)
            SizedBox(
              width: width,
              child: AppVideo(url: data.content ?? ''),
            ),
          if (local && Platform.isWindows)
            Container(
              width: width,
              constraints: const BoxConstraints(
                maxHeight: 300,
              ),
              child: AppVideoWin(
                url: data.content ?? '',
                autoPlay: false,
                showContorll: false,
              ),
            ),
          if (!local)
            cover.isNotEmpty
                ? AppNetworkImage(
                    cover,
                    width: width,
                    height: height,
                    borderRadius: BorderRadius.circular(5),
                  )
                : Container(
                    width: width,
                    height: width,
                    padding: const EdgeInsets.only(top: 30),
                    alignment: Alignment.topCenter,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: myColors.grey,
                    ),
                    child: Text(
                      '未找到视频封面',
                      style: TextStyle(
                        color: myColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          if (!local) Image.asset(assetPath('images/play2.png'), width: 40),
          //视频时长
          Positioned(
            bottom: 5,
            right: sender ? null : 5,
            left: sender ? 5 : null,
            child: Text(
              second2minute(data.duration ?? 0),
              style: TextStyle(
                color: myColors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 笔记消息
class MessageNote extends StatelessWidget {
  final Message data;
  final Widget readWidget;
  final bool isHistory;
  final double maxWidth;

  const MessageNote({
    required this.maxWidth,
    required this.data,
    required this.readWidget,
    this.isHistory = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = ThemeNotifier();
    var note = json2note(data.content ?? '');
    bool sender = (data.sender ?? 0).toString() == (Global.user?.id ?? '');
    return MessageBox(
      leftWidget: readWidget,
      isHistory: isHistory,
      send: sender,
      padding: const EdgeInsets.all(0),
      color: myColors.tagColor,
      maxWidth: maxWidth - (isHistory ? 70 : 0),
      child: NoteItemPro(
        note,
        titleSize: 14,
        textSize: 12,
        marginBottom: 0,
        vertical: 10,
        horizontal: 10,
        isMessage: true,
      ),
    );
  }
}

// 语音、视频通话消息
class MessageCall extends StatelessWidget {
  final Message data;
  final bool isHistory;
  final double maxWidth;
  final IconData icon;

  const MessageCall({
    required this.data,
    required this.maxWidth,
    required this.icon,
    this.isHistory = false,
    super.key,
  });

  String _getCallText() {
    switch (data.callStatus) {
      case GCallStatus.NIL:
        return '';
      case GCallStatus.WAIT:
        return '等待接听'.tr();
      case GCallStatus.ACCEPT:
        return '已接听'.tr();
      case GCallStatus.REJECT:
        return '已拒绝'.tr();
      case GCallStatus.CANCEL:
        return '已取消'.tr();
      case GCallStatus.HANG_UP:
        return '已通话'.tr();
      case GCallStatus.EXPIRED:
        return '未接听'.tr();
      case GCallStatus.BUSY:
        return '忙线中'.tr();
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    var myColors = ThemeNotifier();
    var content = _getCallText();
    if (data.callStatus == GCallStatus.HANG_UP) {
      content += ' ${second2minute(data.duration ?? 0)}';
    }
    bool send = (data.sender ?? 0).toString() == (Global.user?.id ?? '');
    Widget iconWidget = Padding(
      padding: EdgeInsets.only(
        left: !send ? 0 : 5,
        right: send ? 0 : 5,
      ),
      child: Icon(
        icon,
        size: 18,
        color: send ? myColors.textBlack : null,
      ),
    );
    return MessageBox(
      color: send ? null : myColors.tagColor,
      isHistory: isHistory,
      send: send,
      maxWidth: maxWidth,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!send) iconWidget,
          Text(
            content,
            style: TextStyle(
              color: send ? myColors.textBlack : null,
            ),
          ),
          if (send) iconWidget,
        ],
      ),
    );
  }
}

// 文件消息组件
class MessageFile extends StatelessWidget {
  final Message data;
  final Widget readWidget;
  final bool isHistory;

  const MessageFile({
    required this.data,
    required this.readWidget,
    this.isHistory = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = ThemeNotifier();
    var uri = Uri.parse(data.fileUrl ?? '');
    bool sender = (data.sender ?? 0).toString() == (Global.user?.id ?? '');
    return MessageBox(
      leftWidget: readWidget,
      isHistory: isHistory,
      maxWidth: 240,
      send: sender,
      color: sender ? null : myColors.tagColor,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.content ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  b2size((data.duration ?? 0).toDouble()),
                  style: TextStyle(
                    fontSize: 12,
                    color: myColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                assetPath('images/sp_wenjian.png'),
                width: 50,
              ),
              Container(
                width: 30,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 15),
                child: Text(
                  uri.path.split('.').last.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 语音消息
class MessageVoice extends StatelessWidget {
  final Message data;
  final double maxWidth;
  final Widget readWidget;
  final bool isHistory;
  final bool playing;

  const MessageVoice({
    required this.data,
    required this.maxWidth,
    required this.readWidget,
    this.isHistory = false,
    this.playing = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = ThemeNotifier();
    bool isVip =
        toInt(data.senderUser?.vipExpireTime ?? 0) >= toInt(date2time(null));
    bool sender = (data.sender ?? 0).toString() == (Global.user?.id ?? '');
    var iconUrl = assetPath('images/sp_yuying${sender ? '_white' : ''}.png');
    if (playing) {
      iconUrl = assetPath('images/voice_play${sender ? '_send' : ''}.gif');
    }
    var icon = Padding(
      padding: EdgeInsets.only(
        left: !sender ? 0 : 5,
        right: !sender ? 5 : 0,
      ),
      child: Image.asset(
        iconUrl,
        height: 15,
        width: 15,
        color: isVip ? myColors.white : null,
      ),
    );
    var rate = (data.duration ?? 0) / 60;
    rate = rate > 1 ? 1 : rate;
    double minWidth = 50;
    minWidth += maxWidth * rate;
    minWidth = minWidth > maxWidth ? maxWidth : minWidth;

    return MessageBox(
      color: sender ? null : myColors.tagColor,
      leftWidget: readWidget,
      isHistory: isHistory,
      maxWidth: maxWidth,
      minWidth: minWidth,
      send: sender,
      sendData: data.senderUser,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment:
            sender ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // Icon(Icons.voicemail),
          !sender ? icon : Container(),
          Text(
            '${data.duration}”',
            style: TextStyle(
              color: sender || isVip ? myColors.white : null,
            ),
          ),
          sender ? icon : Container(),
        ],
      ),
    );
  }
}

//消息内容框
class MessageBox extends StatelessWidget {
  final double maxWidth;
  final double minWidth;
  final double radius;
  final bool send;
  final Widget child;
  final Widget? leftWidget;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final bool isHistory;
  final ShowUser? sendData;

  const MessageBox({
    required this.maxWidth,
    required this.child,
    this.leftWidget,
    this.minWidth = 0,
    this.radius = 10,
    this.send = false,
    this.sendData,
    this.color,
    this.padding,
    this.isHistory = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = ThemeNotifier();
    // Color bgColor = send ? myColors.primary : myColors.white;
    Color bgColor = send ? myColors.circleBlueButtonBg : myColors.white;
    if (color != null) bgColor = color!;
    var borderRadius = BorderRadius.only(
      topLeft: Radius.circular(send ? radius : 3),
      topRight: Radius.circular(!send ? radius : 3),
      bottomLeft: Radius.circular(radius),
      bottomRight: Radius.circular(radius),
    );
    Gradient? gradient;
    EdgeInsets margin = EdgeInsets.only(
      right: send ? 4 : 0,
      left: send ? 0 : 4,
    );
    bool isVip = toInt(sendData?.vipExpireTime ?? 0) >= toInt(date2time(null));
    if (isVip) {
      margin = EdgeInsets.only(
        right: send ? 8 : 10,
        left: send ? 10 : 8,
        top: 12,
        bottom: 5,
      ); //vip时边距
      gradient = vipStageBubble(sendData?.vipLevel ?? GVipLevel.NIL);
    }
    return Row(
      children: [
        if (send)
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: leftWidget,
          ),
        Stack(
          alignment: send ? Alignment.topRight : Alignment.topLeft,
          children: [
            // if (!isHistory)
            // Positioned(
            //   top: 15,
            //   child: Transform.rotate(
            //     angle: 2.3,
            //     child: Container(
            //       width: 10,
            //       height: 10,
            //       decoration: BoxDecoration(
            //         color: bgColor,
            //         borderRadius: BorderRadius.circular(2),
            //       ),
            //     ),
            //   ),
            // ),
            // ClipRRect(
            //   borderRadius: borderRadius,
            //   child:
            Container(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                minWidth: minWidth,
              ),
              padding: padding ?? const EdgeInsets.all(10),
              margin: isHistory //消息外边距
                  ? null
                  : margin,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: borderRadius,
                boxShadow: [
                  BoxShadow(
                    color: myColors.bottomShadow,
                    blurRadius: 5,
                    offset: const Offset(0, 0),
                  ),
                ],
                gradient: gradient,
              ),
              child: child,
            ),
            if (isVip)
              Positioned(
                left: send ? 0 : null,
                right: send ? null : 0,
                top: 0,
                child: Transform.rotate(
                  angle: send ? 0 : 45,
                  child: Image.asset(
                    assetPath('images/talk/v1talk.png'),
                    width: 31,
                    height: 25,
                  ),
                ),
              ),
            if (isVip)
              Positioned(
                left: send ? 2 : 0,
                bottom: 0,
                child: Image.asset(
                  assetPath('images/talk/left_bottom.png'),
                  width: 52,
                  height: 23,
                ),
              ),
            if (isVip)
              Positioned(
                right: send ? 0 : 2,
                bottom: 0,
                child: Image.asset(
                  assetPath('images/talk/right_bottom.png'),
                  width: 52,
                  height: 23,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

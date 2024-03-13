import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:badges/badges.dart' as badges;
import 'package:desktop_drop/desktop_drop.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openapi/api.dart';
import 'package:unionchat/common/api_request.dart';
import 'package:unionchat/common/cache_file.dart';
import 'package:unionchat/common/enum.dart';
import 'package:unionchat/common/file_share.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/common/media_save.dart';
import 'package:unionchat/db/message_utils.dart';
import 'package:unionchat/db/model/message.dart';
import 'package:unionchat/db/model/notes.dart';
import 'package:unionchat/db/notes_utils.dart';
import 'package:unionchat/db/notifier/channel_list_notifier.dart';
import 'package:unionchat/db/notifier/channel_page_notifier.dart';
import 'package:unionchat/db/notifier/message_notifier.dart';
import 'package:unionchat/function_config.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/notifier/custom_emoji_notifier.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/pages/call/mini_talk_overlay.dart';
import 'package:unionchat/pages/chat/widgets/chat_input.dart';
import 'package:unionchat/pages/chat/widgets/chat_talk_model.dart';
import 'package:unionchat/pages/chat/widgets/chat_talk_title.dart';
import 'package:unionchat/pages/chat/widgets/red_packet.dart';
import 'package:unionchat/pages/chat/widgets/talk_message.dart';
import 'package:unionchat/pages/chat/widgets/top_message.dart';
import 'package:unionchat/pages/file_preview.dart';
import 'package:unionchat/pages/friend/friend_detail.dart';
import 'package:unionchat/pages/message_menu/red_integral/red_packet_integral.dart';
import 'package:unionchat/pages/message_menu/red_integral/red_packet_integral_detil.dart';
import 'package:unionchat/pages/message_menu/red_packet.dart';
import 'package:unionchat/pages/message_menu/red_packet_detil.dart';
import 'package:unionchat/pages/note/note_detail_pro.dart';
import 'package:unionchat/pages/play_video.dart';
import 'package:unionchat/pages/play_video_win.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/map.dart';
import 'package:unionchat/widgets/pc_send_file_preview.dart';
import 'package:unionchat/widgets/photo_preview.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:unionchat/widgets/undo_dialog.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import '../../common/common_data.dart';
import '../../common/file_save.dart';
import '../help/circle/circle_card.dart';
import '../help/group/group_home.dart';
import '../share/share_home.dart';
import 'chat_forward.dart';
import 'chat_management/group_apply_manage.dart';
import 'chat_management/group_card.dart';
import 'chat_management/group_notice.dart';
import 'chat_setting.dart';

class ItemOrDate {
  int index;
  String date;

  ItemOrDate({required this.index, this.date = ''});
}

//消息查询方式
enum ChatQueryType {
  up,
  down,
  search,
  init,
}

class ChatTalk extends StatefulWidget {
  final ChatItemData? data;

  const ChatTalk({this.data, super.key});

  static const String path = 'chat/talk';

  @override
  State<StatefulWidget> createState() {
    return _ChatTalkState();
  }
}

class _ChatTalkState extends State<ChatTalk> {
  int initTime = DateTime.now().millisecondsSinceEpoch;
  static final Map<String, Map<String, List<String>>> _roomManageIds =
      {}; // 群聊管理员列表
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textEditingController = TextEditingController();
  final GlobalKey _stackKey = GlobalKey();
  ChannelPageNotifier? _notifier;
  final _topNotifier = ValueNotifier<List<Message>>([]);
  final _chatInputNotifier = ChatInputNotifier();
  var _params = ChatTalkParams(); // 页面传递参数
  var _roomData = ChatTalkRoomData(); // 群聊相关变量
  var _userData = ChatTalkUserData(); // 个人相关变量
  GUserModel? _user; // 好友信息
  final _talkData = ChatTalkData(); // 对话相关变量
  String tipText = ''; //对话框提示文字
  Timer? _prohibitionTimer; //群聊禁言计时器
  final _scrollController = ScrollController();
  GlobalKey? _centerKey;
  int? _centerId;
  final Map<int, GlobalKey> _msgKeys = {};

  int limit = 20;
  double voiceWidth = 0;
  double voiceHeight = 0;
  double decibels = 0; //语音振幅
  VoicePressType voicePressType = VoicePressType.nil;
  StreamSubscription<GChatModel>? messageSub; // 消息接收监听器
  List<int> chooseIds = []; // 选择的消息id
  List<Message> chooseMessage = []; // 选择的消息
  bool checkModal = false; // 是否开启多选模式
  bool _isButtonDisabled = false; // 按钮是否已经点击
  bool _showDropWidget = false; // 是否显示拖动弹窗
  final List<Message> _scrollMessageList = []; // todo:滚动条未在最底部时接收到的新消息
  bool _firstTipWarning = false; // 第一次进入显示清空记录弹窗
  final player = AudioPlayer(); // 语音播放器
  late StreamSubscription<PlayerState> audioSub; // 语音播放监听器
  final ValueNotifier<bool> _showRemind = ValueNotifier(false); //是否显示@我
  bool _dispose = false;

  //页面数据初始化
  _initData() async {
    if (_params.queryId.isNotEmpty) {
      await _getChatHistory(
        type: ChatQueryType.search,
        id: toInt(_params.queryId),
      );
    } else {
      await _getChatHistory(type: ChatQueryType.init);
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      futureDelayFunction(_dataRequest);
    });
  }

  // 请求数据
  _dataRequest() {
    if (_dispose) return;
    _getTalkInfo();
    MessageUtil.reportRead([_params.pairId]);
    _getTopMessage();
    Global.syncLoginUser();
  }

  // 是否禁言
  _getEnableSend() {
    var nowTime = toInt(date2time(null));
    _talkData.enableSend = nowTime - _roomData.prohibitionTime > 0;
  }

  // 获取对话信息
  Future<void> _getTalkInfo({bool init = true}) async {
    if (init) {
      _talkData.enableRevoke = UserPowerType.undo.hasPower;
      _talkData.enableEdit = UserPowerType.edit.hasPower;
    }
    final api = UserApi(apiClient());
    try {
      final args = V1UserChannelArgs();
      if (_params.receiver.isNotEmpty) {
        args.userId = _params.receiver;
      } else if (_params.roomId.isNotEmpty) {
        args.roomId = _params.roomId;
      }
      final res = await api.userChannel(args);
      if (res == null) return;
      _userInfoInit(res.user);
      _topicInfoInit(res.channel);
      _roomManageInit(res.roomAdmin);
      _roomInfoInit(res.room, res.my);
    } on ApiException catch (e) {
      var err = parseError(e);
      if (err.code == 4303) {
        _roomData.roomDissolve = true;
        tipText = '当前群聊已解散'.tr();
      } else if (err.code == 4304) {
        _roomData.roomDisabled = true;
        tipText = '当前群聊已被封禁'.tr();
      }
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {
      if (mounted || !_dispose) setState(() {});
    }
  }

  // 初始化群管理员
  _roomManageInit(List<GRoomMemberModel> manage) {
    if (_params.roomId.isEmpty) return;
    List<String> admin = [];
    List<String> owner = [];
    for (var v in manage) {
      if (v.identity == GRoomMemberIdentity.ADMIN) {
        admin.add(v.userId!);
      } else if (v.identity == GRoomMemberIdentity.OWNER) {
        owner.add(v.userId!);
      }
    }
    _roomManageIds[_params.roomId] ??= {
      'admin': admin,
      'owner': owner,
    };
  }

  // 初始化对话信息
  _topicInfoInit(GChannelModel? res) {
    if (res == null) return;
    MessageUtil.updateChannel(res);
    _params.isTop = toInt(res.topTime) > 0;
    _params.doNotDisturb = res.doNotDisturb ?? false;
    int otherChatDestroy = toInt(res.otherChatDestroyDuration);
    int chatDestroy = toInt(res.messageDestroyDuration);
    //判断我和对方是否针对当前对话设置自毁时间，
    int topicDestroy =
        chatDestroy < otherChatDestroy ? chatDestroy : otherChatDestroy;
    int mineDestroy = toInt(Global.user?.chatDestroyDuration);
    //判断全局和当前对话的自毁时间
    int destroy = topicDestroy <= 0 ? mineDestroy : topicDestroy;
    _params.readId = toInt(res.otherReadId);
    _talkData.destroyTime = destroy;
    // _params.name = res.nickname ?? '';
    // _params.mark = res.mark ?? '';
    _talkData.showWarning = res.applyClean == GApplyCleanStatus.APPLY;
    if (_talkData.showWarning && !_firstTipWarning) {
      _firstTipWarning = true;
      _showCleanMessage();
    }
  }

  // 初始化个人信息
  _userInfoInit(GUserModel? user) {
    if (_params.receiver.isEmpty || user == null) return;
    _user = user;
    var ud = ChatTalkUserData();
    _params.userNumber = user.userExtend?.userNumber ?? '';
    _params.numberType = user.userExtend?.userNumberType;
    _params.circleGuarantee = toBool(user.userExtend?.circleGuarantee);
    ud.avatar = user.avatar ?? '';
    ud.onlineTime = time2onlineDate(
      user.lastOnlineTime,
      joinStr: '在线'.tr(),
      zeroStr: '在线'.tr(),
    );
    ud.online = ud.onlineTime == '在线'.tr();
    ud.userIP = ('${user.ip ?? ''} ${user.city ?? ''}').trim();
    ud.userId = user.id ?? '';
    ud.userAccount = user.account ?? '';
    _params.name = user.nickname ?? '';
    _params.mark = user.mark ?? '';
    _params.vip =
        toInt(user.userExtend?.vipExpireTime) >= toInt(date2time(null));
    _params.vipLevel = user.userExtend?.vipLevel ?? GVipLevel.NIL;
    _params.vipBadge = user.userExtend?.vipBadge ?? GBadge.NIL;
    _params.onlyName = toBool(user.useChangeNicknameCard);
    _userData = ud;
  }

  // 初始化群信息
  _roomInfoInit(GRoomModel? room, GRoomMemberModel? my) {
    if (_params.roomId.isEmpty || room == null || my == null) return;
    final rd = ChatTalkRoomData(enableVisit: true);
    if (toDouble(my.id) <= 0) {
      rd.roomOut = true;
      return;
    }
    _params.name = room.roomName ?? '';
    _params.mark = room.roomMark ?? '';
    rd.roomUnreadCount = toInt(room.unreadCount);
    rd.roomNotice = room.notice ?? '';
    rd.roomNoticeRead = Global.isUserNoticeDataRead(
      _params.roomId,
      rd.roomNotice,
    );
    if (FunctionConfig.roomShowTotal) {
      _params.totalCount = room.totalCount ?? '';
    }
    rd.identity = my.identity ?? GRoomMemberIdentity.NIL;
    rd.roomManage = rd.identity == GRoomMemberIdentity.ADMIN ||
        rd.identity == GRoomMemberIdentity.OWNER;
    if (rd.roomManage) {
      rd.roomPower = -1;
      _talkData.enableTop = true;
    } else {
      rd.allNoSpeak = toBool(room.enableProhibition);
      rd.roomPower = toInt(room.allowChatType);
      rd.enableVisit = toBool(room.enableVisit);
      if (_talkData.enableRevoke) {
        _talkData.enableRevoke = toBool(room.enableRevoke);
      }
      if (_talkData.enableEdit) {
        _talkData.enableEdit = toBool(room.enableEditMessage);
      }
      rd.prohibitionTime = toInt(my.prohibitionTime);
      if (rd.prohibitionTime == 0) {
        rd.prohibitionTime = toBool(room.enableProhibition)
            ? toInt(
                date2time(
                  DateTime.now().add(
                    const Duration(days: 365 * 10),
                  ),
                ),
              )
            : 0;
      }
    }
    _roomData = rd;
    _getEnableSend();
    if (!_talkData.enableSend) {
      _prohibitionTimer?.cancel();
      _prohibitionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _getEnableSend();
        setState(() {});
      });
    }
  }

  //查询置顶消息
  Future<void> _getTopMessage() async {
    _topNotifier.value = await MessageUtil.listTopMessages(_params.pairId);
  }

  // 查询聊天记录
  Future<void> _getChatHistory({
    ChatQueryType type = ChatQueryType.init,
    int id = 0,
    Function()? over,
    double? oldScrollMax,
  }) async {
    // logger.d('---------1>>> ${_notifier!.loading.value} ');
    if (_notifier == null) return;
    if (_notifier!.loading.value) {
      over?.call();
      return;
    }
    switch (type) {
      case ChatQueryType.up:
        // logger.d('--------->>> ${_notifier!.upMore.value} ');
        if (!_notifier!.upMore.value) {
          over?.call();
          return;
        }
        await _notifier!.nextUp();
        over?.call();
        break;
      case ChatQueryType.down:
        if (!_notifier!.downMore.value) {
          if (_centerId != null) _centerId = null;
          over?.call();
          return;
        }
        await _notifier!.nextDown();
        over?.call();
        break;
      case ChatQueryType.search:
        if (id <= 0) {
          over?.call();
          return;
        }
        _centerId = id;
        await _notifier!.initPage(id: id);
        over?.call();
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          _scrollController.jumpTo(0);
          _countShowRemind();
        });
        break;
      case ChatQueryType.init:
        await _notifier!.initPage();
        over?.call();
        _countShowRemind();
        break;
    }
  }

  // 判断是否显示@消息
  _countShowRemind() {
    if (_params.remindId.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var goKey = _msgKeys[toInt(_params.remindId)];
      if (goKey == null) {
        _showRemind.value = true;
        return;
      }
      if (goKey.currentContext == null) return;
      RenderBox? box = goKey.currentContext!.findRenderObject() as RenderBox;
      var boxOffset = box.localToGlobal(Offset.zero);
      if (boxOffset.dy < 0) {
        _showRemind.value = true;
      } else {
        _params.remindId = '';
        _showRemind.value = false;
      }
    });
  }

  //语音按住事件
  voicePress(VoicePressType type) {
    voicePressType = type;
    switch (type) {
      case VoicePressType.down:
        voiceWidth = _stackKey.currentContext!.size!.width;
        voiceHeight = _stackKey.currentContext!.size!.height - 50;
        break;
      case VoicePressType.up:
        voiceWidth = 0;
        voiceHeight = 0;
        break;
      case VoicePressType.out:
      case VoicePressType.inside:
      case VoicePressType.nil:
        return;
    }
    setState(() {});
  }

  //红包弹窗
  Future<void> _showMyDialog(Message msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return RedPacketDialog(
          msg,
          onOpen: () {
            _takeRed(msg, context);
          },
          onDetail: () {
            _takeRed(msg, context, take: false);
          },
        );
      },
    );
  }

  //查看用户详情
  seeDetail(Message data) {
    if (((data.sender ?? 0).toString() == Global.user?.id) ||
        !_roomData.enableVisit ||
        _roomData.roomDisabled ||
        _roomData.roomDissolve) {
      return;
    }
    Navigator.pushNamed(
      context,
      FriendDetails.path,
      arguments: {
        'id': data.sender.toString(),
        'roomId': _params.roomId,
        'roomManage': _roomData.roomManage,
        'friendFrom': _params.roomId.isNotEmpty ? 'ROOM' : '',
        'removeToTabs': true,
        'detail': GUserModel(
          avatar: data.senderUser?.avatar ?? '',
          nickname: data.senderUser?.nickname ?? '',
        ),
      },
    );
  }

  //头像长按事件
  avatarLongTap(Message data) {
    if (_params.roomId.isEmpty ||
        (data.sender ?? 0).toString() == Global.user?.id ||
        _chatInputNotifier.remindContainsId(data.sender.toString())) {
      return;
    }
    _chatInputNotifier.remindAdd(ChatItemData(
      icons: [''],
      title: data.senderUser?.nickname ?? '',
      id: data.sender.toString(),
    ));
    var controller = _textEditingController;
    var inputText = controller.text;
    controller.text = '$inputText@${data.senderUser?.nickname ?? ''} ';
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
    _focusNode.requestFocus();
    if (!_chatInputNotifier.showSendBtn) {
      _chatInputNotifier.showSendBtn = true;
    }
  }

  //消息双击事件
  messageDoubleTap(Message data) async {
    _chatInputNotifier.quoteEditMessageData = data;
    _chatInputNotifier.messagePopType = MessagePopType.quote;
    _focusNode.requestFocus();
  }

  //消息图片点击事件
  messageImageTap(Message data, String url) {
    List<String> mediaList = [];
    for (var v in _notifier!.messages) {
      var url = v.message.content ?? '';
      if (v.message.type != GMessageType.IMAGE) {
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

  //语音播放监听
  audioListen(PlayerState state) {
    bool stop = false;
    switch (state) {
      case PlayerState.stopped:
        stop = true;
        break;
      case PlayerState.playing:
        break;
      case PlayerState.paused:
        stop = true;
        break;
      case PlayerState.completed:
        stop = true;
        break;
      case PlayerState.disposed:
        stop = true;
        break;
    }
    if (stop) {
      MessageNotifier.stopAllPlaying();
    }
  }

  //播放语音
  playVoice(Message data) async {
    MessageNotifier.stopAllPlaying();
    MessageNotifier.playingForId(data.id);
    if (player.state == PlayerState.playing) {
      await player.stop();
    }
    String path = data.content ?? '';
    if (path.isEmpty) return;
    MessageNotifier.setLoading(data.id, true);
    var file = await CacheFile.load(path);
    var filepath = file.path;
    if (Platform.isWindows) {
      filepath = filepath.replaceAll('/', '\\');
    }
    MessageNotifier.setLoading(data.id, false);
    await player.play(DeviceFileSource(filepath));
  }

  //消息点击事件
  messageTap(Message data) async {
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
      case GMessageType.AUDIO:
        playVoice(data);
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
        logger.i(data);
        logger.i(data.location);
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
      case GMessageType.RED_PACKET:
        // redPacketId = data.contentId;
        _requestData(data);
        break;
      case GMessageType.RED_INTEGRAL:
        _requestIntegralData(data);
        break;
      case GMessageType.AUDIO_CALL:
        sendCall(false);
        break;
      case GMessageType.VIDEO_CALL:
        sendCall(true);
        break;
      case GMessageType.NOTES:
        Navigator.pushNamed(
          context,
          NoteDetailPro.path,
          arguments: {
            // 'id': data.contentId.toString(),
            'preview': true,
            'notes': Notes.fromJson(jsonDecode(data.content ?? '')),
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
            'detail': GCircleModel(image: data.fileUrl),
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

  //引用消息点击事件
  quoteMessageTap(MessageItem data, int id) {
    if (id < 0) return;
    _getChatHistory(type: ChatQueryType.search, id: id);
  }

  //长按菜单点击事件
  messagePopTap(MessagePopType type, Message data) async {
    switch (type) {
      case MessagePopType.copy:
        await Clipboard.setData(ClipboardData(text: data.content ?? ''));
        tipSuccess('复制成功'.tr());
        break;
      case MessagePopType.forward:
        forwardSend([data]);
        break;
      case MessagePopType.undo:
        break;
      case MessagePopType.quote:
      case MessagePopType.edit:
        _chatInputNotifier.quoteEditMessageData = data;
        _chatInputNotifier.messagePopType = type;
        if (type == MessagePopType.edit) {
          _textEditingController.text = data.content ?? '';
          _focusNode.requestFocus();
        }
        break;
      case MessagePopType.remove:
        messageRemoveConfirm([data]);
        break;
      case MessagePopType.top:
        messageTop(data, true);
        break;
      case MessagePopType.save:
        if (data.type == GMessageType.NOTES) {
          noteSave(data);
        } else {
          mediaSave(data);
        }
        break;
      case MessagePopType.share:
        FileShare().shareFile(data.content ?? '');
        break;
      case MessagePopType.collect:
        messageCollect([data.id]);
        break;
      case MessagePopType.choice:
        setState(() {
          checkModal = true;
        });
        break;
      case MessagePopType.ban:
        silenceEnabled(data.sender);
        break;
      case MessagePopType.saveCustom:
        CustomEmojiNotifier().saveCustom(data.content ?? '', load: true);
        break;
    }
  }

  // 笔记保存
  void noteSave(Message data) async {
    loading();
    try {
      var notes = Notes.fromJson(jsonDecode(data.content ?? ''));
      var sendNotes = Notes();
      sendNotes.items = notes.items.toList();
      await NotesUtils.save(sendNotes);
      tipSuccess('保存成功'.tr());
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {
      loadClose();
    }
  }

  //图片、视频保存
  Future<void> mediaSave(Message data) async {
    String url = data.content ?? '';
    if (data.type == GMessageType.VIDEO) {
      await MediaSave().saveMedia(url, video: true);
    } else {
      await MediaSave().saveMedia(url);
    }
  }

  //收藏
  messageCollect(List<int> ids) async {
    for (var v in chooseMessage) {
      if (v.type == GMessageType.RED_PACKET ||
          v.type == GMessageType.RED_INTEGRAL) {
        tipError('红包无法收藏，请取消选择');
        return;
      }
    }
    var api = UserFavoritesApi(apiClient());
    loading();
    try {
      var args = V1UserFavoritesArgs(
        pairId: _params.pairId,
        ids: ids.map((e) => e.toString()).toList(),
      );
      await api.userFavoritesFavorites(args);
      tipSuccess('收藏成功');
      if (!checkModal) return;
      setState(() {
        checkModal = false;
        chooseIds = [];
        chooseMessage = [];
      });
    } on ApiException catch (e) {
      tipError('收藏失败');
      onError(e);
    } catch (e) {
      tipError('收藏失败');
      logger.e(e);
    } finally {
      loadClose();
    }
  }

  // 通过id删除置顶消息
  _topRemoveById(int id) {
    var i = -1;
    for (var v in _topNotifier.value) {
      if (v.id == id) {
        i = _topNotifier.value.indexOf(v);
      }
    }
    if (i == -1) return;
    List<Message> l = List<Message>.from(_topNotifier.value);
    l.removeAt(i);
    _topNotifier.value = l;
  }

  //消息置顶
  messageTop(Message data, bool top) async {
    if (!_talkData.enableTop) return;
    if (top) {
      for (var v in _topNotifier.value) {
        if (v.id == data.id) return;
      }
    }
    await MessageUtil.setMessageTop(data.id, top);
    if (top) {
      List<Message> l = List<Message>.from(_topNotifier.value);
      l.insert(0, data);
      _topNotifier.value = l;
    } else {
      _topRemoveById(data.id);
    }
  }

  //置顶消息点击
  topMessageTap(Message data) async {
    _getChatHistory(type: ChatQueryType.search, id: data.id);
  }

  //消息删除、撤回
  messageUndo(List<Message> messages) async {
    loading();
    List<String> allIds = []; //所有的消息
    List<String> notOverIds = []; //我的超限消息
    List<String> overIds = []; //我的未超限消息
    List<String> mineIds = []; //我的消息id
    List<String> otherIds = []; //其他人的消息id
    for (var msg in messages) {
      var id = msg.id.toString();
      allIds.add(id);
      if ((msg.sender ?? 0).toString() != Global.user!.id) {
        otherIds.add(id);
      } else {
        if (isTimestamp15MinutesAgo(msg.createTime)) {
          notOverIds.add(id);
        } else {
          overIds.add(id);
        }
        mineIds.add(id);
      }
    }
    List<String> undoIds = [];
    List<String> removeIds = [];
    if (_talkData.undo) {
      if (_params.roomId.isNotEmpty) {
        if (_roomData.roomManage) {
          undoIds = allIds;
        } else {
          undoIds = mineIds;
          removeIds = otherIds;
        }
      } else {
        undoIds = [...notOverIds];
        removeIds = [...overIds, ...otherIds];
      }
    } else {
      removeIds = allIds;
    }
    try {
      if (undoIds.isNotEmpty) {
        await MessageUtil.clearMessage(
          _params.pairId,
          undoIds.map((e) => toInt(e)).toList(),
          both: true,
        );
      }
      if (removeIds.isNotEmpty) {
        await MessageUtil.clearMessage(
          _params.pairId,
          removeIds.map((e) => toInt(e)).toList(),
          both: true,
        );
      }
      if (!checkModal) return;
      setState(() {
        checkModal = false;
        chooseIds = [];
        chooseMessage = [];
      });
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {
      loadClose();
    }
  }

  // 消息转发提示
  forwardSendMenu() {
    for (var v in chooseMessage) {
      if (v.type == GMessageType.FORWARD_CIRCLE) {
        tipError('圈子无法转发，请取消选择');
        return;
      }
      if (v.type == GMessageType.AUDIO) {
        tipError('语音无法转发，请取消选择');
        return;
      }
      if (v.type == GMessageType.RED_PACKET ||
          v.type == GMessageType.RED_INTEGRAL) {
        tipError('红包无法转发，请取消选择');
        return;
      }
    }
    openSheetMenu(context, list: ['逐条转发'.tr(), '合并转发'.tr()], onTap: (i) {
      forwardSend(chooseMessage, merge: i == 1);
    });
  }

  //消息转发
  forwardSend(List<Message> list, {bool merge = false}) {
    String content = '';
    if (_params.roomId.isNotEmpty) {
      content = '的聊天记录'.tr(args: [_params.name]);
    } else {
      content =
          '[消息转发]和的聊天记录'.tr(args: [_params.name, Global.user!.nickname ?? '']);
    }
    Message? msg;
    if (merge) {
      msg = MessageUtil.newMessage(_params.pairId, GMessageType.HISTORY);
      var messageHistory = MessageHistory()
        ..messageIds = list.map((e) => e.id).toList()
        ..items = list.map((e) => MessageItem.fromMessage(e)).toList();
      if (_params.roomId.isNotEmpty) {
        messageHistory.isRoom = true;
        messageHistory.nameA = _params.name;
      } else {
        messageHistory.isRoom = false;
        messageHistory.nameA = _params.name;
        messageHistory.nameB = Global.user!.nickname ?? '';
      }
      msg.messageHistory = messageHistory;
    }
    Navigator.push(
      context,
      CupertinoModalPopupRoute(
        builder: (context) {
          return ShareHome(
            shareText: content,
            list: merge ? [msg!] : list,
            merge: merge,
          );
        },
      ),
    ).then((value) {
      if (!mounted || !checkModal) return;
      setState(() {
        chooseIds = [];
        chooseMessage = [];
        checkModal = false;
      });
    });
  }

  //禁言
  silenceEnabled(int? id) async {
    if (id == null) return;
    var cfm = await confirm(context, title: '确定要禁言该用户？');
    if (cfm != true) return;
    ApiRequest.apiUserSilence([id.toString()], _params.roomId, load: true);
  }

  //发送文件
  _sendSingleFile(File file) async {
    var path = file.path;
    switch (getFileType(path)) {
      case AppFileType.image:
        sendMessage(path, GMessageType.IMAGE);
        break;
      case AppFileType.video:
        getVideoDuration(path, success: (seconds) {
          sendMessage(
            path,
            GMessageType.VIDEO,
            duration: seconds,
          );
        });
        break;
      case AppFileType.other:
        sendMessage(
          path,
          GMessageType.FILE,
          duration: await file.length(),
          fileName: path.split(Platform.isWindows ? '\\' : '/').last,
        );
        break;
    }
  }

  //拖拽发送文件监听
  _dropSendMessageListen(List<XFile> files) async {
    for (var v in files) {
      _sendSingleFile(File(v.path));
    }
  }

  //发送失败重试
  _sendFailedTap(MessageNotifier data) async {
    if (!_talkData.enableSend ||
        _roomData.roomDissolve ||
        _roomData.roomDisabled) {
      return;
    }
    var cfm = await confirm(context, title: '确定要重新发送消息？');
    if (cfm == null || !cfm) return;
    MessageUtil.resendMessage(data.message.id);
  }

  // 发送消息时判断是否需要滚动到最底部
  _sendMessageScroll({Function()? over}) async {
    double scroll = _scrollController.position.pixels;
    double scrollMin = _scrollController.position.minScrollExtent;
    if (_centerId != null) _centerId = null;
    if (scroll > scrollMin + 50) {
      _getChatHistory(
        type: ChatQueryType.init,
        over: () {
          over?.call();
          _scrollController.jumpTo(scrollMin);
        },
      );
    } else {
      over?.call();
    }
  }

  //发送消息监听
  sendMessage(
    String str,
    GMessageType type, {
    int? duration,
    // String? cover,
    String? fileName,
    MessagePopType? editType,
    Message? data,
    List<int>? remind,
  }) {
    if (!_talkData.enableSend) {
      tip('当前已禁言，请联系管理员'.tr());
      return;
    }
    if (_roomData.roomDissolve) {
      tip('当前群聊已解散'.tr());
      return;
    }
    if (_roomData.roomDisabled) {
      tip('当前群聊已被封禁'.tr());
      return;
    }
    switch (type) {
      case GMessageType.TEXT:
        if (editType != null &&
            data != null &&
            editType == MessagePopType.edit) {
          //消息编辑
          MessageUtil.editMessage(data.id, str);
        } else {
          _sendMessageScroll(
            over: () => sendText(str, quote: data, remind: remind),
          );
        }
        break;
      case GMessageType.IMAGE:
        _sendMessageScroll(
          over: () => sendImage(str),
        );
        break;
      case GMessageType.VIDEO:
        _sendMessageScroll(
          over: () => sendVideo(str, duration!),
        );
        break;
      case GMessageType.AUDIO:
        _sendMessageScroll(
          over: () => sendVoice(str, duration!),
        );
        break;
      case GMessageType.FILE:
        _sendMessageScroll(
          over: () => sendFile(str, duration!, fileName ?? ''),
        );
        break;
      case GMessageType.LOCATION: //发送位置消息
        if (data != null) {
          _sendMessageScroll(
            over: () => sendLocation(data),
          );
        }
        break;
      case GMessageType.RED_PACKET: // 红包
        _sendMessageScroll(over: sendRedPacket);
        break;
      case GMessageType.RED_INTEGRAL: // 红包
        _sendMessageScroll(over: () => sendRedPacket(integral: true));
        break;
      case GMessageType.AUDIO_CALL:
        sendCall(false);
        break;
      case GMessageType.VIDEO_CALL:
        sendCall(true);
        break;
      case GMessageType.SHAKE:
        _sendMessageScroll(over: sendShake);
        break;
      case GMessageType.NIL:
      case GMessageType.USER_CARD:
      case GMessageType.NOTES:
      case GMessageType.FORWARD_CIRCLE:
      case GMessageType.ROOM_CARD:
      case GMessageType.HISTORY:
      case GMessageType.FRIEND_APPLY_PASS:
      case GMessageType.ROOM_NOTICE_JOIN:
      case GMessageType.ROOM_NOTICE_EXIT:
      case GMessageType.GIVE_RELIABLE:
      case GMessageType.COLLECT:
      case GMessageType.FORWARD_ONE_BY_ONE:
        break;
    }
  }

  //发送抖一抖
  sendShake() async {
    final msg = _getSendMessage(GMessageType.SHAKE);
    _sendMessageApi(msg);
    Vibration.vibrate(duration: 100);
  }

  //发送消息api
  Future<bool> _sendMessageApi(Message msg) async {
    await MessageUtil.send(msg);
    return true;
    // try {
    //   logger.d(msg);
    //   await MessageUtil.send(msg);
    //   return true;
    // } catch (e) {
    //   logger.d(e);
    //   return false;
    // }
  }

  //发送文件消息
  sendFile(String path, int size, String name) async {
    final msg = _getSendMessage(GMessageType.FILE);
    msg.content = name;
    msg.fileUrl = path;
    _sendMessageApi(msg);
  }

  //发送视频消息
  sendVideo(String path, int duration) async {
    final msg = _getSendMessage(GMessageType.VIDEO);
    msg.content = path;
    msg.duration = duration;
    _sendMessageApi(msg);
  }

  //发送图片消息
  sendImage(String paths) async {
    if (_params.roomId.isEmpty && _params.receiver.isEmpty) return;
    final msg = _getSendMessage(GMessageType.IMAGE);
    msg.content = paths;
    _sendMessageApi(msg);
  }

  //发送语音消息
  sendVoice(String path, int duration) async {
    final msg = _getSendMessage(GMessageType.AUDIO);
    msg.content = path;
    msg.duration = duration;
    _sendMessageApi(msg);
  }

  //发送文字消息
  sendText(String str, {Message? quote, List<int>? remind}) async {
    final msg = _getSendMessage(GMessageType.TEXT);
    msg.content = str;
    msg.at = remind ?? [];
    if (quote != null) {
      msg.quoteMessageId = quote.id;
      msg.quoteMessage = MessageItem.fromMessage(quote);
    }
    _sendMessageApi(msg);
  }

  // 获取发送消息对象
  Message _getSendMessage(GMessageType type) {
    return MessageUtil.newMessage(_params.pairId, type)
      ..receiverUserId = toInt(_params.receiver)
      ..receiverRoomId = toInt(_params.roomId)
      ..sender = toInt(Global.user?.id)
      ..senderUser = getSenderUser()
      ..createTime = int.parse(date2time(null));
  }

  //发送语音通话消息
  sendCall(bool isVideo) async {
    if (_isButtonDisabled) return;
    List<Permission> permission = [Permission.microphone];
    if (isVideo) permission.add(Permission.camera);
    var hasPower = await devicePermission(permission);
    _isButtonDisabled = false;
    if (!hasPower || _params.roomId.isNotEmpty) return;
    if (!mounted) return;
    MiniTalk.open(
      context,
      nickname: _params.mark.isNotEmpty ? _params.mark : _params.name,
      avatar: _userData.avatar,
      isVideo: isVideo,
      toUserId: toInt(_params.receiver),
    );
  }

  //发送位置消息
  sendLocation(Message data) async {
    final msg = _getSendMessage(GMessageType.LOCATION);
    msg
      ..location = data.location
      ..title = data.title
      ..content = data.content
      ..fileUrl = data.fileUrl
      ..type = GMessageType.LOCATION;
    _sendMessageApi(msg);
    // _cleanOldMessage(1);
  }

  //发送红包--push
  sendRedPacket({bool integral = false}) async {
    if (!integral && _params.roomId.isEmpty) return;
    var msg = MessageUtil.newMessage(
      _params.pairId,
      integral ? GMessageType.RED_INTEGRAL : GMessageType.RED_PACKET,
    )
      ..receiverUserId =
          _params.receiver.isNotEmpty ? toInt(_params.receiver) : null
      ..sender = toInt(Global.user?.id)
      ..receiverRoomId =
          _params.roomId.isNotEmpty ? toInt(_params.roomId) : null
      ..senderUser = getSenderUser()
      ..createTime = int.parse(date2time(null));
    Navigator.pushNamed(
      context,
      integral ? RedPacketIntegralPage.path : RedPacketPage.path,
      arguments: msg,
    ).then((value) {});
  }

  //删除弹窗按钮
  Widget removeDialogBtn({
    required String text,
    Function()? onTap,
    Color? color,
  }) {
    var myColors = ThemeNotifier();
    color = color ?? myColors.textGrey;
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
          ),
        ),
      ),
    );
  }

  // 是否超过15分钟
  bool isTimestamp15MinutesAgo(int timestamp) {
    DateTime timestampDateTime =
        DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    DateTime now = DateTime.now();
    Duration difference = now.difference(timestampDateTime);
    return difference.inMinutes < 15;
  }

  //消息删除弹窗
  messageRemoveConfirm(List<Message> messages) {
    if ((_params.roomId.isEmpty || !_roomData.roomManage) &&
        messages.length > 20) {
      tip('已选择的消息条数超过 20 条，无法进行删除操作');
      return;
    }
    // undo = data.sender
    bool canUndo = _talkData.enableRevoke;
    // 是否有超过15分钟的消息
    var hasOverTime = false;
    // 是否有未超过15分钟的消息
    var hasNotOverTime = false;
    var overStr = '';
    var undoStr = '双向删除消息'.tr();
    var undoTitle = messages.length > 1
        ? '确定要删除所选的 ${messages.length} 条消息？'
        : '确定要删除此消息？'.tr();
    if (_talkData.enableRevoke) {
      // 选择的消息是否有我的消息
      var hasMe = false;
      // 选择的消息是否有其他人的消息
      var hasOther = false;
      for (var msg in messages) {
        if ((msg.sender ?? 0).toString() != Global.user!.id) {
          hasOther = true;
        } else {
          // 判断已选择的消息是否超过15分钟
          if (!isTimestamp15MinutesAgo(msg.createTime)) {
            hasOverTime = true;
          } else {
            hasNotOverTime = true;
          }
          hasMe = true;
        }
      }
      if (hasMe && hasOther) {
        // 选择的有其他人和我的消息
        if (_params.roomId.isNotEmpty) {
          if (!_roomData.roomManage) {
            undoStr = '撤回我的消息';
          }
        } else {
          undoStr = '撤回我的消息';
        }
      } else if (!hasMe && hasOther) {
        // 选择的只有其他人的消息
        if (_params.roomId.isNotEmpty) {
          if (!_roomData.roomManage) {
            canUndo = false;
          }
        } else {
          canUndo = false;
        }
      }

      // 判断是否有超限消息
      // if (roomId.isNotEmpty && roomManage) {
      if (_params.roomId.isNotEmpty) {
        hasOverTime = false;
      } else {
        if (hasOverTime && hasNotOverTime) {
          overStr = '包含无法撤回的消息，撤回只支持 15 分钟以内的消息';
        } else if (hasOverTime && !hasNotOverTime) {
          canUndo = false;
        }
      }
    }
    _talkData.undo = canUndo;
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            var myColors = ThemeNotifier();
            return Container(
              decoration: BoxDecoration(
                color: myColors.themeBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.only(bottom: 20, top: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        undoTitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: myColors.textGrey,
                        ),
                      ),
                      if (_talkData.undo && overStr.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            overStr,
                            style: TextStyle(
                              fontSize: 11,
                              color: myColors.red,
                            ),
                          ),
                        ),
                      if (canUndo)
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            setState(() {
                              _talkData.undo = !_talkData.undo;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AppCheckbox(
                                  value: _talkData.undo,
                                  size: 15,
                                  paddingRight: 5,
                                ),
                                Text(
                                  undoStr,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: myColors.textGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      removeDialogBtn(
                        text: '删除'.tr(),
                        color: myColors.red,
                        onTap: () {
                          Navigator.pop(context);
                          messageUndo(messages);
                        },
                      ),
                      removeDialogBtn(
                        text: '取消'.tr(),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  //获取粘贴板的文件
  void _getClipboardFile() async {
    var image = await Pasteboard.image;
    var file = '';
    //获取剪切板的截图数据
    if (image != null) {
      file = await FileSave().pcTempSaveImage(image);
    }
    //获取复制的文件
    final files = await Pasteboard.files();
    if (files.length == 1 && mounted) {
      file = files[0];
    }
    if (file.isEmpty || !mounted) return;
    var pattern = Platform.isWindows ? '\\' : '/';
    var fileName = file.split(pattern).last;
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) {
        return PcSendFilePreview(
          path: file,
          onEnter: () {
            _sendSingleFile(File(file));
          },
        );
      },
    );
    var text = _textEditingController.text;
    if (text.contains(fileName)) {
      _textEditingController.text = text.replaceAll(fileName, '');
    }
  }

  //windows粘贴快捷键监听
  void _windowsPasteListener(RawKeyEvent event) {
    RawKeyEventDataWindows data = event.data as RawKeyEventDataWindows;
    if (data.isControlPressed && data.physicalKey == PhysicalKeyboardKey.keyV) {
      _getClipboardFile();
    }
  }

  //macos粘贴快捷键监听
  void _macosPasteListener(RawKeyEvent event) async {
    RawKeyEventDataMacOs data = event.data as RawKeyEventDataMacOs;
    if (data.isMetaPressed && data.logicalKey == LogicalKeyboardKey.keyV) {
      _getClipboardFile();
    }
  }

  //键盘监听事件
  void _keyboardListener(RawKeyEvent event) {
    if (event.runtimeType == RawKeyDownEvent) {
      if (Platform.isWindows) _windowsPasteListener(event);
      if (Platform.isMacOS) _macosPasteListener(event);
    }
  }

  // 领取红包
  _takeRed(Message msg, BuildContext context1, {bool take = true}) {
    if (msg.type == GMessageType.RED_PACKET) {
      _receiveRedPacket(
        msg.contentId.toString(),
        msg.senderUser?.nickname ?? '',
        context1,
        take: take,
      );
    } else {
      _receiveIntegralRedPacket(msg, context1, take: take);
    }
  }

  //获取红包领取详情的接口
  _receiveRedPacket(String id, String nickName, BuildContext context1,
      {bool take = true}) async {
    loading();
    try {
      if (take) {
        await RedEnvelopeApi(apiClient()).redEnvelopeReceived(GIdArgs(id: id));
      }
      if (mounted) {
        Navigator.pop(context1);
        var msg = MessageUtil.newMessage(
          _params.pairId,
          GMessageType.RED_PACKET,
        )
          ..receiverUserId = toInt(_params.receiver)
          ..sender = toInt(Global.user?.id)
          ..receiverRoomId = toInt(_params.roomId)
          ..senderUser = getSenderUser()
          ..contentId = toInt(id)
          ..createTime = int.parse(date2time(null));
        Navigator.pushNamed(context, RedPacketDetilPage.path, arguments: msg);
      }
    } on ApiException catch (e) {
      onError(e);
      if (mounted) Navigator.pop(context1);
    } catch (e) {
      logger.e(e);
    } finally {
      loadClose();
    }
  }

  //获取积分红包领取详情的接口
  _receiveIntegralRedPacket(
    Message msg,
    BuildContext context1, {
    bool take = true,
  }) async {
    loading();
    try {
      if (take &&
          (_params.roomId.isNotEmpty ||
              (msg.sender ?? 0).toString() != Global.user!.id)) {
        var api = IntegralRedEnvelopeApi(apiClient());
        await api.integralRedEnvelopeReceived(GIdArgs(
          id: msg.contentId.toString(),
        ));
      }
      if (mounted) {
        Navigator.pop(context1);
        Navigator.pushNamed(context, RedPacketIntegralDetailPage.path,
            arguments: msg);
      }
    } on ApiException catch (e) {
      onError(e);
      if (mounted) Navigator.pop(context1);
    } catch (e) {
      logger.e(e);
    } finally {
      loadClose();
    }
  }

  //获取红包领取详情的接口
  _requestData(Message data) async {
    int? id = data.contentId;
    if (id == null || id <= 0) return;
    loading();
    try {
      var api = RedEnvelopeApi(apiClient());
      var res = await api.redEnvelopeSendDetails(GIdArgs(id: id.toString()));
      if (res == null) return;
      bool surplus = toInt(res.meReceived?.amount) > 0;
      if (toInt(res.details?.surplusQuantity) <= 0 ||
          surplus ||
          (_params.roomId.isEmpty &&
              (data.sender ?? 0).toString() == Global.user!.id)) {
        if (!mounted) return;
        Navigator.pushNamed(context, RedPacketDetilPage.path, arguments: data);
      } else {
        _showMyDialog(data);
      }
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {
      loadClose();
    }
  }

  //获取红包领取详情的接口
  _requestIntegralData(Message data) async {
    int? id = data.contentId;
    if (id == null || id <= 0) return;
    loading();
    try {
      var api = IntegralRedEnvelopeApi(apiClient());
      var res =
          await api.integralRedEnvelopeSendDetails(GIdArgs(id: id.toString()));
      if (res == null) return;
      bool surplus = toInt(res.meReceived?.amount) > 0;
      if (toInt(res.details?.surplusQuantity) <= 0 ||
          surplus ||
          (_params.roomId.isEmpty &&
              (data.sender ?? 0).toString() == Global.user!.id)) {
        if (!mounted) return;
        Navigator.pushNamed(context, RedPacketIntegralDetailPage.path,
            arguments: data);
      } else {
        _showMyDialog(data);
      }
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {
      loadClose();
    }
  }

  //群聊管理审核组件
  Widget roomApplyWidget() {
    bool show = _params.roomId.isNotEmpty &&
        _roomData.roomUnreadCount > 0 &&
        _roomData.roomManage;
    if (!show) return Container();
    var myColors = ThemeNotifier();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.pushNamed(context, GroupApplyManage.path,
            arguments: {'roomId': _params.roomId}).then((value) {
          _getTalkInfo(init: false);
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          color: myColors.tagColor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(
                '[新的入群申请]',
                style: TextStyle(
                  color: myColors.vipName,
                ),
              ),
            ),
            badges.Badge(
              showBadge: _roomData.roomUnreadCount > 0,
              badgeContent: Text(
                '${_roomData.roomUnreadCount}',
                style: TextStyle(
                  color: myColors.white,
                  fontSize: 12,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }

  // @我的组件
  Widget _remindWidget() {
    return ValueListenableBuilder(
      valueListenable: _showRemind,
      builder: (ctx, show, _) {
        if (!show) return Container();
        return Positioned(
          top: 50,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _getChatHistory(
                  type: ChatQueryType.search,
                  id: toInt(_params.remindId),
                );
              },
              child: rightRemindWidget(
                text: '有人@我',
                icon: Icons.keyboard_double_arrow_up,
              ),
            ),
          ),
        );
      },
    );
  }

  // 新消息组件
  Widget scrollNewMessageWidget() {
    if (_scrollMessageList.isEmpty) {
      return Container();
    }
    return Positioned(
      bottom: 15,
      right: 0,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _getChatHistory(
            type: ChatQueryType.search,
            id: _scrollMessageList.first.id,
          );
        },
        child: rightRemindWidget(
          text: '${_scrollMessageList.length}条新消息',
          icon: Icons.keyboard_double_arrow_down,
        ),
      ),
    );
  }

  // @我组件
  Widget rightRemindWidget({
    required String text,
    required IconData icon,
  }) {
    var myColors = ThemeNotifier();
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 7,
        horizontal: 15,
      ),
      decoration: BoxDecoration(
        color: myColors.tagColor,
        boxShadow: [
          BoxShadow(
            color: myColors.voiceBg,
            blurRadius: 5,
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          bottomLeft: Radius.circular(40),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: myColors.primary,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: myColors.primary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  //置顶公告组件
  Widget roomMarkWidget() {
    bool show = _roomData.roomNotice.isNotEmpty &&
        _params.roomId.isNotEmpty &&
        !_roomData.roomNoticeRead;
    // bool show = _roomNotice.isNotEmpty && roomId.isNotEmpty;
    if (!show) return Container();
    var myColors = ThemeNotifier();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Global.setUserNoticeDataRead(_params.roomId, _roomData.roomNotice);
        setState(() {
          _roomData.roomNoticeRead = true;
        });
        Navigator.pushNamed(
          context,
          GroupNotice.path,
          arguments: {'roomId': _params.roomId},
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(5, 5, 5, 0),
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          color: myColors.tagColor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            Text(
              '[群公告]'.tr(),
              style: TextStyle(
                color: myColors.vipName,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              flex: 1,
              child: Text(
                _roomData.roomNotice.replaceAll('\n', ''),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }

  //底部状态消息展示
  Widget tipWidget() {
    if (tipText.isEmpty) return Container();
    var myColors = ThemeNotifier();
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      alignment: Alignment.center,
      child: Text(
        tipText,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: myColors.textGrey,
          fontSize: 12,
        ),
      ),
    );
  }

  //拖动上传弹窗
  Widget dropWidget() {
    var myColors = ThemeNotifier();
    var size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: myColors.whiteOpacity2,
      ),
      child: Text(
        '松开发送文件'.tr(),
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: myColors.primary,
        ),
      ),
    );
  }

  //清空聊天记录提示
  removeHistoryConfirm() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return UndoDialog(
          // showUndo: false,
          tip: '双向清空需好友 "确定授权" 才会清空对方消息记录',
          onEnter: (undo) {
            ApiRequest.removeHistory(_params.pairId, undo: undo);
          },
        );
      },
    );
  }

  // 标题点击
  _titleTap() {
    if (_params.roomId.isNotEmpty) return;
    Navigator.pushNamed(
      context,
      FriendDetails.path,
      arguments: {
        'id': _params.receiver,
        'removeToTabs': true,
        'detail': _user,
        'isTitleJump': true,
      },
    ).then((value) {
      _getTalkInfo(init: false);
    });
  }

  // 收起键盘和表情
  _closeKeyEmoji() {
    if (_chatInputNotifier.showBottomBtn) {
      _chatInputNotifier.showBottomBtn = false;
    }
    if (_chatInputNotifier.showEmojiPicker) {
      _chatInputNotifier.showEmojiPicker = false;
    }
    _focusNode.unfocus();
  }

  //appbar actions组件
  List<Widget> _appbarActions(Color popupColors) {
    if (_roomData.roomOut) return [];
    return [
      //如果是群聊天
      if (!checkModal && !_roomData.roomDissolve && _params.roomId.isNotEmpty)
        Badge(
          offset: const Offset(-15, 5),
          isLabelVisible: _roomData.roomUnreadCount > 0,
          label: Text('${_roomData.roomUnreadCount}'),
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                ChatSetting.path,
                arguments: {
                  'roomId': _params.roomId,
                  'pairId': _params.pairId,
                },
              ).then((value) {
                _getTalkInfo(init: false);
              });
              // }
            },
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: const Icon(Icons.more_horiz),
            ),
          ),
        ),
      //如果是单用户聊天
      if (!checkModal && !_roomData.roomDissolve && _params.receiver.isNotEmpty)
        PopupMenuButton<int>(
          color: popupColors,
          onSelected: (i) {
            if (i == 0) {
              setState(() {
                _params.isTop = !_params.isTop;
              });
              MessageUtil.top(_params.pairId, _params.isTop);
            }
            if (i == 1) {
              setState(() {
                _params.doNotDisturb = !_params.doNotDisturb;
              });
              MessageUtil.silence(_params.pairId, _params.doNotDisturb);
            }
            if (i == 2) {
              removeHistoryConfirm();
            }
          },
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                value: 0,
                height: 40,
                padding: EdgeInsets.zero,
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    _params.isTop ? '取消置顶'.tr() : '置顶消息'.tr(),
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              PopupMenuItem(
                value: 1,
                height: 40,
                padding: EdgeInsets.zero,
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    _params.doNotDisturb ? '关闭免打扰'.tr() : '开启免打扰'.tr(),
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              if (_params.pairId.isNotEmpty && FunctionConfig.cleanTalkHistory)
                PopupMenuItem(
                  value: 2,
                  height: 40,
                  padding: EdgeInsets.zero,
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      '清空消息记录'.tr(),
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
            ];
          },
          position: PopupMenuPosition.under,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: const Icon(Icons.more_horiz),
          ),
        ),
    ];
  }

  //聊天消息列表组件
  Widget _talkBody() {
    var myColors = ThemeNotifier();
    final list = (_notifier?.messages ?? []);
    List<ItemOrDate> upList = [];
    List<ItemOrDate> downList = [];
    final id = toInt(_centerId);
    String activeDay = '';
    if (id > 0) {
      _centerKey = GlobalKey();
    } else {
      _centerKey = null;
    }
    for (var i = 0; i < list.length; i++) {
      var element = list[i];
      final day = time2date(
        element.message.createTime.toString(),
        format: 'yy/MM/dd',
      );
      final item = ItemOrDate(index: i);
      if (day != activeDay) {
        activeDay = day;
        item.date = activeDay;
      }
      if (id != 0 && element.message.id > id) {
        downList.add(item);
      } else {
        upList.add(item);
      }
    }
    upList = upList.reversed.toList();
    // logger.d('id:$id-----down:${downList.length}-----up:${upList.length}');
    Widget messageItem(List<ItemOrDate> msgList, int i) {
      var v = list[msgList[i].index];
      var message = v.message;
      // logger.d(msg.content);
      bool sender = (message.sender ?? 0).toString() == (Global.user?.id ?? '');
      var viewTime = msgList[i].date;
      _msgKeys[message.id] = GlobalKey();
      return Container(
        key: _msgKeys[message.id],
        child: TalkMessage(
          list[msgList[i].index],
          viewTime: viewTime,
          roomManage:
              _params.roomId.isNotEmpty ? _roomManageIds[_params.roomId] : null,
          // avatar: '',
          hasTop: _talkData.enableTop,
          roomAdmin: _roomData.roomManage,
          hasBan: _roomData.roomManage && _params.roomId.isNotEmpty && !sender,
          hasEdit: _talkData.enableEdit,
          // hasUndo: enableRevoke,
          checkModal: checkModal,
          // checkType: checkType,
          // checkDisabled: checkType == MessagePopType.collect &&
          //     v.value.type == MessageType.notes,
          showName: _params.roomId.isNotEmpty,
          checked: chooseIds.contains(message.id),
          onFailed: _sendFailedTap,
          onCheck: (msg) {
            var id = msg.id;
            var i = chooseIds.indexOf(id);
            setState(() {
              if (i >= 0) {
                chooseMessage.removeAt(i);
                chooseIds.removeAt(i);
              } else {
                chooseMessage.add(msg);
                chooseIds.add(id);
              }
            });
          },
          onPopTap: (type, msg) => messagePopTap(type, msg),
          onTap: (msg) => messageTap(msg),
          onImageTap: messageImageTap,
          onDoubleTap: (msg) => messageDoubleTap(msg),
          onQuoteTap: (msg) => quoteMessageTap(msg, msg.quoteMessageId ?? 0),
          onAvatarTap: () => seeDetail(message),
          onAvatarLongTap: avatarLongTap,
        ),
      );
    }

    return Expanded(
      key: _stackKey,
      flex: 1,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _closeKeyEmoji,
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Stack(
                children: [
                  // 消息列表组件
                  CustomScrollView(
                    controller: _scrollController,
                    reverse: true,
                    center: _centerKey,
                    slivers: [
                      const SliverPadding(padding: EdgeInsets.only(top: 15)),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => tipWidget(),
                          childCount: 1,
                        ),
                      ),
                      if (downList.isNotEmpty)
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) => messageItem(downList, i),
                            childCount: downList.length,
                          ),
                        ),
                      if (_centerKey != null)
                        SliverPadding(
                          padding: EdgeInsets.zero,
                          key: _centerKey,
                        ),
                      if (upList.isNotEmpty)
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) => messageItem(upList, i),
                            childCount: upList.length,
                          ),
                        ),
                    ],
                  ),
                  Column(
                    children: [
                      //置顶公告组件
                      roomMarkWidget(),
                      //申请审核组件
                      roomApplyWidget(),
                    ],
                  ),
                  //滚动新消息
                  scrollNewMessageWidget(),
                  //@组件显示
                  _remindWidget(),
                ],
              ),
            ),

            //自毁显示组件
            if ((_talkData.destroyTime > 0 && voiceWidth <= 0) ||
                _roomData.roomOut)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: _roomData.roomOut ? 20 : 10,
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
                    child: Text(
                      _roomData.roomOut
                          ? '您已不在当前群聊'
                          : '当前对话消息自毁时间：${DestroyTimeExt.fromSecond(_talkData.destroyTime)?.toChar ?? '${_talkData.destroyTime} 秒'}',
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // 底部多选操作组件
  Widget _selectAllTools() {
    var myColors = ThemeNotifier();
    bool noForward = false;
    bool noCollect = false;
    for (var v in chooseMessage) {
      if (v.type == GMessageType.RED_PACKET ||
          v.type == GMessageType.RED_INTEGRAL) {
        noCollect = true;
        break;
      }
    }
    for (var v in chooseMessage) {
      if (v.type == GMessageType.FORWARD_CIRCLE ||
          v.type == GMessageType.AUDIO ||
          v.type == GMessageType.RED_PACKET ||
          v.type == GMessageType.RED_INTEGRAL) {
        noForward = true;
        break;
      }
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(
            onPressed: () {
              if (chooseIds.isEmpty) return;
              messageCollect(chooseIds);
            },
            child: Row(
              children: [
                Icon(
                  Icons.favorite,
                  size: 18,
                  color: noCollect ? ThemeNotifier().grey : null,
                ),
                Text(
                  '收藏',
                  style: TextStyle(
                    color: noCollect ? ThemeNotifier().grey : null,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              if (chooseIds.isEmpty) return;
              forwardSendMenu();
            },
            child: Row(
              children: [
                Icon(
                  Icons.forward,
                  size: 20,
                  color: noForward ? ThemeNotifier().grey : null,
                ),
                Text(
                  '转发',
                  style: TextStyle(
                    color: noForward ? ThemeNotifier().grey : null,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              if (chooseIds.isEmpty) return;
              messageRemoveConfirm(chooseMessage);
            },
            child: Row(
              children: [
                Icon(
                  Icons.delete_forever_outlined,
                  size: 18,
                  color: myColors.red,
                ),
                Text(
                  '删除',
                  style: TextStyle(
                    color: myColors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 警告组件
  Widget _warningWidget() {
    var myColors = ThemeNotifier();
    return Positioned(
      top: 10,
      right: 20,
      child: GestureDetector(
        onTap: () async {
          await ApiRequest.agreeCleanMyMessage(_params.pairId);
          _getTalkInfo(init: false);
        },
        child: Container(
          width: 45,
          height: 45,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: myColors.imRed,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: myColors.voiceBg,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.priority_high,
            color: myColors.white,
          ),
        ),
      ),
    );
  }

  // 显示授权清空聊天记录
  _showCleanMessage() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (!mounted) return;
      await ApiRequest.agreeCleanMyMessage(_params.pairId);
      _getTalkInfo(init: false);
    });
  }

  @override
  void didUpdateWidget(covariant ChatTalk oldWidget) {
    super.didUpdateWidget(oldWidget);
    logger.d('chat-talk----didUpdateWidget');
    if (widget.data != null && oldWidget.data != widget.data) {
      var data = widget.data;
      if (data!.room) {
        _params.receiver = '';
        _params.roomId = data.id!;
      } else {
        _params.receiver = data.id!;
        _params.roomId = '';
      }
      _initData();
      setState(() {
        _params.name = data.title;
      });
    }
  }

  bool _firstIn = false;

  // 页面初始化
  _pageInit({bool build = false, bool init = false}) {
    if (!mounted) return;
    if (build && _firstIn) return;
    if (build) _firstIn = true;
    dynamic args = ModalRoute.of(context)!.settings.arguments;
    if (args == null || args is! ChatTalkParams) return;
    _params = args;
    if (_params.pairId.isEmpty) {
      if (_params.roomId.isNotEmpty) {
        _params.pairId = generatePairId(0, toInt(_params.roomId));
      } else if (_params.receiver.isNotEmpty) {
        _params.pairId =
            generatePairId(toInt(Global.user!.id), toInt(_params.receiver));
      }
    }
    if (init) {
      MessageUtil.resetUnreadCount([_params.pairId]);
      _notifier = ChannelPageNotifier.getInstance(_params.pairId)
        ..addListener(() {
          if (mounted) setState(() {});
        });
    }
    if (build) {
      if ((chatEditText[_params.pairId] ?? '').isNotEmpty) {
        _textEditingController.text = chatEditText[_params.pairId] ?? '';
        _chatInputNotifier.showSendBtn = true;
      }
    } else {
      _initData();
    }
  }

  @override
  void initState() {
    if (!platformPhone) RawKeyboard.instance.addListener(_keyboardListener);
    super.initState();
    _scrollController.addListener(() {
      double scroll = _scrollController.position.pixels;
      double maxScroll = _scrollController.position.maxScrollExtent;
      double minScroll = _scrollController.position.minScrollExtent;
      // 判断接收新消息时不往上滚动
      if (scroll > minScroll + 200 && _centerId == null && _notifier != null) {
        _centerId = _notifier?.messages.last.message.id;
      }
      if (scroll <= minScroll) {
        _getChatHistory(type: ChatQueryType.down, oldScrollMax: maxScroll);
      } else if (scroll >= maxScroll) {
        _getChatHistory(type: ChatQueryType.up);
      }
      if (toInt(_params.remindId) > 0 && _showRemind.value) {
        var goKey = _msgKeys[toInt(_params.remindId)];
        if (goKey == null) return;
        if (goKey.currentContext == null) return;
        RenderBox? box = goKey.currentContext!.findRenderObject() as RenderBox;
        var boxOffset = box.localToGlobal(Offset.zero);
        if (boxOffset.dy > 0) {
          _params.remindId = '';
          _showRemind.value = false;
        }
      }
    });
    audioSub = player.onPlayerStateChanged.listen(audioListen);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _pageInit(init: true);
    });
  }

  @override
  void dispose() {
    _dispose = true;
    var msgText = _textEditingController.text;
    if (msgText.isNotEmpty) {
      chatEditText[_params.pairId] = msgText;
    } else if (chatEditText[_params.pairId] != null) {
      chatEditText.remove(_params.pairId);
    }
    audioSub.cancel();
    messageSub?.cancel();
    _prohibitionTimer?.cancel();
    RawKeyboard.instance.removeListener(_keyboardListener);
    _notifier?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (initTime > 0) {
      // logger.d('------->${DateTime.now().millisecondsSinceEpoch - initTime}');
    } else {
      initTime = DateTime.now().millisecondsSinceEpoch;
    }
    _pageInit(build: true);
    var myColors = context.watch<ThemeNotifier>();
    Color textColor = myColors.iconThemeColor;
    var popupColors = context.watch<ThemeNotifier>().popupThemeColor;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChatInputNotifier>(
          create: (_) => _chatInputNotifier,
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          leading: checkModal
              ? TextButton(
                  onPressed: () {
                    setState(() {
                      checkModal = false;
                      chooseIds = [];
                      chooseMessage = [];
                    });
                  },
                  child: Text(
                    '取消'.tr(),
                    style: TextStyle(color: myColors.red),
                  ),
                )
              : GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: ValueListenableBuilder(
                      valueListenable: ChannelListNotifier().unreadCount,
                      builder: (context, value, _) {
                        var num = value - _scrollMessageList.length;
                        return Badge(
                          isLabelVisible: num > 0,
                          label: Text(
                            num.toString(),
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            color: textColor,
                          ),
                        );
                      },
                    ),
                  ),
                ),
          title: ChatTalkTitle(
            params: _params,
            userData: _userData,
            checkModal: checkModal,
            onTap: _titleTap,
          ),
          // title: Text(checkModal ? '选择消息' : name),
          actions: _appbarActions(popupColors),
        ),
        body: ThemeBody(
          topPadding: 0,
          child: DropTarget(
            onDragExited: (DropEventDetails details) {
              if (!_showDropWidget) return;
              setState(() {
                _showDropWidget = false;
              });
            },
            onDragEntered: (DropEventDetails details) {
              if (_showDropWidget) return;
              setState(() {
                _showDropWidget = true;
              });
            },
            onDragDone: (DropDoneDetails detail) {
              setState(() {
                _showDropWidget = false;
              });
              _dropSendMessageListen(detail.files);
            },
            child: Stack(
              alignment: Alignment.topLeft,
              children: [
                Flex(
                  direction: Axis.vertical,
                  children: [
                    // 置顶消息顶部填充组件
                    ValueListenableBuilder(
                      valueListenable: _topNotifier,
                      builder: (context, value, _) {
                        if (value.isNotEmpty) {
                          return const SizedBox(width: 1, height: 54);
                        }
                        return Container();
                      },
                    ),
                    // Consumer<TopMessageNotifier>(
                    //   builder: (context, value, _) {
                    //     if (value.list.isNotEmpty) {
                    //       return const SizedBox(width: 1, height: 54);
                    //     }
                    //     return Container();
                    //   },
                    // ),
                    //聊天消息列表组件
                    _talkBody(),
                    // 多选操作栏
                    if (checkModal) _selectAllTools(),
                    //底部输入框
                    if (!checkModal && !_roomData.roomOut)
                      ChatInput(
                        singleNoSpeak: !_talkData.enableSend,
                        allNoSpeak: _roomData.allNoSpeak,
                        textEditingController: _textEditingController,
                        focusNode: _focusNode,
                        identity: _roomData.identity,
                        onSend: sendMessage,
                        voicePress: voicePress,
                        roomId: _params.roomId,
                        receiveId: _params.receiver,
                        roomPower: _roomData.roomPower,
                        listenRecord: (double edc) {
                          setState(() {
                            decibels = edc / 160 * 65;
                          });
                        },
                      ),
                  ],
                ),
                //置顶消息组件
                ValueListenableBuilder(
                  valueListenable: _topNotifier,
                  builder: (context, value, _) {
                    return TopMessageWidget(
                      list: value,
                      manage: _roomData.roomManage,
                      onRemove: (data) {
                        messageTop(data, false);
                      },
                      onItemTap: topMessageTap,
                    );
                  },
                ),
                //语音输入组件
                if (voiceWidth > 0)
                  Container(
                    width: voiceWidth,
                    height: voiceHeight + 0.5,
                    color: myColors.voiceBg,
                    alignment: Alignment.bottomCenter,
                    // padding: const EdgeInsets.only(bottom: 0),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Image.asset(
                                    assetPath('images/sp_yuyingbeijing.png'),
                                    width: 150,
                                  ),
                                ),
                                Image.asset(
                                  assetPath('images/yuyin.gif'),
                                  width: 90,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Image.asset(
                          assetPath('images/sp_yuyinguanbi.png'),
                          width: 70,
                          height: 70,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          voicePressType == VoicePressType.out
                              ? '松开取消发送'.tr()
                              : '向上滑动取消'.tr(),
                          style: TextStyle(
                            color: myColors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                //拖动上传弹窗
                if (_showDropWidget) dropWidget(),
                if (_talkData.showWarning) _warningWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

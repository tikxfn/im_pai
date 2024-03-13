import 'package:unionchat/common/func.dart';
import 'package:unionchat/db/model/message.dart';
import 'package:unionchat/db/model/show_user.dart';
import 'package:isar/isar.dart';
import 'package:openapi/api.dart';
part 'channel.g.dart';

@collection
class Channel {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  int? upId;
  // 连接id 连接发送者和接受者
  @Index(unique: true, replace: true)
  String? pairId;
  // 关联用户id
  int? relateUserId;
  // 关联群id
  int? relateRoomId;
  // 最后一条消息id
  @Index()
  int lastMessageId = 0;
  // 第一条消息id
  int firstMessageId = 0;
  // 最后一条消息内容
  MessageItem? lastMessage;
  // 免打扰
  @Index()
  bool doNotDisturb = false;
  // 置顶时间, 0为未置顶
  @Index(composite: [CompositeIndex('lastMessageId')])
  int topTime = 0;
  // 删除时间
  @Index()
  int? deleteTime;
  // 读取的最后消息id
  @Index()
  int lastReadId = 0;
  // 对方读取的最后消息id
  int? otherReadId;
  // 消息自毁时间
  int messageDestroyDuration = 0;
  // 消息自毁时间
  int otherChatDestroyDuration = 0;
  // 清理的最大消息id
  int? cleanMessageId;
  // 分组,逗号分割
  @Index()
  List<String>? groups;
  // 群聊群名称｜单聊用户名称
  String? name;
  // 备注
  String? mark;
  // 群聊群头像｜单聊用户头像
  String? avatar;
  // at我的消息id
  List<int> atMessageIds = [];
  // 清除消息状态
  int get applyCleanStatusInt => GApplyCleanStatus.values.indexOf(
        applyCleanStatus ?? GApplyCleanStatus.NIL,
      );
  set applyCleanStatusInt(int index) {
    applyCleanStatus = GApplyCleanStatus.values[index];
  }

  @ignore
  GApplyCleanStatus? applyCleanStatus;

  // 发送消息者的信息(只有群聊才有，单聊这个信息在channel中)
  ShowUser? senderUser;

  // 未读消息数量
  @Index()
  int unreadCount = 0;

  // 断点ID（处理断线逻辑）
  List<int> breakpoints = [];

  // 是否正在加载历史消息
  @Index()
  bool isLoadingHistory = false;

  Channel.fromModel(GChannelModel m) {
    load(m);
  }

  load(GChannelModel m) {
    upId = toInt(m.upId);
    pairId = m.pairId;
    relateUserId = toInt(m.relateUserId);
    relateRoomId = toInt(m.relateRoomId);
    // lastMessageId = toInt(m.lastMessageId);
    firstMessageId = toInt(m.firstMessageId);
    doNotDisturb = m.doNotDisturb ?? false;
    topTime = toInt(m.topTime);
    messageDestroyDuration = toInt(m.messageDestroyDuration);
    otherChatDestroyDuration = toInt(m.otherChatDestroyDuration);
    cleanMessageId = toInt(m.cleanMessageId);
    groups = m.groups;
    applyCleanStatus = m.applyClean;
    name = m.name;
    avatar = m.avatar;
    applyCleanStatus = m.applyClean;
    mark = m.mark;
    final mLastReadId = toInt(m.lastReadId);
    final mOtherReadId = toInt(m.otherReadId);
    if (lastReadId < mLastReadId) {
      lastReadId = mLastReadId;
    }
    if (otherReadId == null || otherReadId! < mOtherReadId) {
      otherReadId = mOtherReadId;
    }
    if (m.senderUser != null) {
      senderUser = ShowUser.fromModel(m.senderUser!);
    }
  }

  Channel();

  @override
  String toString() {
    return 'Channel{upId: $upId, pairId: $pairId, relateUserId: $relateUserId, relateRoomId: $relateRoomId, lastMessageId: $lastMessageId, firstMessageId: $firstMessageId, lastMessage: $lastMessage, doNotDisturb: $doNotDisturb, topTime: $topTime, deleteTime: $deleteTime, lastReadId: $lastReadId, otherReadId: $otherReadId, messageDestroyDuration: $messageDestroyDuration, cleanMessageId: $cleanMessageId, groups: $groups, name: $name, mark: $mark, avatar: $avatar, applyCleanStatus: $applyCleanStatus, senderUser: $senderUser, unreadCount: $unreadCount, breakpoints: $breakpoints, isLoadingHistory: $isLoadingHistory}';
  }
}

import 'package:openapi/api.dart';

// 页面进入参数
class ChatTalkParams {
  bool vip; // 是否是vip
  GVipLevel vipLevel; // vip等级
  GBadge vipBadge; // vip标志
  bool onlyName; // 唯名卡
  String name; // 接收者昵称
  String mark; // 接收者备注
  String totalCount; // 群成员总数
  String receiver; // 接收者id
  String avatar; // 接收者头像
  String roomId; // 群聊id
  String pairId; // 对话id
  String queryId; // 需要查询的消息id
  String remindId; // @我的消息id
  String userNumber; // 靓号
  bool circleGuarantee; // 是否输入保圈
  GUserNumberType? numberType; // 靓号类型
  int readId; // 消息已读最大id
  bool isTop; //消息是否置顶
  bool doNotDisturb; //消息是否免打扰
  ChatTalkParams({
    this.pairId = '',
    this.vip = false,
    this.vipLevel = GVipLevel.NIL,
    this.vipBadge = GBadge.NIL,
    this.onlyName = false,
    this.mark = '',
    this.name = '',
    this.totalCount = '',
    this.receiver = '',
    this.avatar = '',
    this.roomId = '',
    this.queryId = '',
    this.remindId = '',
    this.userNumber = '',
    this.circleGuarantee = false,
    this.numberType,
    this.readId = 0,
    this.isTop = false,
    this.doNotDisturb = false,
  });
}

// 群聊参数
class ChatTalkRoomData {
  bool roomDissolve; // 群聊是否解散
  bool roomDisabled; // 群聊是否封禁
  bool enableVisit; // 是否可以查看群成员
  GRoomMemberIdentity identity = GRoomMemberIdentity.NIL; // 我在群聊的身份
  bool roomManage; // 群主或管理员
  int prohibitionTime; // 禁言时间
  bool allNoSpeak; // 全体禁言
  int roomPower; // 当前群聊可发送消息类型，-1全部权限
  bool roomOut; // 是否已经不在群内
  String roomNotice; // 群公告
  bool roomNoticeRead; // 是否阅读群公告
  int roomUnreadCount; // 群聊未读数量
  ChatTalkRoomData({
    this.roomDissolve = false,
    this.roomDisabled = false,
    this.enableVisit = false,
    this.identity = GRoomMemberIdentity.NIL,
    this.roomManage = false,
    this.prohibitionTime = 0,
    this.allNoSpeak = false,
    this.roomPower = -1,
    this.roomOut = false,
    this.roomNotice = '',
    this.roomNoticeRead = true,
    this.roomUnreadCount = 0,
  });
}

// 个人参数
class ChatTalkUserData {
  String onlineTime; //最后在线时间
  bool online; //当前是否在线
  String avatar; //接收者头像
  String userIP; //用户ip和地址
  String userId; //用户id
  String userAccount; //用户账号
  ChatTalkUserData({
    this.onlineTime = '',
    this.online = false,
    this.avatar = '',
    this.userIP = '',
    this.userId = '',
    this.userAccount = '',
  });
}

// 聊天参数
class ChatTalkData {
  bool enableRevoke; //是否可以撤回消息
  bool enableEdit; //是否可以编辑消息
  bool enableTop; //是否可以置顶消息
  bool enableSend; //是否可以发送消息
  bool undo; //是否双向删除（撤回）
  int destroyTime; //消息自毁时间
  bool showWarning; //是否显示警告按钮
  ChatTalkData({
    this.enableRevoke = false,
    this.enableEdit = false,
    this.enableTop = false,
    this.enableSend = true,
    this.undo = false,
    this.destroyTime = 0,
    this.showWarning = false,
  });
}
import 'dart:math';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/db/enum.dart';
import 'package:unionchat/db/model/show_user.dart';
import 'package:isar/isar.dart';
import 'package:openapi/api.dart';
import 'package:unionchat/global.dart';
part 'message.g.dart';

@collection
class Message {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  int msgId = 0;

  // 消息本地发送队列状态
  @Index()
  int get taskStatusInt => taskStatus.toInt();
  set taskStatusInt(int index) {
    taskStatus = TaskStatus.values[index];
  }

  @ignore
  TaskStatus taskStatus = TaskStatus.nil;
  // 发送失败原因
  String? reason;

  @Index(unique: true, replace: true)
  int? upId;
  // 连接id 连接发送者和接受者
  @Index(composite: [
    CompositeIndex('msgId'),
  ])
  String? pairId;
  // 发送者
  int? sender;
  // 接收者
  int? receiverUserId;
  // 群聊房间id
  int? receiverRoomId;
  // 消息状态
  @Index()
  int get statusInt => GMessageStatus.values.indexOf(
        status ?? GMessageStatus.NIL,
      );
  set statusInt(int index) {
    if (index < 0 || index >= GMessageStatus.values.length) {
      index = 0;
    }
    status = GMessageStatus.values[index];
  }

  @ignore
  GMessageStatus? status;
  // 消息类型
  @Index()
  int get typeInt => GMessageType.values.indexOf(
        type ?? GMessageType.NIL,
      );
  set typeInt(int index) {
    if (index < 0 || index >= GMessageType.values.length) {
      index = 0;
    }
    type = GMessageType.values[index];
  }

  @ignore
  GMessageType? type;
  List<int> at = [];
  // 标题
  String? title;
  // 内容
  String? content;
  // 文件地址
  String? fileUrl;
  // 图片地址, 如果是视频消息, 则为视频封面地址
  String? imageUrl;
  // 位置信息
  String? location;
  // 发送者的设备
  String? senderDno;
  // 笔记/圈子/名片ID
  int? contentId;

  MessageHistory? messageHistory;

  // 通话状态
  @Index()
  int get callStatusInt => GCallStatus.values.indexOf(
        callStatus ?? GCallStatus.NIL,
      );
  set callStatusInt(int index) {
    if (index < 0 || index >= GCallStatus.values.length) {
      index = 0;
    }
    callStatus = GCallStatus.values[index];
  }

  @ignore
  GCallStatus? callStatus;
  // 通话开始时间
  int? callStartTime;
  // 通话时长(语音，视频等)
  int? duration;
  // 创建时间
  int createTime = 0;
  // 置顶时间
  int topTime = 0;
  // 消息引用id
  int quoteMessageId = 0;
  // 引用消息内容
  @ignore
  MessageItem? quoteMessage;
  // 消息自毁时间
  int messageDestroyTime = 0;
  bool? isListened;
  // 发送消息者的信息(只有群聊才有，单聊这个信息在channel中)
  ShowUser? senderUser;

  // 消息是否已读
  bool readed = false;

  @Index()
  String get contentWords {
    return content ?? '';
  }

  Message();

  // 创建一个将要发送的消息
  Message.forSend(
    int this.sender,
    String this.pairId,
    GMessageType this.type,
  ) {
    if (sender == 0) {
      throw Exception('sender is empty');
    }
    if (pairId!.isEmpty) {
      throw Exception('pairId is empty');
    }
    final arr = extractIntegersFromPairId(pairId!);
    final a = arr[0];
    final b = arr[1];
    if (a == 0) {
      receiverRoomId = b;
    } else if (b == 0) {
      receiverRoomId = a;
    } else if (sender == a) {
      receiverUserId = b;
    } else if (sender == b) {
      receiverUserId = a;
    } else {
      throw Exception('sender is not in pairId');
    }
    // 随机生成一个upid
    var random = Random();
    upId = random.nextInt(2 << 31);
    taskStatus = TaskStatus.sending;
  }

  GMessageModel toModel() {
    final m = GMessageModel();
    m.id = toStr(id);
    m.pairId = pairId;
    m.type = type;
    m.at = at.map((e) => toStr(e)).toList();
    m.title = title;
    m.content = content;
    m.fileUrl = fileUrl;
    m.imageUrl = imageUrl;
    m.location = location;
    m.contentId = contentId?.toString();
    m.messageHistory = messageHistory?.toModel();
    m.duration = duration?.toString();
    m.quoteMessageId = quoteMessageId.toString();
    return m;
  }

  Message.fromModel(GMessageModel msg) {
    load(msg);
  }

  void load(GMessageModel msg) {
    id = toInt(msg.id);
    msgId = id;
    taskStatus = TaskStatus.success;
    upId = toInt(msg.upId);
    pairId = msg.pairId;
    sender = toInt(msg.sender);
    receiverUserId = toInt(msg.receiverUserId);
    receiverRoomId = toInt(msg.receiverRoomId);
    status = msg.status;
    type = msg.type;
    at = msg.at.map((e) => toInt(e)).toList();
    title = msg.title;
    content = msg.content;
    fileUrl = msg.fileUrl;
    imageUrl = msg.imageUrl;
    location = msg.location;
    senderDno = msg.senderDno;
    contentId = toInt(msg.contentId);
    messageHistory = MessageHistory.fromModel(msg.messageHistory);
    callStatus = msg.callStatus;
    callStartTime = toInt(msg.callStartTime);
    duration = toInt(msg.duration);
    createTime = toInt(msg.createTime);
    topTime = toInt(msg.topTime);
    quoteMessageId = toInt(msg.quoteMessageId);
    // quoteMessage = MessageItem.fromMessage(msg.quoteMessage);
    messageDestroyTime = toInt(msg.messageDestroyTime);
    senderUser = ShowUser.fromModel(msg.senderUser);
    if (senderUser == null && sender == Global.loginUser?.id) {
      senderUser = getSenderUser();
    }
    isListened = msg.isListened;
  }

  Message.fromFavoritesModel(GFavoritesMessageModel msg) {
    id = toInt(msg.id);
    msgId = id;
    taskStatus = TaskStatus.success;
    upId = toInt(msg.upId);
    pairId = msg.pairId;
    sender = toInt(msg.sender);
    receiverUserId = toInt(msg.receiverUserId);
    receiverRoomId = toInt(msg.receiverRoomId);
    status = msg.status;
    type = msg.type;
    title = msg.title;
    content = msg.content;
    fileUrl = msg.fileUrl;
    imageUrl = msg.imageUrl;
    location = msg.location;
    contentId = toInt(msg.contentId);
    messageHistory = MessageHistory.fromModel(msg.messageHistory);
    duration = toInt(msg.duration);
    createTime = toInt(msg.createTime);
    // TODO
    // data.quoteMessage = MessageItem.fromMessage(msg.quoteMessage);
    // senderUser = ShowUser.fromModel(msg.);
  }

  @override
  String toString() {
    return '''
'Message {
  id $id, 
  upId: $upId, 
  taskStatus $taskStatus,
  pairId: $pairId, 
  sender: $sender, 
  receiverUserId: $receiverUserId, 
  receiverRoomId: $receiverRoomId, 
  status: $status, 
  type: $type, 
  title: $title, 
  content: $content, 
  fileUrl: $fileUrl, 
  imageUrl: $imageUrl, 
  location: $location, 
  contentId: $contentId, 
  messageHistory: $messageHistory, 
  duration: $duration, 
  createTime: $createTime,
  callStatus: $callStatus,
}'
''';
  }
}

@embedded
class MessageHistory {
  String? nameA;
  String? nameB;
  bool? isRoom;
  List<int> messageIds = [];
  List<MessageItem> items = [];

  @ignore
  List<String> get contentWords {
    final List<String> list = [];
    if (nameA != null && nameA!.isNotEmpty) {
      list.addAll(nameA!.split(' '));
    }
    if (nameB != null && nameB!.isNotEmpty) {
      list.addAll(nameB!.split(' '));
    }
    for (var element in items) {
      list.add(element.contentWords);
    }
    return list;
  }

  MessageHistory();

  GMessageHistory toModel() {
    final m = GMessageHistory();
    m.nameA = nameA;
    m.nameB = nameB;
    m.isRoom = isRoom;
    m.messageIds = messageIds.map((e) => toStr(e)).toList();
    m.items = [];
    for (var element in items) {
      m.items.add(element.toModel());
    }
    return m;
  }

  MessageHistory.fromModel(GMessageHistory? data) {
    if (data == null) return;
    nameA = data.nameA;
    nameB = data.nameB;
    isRoom = data.isRoom;
    messageIds = data.messageIds.map((e) => toInt(e)).toList();
    items = [];
    for (var element in data.items) {
      items.add(MessageItem.fromModel(element));
    }
  }
}

@embedded
class MessageItem {
  // 昵称
  String? nickname;
  String? mark;
  String? roomNickname;
  // 头像
  String? avatar;
  int get taskStatusInt => taskStatus.toInt();
  set taskStatusInt(int index) {
    taskStatus = TaskStatus.values[index];
  }

  @ignore
  TaskStatus taskStatus = TaskStatus.nil;
  // 发送失败原因
  String? reason;
  int? sender;
  // 接收者
  int? receiverUserId;
  // 群聊房间id
  int? receiverRoomId;
  // 消息类型
  int get typeInt => GMessageType.values.indexOf(
        type ?? GMessageType.NIL,
      );
  set typeInt(int index) {
    if (index < 0 || index >= GMessageType.values.length) {
      index = 0;
    }
    type = GMessageType.values[index];
  }

  @ignore
  GMessageType? type;
  // 标题
  String? title;
  // 内容
  String? content;
  // 文件地址
  String? fileUrl;
  // 图片地址, 如果是视频消息, 则为视频封面地址
  String? imageUrl;
  // 位置信息
  String? location;
  // 笔记/圈子/名片ID
  int? contentId;

  MessageHistory? messageHistory;

  // 通话状态
  int get callStatusInt => GCallStatus.values.indexOf(
        callStatus ?? GCallStatus.NIL,
      );
  set callStatusInt(int index) {
    if (index < 0 || index >= GCallStatus.values.length) {
      index = 0;
    }
    callStatus = GCallStatus.values[index];
  }

  @ignore
  GCallStatus? callStatus;
  //
  int? callStartTime;
  // 通话时长(语音，视频等)
  int? duration;
  // 创建时间
  int? createTime;
  // 消息引用id
  int? quoteMessageId;

  @ignore
  String get contentWords {
    final List<String> list = [];
    if (title != null) {
      list.addAll(title!.split(' '));
    }
    if (content != null) {
      list.addAll(content!.split(' '));
    }
    if (messageHistory != null) {
      list.addAll(messageHistory!.contentWords);
    }
    return list.join(' ');
  }

  MessageItem();

  MessageItem.fromMessage(Message msg) {
    nickname = msg.senderUser?.nickname; // 我对好友的备注
    mark = msg.senderUser?.mark; // 我对好友的备注
    roomNickname = msg.senderUser?.roomNickname; // 用户在群里面取的昵称
    avatar = msg.senderUser?.avatar;
    taskStatus = msg.taskStatus;
    reason = msg.reason;
    sender = msg.sender;
    receiverUserId = msg.receiverUserId;
    receiverRoomId = msg.receiverRoomId;
    type = msg.type;
    title = msg.title;
    content = msg.content;
    fileUrl = msg.fileUrl;
    imageUrl = msg.imageUrl;
    location = msg.location;
    contentId = msg.contentId;
    messageHistory = msg.messageHistory;
    callStatus = msg.callStatus;
    callStartTime = msg.callStartTime;
    duration = msg.duration;
    createTime = msg.createTime;
    quoteMessageId = msg.quoteMessageId;
  }

  MessageItem.fromModel(GMessageItem msg) {
    nickname = msg.nickname;
    avatar = msg.avatar;
    taskStatus = TaskStatus.success;
    sender = toInt(msg.sender);
    receiverUserId = toInt(msg.receiverUserId);
    receiverRoomId = toInt(msg.receiverRoomId);
    type = msg.type;
    title = msg.title;
    content = msg.content;
    fileUrl = msg.fileUrl;
    imageUrl = msg.imageUrl;
    location = msg.location;
    contentId = toInt(msg.contentId);
    messageHistory = MessageHistory.fromModel(msg.messageHistory);
    callStatus = msg.callStatus;
    callStartTime = toInt(callStartTime);
    duration = toInt(msg.duration);
    createTime = toInt(msg.createTime);
    quoteMessageId = toInt(msg.quoteMessageId);
  }

  GMessageItem toModel() {
    final m = GMessageItem();
    m.nickname = nickname;
    m.avatar = avatar;
    m.sender = '${toInt(sender)}';
    m.receiverUserId = '${toInt(receiverUserId)}';
    m.receiverRoomId = '${toInt(receiverRoomId)}';
    m.type = type;
    m.title = title;
    m.content = content;
    m.fileUrl = fileUrl;
    m.imageUrl = imageUrl;
    m.location = location;
    m.contentId = '${toInt(contentId)}';
    m.messageHistory = messageHistory?.toModel();
    m.callStatus = callStatus;
    m.callStartTime = '${toInt(callStartTime)}';
    m.duration = '${toInt(duration)}';
    m.createTime = '${toInt(createTime)}';
    m.quoteMessageId = '${toInt(quoteMessageId)}';
    return m;
  }

  @override
  String toString() {
    return 'MessageItem{nickname: $nickname, avatar: $avatar, taskStatus: $taskStatus, reason: $reason, sender: $sender, receiverUserId: $receiverUserId, receiverRoomId: $receiverRoomId, type: $type, title: $title, content: $content, fileUrl: $fileUrl, imageUrl: $imageUrl, location: $location, contentId: $contentId, messageHistory: $messageHistory, callStatus: $callStatus, callStartTime: $callStartTime, duration: $duration, createTime: $createTime, quoteMessageId: $quoteMessageId}';
  }
}

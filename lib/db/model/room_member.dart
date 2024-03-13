import 'package:unionchat/db/model/show_user.dart';
import 'package:isar/isar.dart';

part 'room_member.g.dart';

@collection
class RoomMember {
  Id id = Isar.autoIncrement;
  @Index(
    unique: true,
    composite: [
      CompositeIndex('userId'),
    ],
  )
  String? pairId;
  int? userId;
  @Index()
  int msgId = 0;
  // 发送消息者的信息(只有群聊才有，单聊这个信息在channel中)
  ShowUser? senderUser;

  RoomMember();
}

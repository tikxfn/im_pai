import 'package:openapi/api.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/db/db.dart';
import 'package:unionchat/db/model/user_info.dart';
import 'package:unionchat/db/operator/user_info_operator.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/notifier/friend_list_notifier.dart';

class UserInfoUtils {
  static int get userId {
    final id = toInt(Global.user?.id);
    if (id == 0) {
      throw Exception('userId is empty');
    }
    return id;
  }

  // 同步联系人列表数据
  static Future<void> syncFriends({bool network = true}) async {
    final isar = await DB.getIsar(userId);
    final friends = await UserInfoOperator.search(isar);
    FriendListNotifier().list = friends;
    if (network) {
      _networkSyncFriends();
    }
  }

  // 网络同步联系人列表
  static Future<void> _networkSyncFriends() async {
    final api = UserApi(apiClient());
    try {
      final res = await api.userListFriend(V1ListFriendArgs(
        pager: GPagination(
          limit: '1000000',
          offset: '0',
        ),
      ));
      List<UserInfo> list =
          (res?.list ?? []).map((e) => UserInfo.fromModel(e)).toList();
      final isar = await DB.getIsar(userId);
      await isar.writeTxn(() async {
        await UserInfoOperator.replaceAll(isar, list);
      });
    } catch (e) {
      logger.e(e);
      rethrow;
    }
    syncFriends(network: false);
  }

  // 添加联系人
  static Future<void> addFriend(UserInfo userInfo) async {
    final isar = await DB.getIsar(userId);
    await isar.writeTxn(() async {
      await UserInfoOperator.add(isar, userInfo);
    });
  }

  // 删除联系人
  static Future<void> deleteFriend(int id) async {
    final isar = await DB.getIsar(userId);
    await isar.writeTxn(() async {
      await UserInfoOperator.delete(isar, id);
    });
  }
}

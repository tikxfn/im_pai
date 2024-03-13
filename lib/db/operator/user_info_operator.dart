import 'package:unionchat/db/model/user_info.dart';
import 'package:isar/isar.dart';

class UserInfoOperator {
  UserInfoOperator._();

  // 同步所有数据
  static Future<void> replaceAll(Isar isar, List<UserInfo> list) async {
    await isar.userInfos.clear();
    await isar.userInfos.putAll(list);
  }

  // 搜索列表
  static Future<List<UserInfo>> search(Isar isar, {String? keywords}) async {
    var list = await isar.userInfos.where().findAll();
    if (keywords != null) {}
    return list;
  }

  // 新增
  static Future<void> add(Isar isar, UserInfo userInfo) async {
    await isar.userInfos.put(userInfo);
  }

  // 删除
  static Future<void> delete(Isar isar, int id) async {
    await isar.userInfos.delete(id);
  }
}

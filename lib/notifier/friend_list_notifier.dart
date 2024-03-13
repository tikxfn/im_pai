import 'package:flutter/material.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/db/message_utils.dart';
import 'package:unionchat/db/model/user_info.dart';
import 'package:unionchat/db/user_info_utils.dart';
import 'package:unionchat/global.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:openapi/api.dart';

class FriendListNotifier with ChangeNotifier {
  static FriendListNotifier? _instance;

  factory FriendListNotifier() {
    return _instance ??= FriendListNotifier._internal();
  }

  FriendListNotifier._internal();

  List<UserInfo> _list = [];

  List<UserInfo> get list => _list;

  set list(List<UserInfo> newList) {
    _list = newList;
    notifyListeners();
  }

  // 保存备注
  Future<bool> updateMark(String pairId, int id, String mark) async {
    var api = UserApi(apiClient());
    try {
      await api.userUpdateUserFriendSetting(
        V1UpdateUserFriendSettingArgs(
          id: id.toString(),
          mark: V1UpdateUserFriendSettingArgsValue(value: mark),
        ),
      );
      for (var v in _list) {
        if (v.id == id) {
          v.mark = mark;
          notifyListeners();
          break;
        }
      }
      MessageUtil.updateChannelInfo(pairId, mark: mark);
      return true;
    } on ApiException catch (e) {
      onError(e);
      return false;
    } catch (e) {
      logger.e(e);
      return false;
    }
  }

  // 添加
  int add(UserInfo data) {
    _list.add(data);
    notifyListeners();
    UserInfoUtils.addFriend(data);
    return _list.indexOf(data);
  }

  //通过id获取索引
  int indexById(int id) {
    var i = -1;
    for (var v in _list) {
      if (v.id == id) {
        i = _list.indexOf(v);
      }
    }
    return i;
  }

  //通过id删除
  removeById(int id) {
    var i = -1;
    for (var v in _list) {
      if (v.id == id) {
        i = _list.indexOf(v);
      }
    }
    if (i == -1) return;
    _list.removeAt(i);
    notifyListeners();
    UserInfoUtils.deleteFriend(id);
  }

  //搜索
  List<UserInfo> search(String keywords, {int? need}) {
    keywords = keywords.toLowerCase();
    List<UserInfo> l = [];
    for (var v in _list) {
      var name = (v.nickname ?? '').toLowerCase();
      var mark = (v.mark ?? '').toLowerCase();
      if (name.contains(keywords) ||
          mark.contains(keywords) ||
          PinyinHelper.getShortPinyin(name).contains(keywords) ||
          PinyinHelper.getShortPinyin(mark).contains(keywords) ||
          (v.phone ?? '').contains(keywords) ||
          v.account.contains(keywords) ||
          (v.userExtend?.userNumber ?? '').contains(keywords)) {
        l.add(v);
        if (need != null && l.length >= need) return l;
      }
    }
    return l;
  }
}

library box;

import 'dart:convert';

import 'package:unionchat/common/func.dart';
import 'package:openapi/api.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'account_list.dart';
part 'user.dart';
part 'setting_info.dart';

// k-v设置
late Box<String> _settingsBox;
// 登录过的用户
late Box<AccountListItem> _accountBox;
// 当前登录用户
late Box<GUserModel> _userBox;
// 服务器配置信息
late Box<V1SettingInfoResp> _settingInfo;

initBox() async {
  Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(AccountListItemAdapter());
  Hive.registerAdapter(SettingInfoAdapter());
  _settingsBox = await Hive.openBox<String>('settings');
  _accountBox = await Hive.openBox<AccountListItem>('account_list');
  _userBox = await Hive.openBox<GUserModel>('user');
  _settingInfo = await Hive.openBox<V1SettingInfoResp>('setting_info');
}

Box<String> get settingsBox => _settingsBox;

Box<AccountListItem> get accountBox => _accountBox;

Box<GUserModel> get userBox => _userBox;

Box<V1SettingInfoResp> get settingInfo => _settingInfo;

// a() {
//   // settingInfo.put(SettingInfoAdapter.activeKey, value)
// }

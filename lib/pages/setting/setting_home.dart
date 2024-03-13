import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:openapi/api.dart';
import 'package:unionchat/box/box.dart';
import 'package:unionchat/common/api_request.dart';
import 'package:unionchat/common/cache_file.dart';
import 'package:unionchat/common/enum.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/db/message_utils.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/pages/friend/friend_black.dart';
import 'package:unionchat/pages/setting/about_app.dart';
import 'package:unionchat/pages/setting/allow_add_method.dart';
import 'package:unionchat/pages/setting/login_device.dart';
import 'package:unionchat/pages/setting/online_state.dart';
import 'package:unionchat/pages/setting/setting_language.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/menu_ul.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../common/func.dart';
import '../../function_config.dart';
import 'lock/lock_update.dart';

class SettingHome extends StatefulWidget {
  const SettingHome({super.key});

  static const path = 'setting/home';

  @override
  State<StatefulWidget> createState() {
    return _SettingHomeState();
  }
}

class _SettingHomeState extends State<SettingHome> {
  bool openPin = false; //是否开启锁定码
  Bitmask privacy = const UserPrivacy(0);
  int destroyTime = 0;
  bool undoPower = UserPowerType.undo.hasPower;

  // 清空聊天记录
  _cleanTopic() async {
    var cfm = await confirm(
      context,
      content: '确定要清除所有聊天记录？'.tr(),
    );
    if (cfm != true) return;
    loading();
    try {
      await MessageUtil.deleteChannel([]);
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {
      loadClose();
    }
  }

  //开启、关闭锁定码
  _openClosePin() async {
    var api = UserApi(apiClient());
    try {
      await api.userSetPin(V1SetPinArgs(
        enablePin: SetPinArgsEnablePin(
          enablePin: openPin ? GSure.YES : GSure.NO,
        ),
      ));
      await Global.syncLoginUser();
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    }
  }

  //开启、关闭陌生人发消息
  _openStrangerMessage() async {
    var api = UserApi(apiClient());
    try {
      await api.userSetBasicInfo(V1SetBasicInfoArgs(
        privacy: SetBasicInfoArgsPrivacy(privacy: privacy.toString()),
      ));
      Global.syncLoginUser();
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    }
  }

  //设置自毁时间
  setDestroyTime(int second) async {
    setState(() {
      destroyTime = second;
    });
    await ApiRequest.setTopicDestroyDuration('', destroyTime);
    Global.syncLoginUser();
  }

  //选择自毁时间
  _chooseDestroyTime() {
    var index = 0;
    for (var v in DestroyTime.values) {
      if (v.toSecond == destroyTime) {
        index = DestroyTime.values.indexOf(v);
      }
    }
    openSelect(
      context,
      index: index,
      list: DestroyTime.values.map((e) {
        return e.toChar;
      }).toList(),
      onEnter: (i) {
        setDestroyTime(DestroyTime.values[i].toSecond);
      },
    );
  }

  //注销账号
  _logoff() async {
    var api = UserApi(apiClient());
    try {
      await api.userCancel({});
      if (mounted) Global.loginOut();
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    }
  }

  _init() async {
    await Global.syncLoginUser();
    if (mounted) {
      setState(() {
        openPin = toBool(Global.user!.enablePin);
        privacy = UserPrivacy(toInt(Global.user?.privacy));
        var dsd = toInt(Global.user?.chatDestroyDuration);
        destroyTime = dsd;
      });
    }
  }

  bool _firstIn = false;

  _dataInit() {
    if (_firstIn) return;
    _firstIn = true;
    openPin = toBool(Global.user!.enablePin);
    privacy = UserPrivacy(toInt(Global.user?.privacy));
    destroyTime = toInt(Global.user?.chatDestroyDuration);
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color textColor = myColors.iconThemeColor;
    _dataInit();
    // logger.d(Global.user);
    return Scaffold(
      appBar: AppBar(
        title: Text('隐私安全'.tr()),
      ),
      body: ThemeBody(
        topPadding: 5,
        child: ListView(
          children: [
            shadowBox(
              child: MenuUl(
                bottomBoder: true,
                marginTop: 0,
                children: [
                  // MenuItemData(
                  //   title: '深色主题'.tr(),
                  //   arrow: false,
                  //   content: AppSwitch(
                  //     value: myColors.isDark,
                  //     onChanged: (val) {
                  //       myColors.setTheme(val ? ThemeType.dark : ThemeType.light);
                  //       // setState(() {});
                  //     },
                  //   ),
                  // ),
                  MenuItemData(
                    title: '黑名单管理'.tr(),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        FriendBlack.path,
                      );
                    },
                  ),
                  MenuItemData(
                    title: '登录设备管理'.tr(),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        LoginDevicePage.path,
                      );
                    },
                  ),
                  if (undoPower && FunctionConfig.messageDestroy)
                    MenuItemData(
                      title: '消息自毁'.tr(),
                      content: Text(
                        DestroyTimeExt.fromSecond(destroyTime)?.toChar ?? '',
                        style: TextStyle(color: textColor),
                      ),
                      onTap: _chooseDestroyTime,
                    ),
                  MenuItemData(
                    title: '锁定码'.tr(),
                    content: Text(
                      toBool(Global.user?.isPin) ? '修改'.tr() : '未设置'.tr(),
                      style: TextStyle(color: textColor),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, LockUpdate.path)
                          .then((value) {
                        setState(() {});
                      });
                    },
                  ),
                  MenuItemData(
                    title: '开启锁定码'.tr(),
                    arrow: false,
                    content: AppSwitch(
                      value: openPin,
                      onChanged: (val) {
                        setState(() {
                          openPin = val;
                        });
                        _openClosePin();
                      },
                    ),
                  ),
                ],
              ),
            ),
            shadowBox(
              child: MenuUl(
                marginTop: 0,
                bottomBoder: true,
                children: [
                  MenuItemData(
                    title: '消息提醒',
                    arrow: false,
                    content: AppSwitch(
                      value: noticeOpen,
                      onChanged: (val) async {
                        if (val) {
                          await settingsBox.delete('noticeClose');
                        } else {
                          await settingsBox.put('noticeClose', '1');
                        }
                        setState(() {});
                      },
                    ),
                  ),
                  if (noticeOpen && platformPhone)
                    MenuItemData(
                      title: '震动',
                      arrow: false,
                      content: AppSwitch(
                        value: noticeVibration,
                        onChanged: (val) async {
                          if (val) {
                            await settingsBox.delete('noticeVibrationClose');
                          } else {
                            await settingsBox.put(
                              'noticeVibrationClose',
                              '1',
                            );
                          }
                          setState(() {});
                        },
                      ),
                    ),
                  if (noticeOpen && platformPhone)
                    MenuItemData(
                      title: '消息提示音',
                      arrow: false,
                      content: AppSwitch(
                        value: noticeSound,
                        onChanged: (val) async {
                          if (val) {
                            await settingsBox.delete('noticeSoundClose');
                          } else {
                            await settingsBox.put(
                              'noticeSoundClose',
                              '1',
                            );
                          }
                          setState(() {});
                        },
                      ),
                    ),
                ],
              ),
            ),
            shadowBox(
              child: MenuUl(
                bottomBoder: true,
                marginTop: 0,
                children: [
                  // MenuItemData(
                  //   title: '在线状态',
                  //   onTap: () {
                  //     Navigator.pushNamed(
                  //       context,
                  //       OnlineStatePage.path,
                  //       arguments: {
                  //         'id': '1',
                  //         'title': '在线状态',
                  //       },
                  //     );
                  //   },
                  // ),
                  MenuItemData(
                    title: '允许陌生人发消息'.tr(),
                    arrow: false,
                    content: AppSwitch(
                      value: privacy.contains(UserPrivacy.strangerMessage),
                      onChanged: (val) {
                        if (val) {
                          privacy |= UserPrivacy.strangerMessage;
                        } else {
                          privacy = privacy.remove(UserPrivacy.strangerMessage);
                        }
                        setState(() {});
                        _openStrangerMessage();
                      },
                    ),
                  ),
                  MenuItemData(
                    title: '加我为好友的方式'.tr(),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AllowAddMethod.path,
                      );
                    },
                  ),
                  MenuItemData(
                    title: '语音通话'.tr(),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        OnlineStatePage.path,
                        arguments: {
                          'id': '2',
                          'title': '语音通话'.tr(),
                        },
                      );
                    },
                  ),
                  MenuItemData(
                    title: '群组和频道'.tr(),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        OnlineStatePage.path,
                        arguments: {
                          'id': '3',
                          'title': '群组和频道'.tr(),
                        },
                      );
                    },
                  ),
                  MenuItemData(
                    title: '语言切换'.tr(),
                    content: Text(
                      '语言'.tr(),
                      style: TextStyle(color: textColor),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, SettingLanguage.path);
                    },
                  ),
                  MenuItemData(
                    title: '清空所有聊天记录'.tr(),
                    onTap: _cleanTopic,
                  ),
                  MenuItemData(
                    title: '清除缓存'.tr(),
                    onTap: () async {
                      confirm(
                        context,
                        content: '确定要清除缓存？'.tr(),
                        onEnter: () async {
                          final directory =
                              await getApplicationSupportDirectory();
                          if (directory.existsSync()) {
                            for (var entity in directory.listSync()) {
                              entity.deleteSync(recursive: true);
                            }
                          }
                          await Global.cleanCache();
                          await CacheFile.clearTempDir();
                        },
                      );
                    },
                  ),
                  MenuItemData(
                    title: '注销账号'.tr(),
                    onTap: () {
                      confirm(
                        context,
                        content: '确定注销当前帐号？注销后将删除此帐号所有信息'.tr(),
                        onEnter: () async {
                          _logoff();
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            shadowBox(
              child: MenuUl(
                marginTop: 0,
                children: [
                  MenuItemData(
                    title: '关于我们'.tr(),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AboutAppPage.path,
                      );
                    },
                  ),
                ],
              ),
            ),

            // Container(
            //   padding: const EdgeInsets.only(left: 15, right: 15),
            //   color: const Color(0xF4F4F4FF),
            //   height: 72,
            //   child: const Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //     children: [
            //       Text(
            //         '控制谁能邀请您进入群组或频道。',
            //         style: TextStyle(color: myColors.textGrey, fontSize: 12),
            //       ),
            //       Text(
            //         '删除我的账号',
            //         style: TextStyle(color: myColors.textGrey, fontSize: 12),
            //       ),
            //     ],
            //   ),
            // ), //群组和频道

            // MenuUl(marginTop: 0, children: [
            //   MenuItemData(
            //     title: '如果离开',
            //     content: const Text(
            //       '6个月',
            //       style: TextStyle(color: myColors.textGrey),
            //     ),
            //   ),
            // ]),
            // Container(
            //   padding: const EdgeInsets.only(left: 15, right: 15),
            //   color: const Color(0xF4F4F4FF),
            //   height: 72,
            //   child: const Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //     children: [
            //       Text(
            //         '此时间后，您的账号如未上线，您的所有资料——包括消息记录，',
            //         style: TextStyle(
            //             color: myColors.textGrey, fontSize: 12, wordSpacing: 20),
            //       ),
            //       Text(
            //         '联系人都会被删除',
            //         style: TextStyle(color: myColors.textGrey, fontSize: 12),
            //       ),
            //     ],
            //   ),
            // ), //群组和频道
          ],
        ),
      ),
    );
  }

  //阴影盒子
  Widget shadowBox({required Widget child}) {
    var myColors = ThemeNotifier();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: myColors.isDark
            ? null
            : [
                BoxShadow(
                  color: myColors.bottomShadow,
                  blurRadius: 10,
                  offset: const Offset(0, 0),
                ),
              ],
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: myColors.themeBackgroundColor,
        ),
        child: child,
      ),
    );
  }
}

import 'dart:io';

import 'package:animations/animations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/db/notifier/channel_list_notifier.dart';
import 'package:unionchat/db/user_info_utils.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/notifier/app_state_notifier.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/notifier/unread_value.dart';
import 'package:unionchat/pages/chat/chat_home.dart';
import 'package:unionchat/pages/community/community_home.dart';
import 'package:unionchat/pages/friend/friend_home.dart';
import 'package:unionchat/pages/help/help_home.dart';
import 'package:unionchat/pages/mine/mine_home.dart';
import 'package:unionchat/pages/setting/lock/lock_enter.dart';
import 'package:provider/provider.dart';
import 'package:tray_manager/tray_manager.dart' as tray;
import 'package:window_manager/window_manager.dart';

class Tabs extends StatefulWidget {
  const Tabs({super.key});

  static const String path = 'tabs';

  @override
  State<StatefulWidget> createState() {
    return _TabsState();
  }
}

class _TabsState extends State<Tabs>
    with WidgetsBindingObserver, WindowListener, tray.TrayListener {
  static final List<AppTabData> _list = [
    AppTabData(
      page: ChangeNotifierProvider(
        create: (context) => ChannelListNotifier(),
        child: const ChatHome(),
      ),
      name: '消息',
      icon: 'xx',
      index: 0,
    ),
    AppTabData(
      page: const FriendHome(),
      name: '联系人',
      icon: 'txl',
      index: 1,
    ),
    AppTabData(
      page: const CommunityHome(),
      name: '发现',
      icon: 'fx',
      index: 2,
    ),
    AppTabData(
      page: const MineHome(),
      name: '我的',
      icon: 'wd',
      index: 3,
    ),
  ];
  int _currentIndex = 0;
  DateTime? _lastPressedAt;
  int appHideTime = 0; //应用进入后台的时间戳
  int lockSeconds = 10; //进入后台多久需要输入密码
  // Timer? _timer;

  //列表组件
  Widget appTabItem(AppTabData v,
      {int notRead = 0, double imageWidth = 25, double imageHeight = 25}) {
    var myColors = ThemeNotifier();
    bool active = v.index == _currentIndex;
    var child = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Badge(
          isLabelVisible: notRead > 0,
          backgroundColor: myColors.redTitle,
          label: Text(v.index == 3 ? ' ' : notRead.toString()),
          largeSize: v.index == 3 ? 12 : 14,
          child: Image.asset(
            assetPath('images/tabs/${v.icon}${active ? '_a' : ''}.png'),
            height: imageWidth,
            width: imageHeight,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          v.name.tr(),
          style: TextStyle(
            fontSize: 11,
            color: active ? myColors.bootmTextSelect : myColors.bootmText,
          ),
        ),
        const SizedBox(height: 7),
      ],
    );
    if (_currentIndex == 0 && _currentIndex == v.index) {
      return Expanded(
        flex: 1,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          // todo:切换未读、所有消息
          // onDoubleTap: () {
          //   if (v.index != 0) return;
          //   // var notifier = TopicListNotifier();
          //   // notifier.allMessage = !notifier.allMessage;
          // },
          onTap: () {
            setState(() {
              _currentIndex = v.index;
            });
          },
          child: child,
        ),
      );
    }
    return Expanded(
      flex: 1,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _currentIndex = v.index;
          });
        },
        child: child,
      ),
    );
  }

  //圈子列表Item
  Widget circleTabItem(
    AppTabData v, {
    int notRead = 0,
  }) {
    var myColors = ThemeNotifier();
    var child = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Badge(
          isLabelVisible: notRead > 0,
          backgroundColor: myColors.redTitle,
          label: Text(notRead.toString()),
          largeSize: 14,
          child: Image.asset(
            assetPath('images/tabs/${v.icon}.png'),
            height: 47,
            width: 47,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
    if (_currentIndex == 0 && _currentIndex == v.index) {
      return Expanded(
        flex: 1,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          // todo:切换未读、所有消息
          // onDoubleTap: () {
          //   if (v.index != 0) return;
          //   // var notifier = TopicListNotifier();
          //   // notifier.allMessage = !notifier.allMessage;
          // },
          onTap: () {
            setState(() {
              _currentIndex = v.index;
            });
          },
          child: child,
        ),
      );
    }
    return Expanded(
      flex: 1,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // Adapter.navigatorTo(HelpHome.path);
          Navigator.push(
            context,
            CupertinoModalPopupRoute(
              builder: (context) {
                return const HelpHome();
              },
            ),
          ).then((value) {
            if (mounted) setState(() {});
          });
        },
        child: child,
      ),
    );
  }

  @override
  void initState() {
    Global.tpns?.setBadge(0);
    Global.tpns?.cleanToolNotice();
    windowManager.addListener(this);
    tray.trayManager.addListener(this);
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pcInit();
    UnreadValue.takeNewNotice();
    UserInfoUtils.syncFriends();
  }

  @override
  void dispose() {
    super.dispose();
    // _timer?.cancel();
    windowManager.removeListener(this);
    tray.trayManager.removeListener(this);
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    var notifier = AppStateNotifier();
    notifier.state = state;
    switch (state) {
      //进入前台
      case AppLifecycleState.resumed:
        AppStateNotifier().appHide = false;
        //清空app角标
        // Global.jgPush?.setBadge(0);
        // Global.jgPush?.clearAllNotifications();
        Global.tpns?.setBadge(0);
        Global.tpns?.cleanToolNotice();
        if (appHideTime <= 0) return;
        var cTime =
            (DateTime.now().microsecondsSinceEpoch - appHideTime) ~/ 1000000;
        appHideTime = 0;
        if (cTime > lockSeconds) {
          Navigator.pushAndRemoveUntil(
            context,
            CupertinoModalPopupRoute(
              builder: (context) => const LockEnter(),
            ),
            (route) => false,
          );
        }
        break;
      //切换到后台
      case AppLifecycleState.inactive:
        break;
      //进入后台
      case AppLifecycleState.paused:
        AppStateNotifier().appHide = true;
        if (!toBool(Global.user!.enablePin) ||
            !toBool(Global.user!.isPin) ||
            !notifier.enablePinDialog) {
          return;
        }
        appHideTime = DateTime.now().microsecondsSinceEpoch;
        break;
      //即将退出
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        logger.d('app_hidden');
        break;
    }
  }

  //pc端窗口初始化
  void _pcInit() async {
    if (platformPhone) return;
    await tray.trayManager.setIcon(
      Platform.isWindows
          ? assetPath('images/logo.ico')
          : assetPath('images/logo.png'),
    );
    tray.Menu menu = tray.Menu(
      items: [
        // tray.MenuItem.separator(),
        tray.MenuItem(
          key: 'exit',
          label: '退出'.tr(),
        ),
      ],
    );
    await tray.trayManager.setContextMenu(menu);
    // 添加此行以覆盖默认关闭处理程序
    await windowManager.setPreventClose(true);
    if (mounted) setState(() {});
  }

  @override
  void onWindowClose() {
    // do something
    windowManager.hide();
  }

  @override
  void onWindowRestore() {
    // do something
    logger.d(123);
  }

  @override
  void onTrayIconMouseDown() {
    windowManager.show();
    // tray.trayManager.popUpContextMenu();
    // do something, for example pop up the menu
    // trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconRightMouseDown() {
    tray.trayManager.popUpContextMenu();
    logger.d(2);
    // do something
  }

  @override
  void onTrayIconRightMouseUp() {
    logger.d(3);
    // do something
  }

  @override
  void onTrayMenuItemClick(tray.MenuItem menuItem) {
    if (menuItem.key == 'exit') {
      windowManager.destroy();
    }
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: WillPopScope(
        // child: Center(
        //   child: Text(_currentIndex.toString()),
        // ),
        child: PageTransitionSwitcher(
          // duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation, secondaryAnimation) {
            return FadeThroughTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
          child: _list[_currentIndex].page,
        ),

        onWillPop: () async {
          if (_lastPressedAt == null ||
              DateTime.now().difference(_lastPressedAt!) >
                  const Duration(seconds: 1)) {
            _lastPressedAt = DateTime.now();
            return false;
          }
          return true;
        },
      ),
      bottomNavigationBar: Container(
        color: myColors.themeBackgroundColor,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            color: myColors.bottom,
            boxShadow: [
              BoxShadow(
                color: myColors.bottomShadow,
                blurRadius: 5,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _list.map((e) {
                if (e.index == 0) {
                  // 消息
                  return ValueListenableBuilder(
                    valueListenable: ChannelListNotifier().unreadCount,
                    builder: (context, value, _) {
                      return appTabItem(
                        e,
                        notRead: value,
                        imageWidth: 25,
                        imageHeight: 21,
                      );
                    },
                  );
                } else if (e.index == 1) {
                  //联系人
                  return ValueListenableBuilder(
                    valueListenable: UnreadValue.friendNotRead,
                    builder: (context, apply, _) {
                      return ValueListenableBuilder(
                          valueListenable: UnreadValue.groupMyApplyNotRead,
                          builder: (context, groupMyApply, _) {
                            return ValueListenableBuilder(
                              valueListenable: UnreadValue.groupApplyNotRead,
                              builder: (context, groupApply, _) {
                                final int friendNotRead = apply +
                                    groupApply.groupApplyNotRead +
                                    groupMyApply;
                                return appTabItem(e,
                                    notRead: friendNotRead,
                                    imageWidth: 21,
                                    imageHeight: 22);
                              },
                            );
                          });
                    },
                  );
                } else if (e.index == 2) {
                  //发现
                  return ValueListenableBuilder(
                    valueListenable: UnreadValue.newTrendsNotRead,
                    builder: (context, apply, _) {
                      return ValueListenableBuilder(
                        valueListenable: UnreadValue.communityNotRead,
                        builder: (context, myApply, _) {
                          final int friendNotRead = apply + myApply;
                          return appTabItem(e,
                              notRead: friendNotRead,
                              imageWidth: 24,
                              imageHeight: 24);
                        },
                      );
                    },
                  );
                }
                return appTabItem(e, imageWidth: 22, imageHeight: 23);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

//tab列表数据
class AppTabData {
  //名称
  final String name;

  //未选中icon
  final String icon;

  //页面
  final Widget page;

  //索引
  final int index;

  AppTabData({
    required this.name,
    required this.icon,
    required this.index,
    required this.page,
  });
}
